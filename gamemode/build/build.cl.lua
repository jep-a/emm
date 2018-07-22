BuildService = BuildService or {}

-- # Properties

function BuildService.InitPlayerProperties(ply)
	ply.can_build = true --= false
	ply.max_objects = false
    ply.in_build = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"BuildService.InitPlayerProperties",
	BuildService.InitPlayerProperties
)

-- # Functions
util.AddNetworkString "BuildService.RequestBuildmode"
function BuildService.RequestBuildmode()
	if not LocalPlayer().can_build then
		chat.AddText( Color(255,0,0), "You are not allowed to build.")
		return
	end

	net.Start "BuildService.RequestBuildmode"
	net.SendToServer()

	LocalPlayer().in_build = true
end