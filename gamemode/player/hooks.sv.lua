-- # Spawning

util.AddNetworkString "PlayerInitialSpawn"
hook.Add("PlayerInitialSpawn", "NetworkPlayerInitialSpawn", function (ply)
	net.Start("PlayerInitialSpawn")
	net.WriteUInt(ply:EntIndex(), 16)
	net.Broadcast()
end)

hook.Add("PlayerInitialSpawn", "InitPlayerProperties", function (ply)
	hook.Run("InitPlayerProperties", ply)
end)

util.AddNetworkString "PlayerSpawn"
hook.Add("PlayerSpawn", "NetworkPlayerSpawn", function (ply)
	net.Start("PlayerSpawn")
	net.WriteUInt(ply:EntIndex(), 16)
	net.Broadcast()
end)

hook.Add("PlayerSpawn", "PlayerProperties", function (ply)
	hook.Run("PlayerProperties", ply)
	ply:SetupCoreProperties()
	ply:SetupModel()
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
end)


-- # Death

hook.Add("DoPlayerDeath", "PrePlayerDeath", function (ply, att, dmg)
	hook.Run("PrePlayerDeath", ply, att, dmg)
end)

util.AddNetworkString "PrePlayerDeath"
hook.Add("PrePlayerDeath", "NetworkPrePlayerDeath", function (ply, att)
	net.Start("PrePlayerDeath")
	net.WriteEntity(ply)
	net.WriteEntity(att)
	net.Broadcast()
end)

hook.Add("PrePlayerDeath", "CreateRagdoll", function (ply)
	ply:CreateRagdoll()
end)

util.AddNetworkString "PlayerDeath"
hook.Add("PlayerDeath", "NetworkPlayerDeath", function (ply, infl, att)
	net.Start("PlayerDeath")
	net.WriteEntity(ply)
	net.WriteEntity(infl)
	net.WriteEntity(att)
	net.Broadcast()
end)

hook.Add("PlayerDeath", "DeathTime", function (ply)
	ply.last_death_time = CurTime()
end)

hook.Add("PlayerDeath", "FreezeMovement", function (ply)
	ply:FreezeMovement()
end)

util.AddNetworkString "PostPlayerDeath"
hook.Add("PostPlayerDeath", "NetworkPostPlayerDeath", function (ply)
	net.Start("PostPlayerDeath")
	net.WriteEntity(ply)
	net.Broadcast()
end)

hook.Add("PlayerDeathThink", "Respawn", function (ply)
	local cur_time = CurTime()
	if cur_time > (ply.last_death_time + ply.death_cooldown) then
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
	end
end)


-- # Falling

hook.Add("GetFallDamage", "Fall", function (ply, speed)
	local speed = (speed - 580) * ply.fall_damage_mult
	local view_punch = speed/20
	ply:ViewPunch(Angle(math.random(-view_punch, view_punch), math.random(-view_punch, view_punch), 0))
	return speed
end)


-- # Health Regeneration

timer.Create("PlayerHealthRegeneration", 1, 0, function ()
	for _, ply in pairs(player.GetAll()) do
		if ply:Alive() and ply.can_health_regen then
			ply:SetHealth(math.Clamp(ply:Health() + ply.health_regen_step, 0, ply.max_health))
		end
	end
end)