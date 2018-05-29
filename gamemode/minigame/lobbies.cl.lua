MinigameLobby = MinigameLobby or {}

function MinigameService.CreateLobby(lobby, notify)
	notify = notify == nil and true or notify
	local lobby = setmetatable(table.Merge({players = {}}, lobby or {}), MinigameLobby)

	for _, ply in pairs(lobby.players) do
		ply.lobby = lobby
	end

	for k, _ in pairs(lobby.prototype.player_classes) do
		lobby[k] = lobby[k] or {}
	end

	MinigameService.lobbies[lobby.id] = lobby
	MinigameService.CallHook(lobby, "Init")
	hook.Run("CreateLobby", lobby)

	if lobby:IsLocal() then
		hook.Run("LocalCreateLobby", self)
	end

	return lobby
end

function MinigameService.RemoveLobby(lobby)
	MinigameService.CallHook(lobby, "Remove")
	hook.Run("RemoveLobby", lobby)
	MinigameService.lobbies[lobby.id] = nil

	for _, ply in pairs(lobby.players) do
		lobby:RemovePlayer(ply, false)
	end

	table.Empty(lobby)
end

function MinigameLobby:GetSanitized()
	local sanitized_lobby = {}
	sanitized_lobby.id = self.id
	sanitized_lobby.minigamePrototype = self.prototype.id
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
	hook.Run("LobbySetHost", self, ply)

	if self:IsLocal() then
		hook.Run("LocalLobbySetHost", self, ply)
	end
end

function MinigameLobby:AddPlayer(ply, notify)
	notify = notify == nil and true or notify
	ply.lobby = self
	table.insert(self.players, ply)
	hook.Run("LobbyAddPlayer", self, ply)

	if self:IsLocal() then
		hook.Run("LocalLobbyAddPlayer", self, ply)
	end
end

function MinigameLobby:RemovePlayer(ply, notify)
	notify = notify == nil and true or notify
	hook.Run("LobbyRemovePlayer", self, ply)

	if self:IsLocal() then
		hook.Run("LocalLobbyRemovePlayer", self, ply)
	end

	ply.lobby = nil
	table.RemoveByValue(self.players, ply)
end