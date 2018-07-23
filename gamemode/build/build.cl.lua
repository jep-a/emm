BuildService = BuildService or {}

-- # Properties

function BuildService.InitPlayerProperties(ply)
	ply.can_build = false
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
	local_ply.current_tool = BuildService.BuildTools["no_tool"]
end

function BuildService.HandleCurrentToolControls(local_ply,key)
	if not local_ply.building then return end
	local_ply.current_tool.Do[key]()
end
hook.Add("KeyPress", "HandleToolControls", BuildService.HandleToolControls)

function BuildService.RenderCurrentToolHUD()
    local local_ply = LocalPlayer()
    if not local_ply.building then return end
    local_ply.current_tool:Render()
end
hook.Add("PostDrawTranslucentRenderables", "RenderCurrentToolHUD", BuildService.RenderCurrentToolHUD)

function BuildService.SnapToGrid(pos, snap_dist)
    if snap_dist == 0 then return pos end

    local new_position = Vector()

    for axis, value in pairs(pos) do
        new_position[axis] = math.Round(value/snap_dist)
    end

    return new_position
end

function BuildService.GetToolPosition()
    return BuildService.SnapToGrid(EyePos()+EyeVector()*LocalPlayer().tool_distance,LocalPlayer().snap_distance)
end

function BuildService.RegisterBuildTool(tool)
    BuildService.BuildTools[tool.name] = tool
end