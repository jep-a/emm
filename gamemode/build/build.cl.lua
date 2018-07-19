BuildService = BuildService or {}

-- # Properties

function BuildService.InitPlayerProperties(ply)
	ply.can_build = true --= false
    ply.building = false
	ply.max_buildmode_primitives = 10
	ply.current_tool = {}
	ply.tool_distance = 100
	ply.snap_distance  = 6
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"BuildService.InitPlayerProperties",
	BuildService.InitPlayerProperties
)

EMM.Include {
	"build/geometry",
	"build/build-tools"
}


-- # Functions

function BuildService.RequestBuildmode()
	local local_ply = LocalPlayer()

	if not local_ply.can_build then
		chat.AddText(Color(255,0,0), "You are not allowed to build.")

		return
	end

	net.Start "Buildmode"
	net.WriteBool(true)
	net.SendToServer()

	local_ply.building = true
end