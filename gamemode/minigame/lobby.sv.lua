MinigameLobby = MinigameLobby or {}

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

	for _, ply in pairs(self.players) do
		ply.lobby = self
	end

	for k, _ in pairs(self.prototype.player_classes) do
		self[k] = {}
	end

	MinigameNetworkService.SendLobby(self)
	hook.Run("LobbyInit", self)

	self:SetState(self.states[self.default_state])
end

function MinigameLobby:Finish()
	hook.Run("LobbyFinish", self)

	for _, ply in pairs(self.players) do
		self:RemovePlayer(ply, false, true)
	end

	MinigameNetworkService.SendLobbyFinish(self)
	table.Empty(self)
end

function MinigameLobby:SetHost(ply)
	self.host = ply
	MinigameNetworkService.SendLobbySetHost(self, ply)
	hook.Run("LobbySetHost", lobby, ply)
end

function MinigameLobby:AddPlayer(ply)
	ply.lobby = self
	table.insert(self.players, ply)

	MinigameNetworkService.SendLobbyPlayer(self, ply)
	hook.Run("LobbyAddPlayer", self, ply)
	MinigameService.CallHook(self, "PlayerJoin", ply)
end

function MinigameLobby:RemovePlayer(ply, net, force)
	net = net == nil and true or net

	local has_plys = #self.players > 1

	if force or has_plys then
		MinigameService.CallHook(self, "PlayerLeave", ply)
		hook.Run("LobbyRemovePlayer", self, ply)

		ply.lobby = nil
		table.RemoveByValue(self.players, ply)

		if net then
			MinigameNetworkService.SendLobbyPlayerLeave(self, ply)
		end

		if has_plys and self.host == ply then
			self:SetHost(self.players[#self.players])
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