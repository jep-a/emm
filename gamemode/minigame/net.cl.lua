function MinigameNetService.ReceiveLobby(lobby_id, proto, host)
	MinigameService.CreateLobby {
		id = lobby_id,
		prototype = proto,
		host = host,
		players = {host}
	}
end
NetService.Receive("Lobby", MinigameNetService.ReceiveLobby)

function MinigameNetService.ReceiveLobbyState(lobby, state_id, last_state_start)
	lobby:SetState(MinigameStateService.State(lobby, state_id), last_state_start)
end
NetService.Receive("LobbyState", MinigameNetService.ReceiveLobbyState)

NetService.Receive("LobbyFinish", MinigameService.FinishLobby)
NetService.Receive("LobbyHost", MinigameLobby.SetHost)
NetService.Receive("LobbyPlayer", MinigameLobby.AddPlayer)
NetService.Receive("LobbyPlayerLeave", MinigameLobby.RemovePlayer)

function MinigameNetService.RequestLobbies()
	NetService.Send "RequestLobbies"
end
hook.Add("InitPostEntity", "MinigameNetService.RequestLobbies", MinigameNetService.RequestLobbies)

function MinigameNetService.ReceiveLobbies()
	local lobby_count = NetService.ReadID()

	for i = 1, lobby_count do
		local lobby_id = NetService.ReadID()
		local proto_id = NetService.ReadID()
		local state_id = NetService.ReadID()
		local last_state_start = net.ReadFloat()
		local host = net.ReadEntity()
		local ply_count = NetService.ReadID()

		local proto = MinigameService.Prototype(proto_id)

		local lobby = {
			id = lobby_id,
			prototype = proto,
			state = MinigameStateService.State(proto, state_id),
			last_state_start = last_state_start,
			host = host,
			players = {}
		}

		for i = 1, ply_count do
			lobby.players[i] = net.ReadEntity()
		end

		MinigameService.CreateLobby(lobby, false)
	end

	hook.Run "ReceiveLobbies"
end
net.Receive("Lobbies", MinigameNetService.ReceiveLobbies)

function MinigameNetService.CreateHookSchema(hk_name, schema)
	NetService.CreateSchema("Minigame."..hk_name, table.Add({"minigame_lobby"}, schema))

	NetService.Receive("Minigame."..hk_name, function (lobby, ...)
		MinigameService.CallHook(lobby, hk_name, ...)
	end)
end