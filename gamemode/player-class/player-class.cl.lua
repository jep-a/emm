PlayerClassService = PlayerClassService or {}

function PlayerClassService.MinigamePlayerClass(ply, ply_class_id)
	return ply:GetMinigame().player_classes[ply_class_id]
end

function PlayerClassService.ReceivePlayerClass()
	local ply = net.ReadEntity()
	local ply_class_id = net.ReadUInt(8)
	if not (ply_class_id == 0) then
		ply:SetPlayerClass(PlayerClassService.MinigamePlayerClass(ply, ply_class_id))
	else
		ply:ClearPlayerClass()
	end
end
net.Receive("PlayerClass", PlayerClassService.ReceivePlayerClass)