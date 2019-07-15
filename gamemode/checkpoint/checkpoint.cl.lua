CheckpointService = CheckpointService or {}
CheckpointService.creating = true
CheckpointService.type = "start"
CheckpointService.save_mode = 0
CheckpointService.save_mode_limit = 3
CheckpointService.saved_eyes = {}
CheckpointService.saved_data = {}
CheckpointService.max_size = Vector(4096, 4096, 8192)
CheckpointService.trace_distance = 99999

CheckpointService.marker_render_position = AnimatableValue.New(Vector(0, 0, 0), {
	smooth = true,
	smooth_multiplier = 2
})


-- # Save mode enums

CHECKPOINT_SAVE_MODE_INACTIVE = 0
CHECKPOINT_SAVE_MODE_INIT = 1
CHECKPOINT_SAVE_MODE_SIZE = 2
CHECKPOINT_SAVE_MODE_DEPTH = 3


-- # Util

function CheckpointService.EyeTrace(ply, dist)
	return util.TraceLine {
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:GetAimVector() * (dist or 999999),
		collisiongroup = COLLISION_GROUP_WORLD
	}
end

function CheckpointService.ClampPoint(vec)
	if CheckpointService.saved_eyes[1] then
		local origin = CheckpointService.saved_eyes[1].hit_position
		local size = CheckpointService.max_size
		
		return ClampVector(vec, origin - size, origin + size)
	end
	return vec
end

function CheckpointService.HorizontalPointFromIntersect(plane_pos)
	local point

	local intersect = util.IntersectRayWithPlane(
		CheckpointService.eye_position,
		CheckpointService.eye_normal,
		plane_pos,
		Vector(0, 0, 1)
	)

	local hit_pos = CheckpointService.EyeTrace(LocalPlayer(), CheckpointService.trace_distance).HitPos

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

function CheckpointService.VerticalPointFromIntersect(plane_pos, plane_norm)
	local point

	local rotated_plane_norm = plane_norm
	rotated_plane_norm:Rotate(Angle(0, 90, 0))

	local intersect = util.IntersectRayWithPlane(
		CheckpointService.eye_position,
		CheckpointService.eye_normal,
		plane_pos,
		plane_norm
	)

	local hit_pos = CheckpointService.EyeTrace(LocalPlayer(), CheckpointService.trace_distance).HitPos

	if intersect then
		local intersect_trace = util.TraceLine {
			start = plane_pos,
			endpos = Vector(plane_pos.x, plane_pos.y, intersect.z),
			collisiongroup = COLLISION_GROUP_WORLD
		}

		point = intersect_trace.HitPos
	else
		local trace = util.TraceLine {
			start = plane_pos,
			endpos = Vector(plane_pos.x, plane_pos.y, hit_pos.z),
			collisiongroup = COLLISION_GROUP_WORLD
		}

		point = trace.HitPos
	end

	return point
end


-- # Saved hit positions

function CheckpointService.SaveCurrentEye()
	local hit_pos = CheckpointService.EyeTrace(LocalPlayer(), CheckpointService.trace_distance).HitPos
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
		intersect_position = CheckpointService.ClampPoint(CheckpointService.HorizontalPointFromIntersect(last_hit_pos)),
	}

	CheckpointService.saved_eyes[CheckpointService.save_mode] = eye

	return eye
end

function CheckpointService.ClearSavedEyes()
	CheckpointService.saved_eyes = {}
end


-- # Creating

function CheckpointService.Save()
	local ply = LocalPlayer()
	if CheckpointService.save_mode == 3 then
		local angle = CheckpointService.saved_data.angle
		angle:Rotate(Angle(0, 90, 0))
		CheckpointService.saved_data.depth = ClampVector(CheckpointService.EyeTrace(LocalPlayer(), CheckpointService.trace_distance).HitPos - CheckpointService.saved_data.pos, (-CheckpointService.max_size), CheckpointService.max_size):Dot(angle)
		--CheckpointService.saved_data.depth = angle * ClampVector(CheckpointService.EyeTrace(LocalPlayer(), CheckpointService.trace_distance).HitPos - CheckpointService.saved_data.pos, (-CheckpointService.max_size), CheckpointService.max_size):Dot(angle)
	end

	net.Start "Race_CreateEnt"
		net.WriteTable(CheckpointService.saved_data)
		net.WriteInt(ply.lobby.id, 8)
		net.WriteString(CheckpointService.type)
	net.SendToServer()
