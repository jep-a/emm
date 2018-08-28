MinigameNetworkService = MinigameNetworkService or {}

util.AddNetworkString "RequestLobbies"
util.AddNetworkString "Lobbies"

function MinigameNetworkService.SendLobbies(ply)
	net.Start "Lobbies"
	net.WriteUInt(table.Count(MinigameService.lobbies), 8)

	for k, lobby in pairs(MinigameService.lobbies) do
		NetworkService.WriteID(k)
		NetworkService.WriteID(lobby.prototype.id)
		NetworkService.WriteID(lobby.state.id)
		net.WriteFloat(lobby.last_state_start)
		net.WriteEntity(lobby.host)
		net.WriteUInt(#lobby.players, 8)

		for _, ply in pairs(lobby.players) do
			net.WriteEntity(ply)
		end
	end

	net.Send(ply)
end
NetService.Receive("RequestLobbies", MinigameNetworkService.SendLobbies)

function MinigameNetworkService.RequestLobby(ply, proto)
	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end

	MinigameService.CreateLobby {
		prototype = table.Copy(proto),
		host = ply,
		players = {ply}
	}
end
NetService.Receive("RequestLobby", MinigameNetworkService.RequestLobby)

function MinigameNetworkService.RequestLobbyFinish(ply)
	MinigameService.FinishLobby(ply.lobby)
end
NetService.Receive("RequestLobbyFinish", MinigameNetworkService.RequestLobbyFinish)

function MinigameNetworkService.RequestLobbyJoin(ply, lobby)
	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end

	lobby:AddPlayer(ply)
end
NetService.Receive("RequestLobbyJoin", MinigameNetworkService.RequestLobbyJoin)

function MinigameNetworkService.RequestLobbyLeave(ply)
	ply.lobby:RemovePlayer(ply)
end
NetService.Receive("RequestLobbyLeave", MinigameNetworkService.RequestLobbyLeave)