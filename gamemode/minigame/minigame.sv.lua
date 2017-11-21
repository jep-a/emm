MinigameService = MinigameService or {}


-- # Lobbies

MinigameLobby = MinigameLobby or {}

function MinigameService.CreateLobby(lobby)
	lobby = setmetatable(table.Merge({players = {}}, lobby or {}), MinigameLobby)
	lobby.id = #MinigameService.lobbies + 1

	if lobby.host then
		lobby:AddPlayer(lobby.host, false)
	end

	for k, _ in pairs(lobby.prototype.player_classes) do
		lobby[k] = {}
	end

	MinigameService.lobbies[lobby.id] = lobby
	MinigameService.NetworkCreateLobby(lobby)

	return lobby
end

function MinigameService.RemoveLobby(lobby)
	MinigameService.lobbies[lobby.id] = nil

	for _, ply in pairs(lobby.players) do
		lobby:RemovePlayer(ply, false)
	end

	MinigameService.NetworkRemoveLobby(lobby)
	table.Empty(lobby)
end

function MinigameLobby:AddPlayer(ply, net)
	net = net == nil and true or net

	ply.minigame_lobby = self
	table.insert(self.players, ply)

	if net then
		MinigameService.NetworkLobbyAddPlayer(self, ply)
	end
end

function MinigameLobby:RemovePlayer(ply, net)
	net = net == nil and true or net

	ply:ClearPlayerClass()
	ply.minigame_lobby = nil
	table.RemoveByValue(self.players, ply)

	if net then
		MinigameService.NetworkLobbyRemovePlayer(self, ply)
	end
end


-- # Networking

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

util.AddNetworkString "RequestLobbies"
util.AddNetworkString "Lobbies"
function MinigameService.NetworkLobbies(_, ply)
	net.Start "Lobbies"
	net.WriteUInt(table.Count(MinigameService.lobbies), 8)

	for k, lobby in pairs(MinigameService.lobbies) do
		net.WriteUInt(k, 8)
		net.WriteUInt(lobby.prototype.id, 8)
		net.WriteEntity(lobby.host)
		net.WriteUInt(#lobby.players, 8)

		for _, ply in pairs(lobby.players) do
			net.WriteEntity(ply)
		end

		for ply_class_key, _ in pairs(lobby.prototype.player_classes) do
			net.WriteUInt(#lobby[ply_class_key], 8)
			for _, ply in pairs(lobby[ply_class_key]) do
				net.WriteEntity(ply)
			end
		end
	end

	net.Send(ply)
end
net.Receive("RequestLobbies", MinigameService.NetworkLobbies)

util.AddNetworkString "RequestCreateLobby"
function MinigameService.ReceiveCreateLobby(_, ply)
	local proto_id = net.ReadUInt(8)
	Minigame.CreateLobby({
		prototype = MinigameService.Prototype(proto_id),
		host = ply
	})
end
net.Receive("RequestCreateLobby", MinigameService.ReceiveCreateLobby)