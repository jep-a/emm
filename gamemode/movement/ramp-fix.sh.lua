RampFixService = RampFixService or {}
RampFixService.TraceHullMins = Vector(-16, -16, 0)
RampFixService.TraceHullMaxs = Vector(16, 16, 0)
RampFixService.MinRampSlideSpeed = 70 * 70 * 10


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


-- # Ramp Fix

function RampFixService.RampFix(ply, mv)
	local tr = RampFixService.GetGroundTrace(mv)

	if (tr.HitWorld and tr.HitNormal.z < 1) then
		local velocity = mv:GetVelocity()
		local velocity2D = Vector(velocity.x, velocity.y)
		local pos = mv:GetOrigin()
		local backoff = velocity:Dot(tr.HitNormal)

		if (velocity2D:Dot(tr.HitNormal) < 0 and velocity2D:Dot(velocity2D) > RampFixService.MinRampSlideSpeed) then 
			local result = tr.HitNormal * backoff
			pos.z = tr.HitPos.z + 2
			mv:SetVelocity(velocity - result)
			mv:SetOrigin(pos)
			ply:SetGroundEntity(NULL)
		end
	end
end
hook.Add("SetupMove", "RampFixService.RampFix", RampFixService.RampFix)