SlideService = SlideService or {}


-- # Properties

function SlideService.InitPlayerProperties(ply)
	ply.can_slide = false
	ply.slide_minimum = 0.71
	ply.slide_hover_height = 2
	ply.old_slide_velocity = Vector(0, 0, 0)
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlideService.InitPlayerProperties",
	SlideService.InitPlayerProperties
)


-- # Util

function SlideService.Clip(vel, plane)
	return vel - (plane * vel:Dot(plane))
end

function SlideService.GetGroundTrace(pos, end_pos, ply)
	return util.TraceHull {
		start = pos,
		endpos = end_pos,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs(),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
end

function SlideService.ShouldSlide(vel, trace, surf_min, can_slide)
	local should_slide

	if
		trace.HitWorld and
		trace.HitNormal.z > surf_min and
		1 > trace.HitNormal.z
	then
		should_slide = vel.z > 130 or (can_slide and (-130 > vel.z))
	elseif
		trace.HitWorld and
		surf_min >= trace.HitNormal.z and
		trace.HitNormal.z > 0
	then
		should_slide = true
	else
		should_slide = false
	end

	return should_slide
end

function SlideService.HandleSlideDamage(ply)
	local vel = ply:GetVelocity()
	local pred_pos = ply:GetPos() + (vel * FrameTime())
	local trace = SlideService.GetGroundTrace(pred_pos, pred_pos - Vector(0, 0, 10), ply)

	if SlideService.ShouldSlide(SlideService.Clip(vel, trace.HitNormal), trace, ply.slide_minimum, ply.can_slide) then
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("OnPlayerHitGround", "SlideService.HandleSlideDamage", SlideService.HandleSlideDamage)


-- # Sliding

function SlideService.SetupSlide(ply, move)
	local frame_time = FrameTime()
	local origin = move:GetOrigin()
	local original_vel = move:GetVelocity()
	local next_vel = original_vel * frame_time

	local trace_z = (origin.z - ply.slide_hover_height) + math.min(next_vel.z, 0)

	local init_trace = SlideService.GetGroundTrace(origin, Vector(
		origin.x,
		origin.y,
		trace_z
	), ply)

	local slide_vel = SlideService.Clip(original_vel, init_trace.HitNormal)

	local pred_trace = SlideService.GetGroundTrace(origin, Vector(origin.x + next_vel.x, origin.y + next_vel.y, trace_z), ply)
	local pred_slide_vel = SlideService.Clip(original_vel, pred_trace.HitNormal)

	local old_slide_vel = ply.old_slide_velocity

	if old_slide_vel and not pred_trace.HitWorld then
		pred_trace = SlideService.GetGroundTrace(origin, Vector(
			origin.x + (old_slide_vel.x * frame_time),
			origin.y + (old_slide_vel.y * frame_time),
			(origin.z - ply.slide_hover_height) + math.min(old_slide_vel.z * frame_time, 0)
		), ply)

		pred_slide_vel = SlideService.Clip(ply.old_slide_velocity, pred_trace.HitNormal)
	end

	if SlideService.ShouldSlide(pred_slide_vel, pred_trace, ply.slide_minimum, ply.can_slide) then
		local vel

		if init_trace.HitWorld then
			origin.z = init_trace.HitPos.z + ply.slide_hover_height

			if init_trace.HitNormal == pred_trace.HitNormal then
				vel = slide_vel
			else
				vel = pred_slide_vel
			end
		else
			vel = pred_slide_vel
			origin.z = pred_trace.HitPos.z + ply.slide_hover_height
		end

		ply.old_slide_velocity = vel

		move:SetVelocity(vel)
		move:SetOrigin(origin)
		ply:SetGroundEntity(NULL)
	elseif SlideService.ShouldSlide(slide_vel, init_trace, ply.slide_minimum, ply.can_slide) then
		local vel = slide_vel

		origin.z = init_trace.HitPos.z + ply.slide_hover_height
		ply.old_slide_velocity = vel

		move:SetVelocity(vel)
		move:SetOrigin(origin)
		ply:SetGroundEntity(NULL)
	else
		ply.old_slide_velocity = nil
	end
end
hook.Add("SetupMove", "SlideService.SetupSlide", SlideService.SetupSlide)
