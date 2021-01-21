-- # Spawning

hook.Add("PlayerInitialSpawn", "EMM.PlayerInitialSpawn", function (ply)
	hook.Run("InitPlayerProperties", ply)
	NetService.Broadcast("PlayerInitialSpawn", ply)
end)

hook.Add("PlayerSpawn", "EMM.PlayerSpawn", function (ply)
	hook.Run("PlayerProperties", ply)
	ply:SetupCoreProperties()
	ply:SetupModel()
	ply:SetupLoadout()

	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PlayerSpawn", ply)
		MinigameService.CallHook(ply.lobby, "PlayerProperties", ply)
	end

	NetService.Broadcast("PlayerSpawn", ply)
end)


-- # Disconnecting

hook.Add("PlayerDisconnected", "NetworkPlayerDisconnected", function (ply)
	NetService.Broadcast("PlayerDisconnected", ply)
end)


-- # Death

function GM:PlayerDeath(ply, inflictor, attacker)
	local att_valid = IsValid(attacker)
	local infl_valid = IsValid(inflictor)

	if att_valid and attacker:GetClass() == "trigger_hurt" then
		attacker = ply
	end

	if att_valid and attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
		attacker = attacker:GetDriver()
	end

	if not infl_valid and att_valid then
		inflictor = attacker
	end

	if infl_valid and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC()) then
		inflictor = inflictor:GetActiveWeapon()

		if not infl_valid then
			inflictor = attacker
		end
	end
end

function GM:DoPlayerDeath(ply, attacker, dmg)
	ply:CreateRagdoll()
end

hook.Add("DoPlayerDeath", "EMM.PrePlayerDeath", function (ply, attacker, dmg)
	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PrePlayerDeath", ply, attacker, dmg)
	end

	hook.Run("PrePlayerDeath", ply, attacker, dmg)
	NetService.Broadcast("PrePlayerDeath", ply, attacker)
end)

hook.Add("PlayerDeath", "EMM.PlayerDeath", function (ply, inflictor, attacker)
	ply:FreezeMovement()

	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PlayerDeath", ply, inflictor, attacker)
	end

	NetService.Broadcast("PlayerDeath", ply, inflictor, attacker)
end)

hook.Add("PostPlayerDeath", "NetworkPostPlayerDeath", function (ply)
	NetService.Broadcast("PostPlayerDeath", ply)
end)

hook.Add("PlayerDeathThink", "Respawn", function (ply)
	local cur_time = CurTime()

	local allow_spawn

	if cur_time > (ply.last_death_time + ply.death_cooldown) then
		allow_spawn = true

		if
			not ply.spectating and (
				ply:IsBot() or
				ply:KeyPressed(IN_FORWARD) or
				ply:KeyPressed(IN_MOVELEFT) or
				ply:KeyPressed(IN_BACK) or
				ply:KeyPressed(IN_MOVERIGHT) or
				ply:KeyPressed(IN_JUMP) or
				cur_time > (ply.last_death_time + 5)
			)
		then
			ply:Spawn()
		end
	else
		allow_spawn = false
	end

	return allow_spawn
end)


-- # Damage

local function ShouldTakeDamage(victim, attacker, dmg)
	local should_damage

	local inflictor = dmg and dmg:GetInflictor()
	local victim_is_player = victim:IsPlayer()

	if victim_is_player and victim.should_take_damage then
		should_damage = victim.should_take_damage
		victim.should_take_damage = nil
	else
		if attacker == game.GetWorld() or attacker:GetClass() == "trigger_hurt" then
			should_damage = true
		elseif
			IsValid(attacker) and
			MinigameService.IsSharingLobby(victim, attacker) and
			victim_is_player and
			attacker:IsPlayer() and
			attacker.player_class and
			victim.player_class and
			(inflictor and MinigameService.IsSharingLobby(victim, inflictor))
		then
			should_damage = attacker.player_class.can_damage_everyone or attacker.player_class.can_damage[victim.player_class.key]
		else
			should_damage = false
		end

		if victim_is_player then
			victim.should_take_damage = should_damage
		end
	end

	return should_damage
end

hook.Add("EntityTakeDamage", "EMM.EntityTakeDamage", function (victim, dmg)
	local attacker = dmg:GetAttacker()
	local should_damage = ShouldTakeDamage(victim, attacker, dmg)

	if should_damage then
		local inflictor = dmg:GetInflictor()
		local dmg_amount = dmg:GetDamage()

		NetService.Broadcast("EntityTakeDamage", victim, inflictor, attacker, math.Truncate(dmg_amount, 2))

		if victim.lobby then
			MinigameService.CallHook(victim.lobby, "EntityTakeDamage", victim, inflictor, attacker, dmg_amount)
		end
	end

	return not should_damage
end)

hook.Add("PlayerShouldTakeDamage", "EMM.PlayerShouldTakeDamage", function (victim, attacker)
	return ShouldTakeDamage(victim, attacker)
end)


-- # Misc

hook.Add("GetFallDamage", "EMM.FallDamage", function (ply, speed)
	local fall_damage

	if ply.can_take_fall_damage then
		fall_damage = (speed - 580) * ply.fall_damage_multiplier

		local view_punch = fall_damage/20

		ply:ViewPunch(Angle(math.random(-view_punch, view_punch), math.random(-view_punch, view_punch), 0))
	else
		fall_damage = 0
	end

	return fall_damage
end)

timer.Create("EMM.PlayerHealthRegeneration", 1, 0, function ()
	for _, ply in pairs(player.GetAll()) do
		if ply:Alive() and ply.can_regenerate_health then
			ply:SetHealth(math.Clamp(ply:Health() + ply.health_regenerate_step, 0, ply.max_health))
		end
	end
end)