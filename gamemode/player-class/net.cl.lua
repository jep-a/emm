function PlayerClassService.ReceivePlayerClass(ply, id)
	if MinigameNetService.received_lobbies then
		if id ~= 0 then
			ply:SetPlayerClass(PlayerClassService.MinigamePlayerClass(ply, id))
		else
			ply:ClearPlayerClass()
		end
	end
end
NetService.Receive("PlayerClass", PlayerClassService.ReceivePlayerClass)

function PlayerClassService.ReceivePlayerClasses()
	for i = 1, #player.GetAll() do
		local ply = net.ReadEntity()
		local id = NetService.ReadID()

		if id ~= 0 then
			ply:SetPlayerClass(PlayerClassService.MinigamePlayerClass(ply, id))
		end
	end
end
net.Receive("PlayerClasses", PlayerClassService.ReceivePlayerClasses)

function PlayerClassService.RequestPlayerClasses()
	NetService.Send "RequestPlayerClasses"
end
hook.Add("ReceiveLobbies", "PlayerClassService.RequestPlayerClasses", PlayerClassService.RequestPlayerClasses)
