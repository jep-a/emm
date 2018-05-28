PlayerClassService = PlayerClassService or {}

util.AddNetworkString "PlayerClass"
function PlayerClassService.NetworkPlayerClass(ply, ply_class)
	net.Start "PlayerClass"
	net.WriteEntity(ply)
	net.WriteUInt(ply_class and ply_class.id or 0, 8)
	net.Broadcast()
end

util.AddNetworkString "RequestPlayerClasses"
util.AddNetworkString "PlayerClasses"
function PlayerClassService.NetworkPlayerClasses(_, ply)
	net.Start "PlayerClasses"

	for _, ply in pairs(player.GetAll()) do
		net.WriteEntity(ply)
		net.WriteUInt(ply.player_class and ply.player_class.id or 0, 8)
	end

	net.Send(ply)
end
net.Receive("RequestPlayerClasses", PlayerClassService.NetworkPlayerClasses)