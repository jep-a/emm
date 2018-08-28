PlayerClassService = PlayerClassService or {}

util.AddNetworkString "RequestPlayerClasses"
util.AddNetworkString "PlayerClasses"

function PlayerClassService.NetworkPlayerClasses(ply)
	net.Start "PlayerClasses"

	for _, _ply in pairs(player.GetAll()) do
		net.WriteEntity(_ply)
		NetService.WriteID(_ply.player_class and _ply.player_class.id)
	end

	net.Send(ply)
end
NetService.Receive("RequestPlayerClasses", PlayerClassService.NetworkPlayerClasses)