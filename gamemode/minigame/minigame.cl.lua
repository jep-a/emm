MinigameService = MinigameService or {}


-- # Lobbies

MinigameLobby = MinigameLobby or {}

function MinigameService.CreateLobby(lobby, notify)
	notify = notify == nil and true or notify

	local lobby = setmetatable(table.Merge({players = {}}, lobby or {}), MinigameLobby)

	if lobby.host then
		lobby:AddPlayer(lobby.host, false)
	end

	for k, _ in pairs(lobby.prototype.player_classes) do
		lobby[k] = lobby[k] or {}
	end

	MinigameService.lobbies[lobby.id] = lobby

	return lobby
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
		
		local proto = MinigameService.Prototype(proto_id)
		local lobby = {
			id = lobby_id,
			prototype = proto,
			host = host,
			players = {}
		}
		
		for i = 1, ply_count do
			local ply = net.ReadEntity()
			lobby.players[i] = ply
		end

		for ply_class_key, _ in pairs(proto.player_classes) do
			local ply_class_count = net.ReadUInt(8)
			lobby[ply_class_key] = {}

			for i = 1, ply_class_count do
				local ply = net.ReadEntity()
				lobby[ply_class_key][i] = ply
			end
		end

		MinigameService.CreateLobby(lobby, false)
	end
end
net.Receive("Lobbies", MinigameService.ReceiveLobbies)

function MinigameService.RequestCreateLobby(proto)
	net.Start "RequestCreateLobby"
	net.WriteUInt(proto.id, 8)
	net.SendToServer()
end