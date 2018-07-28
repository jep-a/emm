BuildUtil = BuildUtil or {}

function BuildUtil.SnapToGrid(pos, snap_dist)
    if snap_dist == 0 then return pos end

    local new_position = Vector()

	for axis, value in pairs(table.Sanitise({pos})[1]) do
		if axis ~= "__type" then
			new_position[axis] = math.Round(value/snap_dist)*snap_dist
		end
    end

    return new_position
end

function BuildUtil.GetToolPosition()
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
	return BuildUtil.SnapToGrid(eye_trace.HitPos,snap_dist)
end

function BuildUtil.RenderToolCursor()
    render.SetColorMaterial()
    local point_pos = BuildUtil.GetToolPosition()
    render.DrawWireframeSphere(point_pos, 2, 10, 10, Color(255,255,255,255))
    
    local trace_struct = util.QuickTrace(point_pos, Vector(0,0,-16000), ents.GetAll())
    render.DrawBeam(point_pos, trace_struct.HitPos, 10, 0, 1, ColorAlpha(COLOR_WHITE, 100))
end