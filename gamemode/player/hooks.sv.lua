-- # Spawning

util.AddNetworkString "PlayerInitialSpawn"
hook.Add("PlayerInitialSpawn", "EMM.PlayerInitialSpawn", function (ply)
	hook.Run("InitPlayerProperties", ply)
	net.Start "PlayerInitialSpawn"
	net.WriteUInt(ply:EntIndex(), 16)
	net.Broadcast()
end)

util.AddNetworkString "PlayerSpawn"
hook.Add("PlayerSpawn", "EMM.PlayerSpawn", function (ply)
	hook.Run("PlayerProperties", ply)
	ply:SetupCoreProperties()
	ply:SetupModel()

	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PlayerSpawn")
	end

	net.Start "PlayerSpawn"
	net.WriteUInt(ply:EntIndex(), 16)
	net.Broadcast()
end)


-- # Disconnecting

util.AddNetworkString "PlayerDisconnected"
hook.Add("PlayerDisconnected", "NetworkPlayerDisconnected", function (ply)
	net.Start "PlayerDisconnected"
	net.WriteEntity(ply)
	net.Broadcast()
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

util.AddNetworkString "PrePlayerDeath"
hook.Add("DoPlayerDeath", "EMM.PrePlayerDeath", function (ply, att, dmg)
	ply:CreateRagdoll()

	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PrePlayerDeath", att, dmg)
	end

	hook.Run("PrePlayerDeath", ply, att, dmg)
	
	net.Start "PrePlayerDeath"
	net.WriteEntity(ply)
	net.WriteEntity(att)
	net.Broadcast()
end)

util.AddNetworkString "PlayerDeath"
hook.Add("PlayerDeath", "EMM.PlayerDeath", function (ply, infl, att)
	ply:FreezeMovement()

	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PlayerDeath", infl, att)
	end

	net.Start "PlayerDeath"
	net.WriteEntity(ply)
	net.WriteEntity(infl)
	net.WriteEntity(att)
	net.Broadcast()
end)

local function SetDeathTime(ply)
	ply.last_death_time = CurTime()
end
hook.Add("PlayerDeath", "DeathTime", SetDeathTime)
hook.Add("PlayerSilentDeath", "SilentDeathTime", SetDeathTime)

util.AddNetworkString "PostPlayerDeath"
hook.Add("PostPlayerDeath", "NetworkPostPlayerDeath", function (ply)
	net.Start "PostPlayerDeath"
	net.WriteEntity(ply)
	net.Broadcast()
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