function MinigameNetService.ReceiveLobby(lobby_id, proto, host)
	MinigameService.CreateLobby {
		id = lobby_id,
		prototype = table.Copy(proto),
		host = host,
		players = {host}
	}
end
NetService.Receive("Lobby", MinigameNetService.ReceiveLobby)

local function CallIfReceivedLobbies(func)
	return function (...)
		if MinigameNetService.received_lobbies then
			func(...)
		end
	end
end

function MinigameNetService.ReceiveLobbyState(lobby, state_id, last_state_start)
	lobby:SetState(MinigameStateService.State(lobby, state_id), last_state_start)
end
NetService.Receive("LobbyState", CallIfReceivedLobbies(MinigameNetService.ReceiveLobbyState))

NetService.Receive("LobbyFinish", CallIfReceivedLobbies(MinigameService.FinishLobby))
NetService.Receive("LobbyHost", CallIfReceivedLobbies(MinigameLobby.SetHost))
NetService.Receive("LobbyPlayer", CallIfReceivedLobbies(MinigameLobby.AddPlayer))
NetService.Receive("LobbyPlayerLeave", CallIfReceivedLobbies(MinigameLobby.RemovePlayer))

local queued_lobby_entities = {}

function MinigameNetService.ReceiveLobbyEntity(lobby, ent_id)
	local ent = Entity(ent_id)

	if IsValid(ent) then
		lobby:AddEntity(ent)
	else
		queued_lobby_entities[ent_id] = lobby
	end
end
NetService.Receive("LobbyEntity", CallIfReceivedLobbies(MinigameNetService.ReceiveLobbyEntity))

hook.Add("OnEntityCreated", "MinigameService.LobbyEntity", function (ent)
	local ent_index = ent:EntIndex()
	local lobby = queued_lobby_entities[ent_index]

	if lobby then
		lobby:AddEntity(ent)
		queued_lobby_entities[ent_index] = nil
	end
end)

NetService.Receive("LobbyEntityRemove", CallIfReceivedLobbies(MinigameLobby.RemoveEntity))

function MinigameNetService.RequestLobbies()
	NetService.SendToServer "RequestLobbies"
end
hook.Add("InitPostEntity", "MinigameNetService.RequestLobbies", MinigameNetService.RequestLobbies)

function MinigameNetService.ReceiveLobbies(len)
	local lobby_count = NetService.ReadID()

	for i = 1, lobby_count do
		local lobby_id = NetService.ReadID()
		local proto_id = NetService.ReadID()
		local state_id = NetService.ReadID()
		local last_state_start = net.ReadFloat()
		local host = net.ReadEntity()
		local ply_count = NetService.ReadID()
		local ent_count = NetService.ReadID()

		local plys = {}

		for i = 1, ply_count do
			plys[i] = net.ReadEntity()
		end

		local ents = {}

		for i = 1, ent_count do
			ents[i] = net.ReadEntity()
		end

		local settings = net.ReadTable()
		local proto = table.Copy(MinigameService.Prototype(proto_id))

		local lobby = MinigameService.CreateLobby({
			id = lobby_id,
			prototype = proto,
			state = MinigameStateService.State(proto, state_id),
			last_state_start = last_state_start,
			host = host,
			players = plys,
			entities = ents
		}, false)

		MinigameSettingsService.Adjust(lobby, settings)
	end

	MinigameNetService.received_lobbies = true
	hook.Run "ReceiveLobbies"
end
net.Receive("Lobbies", MinigameNetService.ReceiveLobbies)

function MinigameNetService.CreateHookSchema(hk_name, schema)
	NetService.CreateSchema("Minigame."..hk_name, table.Add({"minigame_lobby"}, schema))

	NetService.Receive("Minigame."..hk_name, function (lobby, ...)
		MinigameService.CallHook(lobby, hk_name, ...)
	end)
end