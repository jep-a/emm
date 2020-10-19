function MinigameService.CreateLobby(props)
	props = props or {}

	local id = #MinigameService.lobbies + 1
	props.id = id

	local lobby = MinigameLobby.New(props)
	MinigameService.lobbies[id] = lobby

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
	self.entities = props.entities or {}
	self.state_objects = {}

	for _, ply in pairs(self.players) do
		ply.lobby = self
	end

	for k, _ in pairs(self.prototype.player_classes) do
		self[k] = {}
	end

	self:InitSettings()

	NetService.Broadcast("Lobby", self.id, self.prototype, self.host)
	hook.Run("LobbyCreate", self)

	self:SetState(self.states[self.default_state])
end

function MinigameLobby:Finish()
	hook.Run("LobbyFinish", self)

	for _, ply in pairs(self.players) do
		self:RemovePlayer(ply, false, true)
	end

	for _, ent in pairs(self.entities) do
		ent:Remove()
	end

	NetService.Broadcast("LobbyFinish", self)
	table.Empty(self)
end

function MinigameLobby:SetHost(ply)
	self.host = ply
	NetService.Broadcast("LobbyHost", self, ply)
	hook.Run("LobbyHostChange", lobby, ply)
end

function MinigameLobby:AddPlayer(ply)
	ply.lobby = self
	table.insert(self.players, ply)

	NetService.Broadcast("LobbyPlayer", self, ply)
	hook.Run("LobbyPlayerJoin", self, ply)
	MinigameService.CallHook(self, "PlayerJoin", ply)
end

function MinigameLobby:RemovePlayer(ply, net, force)
	net = Default(net, true)

	local has_plys = #self.players > 1

	if force or has_plys then
		MinigameService.CallHook(self, "PlayerLeave", ply)
		hook.Run("LobbyPlayerLeave", self, ply)

		ply.lobby = nil
		table.RemoveByValue(self.players, ply)

		if net then
			NetService.Broadcast("LobbyPlayerLeave", self, ply)
		end

		if has_plys and self.host == ply then
			self:SetHost(self.players[1])
		end
	else
		MinigameService.FinishLobby(self)
	end
end
hook.Add("PlayerDisconnected", "MinigameService.RemoveDisconnectedPlayer", function (ply)
	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end
end)

function MinigameLobby:AddEntity(ent)
	ent.lobby = self
	table.insert(self.entities, ent)

	ent:CallOnRemove("LobbyFinish", function ()
		self:RemoveEntity(ent, false)
	end)

	NetService.Broadcast("LobbyEntity", self, ent:EntIndex())
	hook.Run("LobbyEntityAdd", self, ent)
	MinigameService.CallHook(self, "EntityAdd", ent)
end

function MinigameLobby:RemoveEntity(ent, net)
	net = Default(net, true)

	if not ent.removed_from_lobby then
		MinigameService.CallHook(self, "EntityRemove", ent)
		hook.Run("LobbyEntityRemove", self, ent)

		ent.lobby = nil
		ent.removed_from_lobby = true
		table.RemoveByValue(self.entities, ent)

		if net then
			NetService.Broadcast("LobbyEntityRemove", self, ent)
		end
	end
end