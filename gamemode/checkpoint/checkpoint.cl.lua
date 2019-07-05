CheckpointService = CheckpointService or {}
CheckpointService.creating = true
CheckpointService.save_mode = 0
CheckpointService.save_mode_limit = 2
CheckpointService.saved_eyes = {}

CheckpointService.marker_render_position = AnimatableValue.New(Vector(0, 0, 0), {
	smooth = true,
	smooth_multiplier = 2
})


-- # Save mode enums

CHECKPOINT_SAVE_MODE_INACTIVE = 0
CHECKPOINT_SAVE_MODE_INIT = 1
CHECKPOINT_SAVE_MODE_SIZE = 2


-- # Util

function CheckpointService.PointFromIntersect(plane_pos)
	local point

	local intersect = util.IntersectRayWithPlane(
		CheckpointService.eye_position,
		CheckpointService.eye_normal,
		plane_pos,
		Vector(0, 0, 1)
	)

	local hit_pos = LocalPlayer():GetEyeTrace().HitPos

	if intersect then
		local intersect_trace = util.TraceLine {
			start = plane_pos,
			endpos = Vector(intersect.x, intersect.y, plane_pos.z),
			collisiongroup = COLLISION_GROUP_WORLD
		}

		local eye_trace = util.TraceLine {
			start = plane_pos,
			endpos = Vector(hit_pos.x, hit_pos.y, plane_pos.z),
			collisiongroup = COLLISION_GROUP_WORLD
		}

		if intersect_trace.HitPos:Distance(CheckpointService.eye_position) > eye_trace.HitPos:Distance(CheckpointService.eye_position) then
			point = eye_trace.HitPos
		else
			point = intersect_trace.HitPos
		end
	else
		local trace = util.TraceLine {
			start = plane_pos,
			endpos = Vector(hit_pos.x, hit_pos.y, plane_pos.z),
			collisiongroup = COLLISION_GROUP_WORLD
		}

		point = trace.HitPos
	end

	local distance = plane_pos:Distance(point)
	local ang = (plane_pos - point):Angle()
	local snapped_ang = Angle(ang.p, Snap(ang.y, 7.5), ang.r)

	local snapped_trace = util.TraceLine {
		start = plane_pos,
		endpos = plane_pos + (snapped_ang:Forward() * -distance),
		collisiongroup = COLLISION_GROUP_WORLD
	}

	return snapped_trace.HitPos
end


-- # Saved hit positions

function CheckpointService.SaveCurrentEye()
	local hit_pos = LocalPlayer():GetEyeTrace().HitPos
	local last_hit_pos

	if CheckpointService.save_mode > 1 then
		last_hit_pos = CheckpointService.saved_eyes[CheckpointService.save_mode - 1].hit_position
	else
		last_hit_pos = hit_pos
	end

	local eye = {
		eye_position = CheckpointService.eye_position,
		eye_angle = CheckpointService.eye_angle,
		eye_normal = CheckpointService.eye_normal,
		hit_position = hit_pos,
		intersect_position = CheckpointService.PointFromIntersect(last_hit_pos),
	}

	CheckpointService.saved_eyes[CheckpointService.save_mode] = eye

	return eye
end

function CheckpointService.ClearSavedEyes()
	CheckpointService.saved_eyes = {}
end


-- # Creating

function CheckpointService.ProgressMode()
	CheckpointService.ClearMarkers()

	if CheckpointService.save_mode == CheckpointService.save_mode_limit then
		CheckpointService.save_mode = 0
	else
		CheckpointService.save_mode = CheckpointService.save_mode + 1
	end

	if CheckpointService.save_mode > 0 then
		local eye = CheckpointService.SaveCurrentEye()

		CheckpointService.marker_render_position:SnapTo(eye.hit_position)
	else
		CheckpointService.ClearSavedEyes()
	end

	if CheckpointService.save_mode == 1 then
		local position = CheckpointService.saved_eyes[1].hit_position

		CheckpointService.start_time = CurTime()
		CheckpointService.start_marker = CheckpointHorizontalPlaneMarker.New(position)
		CheckpointService.end_marker = CheckpointHorizontalPlaneMarker.New(position)
		CheckpointService.horizontal_beam = CheckpointMarkerTwoPointBeam.New()
	elseif CheckpointService.save_mode == 2 then
		local xy_start_position = CheckpointService.saved_eyes[1].hit_position
		local xy_end_position = CheckpointService.saved_eyes[2].intersect_position

		CheckpointService.horizontal_beam = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_start_position,
			end_position = xy_end_position
		}
	end

end

function CheckpointService.SetupCreating(ply, move)
	if IsFirstTimePredicted() then
		if move:KeyPressed(IN_ATTACK) or (
			move:KeyReleased(IN_ATTACK) and CheckpointService.save_mode == 1 and CurTime() > (CheckpointService.start_time + 0.25)
		) then
			CheckpointService.ProgressMode()
		end
	end
end
hook.Add("SetupMove", "CheckpointService.SetupCreating", CheckpointService.SetupCreating)

function CheckpointService.CalcView(ply, eye_pos, eye_ang)
	CheckpointService.eye_position = eye_pos
	CheckpointService.eye_angle = eye_ang
	CheckpointService.eye_normal = eye_ang:Forward()
end
hook.Add("CalcView", "CheckpointService.CalcView", CheckpointService.CalcView)

function CheckpointService.Think()
	if CheckpointService.start_marker then
		if CheckpointService.save_mode == 1 then
			CheckpointService.marker_render_position.current = CheckpointService.PointFromIntersect(CheckpointService.start_marker.position)
			CheckpointService.end_marker.position = CheckpointService.marker_render_position.smooth
			CheckpointService.horizontal_beam.end_position = CheckpointService.marker_render_position.smooth
		elseif CheckpointService.save_mode == 2 then

		end
	end
end
hook.Add("PostDrawTranslucentRenderables", "CheckpointService.Think", CheckpointService.Think)