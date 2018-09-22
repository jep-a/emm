util.AddNetworkString "RequestLobbies"
util.AddNetworkString "Lobbies"

function MinigameNetService.SendLobbies(ply)
	net.Start "Lobbies"
	net.WriteUInt(table.Count(MinigameService.lobbies), 8)

	for k, lobby in pairs(MinigameService.lobbies) do
		NetService.WriteID(k)
		NetService.WriteID(lobby.prototype.id)
		NetService.WriteID(lobby.state.id)
		net.WriteFloat(lobby.last_state_start)
		net.WriteEntity(lobby.host)
		net.WriteUInt(#lobby.players, 8)

		for _, ply in pairs(lobby.players) do
			net.WriteEntity(ply)
		end

		MinigameSettingsService.WriteSettings(lobby)
	end

	net.Send(ply)
end
NetService.Receive("RequestLobbies", MinigameNetService.SendLobbies)

function MinigameNetService.RequestLobby(ply, proto)
	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end

	MinigameService.CreateLobby {
		prototype = table.Copy(proto),
		host = ply,
		players = {ply}
	}
end
NetService.Receive("RequestLobby", MinigameNetService.RequestLobby)

function MinigameNetService.RequestLobbyFinish(ply)
	MinigameService.FinishLobby(ply.lobby)
end
NetService.Receive("RequestLobbyFinish", MinigameNetService.RequestLobbyFinish)

function MinigameNetService.RequestLobbyJoin(ply, lobby)
	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end

	lobby:AddPlayer(ply)
end
NetService.Receive("RequestLobbyJoin", MinigameNetService.RequestLobbyJoin)

function MinigameNetService.RequestLobbyLeave(ply)
	ply.lobby:RemovePlayer(ply)
end
NetService.Receive("RequestLobbyLeave", MinigameNetService.RequestLobbyLeave)

function MinigameNetService.CreateHookSchema(hk_name, schema)
	NetService.CreateSchema("Minigame."..hk_name, table.Add({"minigame_lobby"}, schema))
end