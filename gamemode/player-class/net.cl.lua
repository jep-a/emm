function PlayerClassService.ReceivePlayerClass()
	local ply = net.ReadEntity()
	local id = net.ReadUInt(8)

	if id ~= 0 then
		ply:SetPlayerClass(PlayerClassService.MinigamePlayerClass(ply, id))
	else
		ply:ClearPlayerClass()
	end
end
net.Receive("PlayerClass", PlayerClassService.ReceivePlayerClass)

function PlayerClassService.ReceivePlayerClasses()
	for i = 1, #player.GetAll() do
		local ply = net.ReadEntity()
		local id = net.ReadUInt(8)

		if id ~= 0 then
			ply:SetPlayerClass(PlayerClassService.MinigamePlayerClass(ply, id))
		end
	end
end
net.Receive("PlayerClasses", PlayerClassService.ReceivePlayerClasses)

function PlayerClassService.RequestPlayerClasses()
	net.Start "RequestPlayerClasses"
	net.SendToServer()
end
hook.Add("ReceiveLobbies", "PlayerClassService.RequestPlayerClasses", PlayerClassService.RequestPlayerClasses)
