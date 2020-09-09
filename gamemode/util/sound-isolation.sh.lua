SoundIsolationService = SoundIsolationService or {}
SoundIsolationService.Sounds = SoundIsolationService.Sounds or {}

if CLIENT then
	SettingsService.New("sound_isolation", {
		default = false,
		userinfo = true,
		help = "Toggle weapon sounds"
	})
end

function SoundIsolationService.GetRecipientFilter(shooter)
	local rf = RecipientFilter()

	for _, ply in pairs(player.GetAll()) do
		local concommand = ply:GetInfoNum ("emm_sound_isolation", 1)

		if ply != shooter and (concommand == 1 or (concommand == 0 and MinigameService.IsSharingLobby(ply, ent))) then
			rf:AddPlayer(ply)
		end
	end

	return rf
end

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
					SoundIsolationService.PlaySound(ent, snd.SoundName, snd.Volume, snd.Pitch, snd.SoundLevel, SoundIsolationService.GetRecipientFilter(ent))
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
		SoundIsolationService.PlaySound(frag, "weapons/explode" .. math.random(3, 5) .. ".wav", 1, 100, 140, SoundIsolationService.GetRecipientFilter(frag:GetOwner()))
	end
end 
hook.Add( "EntityRemoved", "SoundIsolationService.FragExplosion", SoundIsolationService.FragExplosion)

function SoundIsolationService.RPGExplosion(missile)
	if missile:GetClass() == "env_explosion" and IsValid(missile:GetOwner()) then
		SoundIsolationService.PlaySound(missile, "weapons/explode" .. math.random(3, 5) .. ".wav", 1, 100, 140, SoundIsolationService.GetRecipientFilter(missile:GetOwner()))
	end
end
hook.Add( "AcceptInput", "SoundIsolationService.RPGExplosion", SoundIsolationService.RPGExplosion)