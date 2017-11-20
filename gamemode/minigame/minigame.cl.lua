MinigameService = MinigameService or {}


-- # Lobbies

MinigameLobby = MinigameLobby or {}

function MinigameService.CreateLobby(lobby, notify)
	notify = notify == nil and true or notify
	MinigameService.lobbies[lobby.id] = setmetatable(table.Merge({players = {}}, lobby or {}), MinigameLobby)
end

function MinigameService.RemoveLobby(lobby)
	MinigameService.lobbies[lobby.id] = nil

	for _, ply in pairs(lobby.players) do
		lobby:RemovePlayer(ply, false)
	end

	table.Empty(lobby)
end

function MinigameLobby:AddPlayer(ply, notify)
	notify = notify == nil and true or notify

	ply.minigame_lobby = self
	table.insert(self.players, ply)
end

function MinigameLobby:RemovePlayer(ply, notify)
	notify = notify == nil and true or notify

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

function MinigameService.ReceiveRemoveLobby()
	local lobby_id = net.ReadUInt(8)
	MinigameService.RemoveLobby(MinigameService.lobbies[lobby_id])
end
net.Receive("RemoveLobby", MinigameService.ReceiveRemoveLobby)

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

function MinigameService.RequestLobbies()
	net.Start "RequestLobbies"
	net.SendToServer()
end
hook.Add("InitPostEntity", "MinigameService.RequestLobbies", MinigameService.RequestLobbies)

function MinigameService.ReceiveLobbies()
	local lobby_count = net.ReadUInt(8)
	for i = 1, lobby_count do
		local lobby_id = net.ReadUInt(8)
		local proto_id = net.ReadUInt(8)
		local host = net.ReadEntity()
		local ply_count = net.ReadUInt(8)
		local plys = {}

		for i = 1, ply_count do
			local ply = net.ReadEntity()
			table.insert(plys, ply)
		end

		MinigameService.CreateLobby({
			id = lobby_id,
			prototype = MinigameService.Prototype(proto_id),
			host = host,
			players = plys
		}, false)
	end
end
net.Receive("Lobbies", MinigameService.ReceiveLobbies)