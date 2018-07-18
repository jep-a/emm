EnviornmentService = EnviornmentService or {}


-- # Enviornment

function EnviornmentService.SetupEnviornment()
	RunConsoleCommand("sv_gravity", 300)
	RunConsoleCommand("sv_sticktoground", 0)
	RunConsoleCommand("sv_maxvelocity", 10000)
end
hook.Add("Initialize", "EnviornmentService.SetupEnviornment", EnviornmentService.SetupEnviornment)