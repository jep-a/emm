RampFixService = RampFixService or {}
RampFixService.TraceHullMins = Vector(-16, -16, 0)
RampFixService.TraceHullMaxs = Vector(16, 16, 0)
RampFixService.MinRampSlideSpeed = 70 * 70 * 10 * 10
RampFixService.MinSurfRamp = 0.9


-- # Utility

function RampFixService.GetGroundTrace(mv)
	local position = mv:GetOrigin()
	local endPos = Vector(position.x, position.y, position.z - 2)
	return util.TraceHull{
		start = position,
		endpos = endPos,
		mins = RampFixService.TraceHullMins,
		maxs = RampFixService.TraceHullMaxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
	}
end

function RampFixService.ShouldSlide(mv, tr)
	local velocity = mv:GetVelocity()
	local velocity2D = Vector(velocity.x, velocity.y)
	local ramp2D = Vector(tr.HitNormal.x, tr.HitNormal.y)
	ramp2D:Normalize()
	velocity2D.x = velocity2D.x * ramp2D.x
	velocity2D.y = velocity2D.y * ramp2D.y
	return velocity2D.x + velocity2D.y < 0 and velocity2D:Dot(velocity2D) > RampFixService.MinRampSlideSpeed
end

-- # Ramp Fix

function RampFixService.RampFix(ply, mv)
	local tr = RampFixService.GetGroundTrace(mv)
	if (tr.HitWorld and tr.HitNormal.z < 1) then
		if (tr.HitNormal.z < RampFixService.MinSurfRamp or RampFixService.ShouldSlide(mv, tr)) then 
			local velocity = mv:GetVelocity()
			local pos = mv:GetOrigin()
			local backoff = velocity:Dot(tr.HitNormal)
			local change = tr.HitNormal * backoff
			pos.z = tr.HitPos.z + 2
			mv:SetVelocity(velocity - change)
			mv:SetOrigin(pos)
			ply:SetGroundEntity(NULL)
		end
	end
end
hook.Add("SetupMove", "RampFixService.RampFix", RampFixService.RampFix)