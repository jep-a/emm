local AirAccelerationPatch = {}


-- # Air Acceleration Patch

function AirAccelerationPatch.SetMoveType(ply, move)
	local z_vel = move:GetVelocity().z

	if
		z_vel > 0 and
		z_vel < 140 and
		ply:GetMoveType() == MOVETYPE_WALK
	then
		ply:SetMoveType(MOVETYPE_LADDER)
	end
end
hook.Add("SetupMove", "AirAccelerationPatch.SetMoveType",AirAccelerationPatch.SetMoveType)

function AirAccelerationPatch.RemoveLadderSound(sound)
	if sound.Entity then
		local z_vel = sound.Entity:GetVelocity().z

		if
			z_vel > 0 and
			z_vel < 140 and
			string.StartWith(sound.SoundName, "player/footsteps/ladder")
		then
			  return false
		end
	end
end
hook.Add("EntityEmitSound", "AirAccelerationPatch.RemoveLadderSound", AirAccelerationPatch.RemoveLadderSound)