end

function CheckpointService.ProgressMode()
	CheckpointService.ClearMarkers()

	if CheckpointService.save_mode == CheckpointService.save_mode_limit then
		CheckpointService.Save()
		CheckpointService.save_mode = 0
	else
		CheckpointService.save_mode = CheckpointService.save_mode + 1
		CheckpointService.start_time = CurTime()
	end

	if CheckpointService.save_mode > 0 then
		local eye = CheckpointService.SaveCurrentEye()

		CheckpointService.marker_render_position:SnapTo(eye.hit_position)
	else
		CheckpointService.ClearSavedEyes()
	end

	if CheckpointService.save_mode == 1 then
		local position = CheckpointService.saved_eyes[1].hit_position

		CheckpointService.start_marker = CheckpointHorizontalPlaneMarker.New(position)
		CheckpointService.end_marker = CheckpointHorizontalPlaneMarker.New(position)
		CheckpointService.horizontal_beam = CheckpointMarkerTwoPointBeam.New()

		CheckpointService.saved_data.pos = position
	elseif CheckpointService.save_mode == 2 then
		local xy_start_position = CheckpointService.saved_eyes[1].hit_position
		local xy_end_position = CheckpointService.saved_eyes[2].intersect_position

		CheckpointService.horizontal_beam_a = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_start_position,
			end_position = xy_end_position
		}

		CheckpointService.horizontal_beam_b = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_start_position,
			end_position = xy_end_position
		}

		CheckpointService.vertical_beam_a = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_start_position
		}

		CheckpointService.vertical_beam_b = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_end_position
		}

		CheckpointService.saved_data.width = math.abs((xy_start_position - xy_end_position):Length2D())
		CheckpointService.saved_data.angle = (xy_start_position - xy_end_position):GetNormalized()
	elseif CheckpointService.save_mode == 3 then
		local xy_start_position = CheckpointService.saved_eyes[1].hit_position
		local xy_end_position = CheckpointService.saved_eyes[2].intersect_position

		local z_end_point_a = CheckpointService.vertical_beam_a.end_position
		local z_end_point_b = CheckpointService.vertical_beam_b.end_position

		CheckpointService.horizontal_beam_a = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_start_position,
			end_position = xy_end_position
		}

		CheckpointService.horizontal_beam_b = CheckpointMarkerTwoPointBeam.New{
			start_position = z_end_point_a,
			end_position = z_end_point_b
		}

		CheckpointService.horizontal_beam_c = CheckpointMarkerTwoPointBeam.New{
			start_position = z_end_point_a
		}

		CheckpointService.horizontal_beam_d = CheckpointMarkerTwoPointBeam.New{
			start_position = z_end_point_b
		}

		CheckpointService.horizontal_beam_e = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_start_position
		}

		CheckpointService.horizontal_beam_f = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_end_position
		}

		CheckpointService.vertical_beam_a = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_start_position,
			end_position = z_end_point_a
		}

		CheckpointService.vertical_beam_b = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_end_position,
			end_position = z_end_point_b
		}

		CheckpointService.vertical_beam_c = CheckpointMarkerTwoPointBeam.New{
			start_position = z_end_point_a,
			end_position = z_end_point_b
		}

		CheckpointService.vertical_beam_d = CheckpointMarkerTwoPointBeam.New{
			start_position = xy_end_position,
			end_position = z_end_point_b
		}

		CheckpointService.horizontal_beam_g = CheckpointMarkerTwoPointBeam.New()
		CheckpointService.horizontal_beam_h = CheckpointMarkerTwoPointBeam.New()
		CheckpointService.vertical_beam_e = CheckpointMarkerTwoPointBeam.New()
		CheckpointService.vertical_beam_f = CheckpointMarkerTwoPointBeam.New()

		CheckpointService.saved_data.height = z_end_point_a.z - xy_start_position.z
	end

end

