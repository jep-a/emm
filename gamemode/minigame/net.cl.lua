-- # Receiving

function MinigameService.ReceiveCreateLobby()
	local lobby_id = net.ReadUInt(8)
	local proto_id = net.ReadUInt(8)
	local host = net.ReadEntity()
	MinigameService.CreateLobby {
		id = lobby_id,
		prototype = MinigameService.Prototype(proto_id),
		host = host,
		players = {host}
	}
end
net.Receive("CreateLobby", MinigameService.ReceiveCreateLobby)

function MinigameService.ReceiveRemoveLobby()
	local lobby_id = net.ReadUInt(8)
	MinigameService.RemoveLobby(MinigameService.lobbies[lobby_id])
end
net.Receive("RemoveLobby", MinigameService.ReceiveRemoveLobby)

function MinigameService.LobbySetHost()
	local lobby_id = net.ReadUInt(8)
	local ply = net.ReadEntity()
	MinigameService.lobbies[lobby_id]:SetHost(ply)
end
net.Receive("LobbySetHost", MinigameService.LobbySetHost)

function MinigameService.LobbySetState()
	local lobby_id = net.ReadUInt(8)
	local state_id = net.ReadUInt(8)
	local last_state_start = net.ReadFloat()
	MinigameService.lobbies[lobby_id]:SetState(StateService.State(MinigameService.lobbies[lobby_id], state_id), last_state_start)
end
net.Receive("LobbySetState", MinigameService.LobbySetState)

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
		local state_id = net.ReadUInt(8)
		local last_state_start = net.ReadFloat()
		local host = net.ReadEntity()
		local ply_count = net.ReadUInt(8)

		local proto = MinigameService.Prototype(proto_id)
		local lobby = {
			id = lobby_id,
			prototype = MinigameService.Prototype(proto_id),
			state = StateService.State(proto, state_id),
			last_state_start = last_state_start,
			host = host,
			players = {}
		}
		
		for i = 1, ply_count do
			local ply = net.ReadEntity()
			lobby.players[i] = ply
		end

		MinigameService.CreateLobby(lobby, false)
	end

	hook.Run "ReceiveLobbies"
end
net.Receive("Lobbies", MinigameService.ReceiveLobbies)


-- # Requesting

function MinigameService.RequestCreateLobby(proto)
	net.Start "RequestCreateLobby"
	net.WriteUInt(proto.id, 8)
	net.SendToServer()
end

function MinigameService.RequestRemoveLobby()
	net.Start "RequestRemoveLobby"
	net.SendToServer()
end

function MinigameService.RequestJoinLobby(lobby)
	net.Start "RequestJoinLobby"
	net.WriteUInt(lobby.id, 8)
	net.SendToServer()
end

function MinigameService.RequestLeaveLobby()
	net.Start "RequestLeaveLobby"
	net.SendToServer()
end