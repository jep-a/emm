MinigameNetworkService = MinigameNetworkService or {}


-- # Sending

util.AddNetworkString "Lobby"
function MinigameNetworkService.SendLobby(lobby)
	net.Start "Lobby"
	net.WriteUInt(lobby.id, 8)
	net.WriteUInt(lobby.prototype.id, 8)
	net.WriteEntity(lobby.host)
	net.Broadcast()
end

util.AddNetworkString "LobbyFinish"
function MinigameNetworkService.SendLobbyFinish(lobby)
	net.Start "LobbyFinish"
	net.WriteUInt(lobby.id, 8)
	net.Broadcast()
end

util.AddNetworkString "LobbyHost"
function MinigameNetworkService.SendLobbyHost(lobby, ply)
	net.Start "LobbyHost"
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end

util.AddNetworkString "LobbyState"
function MinigameNetworkService.SendLobbyState(lobby)
	net.Start "LobbyState"
	net.WriteUInt(lobby.id, 8)
	net.WriteUInt(lobby.state.id, 8)
	net.WriteFloat(lobby.last_state_start)
	net.Broadcast()
end

util.AddNetworkString "LobbyPlayer"
function MinigameNetworkService.SendLobbyPlayer(lobby, ply)
	net.Start "LobbyPlayer"
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end

util.AddNetworkString "LobbyPlayerLeave"
function MinigameNetworkService.SendLobbyPlayerLeave(lobby, ply)
	net.Start "LobbyPlayerLeave"
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end

util.AddNetworkString "LobbyHost"
function MinigameNetworkService.SendLobbyHost(lobby, ply)
	net.Start "LobbyHost"
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end

util.AddNetworkString "RequestLobbies"
util.AddNetworkString "Lobbies"
function MinigameNetworkService.SendLobbies(_, ply)
	net.Start "Lobbies"
	net.WriteUInt(table.Count(MinigameService.lobbies), 8)

	for k, lobby in pairs(MinigameService.lobbies) do
		net.WriteUInt(k, 8)
		net.WriteUInt(lobby.prototype.id, 8)
		net.WriteUInt(lobby.state.id, 8)
		net.WriteFloat(lobby.last_state_start)
		net.WriteEntity(lobby.host)
		net.WriteUInt(#lobby.players, 8)

		for _, ply in pairs(lobby.players) do
			net.WriteEntity(ply)
		end
	end

	net.Send(ply)
end
net.Receive("RequestLobbies", MinigameNetworkService.SendLobbies)


-- # Requesting

util.AddNetworkString "RequestLobby"
function MinigameNetworkService.RequestLobby(_, ply)
	local proto_id = net.ReadUInt(8)

	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end

	MinigameService.CreateLobby {
		prototype = table.Copy(MinigameService.Prototype(proto_id)),
		host = ply,
		players = {ply}
	}
end
net.Receive("RequestLobby", MinigameNetworkService.RequestLobby)

util.AddNetworkString "RequestLobbyFinish"
function MinigameNetworkService.RequestLobbyFinish(_, ply)
	MinigameService.FinishLobby(ply.lobby)
end
net.Receive("RequestLobbyFinish", MinigameNetworkService.RequestLobbyFinish)

util.AddNetworkString "RequestLobbyJoin"
function MinigameNetworkService.RequestLobbyJoin(_, ply)
	local lobby_id = net.ReadUInt(8)

	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end

	MinigameService.lobbies[lobby_id]:AddPlayer(ply)
end
net.Receive("RequestLobbyJoin", MinigameNetworkService.RequestLobbyJoin)

util.AddNetworkString "RequestLobbyLeave"
function MinigameNetworkService.RequestLobbyLeave(_, ply)
	ply.lobby:RemovePlayer(ply)
end
net.Receive("RequestLobbyLeave", MinigameNetworkService.RequestLobbyLeave)