function CheckpointService.SetupCreating(ply, move)
	if IsFirstTimePredicted() then
		if ply.lobby then
			if move:KeyDown(IN_WALK) then
				CheckpointService.trace_distance = 10
			else
				CheckpointService.trace_distance = 999999
			end

			if (move:KeyPressed(IN_ATTACK) or 
				(move:KeyReleased(IN_ATTACK) and CheckpointService.save_mode >= 1 and CurTime() > (CheckpointService.start_time + 0.25))) and 
				CheckpointService.creating and
				ply.lobby.host == ply and
				ply.lobby.prototype.name == "Race"
			then
				if CheckpointService.type == "start" then
					local tr = util.TraceLine{
						start = ply:EyePos(),
						endpos = ply:EyePos() + ply:GetAimVector() * 500,
						mask = CONTENTS_SOLID
					}

					net.Start "Race_CreateEnt"
						net.WriteTable{
							pos = tr.HitPos,
							width = 17.5
						}
						net.WriteInt(ply.lobby.id, 8)
						net.WriteString(CheckpointService.type)
					net.SendToServer()
				else
					CheckpointService.ProgressMode()
				end
			end
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
			CheckpointService.marker_render_position.current = CheckpointService.ClampPoint(CheckpointService.HorizontalPointFromIntersect(CheckpointService.start_marker.position))
			CheckpointService.end_marker.position = CheckpointService.marker_render_position.smooth
			CheckpointService.horizontal_beam.end_position = CheckpointService.marker_render_position.smooth
		elseif CheckpointService.save_mode == 2 then
			local xy_start_position = CheckpointService.saved_eyes[1].hit_position
			local xy_end_position = CheckpointService.saved_eyes[2].intersect_position

			local z_start_point = CheckpointService.ClampPoint(CheckpointService.VerticalPointFromIntersect(xy_start_position, xy_start_position - xy_end_position))
			local z_end_point = CheckpointService.ClampPoint(CheckpointService.VerticalPointFromIntersect(xy_end_position, xy_start_position - xy_end_position))

			CheckpointService.vertical_beam_a.end_position = Vector(xy_start_position.x, xy_start_position.y, z_start_point.z)
			CheckpointService.vertical_beam_b.end_position = Vector(xy_end_position.x, xy_end_position.y, z_end_point.z)
			CheckpointService.horizontal_beam_b.start_position = CheckpointService.vertical_beam_a.end_position
			CheckpointService.horizontal_beam_b.end_position = CheckpointService.vertical_beam_b.end_position
		elseif CheckpointService.save_mode == 3 then
			local xy_start_position = CheckpointService.saved_eyes[1].hit_position
			local xy_end_position = CheckpointService.saved_eyes[2].intersect_position

			local z_end_point_a = CheckpointService.vertical_beam_a.end_position
			local z_end_point_b = CheckpointService.vertical_beam_b.end_position

			local depth = ClampVector(CheckpointService.EyeTrace(LocalPlayer(), CheckpointService.trace_distance).HitPos - CheckpointService.saved_data.pos, -CheckpointService.max_size, CheckpointService.max_size)
			local checkpoint_angle =  (xy_start_position - xy_end_position):GetNormalized()

			checkpoint_angle:Rotate(Angle(0, 90, 0))
			depth = checkpoint_angle * depth:Dot(checkpoint_angle)
			
			CheckpointService.vertical_beam_e.start_position = xy_start_position + depth
			CheckpointService.vertical_beam_f.start_position = xy_end_position + depth
			CheckpointService.vertical_beam_e.end_position = z_end_point_a + depth
			CheckpointService.vertical_beam_f.end_position = z_end_point_b + depth
			CheckpointService.horizontal_beam_c.end_position = z_end_point_a + depth
			CheckpointService.horizontal_beam_d.end_position = z_end_point_b + depth
			CheckpointService.horizontal_beam_e.end_position = xy_start_position + depth
			CheckpointService.horizontal_beam_f.end_position = xy_end_position + depth
			CheckpointService.horizontal_beam_g.start_position = z_end_point_a + depth
			CheckpointService.horizontal_beam_g.end_position = z_end_point_b + depth
			CheckpointService.horizontal_beam_h.start_position = xy_start_position + depth
			CheckpointService.horizontal_beam_h.end_position = xy_end_position + depth
		end
	end
end
hook.Add("PostDrawTranslucentRenderables", "CheckpointService.Think", CheckpointService.Think)