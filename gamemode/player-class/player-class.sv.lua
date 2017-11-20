PlayerClassService = PlayerClassService or {}

util.AddNetworkString "PlayerClass"
function PlayerClassService.NetworkPlayerClass(ply, ply_class)
	net.Start "PlayerClass"
	net.WriteEntity(ply)
	net.WriteUInt(ply_class and ply_class.id or 0, 8)
	net.Broadcast()
end
