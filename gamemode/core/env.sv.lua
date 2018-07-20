EnvironmentService = EnvironmentService or {}


-- # Enviornment

function EnvironmentService.SetupEnvironment()
	RunConsoleCommand("sv_gravity", 300)
	RunConsoleCommand("sv_sticktoground", 0)
	RunConsoleCommand("sv_maxvelocity", 10000)
	RunConsoleCommand("sv_accelerate", 10)
	RunConsoleCommand("sv_airaccelerate", 10)
end
hook.Add("Initialize", "EnvironmentService.SetupEnvironment", EnvironmentService.SetupEnvironment)