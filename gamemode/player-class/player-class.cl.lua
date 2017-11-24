PlayerClassService = PlayerClassService or {}

function PlayerClassService.MinigamePlayerClass(ply, id)
	for _, ply_class in pairs(ply.lobby.player_classes) do
		if id == ply_class.id then
			return ply_class
		end
	end
end

function PlayerClassService.ReceivePlayerClass()
	local ply = net.ReadEntity()
	local id = net.ReadUInt(8)
	if not (id == 0) then
		ply:SetPlayerClass(PlayerClassService.MinigamePlayerClass(ply, id))
	else
		ply:ClearPlayerClass()
	end
end
net.Receive("PlayerClass", PlayerClassService.ReceivePlayerClass)