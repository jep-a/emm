local Move = FindMetaTable( "CMoveData" )
-- Updated, feels way more like the normal one. 
function PhysicsClipVelocity( inv, normal, out, overbounce )
	local	backoff
	local	change = 0
	local	angle
	local	i

	local STOP_EPSILON = 0.1

	angle = normal.z

	backoff = inv:Dot( normal ) * overbounce
	for i = 1 , 3 do
		change = normal[i] * backoff
		if i == 3 then

			out[3] = inv[3] - change
		else
			out[i] =inv[i] -change --+((normal[i] * ( (inv[i])*normal[i] ))/20)
		end
		if out[i] > -STOP_EPSILON and out[i] < STOP_EPSILON then
			out[i] = 0
		end
	end
end

function Move:resolveFlyCollisionSlide( trace, vecVelocity, ply )
	if IsFirstTimePredicted() then
	-- Original velocity.
	local mv = self
	local origVel = vecVelocity

	-- The speed required for sliding on ramps
	local slideVel = 500 -- 900

	-- A backoff of 1.0 is a slide.
	-- Slightly above 1 keeps keeps the player slightly higher than normally and lets us "evade" bad ramp clipping
	local flBackOff = 1.1
	local vecAbsVelocity = Vector()

	PhysicsClipVelocity( vecVelocity, trace.HitNormal, vecAbsVelocity, flBackOff )

	-- Only enable sliding up ramps
	-- Removing this kinda enables surfing on any ramp size.
	--print(vecVelocity:DotProduct( trace.HitNormal ))

	-- Prevents sliding at a realy wide angle and sliding down ramps, might want to make an adjustment depending on 2D velocity on ramp
	if (vecAbsVelocity:GetNormalized()-trace.HitNormal).z < -0.90 then 
		mv:SetVelocity( origVel )
		return
	end
	
	if ( trace.HitNormal.z <= 0.7 ) then -- Is surfing
		return
	elseif ( trace.HitNormal.z == 1 ) then
		mv:SetVelocity( origVel )
		return
	end


	 -- Get the total velocity (player + conveyors, etc.)
	 vecVelocity = vecAbsVelocity + ply:GetBaseVelocity()
	 local flSpeedSqr = vecVelocity:Length()
	 -- Verify that we have an entity.
	 local pEntity = trace.Entity

	 mv:SetVelocity( vecAbsVelocity )

	 if ( flSpeedSqr < slideVel ) then
		 if ply:OnGround() then
			 ply:SetGroundEntity( pEntity )
		 end

		 -- Reset velocities.
			mv:SetVelocity( origVel );
	 else
		 if ( trace.HitNormal.z < 1 ) then
			 -- Just incase we touch the ground we don't want to apply any friction yet.
			 ply:SetGroundEntity( NULL )
		 end
	 end
 end
end

function rampSlide(ply, mv)
	local Pos = ply:GetPos()
	local Mins = ply:OBBMins()
	local Maxs = ply:OBBMaxs()
	local endPos = Pos *1
	local vel = mv:GetVelocity()
endPos.z = endPos.z -15 -- trace a bit further than feet

	local tr = util.TraceHull{
		start = Pos,
		endpos = endPos,
		mins = Mins,
		maxs = Maxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
		filter = function(e1, e2)
			return not e1:IsPlayer()
		end
	}

	if tr.HitWorld and tr.HitNormal.z <1 then
		mv:resolveFlyCollisionSlide( tr, vel, ply )

	end

end
hook.Add("PlayerTick", "Rampslide Fix", rampSlide)