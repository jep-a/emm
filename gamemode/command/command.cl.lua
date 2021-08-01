function CommandService.CreateConCommand(cmd)
	concommand.Add("emm_" .. cmd.name, function(sender, _, args)
		if CLIENT then
			RunConsoleCommand("net_emm_" .. cmd.name, unpack(args))
		else
			for _, ply in ipairs(player.GetAll()) do
				concommand.Run(ply, "net_emm_"  .. cmd.name, args)
			end
		end
		
		cmd:Execute(sender, unpack(args))
	end, CommandService.AutoComplete)
end