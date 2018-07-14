-- # Sending

util.AddNetworkString "CreateLobby"
function MinigameService.NetworkCreateLobby(lobby)
	net.Start "CreateLobby"
	net.WriteUInt(lobby.id, 8)
	net.WriteUInt(lobby.prototype.id, 8)
	net.WriteEntity(lobby.host)
	net.Broadcast()
end

util.AddNetworkString "RemoveLobby"
function MinigameService.NetworkRemoveLobby(lobby)
	net.Start "RemoveLobby"
	net.WriteUInt(lobby.id, 8)
	net.Broadcast()
end

util.AddNetworkString "LobbySetHost"
function MinigameService.NetworkLobbySetHost(lobby, ply)
	net.Start "LobbySetHost"
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end

util.AddNetworkString "LobbySetState"
function MinigameService.NetworkLobbySetState(lobby)
	net.Start "LobbySetState"
	net.WriteUInt(lobby.id, 8)
	net.WriteUInt(lobby.state.id, 8)
	net.WriteFloat(lobby.last_state_start)
	net.Broadcast()
end

util.AddNetworkString "LobbyAddPlayer"
function MinigameService.NetworkLobbyAddPlayer(lobby, ply)
	net.Start "LobbyAddPlayer"
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end

util.AddNetworkString "LobbyRemovePlayer"
function MinigameService.NetworkLobbyRemovePlayer(lobby, ply)
	net.Start "LobbyRemovePlayer"
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end

util.AddNetworkString "LobbySetHost"
function MinigameService.NetworkLobbySetHost(lobby, ply)
	net.Start "LobbySetHost"
	net.WriteUInt(lobby.id, 8)
	net.WriteEntity(ply)
	net.Broadcast()
end

util.AddNetworkString "RequestLobbies"
util.AddNetworkString "Lobbies"
function MinigameService.NetworkLobbies(_, ply)
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
net.Receive("RequestLobbies", MinigameService.NetworkLobbies)


-- # Requesting

util.AddNetworkString "RequestCreateLobby"
function MinigameService.ReceiveCreateLobby(_, ply)
	local proto_id = net.ReadUInt(8)

	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end

	MinigameService.CreateLobby({
		prototype = table.Copy(MinigameService.Prototype(proto_id)),
		host = ply,
		players = {ply}
	})
end
net.Receive("RequestCreateLobby", MinigameService.ReceiveCreateLobby)

util.AddNetworkString "RequestRemoveLobby"
function MinigameService.ReceiveRemoveLobby(_, ply)
	MinigameService.RemoveLobby(ply.lobby)
end
net.Receive("RequestRemoveLobby", MinigameService.ReceiveRemoveLobby)

util.AddNetworkString "RequestJoinLobby"
function MinigameService.RequestJoinLobby(_, ply)
	local lobby_id = net.ReadUInt(8)

	if ply.lobby then
		ply.lobby:RemovePlayer(ply)
	end

	MinigameService.lobbies[lobby_id]:AddPlayer(ply)
end
net.Receive("RequestJoinLobby", MinigameService.RequestJoinLobby)

util.AddNetworkString "RequestLeaveLobby"
function MinigameService.RequestLeaveLobby(_, ply)
	ply.lobby:RemovePlayer(ply)
end
net.Receive("RequestLeaveLobby", MinigameService.RequestLeaveLobby)