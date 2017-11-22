SlideService = SlideService or {}
SlideService.TraceHullMins = Vector(-16, -16, 0)
SlideService.TraceHullMaxs = Vector(16, 16, 0)
SlideService.MinRampSlideSpeedSqr = 700 * 700
SlideService.MinSurfRamp = 0.71
SlideService.HoverHeight = 2


-- # Utility

function SlideService.Clip(velocity, plane)
	return velocity - plane * velocity:Dot(plane)
end

function SlideService.GetGroundTrace(position, distance)
	local endPos = Vector(position.x, position.y, position.z - distance)
	return util.TraceHull{
		start = position,
		endpos = endPos,
		mins = SlideService.TraceHullMins,
		maxs = SlideService.TraceHullMaxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
	}
end

function SlideService.ShouldSlide(velocity, tr)
	if not tr.HitWorld or tr.HitNormal.z == 1 then
		return false
	end

	if tr.HitNormal.z < SlideService.MinSurfRamp then
		return true
	end

	return velocity.z > 130
end


-- # Sliding

function SlideService.RampFallDamageFix(ply) 
	local tr = SlideService.GetGroundTrace(ply:GetLocalPos(), 10)
	
	if SlideService.ShouldSlide(SlideService.Clip(ply:GetVelocity(), tr.HitNormal), tr) then
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("OnPlayerHitGround", "SlideService.RampFallDamageFix", SlideService.RampFallDamageFix)

function SlideService.RampFix(ply, mv)
	local pos = mv:GetOrigin()
	local tr = SlideService.GetGroundTrace(pos, SlideService.HoverHeight)
	local velocity = SlideService.Clip(mv:GetVelocity(), tr.HitNormal)
	if (SlideService.ShouldSlide(velocity, tr)) then
		if (IsFirstTimePredicted()) then print("activated") end
		pos.z = tr.HitPos.z + SlideService.HoverHeight
		mv:SetVelocity(velocity)
		mv:SetOrigin(pos)
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("SetupMove", "SlideService.RampFix", SlideService.RampFix)