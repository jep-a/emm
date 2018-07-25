BuildService = BuildService or {}
BuildService.BuildTools = {}
BuildService.BuildObjects = {
	Points = {},
	Edges = {},
	Faces = {},
	Primitives = {}
}

-- # Properties

function BuildService.InitPlayerProperties(ply)
    ply.building = false
	ply.can_build = false
	ply.current_tool = {}
	ply.last_button_flag = 0
	ply.max_buildmode_primitives = 10
	ply.snap_distance  = 6
	ply.tool_distance = 100
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"BuildService.InitPlayerProperties",
	BuildService.InitPlayerProperties
)

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

function BuildService.RenderCurrentToolHUD()
    local local_ply = LocalPlayer()
    if not local_ply.building then return end
    local_ply.current_tool:Render()
end
hook.Add("PostDrawTranslucentRenderables", "RenderCurrentToolHUD", BuildService.RenderCurrentToolHUD)

function BuildService.KeyWasDown(in_key)
	--print(bit.band(LocalPlayer().last_button_flag,in_key) ~= 0)
	return (bit.band(LocalPlayer().last_button_flag,in_key) ~= 0)
end

function BuildService.HandleCurrentToolControls(ucmd)
	local local_ply = LocalPlayer()
	if not local_ply.building then return end

	local tool = local_ply.current_tool
	local button_flag = ucmd:GetButtons()

	for key, control_hook in pairs(tool.Control) do
		if (bit.band(key, button_flag) ~= 0) and (not BuildService.KeyWasDown(key)) then
			control_hook()
			ucmd:RemoveKey(key) --Suppress the button by removing the bit flag
		end
	end
	local_ply.last_button_flag = button_flag

	local mouse_delta = ucmd:GetMouseWheel()
	local mouse_hook_return = false
	if mouse_delta ~= 0 then
		mouse_hook_return = tool:OnMouseScroll(mouse_delta)
	end
	if mouse_hook_return then
		ucmd:ClearButtons()
	end
end
hook.Add("CreateMove", "HandleCurrentToolControls", BuildService.HandleCurrentToolControls)

function BuildService.SnapToGrid(pos, snap_dist)
    if snap_dist == 0 then return pos end

    local new_position = Vector()

	for axis, value in pairs(table.Sanitise({pos})[1]) do
		if axis ~= "__type" then
			new_position[axis] = math.Round(value/snap_dist)*snap_dist
		end
    end

    return new_position
end

function BuildService.GetToolPosition()
	local eye_pos = EyePos()
	local eye_vec = EyeVector()
	local local_ply = LocalPlayer()
	local eye_trace = {}
	util.TraceLine({
		start = eye_pos,
		endpos = eye_pos + eye_vec*local_ply.tool_distance,
		filter = player.GetAll(),
		output = eye_trace
	})

	local snap_dist = local_ply.snap_distance
	return BuildService.SnapToGrid(eye_trace.HitPos,snap_dist)
end

function BuildService.RegisterBuildTool(tool)
    BuildService.BuildTools[tool.name] = tool
end

function BuildService.ChangeBuildTool(toolname)
	if BuildService.BuildTools[toolname] == nil then return end
	
	local new_tool = BuildService.BuildTools[toolname]
	local old_tool = LocalPlayer().current_tool
	old_tool:OnChangeFrom()
	old_tool = new_tool
	new_tool:OnChangeTo()
end

EMM.Include {
	"build/geometry",
	"build/build-tools"
}