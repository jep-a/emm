local AirAccelerationPatch = {}


-- # Air Acceleration Patch

function AirAccelerationPatch.SetMoveType(ply, move)
	local zvel = move:GetVelocity().z

	if
		zvel > 0
		and zvel < 140
		and ply:GetMoveType() == MOVETYPE_WALK
	then
		ply:SetMoveType(MOVETYPE_LADDER)
	end
end
hook.Add("SetupMove", "AirAccelerationPatch.SetMoveType", AirAccelerationPatch.SetMoveType)

function AirAccelerationPatch.RemoveLadderSound(sound)
	if (sound.Entity != NULL) then
		local zvel = sound.Entity:GetVelocity().z

		if
			zvel > 0
			and zvel < 140
			and string.StartWith(sound.SoundName, "player/footsteps/ladder")
		then
			  return false
		end
	end
end
hook.Add("EntityEmitSound", "AirAccelerationPatch.RemoveLadderSound", AirAccelerationPatch.RemoveLadderSound)