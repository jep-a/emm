RampFixService = RampFixService or {}
RampFixService.TraceHullMins = Vector(-16, -16, 0)
RampFixService.TraceHullMaxs = Vector(16, 16, 0)
RampFixService.MinRampSlideSpeed = 70 * 70 * 10 * 10
RampFixService.MinSurfRamp = 0.9
RampFixService.HoverHeight = 2


-- # Utility

function RampFixService.GetGroundTrace(position, distance)
	local endPos = Vector(position.x, position.y, position.z - distance)
	return util.TraceHull{
		start = position,
		endpos = endPos,
		mins = RampFixService.TraceHullMins,
		maxs = RampFixService.TraceHullMaxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
	}
end

function RampFixService.ShouldSlide(velocity, tr)
	if not tr.HitWorld or tr.HitNormal.z == 1 then
		return false
	end

	if tr.HitNormal.z < RampFixService.MinSurfRamp then
		return true
	end

	local velocity2D = Vector(velocity.x, velocity.y)
	local ramp2D = Vector(tr.HitNormal.x, tr.HitNormal.y)
	ramp2D:Normalize()
	velocity2D.x = velocity2D.x * ramp2D.x
	velocity2D.y = velocity2D.y * ramp2D.y
	return velocity2D.x + velocity2D.y < 0 and velocity2D:Dot(velocity2D) > RampFixService.MinRampSlideSpeed
end


-- # Ramp Fix

function RampFixService.RampFallDamageFix(ply) 
	if RampFixService.ShouldSlide(ply:GetVelocity(), RampFixService.GetGroundTrace(ply:GetLocalPos(), 10)) then
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("OnPlayerHitGround", "RampFixService.RampFallDamageFix", RampFixService.RampFallDamageFix)

function RampFixService.RampFix(ply, mv)
	local pos = mv:GetOrigin()
	local tr = RampFixService.GetGroundTrace(pos, RampFixService.HoverHeight)
	local velocity = mv:GetVelocity()
	if (RampFixService.ShouldSlide(velocity, tr)) then
		local backoff = velocity:Dot(tr.HitNormal)
		local change = tr.HitNormal * backoff
		pos.z = tr.HitPos.z + RampFixService.HoverHeight
		mv:SetVelocity(velocity - change)
		mv:SetOrigin(pos)
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("SetupMove", "RampFixService.RampFix", RampFixService.RampFix)