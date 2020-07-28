SoundIsolationService = SoundIsolationService or {}
SoundIsolationService.Sounds = SoundIsolationService.Sounds or {}

function SoundIsolationService.PlaySound(ent, name, volume, pitch, level, filter)
	local sound = CreateSound(ent, name, filter)
            
    if SoundIsolationService.Sounds[name] then
        SoundIsolationService.Sounds[name]:Stop()
    end

	sound:SetSoundLevel(level)
    sound:SetDSP(60)
    SoundIsolationService.Sounds[name] = sound
    sound:PlayEx(volume, pitch)
end

function SoundIsolationService.WeaponSound(snd)
	local ent = snd.Entity

	if IsValid(ent:GetOwner()) then
		ent = ent:GetOwner()
    end
    
	if SERVER and IsPlayer(ent) and snd.DSP ~= 60 then
		if IsValid(ent:GetActiveWeapon()) then
			if ((table.HasValue(MINIGAME_WEAPONS, ent:GetActiveWeapon():GetKeyValues().classname) or snd.Channel == CHAN_WEAPON) and snd.OriginalSoundName:Split("_")[1] == "Weapon") then
				if ent.lobby then 
					local filter = RecipientFilter()

					for _, ply in pairs(ent.lobby.players) do
						if ply != ent then
							filter:AddPlayer(ply)
						end
					end
					
					SoundIsolationService.PlaySound(ent, snd.SoundName, snd.Volume, snd.Pitch, snd.SoundLevel, filter)
                end
                
				return false
			end
		end
	elseif CLIENT and snd.OriginalSoundName == "BaseExplosionEffect.Sound" then
		return false
	end
end
hook.Add( "EntityEmitSound", "SoundIsolationService.WeaponSound", SoundIsolationService.WeaponSound)

function SoundIsolationService.FragExplosion(frag)
	if frag:GetClass() == "npc_grenade_frag" and IsValid(frag:GetOwner()) and SERVER then
		local filter = RecipientFilter()

		for _, ply in pairs(frag:GetOwner().lobby.players) do
			filter:AddPlayer(ply)
		end

		SoundIsolationService.PlaySound(frag, "weapons/explode" .. math.random(3, 5) .. ".wav", 1, 100, 140, filter)
	end
end 
hook.Add( "EntityRemoved", "SoundIsolationService.FragExplosion", SoundIsolationService.FragExplosion)

function SoundIsolationService.RPGExplosion(missile)
	if missile:GetClass() == "env_explosion" and IsValid(missile:GetOwner()) then
		local filter = RecipientFilter()

		for _, ply in pairs(missile:GetOwner().lobby.players) do
				filter:AddPlayer(ply)
		end

		SoundIsolationService.PlaySound(missile, "weapons/explode" .. math.random(3, 5) .. ".wav", 1, 100, 140, filter)
	end
end
hook.Add( "AcceptInput", "SoundIsolationService.RPGExplosion", SoundIsolationService.RPGExplosion)