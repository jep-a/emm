function MinigameService.SetupMove(ply, move, cmd)
	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "SetupMove", ply)

		local ply_class = ply.player_class

		if ply_class and ply_class.SetupMove then
			ply_class.SetupMove(ply, move, cmd)
		end
	end
end
hook.Add("SetupMove", "MinigameService.SetupMove", MinigameService.SetupMove)