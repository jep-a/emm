MinigameNetworkService = MinigameNetworkService or {}


-- # Receiving

function MinigameNetworkService.ReceiveLobby()
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
net.Receive("Lobby", MinigameNetworkService.ReceiveLobby)

function MinigameNetworkService.ReceiveLobbyFinish()
	local lobby_id = net.ReadUInt(8)
	MinigameService.FinishLobby(MinigameService.lobbies[lobby_id])
end
net.Receive("LobbyFinish", MinigameNetworkService.ReceiveLobbyFinish)

function MinigameNetworkService.ReceiveLobbyHost()
	local lobby_id = net.ReadUInt(8)
	local ply = net.ReadEntity()

	MinigameService.lobbies[lobby_id]:SetHost(ply)
end
net.Receive("LobbyHost", MinigameNetworkService.ReceiveLobbyHost)

function MinigameNetworkService.ReceiveLobbyState()
	local lobby_id = net.ReadUInt(8)
	local state_id = net.ReadUInt(8)
	local last_state_start = net.ReadFloat()

	MinigameService.lobbies[lobby_id]:SetState(MinigameStateService.State(MinigameService.lobbies[lobby_id], state_id), last_state_start)
end
net.Receive("LobbyState", MinigameNetworkService.ReceiveLobbyState)

function MinigameNetworkService.ReceiveLobbyPlayer()
	local lobby_id = net.ReadUInt(8)
	local ply = net.ReadEntity()

	MinigameService.lobbies[lobby_id]:AddPlayer(ply)
end
net.Receive("LobbyPlayer", MinigameNetworkService.ReceiveLobbyPlayer)

function MinigameNetworkService.ReceiveLobbyPlayerLeave()
	local lobby_id = net.ReadUInt(8)
	local ply = net.ReadEntity()

	MinigameService.lobbies[lobby_id]:RemovePlayer(ply)
end
net.Receive("LobbyPlayerLeave", MinigameNetworkService.ReceiveLobbyPlayerLeave)

function MinigameNetworkService.RequestLobbies()
	net.Start "RequestLobbies"
	net.SendToServer()
end
hook.Add("InitPostEntity", "MinigameNetworkService.RequestLobbies", MinigameNetworkService.RequestLobbies)

function MinigameNetworkService.ReceiveLobbies()
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
			state = MinigameStateService.State(proto, state_id),
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
net.Receive("Lobbies", MinigameNetworkService.ReceiveLobbies)


-- # Requesting

function MinigameNetworkService.RequestLobby(proto)
	net.Start "RequestLobby"
	net.WriteUInt(proto.id, 8)
	net.SendToServer()
end

function MinigameNetworkService.RequestLobbyFinish()
	net.Start "RequestLobbyFinish"
	net.SendToServer()
end

function MinigameNetworkService.RequestLobbyJoin(lobby)
	net.Start "RequestLobbyJoin"
	net.WriteUInt(lobby.id, 8)
	net.SendToServer()
end

function MinigameNetworkService.RequestLobbyLeave()
	net.Start "RequestLobbyLeave"
	net.SendToServer()
end