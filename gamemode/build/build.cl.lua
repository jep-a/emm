BuildService = BuildService or {}
BuildService.BuildTools = BuildService.BuildTools or {}
BuildService.BuildObjects = BuildService.BuildObjects or {
	Points = {},
	Edges = {},
	Faces = {},
	Primitives = {}
}

-- # Properties

function BuildService.InitPlayerProperties(ply)
    ply.building = false
	ply.can_build = true --false
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

function BuildService.HandleCurrentToolThink()
    local local_ply = LocalPlayer()
    if not local_ply.building then return end
    local_ply.current_tool:Think()
end
hook.Add("Think", "HandleCurrentToolThink", BuildService.HandleCurrentToolThink)

function BuildService.KeyWasDown(in_key)
	--print(bit.band(LocalPlayer().last_button_flag,in_key) ~= 0)
	return (bit.band(LocalPlayer().last_button_flag,in_key) ~= 0)
end

function BuildService.HandleCurrentToolControls(ucmd)
	local local_ply = LocalPlayer()
	if not local_ply.building then return end

	local tool = local_ply.current_tool
	local button_flag = ucmd:GetButtons()

	for key, press_hook in pairs(tool.Press) do
		if (bit.band(key, button_flag) ~= 0) and (not BuildService.KeyWasDown(key)) then
			press_hook()
			ucmd:RemoveKey(key) --Suppress the button by removing the bit flag
        end
    end
    for key, release_hook in pairs(tool.Release) do
        if (bit.band(key, button_flag) == 0) and (BuildService.KeyWasDown(key)) then
			release_hook()
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

function BuildService.RegisterBuildTool(tool)
	print(tool.name.." registered")
    BuildService.BuildTools[tool.name] = tool
end

function BuildService.ChangeBuildTool(toolname)
	if BuildService.BuildTools[toolname] == nil then return end
	local new_tool = BuildService.BuildTools[toolname]
	LocalPlayer().current_tool:OnHolster()
	LocalPlayer().current_tool = new_tool
	new_tool:OnEquip()
end

function BuildService.RegisterPoints(new_points)
    for _, new_point in pairs(new_points) do
        table.insert(BuildService.BuildObjects.Points, new_point)
    end
end

function BuildService.RegisterEdges(new_edges)
    for _, new_edge in pairs(new_edges) do
        table.insert(BuildService.BuildObjects.Edges, new_edge)
    end
end

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

function BuildService.RenderToolCursor()
    local CURSOR_INVISIBLE_SPEED = 50
    local speed_alpha = math.Clamp((CURSOR_INVISIBLE_SPEED-LocalPlayer():GetVelocity():Length()/10)/CURSOR_INVISIBLE_SPEED, 0, 1)*200

    render.SetColorMaterial()
    local point_pos = BuildService.GetToolPosition()
    render.DrawWireframeSphere(point_pos, 2, 10, 10, ColorAlpha(COLOR_WHITE,speed_alpha))
    
    local ground_trace = util.QuickTrace(point_pos, Vector(0,0,-16000), ents.GetAll())
    render.DrawLine(point_pos, ground_trace.HitPos, ColorAlpha(COLOR_WHITE,speed_alpha))

    local rad = 2*math.pi
    for i = 0, 1, 1/4 do
        render.DrawLine(ground_trace.HitPos, ground_trace.HitPos + Vector(math.cos(i*rad), math.sin(i*rad),0)*20, ColorAlpha(COLOR_WHITE,speed_alpha))
    end
end

function BuildService.GetHoveredEdge()
    local closest_edge = nil
    local shortest_distance = -1
    for _, edge in pairs(BuildService.BuildObjects.Edges) do
        local edge_hit = edge:LookingAt()
        if edge_hit ~= nil then
            local edge_distance = edge:LookingAt():Distance(EyePos())
            if shortest_distance < 0 or edge_distance < shortest_distance then
                closest_edge = edge
                shortest_distance = edge_distance
            end
        end
    end

    return closest_edge
end

function BuildService.LookAt(vec)
    timer.Simple(0.001, function()
        LocalPlayer():SetEyeAngles((vec - EyePos()):Angle())
    end)
end

EMM.Include {
	"build/geometry",
	"build/build-tools"
}

concommand.Add("emm_build_changetool", function(ply, cmd, args, arg_str)
    BuildService.ChangeBuildTool(args[1])
end,
function(cmd, args)
    local tool_names = {}
    for tool_name, tool in pairs(BuildService.BuildTools) do
        table.insert(tool_names, cmd .. " " .. tool_name)
    end

    return tool_names
end, nil, 1073741824)

concommand.Add("emm_build_requestbuildmode", function(ply, cmd, args, arg_str)
    BuildService.RequestBuildmode()
end,nil, nil, 1073741824)