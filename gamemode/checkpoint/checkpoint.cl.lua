CheckpointService = CheckpointService or {}
CheckpointService.creating = true
CheckpointService.save_mode = 0
CheckpointService.save_mode_limit = 2
CheckpointService.saved_eyes = {}


-- # Save mode enums

CHECKPOINT_SAVE_MODE_INACTIVE = 0
CHECKPOINT_SAVE_MODE_INIT = 1
CHECKPOINT_SAVE_MODE_SIZE = 2


-- # Util

function CheckpointService.PointFromIntersect(plane_pos)
	local hit_pos = LocalPlayer():GetEyeTrace().HitPos

	local trace = util.TraceLine {
		start = plane_pos,
		endpos = Vector(hit_pos.x, hit_pos.y, plane_pos.z),
		collisiongroup = COLLISION_GROUP_WORLD
	}

	return trace.HitPos
end

function CheckpointService.DistanceFromIntersect(plane_pos, plane_norm)
	local dist

	local intersect = util.IntersectRayWithPlane(
		CheckpointService.eye_position,
		CheckpointService.eye_normal,
		plane_pos,
		plane_norm
	)

	if intersect then
		dist = math.min(plane_pos:Distance(intersect), 32000)
	else
		dist = 32000
	end

	return dist
end


-- # Saved hit positions

function CheckpointService.SaveCurrentEye()
	CheckpointService.saved_eyes[CheckpointService.save_mode] = {
		eye_position = CheckpointService.eye_position,
		eye_angle = CheckpointService.eye_angle,
		eye_normal = CheckpointService.eye_normal,
		hit_position = LocalPlayer():GetEyeTrace().HitPos
	}
end

function CheckpointService.ClearSavedEyes()
	CheckpointService.saved_eyes = {}
end


-- # Creating

function CheckpointService.SetupCreating(ply, move)
	if IsFirstTimePredicted() and move:KeyPressed(IN_ATTACK) then
		CheckpointService.ClearMarkers()

		if CheckpointService.save_mode == CheckpointService.save_mode_limit then
			CheckpointService.save_mode = 0
		else
			CheckpointService.save_mode = CheckpointService.save_mode + 1
		end

		if CheckpointService.save_mode > 0 then
			CheckpointService.SaveCurrentEye()
		else
			CheckpointService.ClearSavedEyes()
		end

		if CheckpointService.save_mode == 1 then
			local position = CheckpointService.saved_eyes[1].hit_position

			CheckpointService.start_marker = CheckpointHorizontalPlaneMarker.New(position)
			CheckpointService.end_marker = CheckpointHorizontalPlaneMarker.New(position)
			CheckpointService.horizontal_beam = CheckpointMarkerTwoPointBeam.New(position)
		elseif CheckpointService.save_mode == 2 then

		end
	end

	if IsFirstTimePredicted() and move:KeyDown(IN_ATTACK) then
		CheckpointService.holding = true
	else
		CheckpointService.holding = false
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
			local intersect = CheckpointService.PointFromIntersect(CheckpointService.start_marker.position)
			CheckpointService.end_marker.position = intersect
			CheckpointService.horizontal_beam.end_position = intersect
		elseif CheckpointService.save_mode == 2 then

		end
	end
end
hook.Add("PostDrawTranslucentRenderables", "CheckpointService.Think", CheckpointService.Think)