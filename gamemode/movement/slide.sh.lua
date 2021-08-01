SlideService = SlideService or {}


-- # Properties

function SlideService.InitPlayerProperties(ply)
	ply.can_surf = true
	ply.can_slide = true
	ply.slide_minimum = 0.71
	ply.slide_minimum_vel = 900
	ply.slide_hover_height = 4
	ply.slide_hitground = false
	ply.sliding = false
	ply.surfing = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlideService.InitPlayerProperties",
	SlideService.InitPlayerProperties
)

SLIDE_MAX_TRACES = 4


-- # Util

function SlideService.Clip(vel, plane)
	return vel - (plane * vel:Dot(plane))
end

function SlideService.MovingTowardsPlane(vel, plane)
	return 0 > Vector(vel.x, vel.y):Dot(Vector(plane.x, plane.y))
end

function SlideService.GetGroundTrace(ply, pos, end_pos)
	return util.TraceHull {
		start = pos,
		endpos = end_pos,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs() + Vector(0,0,2),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
end

function SlideService.ShouldSlide(ply, normal, vel)
	if 
		(SlideService.MovingTowardsPlane(vel, normal) and
		1 > normal.z and
		normal.z > ply.slide_minimum and
		vel:Dot(vel) > ply.slide_minimum_vel and
		((not ply.sliding and 
		SlideService.Clip(vel, normal).z > 150 or vel.z > 150) or 
		ply.sliding)) and
		ply.can_slide
	then
		return true
	end

	return false
end


function SlideService.ShouldSurf(ply, normal, vel)
	if normal.z > 0 and ply.slide_minimum >= normal.z and ply.can_surf then
		return true
	end

	return false
end

function SlideService.SlideStrafe(move, vel, normal)
	return normal:Dot(AiraccelService.WishDir(ply, move:GetMoveAngles():Forward(), move:GetForwardSpeed(), move:GetSideSpeed()):GetNormalized()) > 0 and vel:Dot(normal) > 0
end

function SlideService.Trace(ply, vel, pos)
	local pred_vel = vel * FrameTime()
	local slide = ply.surfing or ply.sliding
	local hover_height = Vector(0, 0, ply.slide_hover_height)
	local obb_offset = (ply:OnGround() and Vector(0, 0, 1)) or Vector()
	local area_trace = util.TraceHull {
		start = pos,
		endpos = pos + (pred_vel * 3) - (hover_height * 5),
		mins = ply:OBBMins() - obb_offset,
		maxs = ply:OBBMaxs() + obb_offset + Vector(0, 0, 2),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
	local ramp_normal = (area_trace.HitWorld and ((slide and slide.HitNormal) or area_trace.HitNormal)) or Vector()
	local slide_pos = pos - (ramp_normal * 0.025) - hover_height
	local trace, normal_length, wall_trace
	
	if slide then
		trace = SlideService.GetGroundTrace(ply, pos, slide_pos - hover_height)

		if slide.is_init then
			trace.HitPos.z = slide.HitPos.z
			slide.is_init = false
		else
			if ((ramp_normal:LengthSqr() < trace.HitNormal:LengthSqr()) or (trace.HitNormal.x ~= ramp_normal.x and trace.HitNormal.y ~= ramp_normal.y)) then
				trace = false
			end
		end
	else
		if 0 > vel.z and not ply:OnGround() then
			if SlideService.MovingTowardsPlane(vel, ramp_normal) or ramp_normal:LengthSqr() == 0 then
				slide_pos = slide_pos + pred_vel
			else
				slide_pos = slide_pos + Vector(0, 0, pred_vel.z)
			end
		end

		trace = SlideService.GetGroundTrace(ply, pos, slide_pos)
		trace.is_init = true
		wall_trace = util.TraceHull {
			start = area_trace.HitPos,
			endpos = area_trace.HitPos - ramp_normal,
			mins = ply:OBBMins(),
			maxs = ply:OBBMaxs(),
			mask = MASK_PLAYERSOLID_BRUSHONLY
		}
		wall_trace.HitNormal.z = 0

		if wall_trace.HitNormal:LengthSqr()  == 1 then
			trace.HitNormal = ramp_normal
		end
	end
	
	if trace then
		local normal_length = trace.HitNormal:LengthSqr()

		if normal_length == 0 or normal_length == 1 then
			trace = false
		end
	end

	return trace
end


-- # Sliding

function SlideService.Slide(ply, move, trace, slide_vel)
	local slide = ply.sliding or ply.surfing
	local pos = move:GetOrigin()

	if not (ply.sliding or ply.surfing) or trace.HitNormal.z ~= slide.HitNormal.z then
		ply.sliding = (SlideService.ShouldSlide(ply, trace.HitNormal, slide_vel) and trace) or false
		ply.surfing = (SlideService.ShouldSurf(ply, trace.HitNormal, slide_vel) and trace) or false
	end

	if ply.sliding or ply.surfing then
		pos = pos + (trace.HitNormal * 0.015)
		pos.z = trace.HitPos.z + ply.slide_hover_height
		ply:SetGroundEntity(NULL)
		move:SetVelocity(slide_vel)
		move:SetOrigin(pos)
	end
end

function SlideService.HandleSlideDamage(ply)
	local vel = ply:GetVelocity()
	local pos = ply:GetPos()
	local trace = SlideService.Trace(ply, vel, pos)

	if trace then
		if SlideService.ShouldSlide(ply, trace.HitNormal, vel) or SlideService.ShouldSurf(ply, trace.HitNormal, vel) then
			pos.z = trace.HitPos.z + ply.slide_hover_height
			ply.slide_hitground = {SlideService.Clip(vel, trace.HitNormal), pos}
			ply:SetGroundEntity(NULL)
		end
	end
end
hook.Add("OnPlayerHitGround", "SlideService.HandleSlideDamage", SlideService.HandleSlideDamage)


function SlideService.SetupSlide(ply, move, cmd)
	local normals = {}
	local trace_count = 0
	local normal
	local original_velocity = move:GetVelocity()
	local original_position = move:GetOrigin()

	if ply.can_slide or ply.can_surf then
		if ply.slide_onground then
			move:SetVelocity(ply.slide_onground[1])
			move:SetOrigin(ply.slide_onground[2])
			ply.slide_onground = false
		end

		for curr_trace = 1, SLIDE_MAX_TRACES do
			local vel = move:GetVelocity()
			local pos = move:GetOrigin()
			local trace = SlideService.Trace(ply, vel, pos)

			if trace then
				normal = trace.HitNormal
				trace.should_slide = SlideService.ShouldSlide(ply, normal, vel) or SlideService.ShouldSurf(ply, normal, vel)

				if trace_count > 1 then
					local is_same_plane = false

					for prev_trace = 1, trace_count do
						if curr_trace > prev_trace and (normals[prev_trace] == normal and normal.z > 0 and 1 > normal.z) then
							is_same_plane = true
							break
						end
					end

					if is_same_plane then
						break
					end
				end

				if normal.z > 0 and 1 > normal.z and not trace.StartSolid and trace.should_slide then
					local slide = ply.sliding or ply.surfing

					trace_count = trace_count + 1
					normals[trace_count] = normal

					if SlideService.SlideStrafe(move, move:GetVelocity(), normal) or (ply:OnGround() and vel:Dot(normal) > 0) then
						ply:SetGroundEntity(NULL)
						move:SetVelocity(vel)
						move:SetOrigin(pos)
						trace.should_slide = false
						break
					else
						SlideService.Slide(ply, move, trace, SlideService.Clip(vel, normal))
					end
				end
			end

			if not trace or (trace and not trace.should_slide) then
				ply.sliding = false
				ply.surfing = false
			end
		end
	end
end
hook.Add("SetupMove", "SlideService.SetupSlide", SlideService.SetupSlide)