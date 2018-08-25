function MinigameService.CreateLobby(props)
	local lobby = MinigameLobby.New(props)
	MinigameService.lobbies[lobby.id] = lobby

	return lobby
end

function MinigameService.FinishLobby(lobby)
	MinigameService.lobbies[lobby.id] = nil
	lobby:Finish()
end

function MinigameLobby:Init(props)
	self.id = props.id
	self.prototype = props.prototype
	self.host = props.host
	self.players = props.players or {}

	for _, ply in pairs(self.players) do
		ply.lobby = self
	end

	for k, _ in pairs(self.prototype.player_classes) do
		self[k] = self[k] or {}
	end

	hook.Run("LobbyInit", self)

	if self:IsLocal() then
		hook.Run("LocalLobbyInit", self)
	end
end

function MinigameLobby:Finish()
	hook.Run("LobbyFinish", self)

	if self:IsLocal() then
		hook.Run("LocalLobbyFinish", self)
	end

	for _, ply in pairs(self.players) do
		self:RemovePlayer(ply, false)
	end

	table.Empty(self)
end

function MinigameLobby:GetSanitized()
	local sanitized_lobby = {}
	sanitized_lobby.id = self.id
	sanitized_lobby.prototype = self.prototype.id
	sanitized_lobby.host = self.host:EntIndex()
	sanitized_lobby.players = {}

	for k, ply in pairs(self.players) do
		sanitized_lobby.players[k] = ply:EntIndex()
	end

	return sanitized_lobby
end

function MinigameLobby:IsLocal()
	return self == LocalPlayer().lobby
end

function MinigameLobby:SetHost(ply)
	self.host = ply
	hook.Run("LobbyHostChange", self, ply)

	if self:IsLocal() then
		hook.Run("LocalLobbyHostChange", self, ply)
	end
end

function MinigameLobby:AddPlayer(ply)
	ply.lobby = self
	table.insert(self.players, ply)

	hook.Run("LobbyAddPlayer", self, ply)

	if self:IsLocal() then
		hook.Run("LocalLobbyAddPlayer", self, ply)
	end

	MinigameService.CallHook(self, "PlayerJoin", ply)
end

function MinigameLobby:RemovePlayer(ply)
	hook.Run("LobbyRemovePlayer", self, ply)

	if self:IsLocal() then
		hook.Run("LocalLobbyRemovePlayer", self, ply)
	end

	MinigameService.CallHook(self, "PlayerLeave", ply)

	ply.lobby = nil
	table.RemoveByValue(self.players, ply)
end