-- # Spawning

hook.Add("PlayerInitialSpawn", "EMM.PlayerInitialSpawn", function (ply)
	hook.Run("InitPlayerProperties", ply)
	NetService.Send("PlayerInitialSpawn", ply)
end)

hook.Add("PlayerSpawn", "EMM.PlayerSpawn", function (ply)
	hook.Run("PlayerProperties", ply)
	ply:SetupCoreProperties()
	ply:SetupModel()

	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PlayerSpawn", ply)
		MinigameService.CallHook(ply.lobby, "PlayerProperties", ply)
	end

	NetService.Send("PlayerSpawn", ply)
end)


-- # Disconnecting

hook.Add("PlayerDisconnected", "NetworkPlayerDisconnected", function (ply)
	NetService.Send("PlayerDisconnected", ply)
end)


-- # Properties

hook.Add("InitPlayerProperties", "InitCorePlayerProperties", function (ply)
	ply.max_health = 100
	ply.can_health_regen = true
	ply.health_regen_step = 1
	ply.run_speed = 400
	ply.jump_power = 220
	ply.fall_damage_mult = 0.0563
	ply.death_cooldown = 2
	ply.last_death_time = 0
end)


-- # Death

function GM:PlayerDeath(ply, infl, att)
	local att_valid = IsValid(att)
	local infl_valid = IsValid(infl)

	if att_valid and att:GetClass() == "trigger_hurt" then
		att = ply
	end

	if att_valid and att:IsVehicle() and IsValid(att:GetDriver()) then
		att = att:GetDriver()
	end

	if not infl_valid and att_valid then
		infl = att
	end

	if infl_valid and infl == att and (infl:IsPlayer() or infl:IsNPC()) then
		infl = infl:GetActiveWeapon()
	
		if not infl_valid then
			infl = att
		end
	end
end

function GM:DoPlayerDeath(ply, att, dmg)
	ply:CreateRagdoll()
end

hook.Add("DoPlayerDeath", "EMM.PrePlayerDeath", function (ply, att, dmg)
	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PrePlayerDeath", ply, att, dmg)
	end

	hook.Run("PrePlayerDeath", ply, att, dmg)
	NetService.Send("PrePlayerDeath", ply, att)
end)

hook.Add("PlayerDeath", "EMM.PlayerDeath", function (ply, infl, att)
	ply:FreezeMovement()

	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PlayerDeath", ply, infl, att)
	end

	NetService.Send("PlayerDeath", ply, infl, att)
end)

local function SetDeathTime(ply)
	ply.last_death_time = CurTime()
end
hook.Add("PlayerDeath", "DeathTime", SetDeathTime)
hook.Add("PlayerSilentDeath", "DeathTime", SetDeathTime)

hook.Add("PostPlayerDeath", "NetworkPostPlayerDeath", function (ply)
	NetService.Send("PostPlayerDeath", ply)
end)

hook.Add("PlayerDeathThink", "Respawn", function (ply)
	local cur_time = CurTime()
	
	local allow_spawn

	if cur_time > (ply.last_death_time + ply.death_cooldown) then
		allow_spawn = true

		if
			ply:IsBot() or
			ply:KeyPressed(IN_FORWARD) or
			ply:KeyPressed(IN_MOVELEFT) or
			ply:KeyPressed(IN_BACK) or
			ply:KeyPressed(IN_MOVERIGHT) or
			ply:KeyPressed(IN_JUMP) or
			cur_time > (ply.last_death_time + 5)
		then
			ply:Spawn()
		end
	else
		allow_spawn = false
	end

	return allow_spawn
end)


-- # Misc

hook.Add("GetFallDamage", "Fall", function (ply, speed)
	local speed = (speed - 580) * ply.fall_damage_mult
	local view_punch = speed/20

	ply:ViewPunch(Angle(math.random(-view_punch, view_punch), math.random(-view_punch, view_punch), 0))

	return speed
end)

timer.Create("PlayerHealthRegeneration", 1, 0, function ()
	for _, ply in pairs(player.GetAll()) do
		if ply:Alive() and ply.can_health_regen then
			ply:SetHealth(math.Clamp(ply:Health() + ply.health_regen_step, 0, ply.max_health))
		end
	end
end)