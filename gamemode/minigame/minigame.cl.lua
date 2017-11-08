MinigameService = MinigameService or {}


-- # Lobbies

MinigameLobby = MinigameLobby or {}

function MinigameService.CreateLobby(lobby)
	MinigameService.lobbies[lobby.id] = setmetatable(table.Merge({
		players = {}
	}, lobby or {}), MinigameLobby)
end

function MinigameLobby:AddPlayer(ply)
	ply.minigame_lobby = self
	table.insert(self.players, ply)
end

function MinigameLobby:RemovePlayer(ply)
	ply.minigame_lobby = nil
	table.RemoveByValue(self.players, ply)
end


-- # Networking

function MinigameService.ReceiveCreateLobby()
	local lobby_id = net.ReadUInt(8)
	local proto_id = net.ReadUInt(8)
	local host = net.ReadEntity()
	MinigameService.CreateLobby {
		id = lobby_id,
		prototype = MinigameService.Prototype(proto_id),
		host = host
	}
end
net.Receive("CreateLobby", MinigameService.ReceiveCreateLobby)

-- function MinigameService.ReceiveRemoveLobby()
-- 	local lobby_id = net.ReadUInt(8)
-- 	MinigameService.RemoveLobby(MinigameService.lobbies(lobby_id))
-- end
-- net.Receive("RemoveLobby", MinigameService.ReceiveRemoveLobby)

function MinigameService.LobbyAddPlayer()
	local lobby_id = net.ReadUInt(8)
	local ply = net.ReadEntity()
	MinigameService.lobbies[lobby_id]:AddPlayer(ply)
end
net.Receive("LobbyAddPlayer", MinigameService.LobbyAddPlayer)

function MinigameService.LobbyRemovePlayer()
	local lobby_id = net.ReadUInt(8)
	local ply = net.ReadEntity()
	MinigameService.lobbies[lobby_id]:RemovePlayer(ply)
end
net.Receive("LobbyRemovePlayer", MinigameService.LobbyRemovePlayer)
