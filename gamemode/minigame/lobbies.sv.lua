MinigameLobby = MinigameLobby or {}

function MinigameService.CreateLobby(lobby)
	lobby = setmetatable(lobby or {}, MinigameLobby)
	lobby.id = #MinigameService.lobbies + 1

	for _, ply in pairs(lobby.players) do
		ply.lobby = lobby
	end

	for k, _ in pairs(lobby.prototype.player_classes) do
		lobby[k] = {}
	end

	MinigameService.lobbies[lobby.id] = lobby
	MinigameService.NetworkCreateLobby(lobby)
	MinigameService.CallHook(lobby, "Init")
	hook.Run("CreateLobby", lobby)
	lobby:SetState(lobby.states[lobby.default_state])

	return lobby
end

function MinigameService.RemoveLobby(lobby)
	MinigameService.CallHook(lobby, "Remove")
	hook.Run("RemoveLobby", lobby)
	MinigameService.lobbies[lobby.id] = nil

	for _, ply in pairs(lobby.players) do
		lobby:RemovePlayer(ply, false, true)
	end

	MinigameService.NetworkRemoveLobby(lobby)
	table.Empty(lobby)
end

function MinigameLobby:SetHost(ply)
	self.host = ply
	MinigameService.NetworkLobbySetHost(self, ply)
	hook.Run("LobbySetHost", lobby, ply)
end

function MinigameLobby:AddPlayer(ply, net)
	net = net == nil and true or net
	ply.lobby = self
	table.insert(self.players, ply)

	if net then
		MinigameService.NetworkLobbyAddPlayer(self, ply)
	end

	MinigameService.CallHook(self, "PlayerJoin", ply)
	hook.Run("LobbyAddPlayer", self, ply)
end

function MinigameLobby:RemovePlayer(ply, net, force)
	net = net == nil and true or net

	local suff_plys = #self.players > 1
	if force or suff_plys then
		MinigameService.CallHook(self, "PlayerLeave", ply)
		hook.Run("LobbyRemovePlayer", self, ply)
		ply.lobby = nil
		table.RemoveByValue(self.players, ply)

		if net then
			MinigameService.NetworkLobbyRemovePlayer(self, ply)
		end

		if suff_plys and self.host == ply then
			self:SetHost(self.players[#self.players])
		end
	else
		MinigameService.RemoveLobby(self)
	end
end
hook.Add("PlayerDisconnected", "MinigameService.RemoveDisconnectedPlayer", function (ply)
	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end
end)