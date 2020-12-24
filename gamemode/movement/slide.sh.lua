SlideService = SlideService or {}


-- # Properties

function SlideService.InitPlayerProperties(ply)
	ply.can_slide = false
	ply.slide_minimum = 0.71
	ply.slide_hover_height = 3
	ply.slide_onground = false
	ply.sliding = false
	ply.surfing = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlideService.InitPlayerProperties",
	SlideService.InitPlayerProperties
)


MAX_CLIP_PLANES = 5

-- # Util

function SlideService.GetNormalDir(vector)
	return Vector(math.ceil(vector.x) + math.floor(vector.x), math.ceil(vector.y) + math.floor(vector.y), math.ceil(vector.z) + math.floor(vector.z))
end

function SlideService.Clip(vel, plane)
	return vel - (plane * vel:Dot(plane))
end

function SlideService.GetGroundTrace(pos, end_pos, ply)
	return util.TraceHull {
		start = pos,
		endpos = end_pos,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs() + Vector(0,0,2),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
end

function SlideService.Trace(ply, vel, pos)
	local pred_vel = vel * FrameTime()
	local hover_height = Vector(0, 0, ply.slide_hover_height)
	local slide = ply.surfing or ply.sliding
	local trace
	local offset = (ply:OnGround() and Vector(0, 0, 1)) or Vector(3, 3, 0)
	local area_trace = util.TraceHull {
		start = pos,
		endpos = pos + (Vector(pred_vel.x, pred_vel.y, math.min(pred_vel.z, 0)) * 2) - hover_height,
		mins = ply:OBBMins() - offset,
		maxs = ply:OBBMaxs() + Vector(offset.x, offset.y, 2),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}

	if area_trace.HitWorld then
		local ramp_normal = SlideService.GetNormalDir((slide and slide.HitNormal) or area_trace.HitNormal)
		local slide_pos = pos - (ramp_normal * hover_height.z)

		if slide then
			trace = SlideService.GetGroundTrace(pos, slide_pos, ply)
			
			if trace.StartSolid and 0 > vel.z then
				trace = SlideService.GetGroundTrace(pos, slide_pos + pred_vel, ply)
			end
		else
			if 0 > vel.z and not ply:OnGround() then
				trace = SlideService.GetGroundTrace(pos, slide_pos + (ramp_normal * Vector(2, 2, -2)) + Vector(0, 0, math.min(pred_vel.z, 0)), ply)
			else
				trace = SlideService.GetGroundTrace(pos, slide_pos - ((ply:OnGround() and hover_height) or Vector()), ply)
			end
		end

		if trace.HitNormal:LengthSqr() ~= 0 then
			local corr_trace_pos = SlideService.GetNormalDir(SlideService.Clip(vel, trace.HitNormal):GetNormalized()) * hover_height.z
			local trace_distance = 3
			local crease_trace

			if 0 > vel.z then
				ramp_normal.x = ramp_normal.y
				ramp_normal.y = ramp_normal.x
			end

			corr_trace_pos = Vector(corr_trace_pos.x * math.abs(ramp_normal.y), corr_trace_pos.y * math.abs(ramp_normal.x), corr_trace_pos.z) * trace_distance
			corr_trace = SlideService.GetGroundTrace(pos, pos - (hover_height * trace_distance) + corr_trace_pos + (ramp_normal * Vector(1,1)), ply)

			if corr_trace.HitNormal ~= trace.HitNormal and corr_trace.HitNormal.z > 0 and 1 > corr_trace.HitNormal.z then
				trace.HitNormal = (corr_trace.HitNormal + trace.HitNormal)/2
			end
			return trace
		end
	end
	return false
end

function SlideService.ShouldSlide(ply, normal, vel, vel_z)
	if 
		(0 > Vector(normal.x, normal.y):Dot(Vector(vel.x, vel.y):GetNormalized()) and
		1 > normal.z and
		normal.z > ply.slide_minimum and
		vel:Dot(vel) > 900 and
		((not ply.sliding and 
		vel_z and vel_z > 150 or vel.z > 150) or 
		ply.sliding))
	then
		return true
	end

	return false
end


function SlideService.ShouldSurf(ply, normal, vel)
	if normal.z > 0 and ply.slide_minimum >= normal.z then
		return true
	end

	return false
end


-- # Sliding

function SlideService.SlideStrafe(move, normal)
	if normal:Dot(AiraccelService.WishDir(ply, move):GetNormalized()) > 0 and move:GetVelocity():Dot(normal) > 0 then
		return true
	end

	return false
end

function SlideService.Slide(ply, move, trace, slide_vel)
	if not ((ply.sliding or ply.surfing) and 0 > (slide_vel.z - move:GetVelocity().z)) then
		ply.sliding = (SlideService.ShouldSlide(ply, trace.HitNormal, slide_vel) and trace) or false
		ply.surfing = (SlideService.ShouldSurf(ply, trace.HitNormal, slide_vel) and trace) or false

		if (move:GetVelocity().z >= 0 and ply.sliding) or ply.surfing then
			local pos = move:GetOrigin()
			
			pos.z = trace.HitPos.z + ply.slide_hover_height
			ply:SetGroundEntity(NULL)
			move:SetVelocity(slide_vel)
			move:SetOrigin(pos)
		end
	end
end

function SlideService.HandleSlideDamage(ply)
	local vel = ply:GetVelocity()
	local pos = ply:GetPos()
	local trace = SlideService.GetGroundTrace(pos, pos + (vel * FrameTime()) - Vector(0, 0, ply.slide_hover_height), ply)
	local slide_vel = SlideService.Clip(vel, trace.HitNormal)

	if (SlideService.ShouldSlide(ply, trace.HitNormal, vel, slide_vel.z) or SlideService.ShouldSurf(ply, trace.HitNormal, vel)) then
		pos.z = trace.HitPos.z + ply.slide_hover_height
		ply.slide_onground = {slide_vel, pos}
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("OnPlayerHitGround", "SlideService.HandleSlideDamage", SlideService.HandleSlideDamage)

function SlideService.SetupSlide(ply, move, cmd)
	local vel = move:GetVelocity()
	local pos = move:GetOrigin()
	local trace, corr_trace = SlideService.Trace(ply, vel, pos, move)
	local slide_vel = Vector()
	local should_slide = false

	if ply.slide_onground then
		move:SetVelocity(ply.slide_onground[1])
		move:SetOrigin(ply.slide_onground[2])
		ply.slide_onground = false
	end

	if trace then
		slide_vel = SlideService.Clip(vel, trace.HitNormal)
		should_slide = SlideService.ShouldSlide(ply, trace.HitNormal, vel, slide_vel.z) or SlideService.ShouldSurf(ply, trace.HitNormal, vel)

		if 1 > trace.HitNormal.z and not trace.StartSolid and should_slide then
			if SlideService.SlideStrafe(move, trace.HitNormal) or ply:OnGround() then
				ply:SetGroundEntity(NULL)
				move:SetVelocity(vel)
				move:SetOrigin(pos + Vector(0, 0, ply.slide_hover_height))
			else
				SlideService.Slide(ply, move, trace, slide_vel)
			end
		end

		if not trace.StartSolid then
			SlopeService.AddSpeed(trace.HitNormal, ply, move)
		end
	end

	if not trace or (trace and not should_slide) then
		ply.sliding = false
		ply.surfing = false
	end
end
hook.Add("SetupMove", "SlideService.SetupSlide", SlideService.SetupSlide)