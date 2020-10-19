function MinigameService.CreateLobby(props, notify)
	notify = Default(notify, true)

	local lobby = MinigameLobby.New(props, notify)
	MinigameService.lobbies[lobby.id] = lobby

	return lobby
end

function MinigameService.FinishLobby(lobby)
	MinigameService.lobbies[lobby.id] = nil
	lobby:Finish()
end

function MinigameService.LobbyText(lobby)
	local host = lobby.host

	return (IsLocalPlayer(host) and "your" or host:GetName().."'s").." "..lobby.prototype.name.." lobby"
end

function MinigameService.PushLobbyMetaText(lobby)
	NotificationService.PushMetaText(MinigameService.LobbyText(lobby), "Lobby", 1)
end

function MinigameService.InitHUDElements()
	local lobby = LocalPlayer().lobby

	if lobby then
		MinigameService.PushLobbyMetaText(lobby)
	end
end
hook.Add("InitHUDElements", "MinigameService.InitHUDElements", MinigameService.InitHUDElements)

function MinigameLobby:Init(props, notify)
	self.id = props.id
	self.prototype = props.prototype
	self.state = props.state
	self.last_state_start = props.last_state_start
	self.host = props.host
	self.players = props.players or {}
	self.entities = props.entities or {}
	self.state_objects = {}

	for _, ply in pairs(self.players) do
		ply.lobby = self
	end

	for _, ent in pairs(self.entities) do
		ent.lobby = self
		hook.Run("LobbyEntityProperties", ent)
	end

	for k, _ in pairs(self.prototype.player_classes) do
		self[k] = self[k] or {}
	end

	self:InitSettings()

	hook.Run("LobbyCreate", self, notify)

	if self:IsLocal() then
		hook.Run("LocalLobbyCreate", self)

		if IsLocalPlayer(self.host) then
			MinigameService.PushLobbyMetaText(self)
		end
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

	for _, ent in pairs(self.entities) do
		self:RemoveEntity(ent, false)
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
		MinigameService.PushLobbyMetaText(self)
	end
end

function MinigameLobby:AddPlayer(ply)
	ply.lobby = self
	table.insert(self.players, ply)

	hook.Run("LobbyPlayerJoin", self, ply)

	if self:IsLocal() then
		hook.Run("LocalLobbyPlayerJoin", self, ply)

		if IsLocalPlayer(ply) then
			MinigameService.PushLobbyMetaText(self)
		end
	end

	MinigameService.CallHook(self, "PlayerJoin", ply)
end

function MinigameLobby:RemovePlayer(ply)
	if IsValid(ply) then
		hook.Run("LobbyPlayerLeave", self, ply)

		if self:IsLocal() then
			hook.Run("LocalLobbyPlayerLeave", self, ply)

			if IsLocalPlayer(ply) then
				NotificationService.FinishSticky "Lobby"
			end
		end

		MinigameService.CallHook(self, "PlayerLeave", ply)

		ply.lobby = nil
		table.RemoveByValue(self.players, ply)
	end
end

hook.Add("PlayerDisconnected", "MinigameService.RemoveDisconnectedPlayer", function (ply)
	if IsValid(ply) and ply.lobby then
		ply.lobby:RemovePlayer(ply)
	else
		for _, lobby in pairs(MinigameService.lobbies) do
			local invalid_plys = {}

			for _, ply in pairs(lobby.players) do
				if not IsValid(ply) then
					table.insert(invalid_plys, ply)
				end
			end

			for _, ply in pairs(invalid_plys) do
				table.RemoveByValue(lobby.players, ply)
			end
		end
	end
end)

function MinigameLobby:AddEntity(ent)
	ent.lobby = self
	table.insert(self.entities, ent)

	ent:CallOnRemove("LobbyFinish", function ()
		self:RemoveEntity(ent)
	end)

	hook.Run("LobbyEntityAdd", self, ent)

	if self:IsLocal() then
		hook.Run("LocalLobbyEntityAdd", self, ent)
	end

	MinigameService.CallHook(self, "EntityAdd", ent)
	hook.Run("LobbyEntityProperties", ent)
end

function MinigameLobby:RemoveEntity(ent)
	if IsValid(ent) and not ent.removed_from_lobby then
		hook.Run("LobbyEntityRemove", self, ent)

		if self:IsLocal() then
			hook.Run("LocalLobbyEntityRemove", self, ent)
		end

		MinigameService.CallHook(self, "EntityRemove", ent)

		ent.lobby = nil
		ent.removed_from_lobby = true
		table.RemoveByValue(self.entities, ent)
	end
end