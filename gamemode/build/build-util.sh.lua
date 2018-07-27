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
    local point_pos = BuildUtil.GetToolPosition()
    render.DrawWireframeSphere(point_pos, 2, 10, 10, Color(255,255,255,255))
end