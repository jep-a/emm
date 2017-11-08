MinigameService = MinigameService or {}


-- # Lobbies

MinigameLobby = MinigameLobby or {}

function MinigameService.CreateLobby(lobby)
	lobby = setmetatable(table.Merge({
		players = {}
	}, lobby or {}), MinigameLobby)
	lobby.id = table.insert(MinigameService.lobbies, lobby)
	MinigameService.NetworkLobbyCreate(lobby)
	return lobby
end

function MinigameLobby:AddPlayer(ply)
	ply.minigame_lobby = self
	table.insert(self.players, ply)
	MinigameService.NetworkLobbyJoin(self, ply)
end

function MinigameLobby:RemovePlayer(ply)
	ply.minigame_lobby = nil
	table.RemoveByValue(self.players, ply)
	MinigameService.NetworkLobbyLeave(self, ply)
end


-- # Networking

util.AddNetworkString "CreateLobby"
function MinigameService.NetworkCreateLobby(lobby)
	net.Start("CreateLobby")
	net.WriteUInt(lobby.id, 8)
	net.WriteUInt(lobby.prototype.id, 8)
	net.WriteEntity(lobby.host)
	net.Broadcast()
end

util.AddNetworkString "RemoveLobby"
function MinigameService.NetworkRemoveLobby(lobby)
	net.Start("RemoveLobby")
	net.WriteUInt(lobby.id, 8)
	net.Broadcast()
end

util.AddNetworkString "LobbyAddPlayer"
function MinigameService.NetworkLobbyAddPlayer(lobby, ply)
	net.Start("LobbyAddPlayer")
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end

util.AddNetworkString "LobbyRemovePlayer"
function MinigameService.NetworkLobbyRemovePlayer(lobby, ply)
	net.Start("LobbyRemovePlayer")
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end