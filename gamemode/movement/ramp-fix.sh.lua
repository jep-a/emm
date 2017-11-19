RampFixService = RampFixService or {}
RampFixService.TraceHullMins = Vector(-16, -16, 0)
RampFixService.TraceHullMaxs = Vector(16, 16, 0)


-- # Utility

function RampFixService.GetGroundTrace(mv)
	local position = mv:GetOrigin()
	local endPos = Vector(position.x, position.y, position.z - 1)
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
	local velocity = mv:GetVelocity()
	
	if tr.HitWorld and tr.HitNormal.z <1 then
		ply.on_ramp = true
		ply.last_ramp = Vector(tr.HitNormal.x, tr.HitNormal.y, 0)
	else
		if not (velocity.x == 0 and velocity.y == 0) and RampFixService.OnRamp(ply) and Vector(velocity.x, velocity.y, 0):Dot(RampFixService.LastRamp(ply)) == 0 then
			if IsFirstTimePredicted() then print("ramp glitch fixed") end
			local position = mv:GetOrigin()
			position.z = position.z + 1
			mv:SetOrigin(position)
			mv:SetVelocity(RampFixService.LastRampVelocity(ply))
		end
		ply.on_ramp = false
	end

	ply.last_velocity = velocity
end
hook.Add("SetupMove", "RampFixService.RampFix", RampFixService.RampFix)