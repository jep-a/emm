NetService.CreateSchema("PlayerInitialSpawn", {"player_index"})
NetService.CreateSchema("PlayerSpawn", {"player_index"})
NetService.CreateSchema("PlayerDisconnected", {"entity"})
NetService.CreateSchema("PrePlayerDeath", {"entity", "entity"})
NetService.CreateSchema("PlayerDeath", {"entity", "entity", "entity"})
NetService.CreateSchema("PostPlayerDeath", {"entity"})

-- # Properties

hook.Add("InitPlayerProperties", "InitCorePlayerProperties", function (ply)
	ply.color = COLOR_WHITE

	if CLIENT then
		ply.animatable_color = AnimatableValue.New(COLOR_WHITE, {
			smooth = true,

			generate = function ()
				return IsValid(ply) and ply.color or COLOR_WHITE
			end
		})
	end

	ply.can_regenerate_health = true
	ply.max_health = 100
	ply.health_regenerate_step = 1

	ply.run_speed = 400
	ply.jump_power = 220

	ply.can_take_fall_damage = true
	ply.fall_damage_multiplier = 0.0563
	ply.collision_damage_multiplier = 0.0563

	ply.death_cooldown = 2
	ply.last_death_time = 0
	ply.old_velocity = Vector()
end)

hook.Add("PlayerDisconnected", "FinishPlayerProperties", function (ply)
	if CLIENT then
		ply.animatable_color:Finish()
	end
end)

hook.Add("PlayerProperties", "SetCollisionCheck", function (ply)
	ply:SetCustomCollisionCheck(true)
end)

hook.Add("ShouldCollide", "EMM.ShouldCollide", function (a, b)
	local should_collide

	if MinigameService.IsSharingLobby(a, b) then
		should_collide = true
	else
		should_collide = false
	end

	return should_collide
end)

local function SetDeathTime(ply)
	ply.last_death_time = CurTime()
end
hook.Add("PlayerDeath", "DeathTime", SetDeathTime)

if SERVER then
	hook.Add("PlayerSilentDeath", "DeathTime", SetDeathTime)
end

hook.Add("OnEntityCreated", "AssignLobby", function (ent)
	local owner = ent:GetOwner()

	if IsValid(owner) and owner.lobby then
		ent.lobby = owner.lobby
	end
end)

hook.Add("Move", "EMM.OldVelocity", function (ply, move)
	ply.old_velocity = move:GetVelocity()
end)


-- # Walldamage

hook.Add("SetupMove", "EMM.WallDamage", function (ply, move)
	local velocity = move:GetVelocity()
	local pos = move:GetOrigin()
	local lost_velocity = ply.old_velocity:Length2D() - velocity:Length2D()
	local min_velocity = 580
	local trace = util.TraceHull {
		start = pos,
		endpos = pos + (ply.old_velocity * FrameTime() * 2),
		mins = ply:OBBMins() + Vector(2, 2),
		maxs = ply:OBBMaxs() - Vector(2, 2),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}

	if 
		0 > Vector(ply.old_velocity.x, ply.old_velocity.y):Dot(trace.HitNormal) and
		-0.8 > Vector(ply.old_velocity.x, ply.old_velocity.y):GetNormalized():Dot(trace.HitNormal) and
		lost_velocity > min_velocity and 
		IsFirstTimePredicted() and 
		not ply:OnGround() and 
		ply:Alive() and
		ply.can_take_collision_damage
	then
		local collision_sound = "physics/body/body_medium_break" .. math.random(2, 4) .. ".wav"

		if SERVER then
			local wall_damage = (lost_velocity - min_velocity) * ply.collision_damage_multiplier
			local view_punch = wall_damage/20
			local dmg = DamageInfo()

			dmg:SetDamage(wall_damage)
			dmg:SetDamageType(DMG_FALL)
			dmg:SetAttacker(game.GetWorld())
			ply:TakeDamageInfo(dmg)
			ply:ViewPunch(Angle(math.random(-view_punch, view_punch), math.random(-view_punch, view_punch), 0))
		end

		PredictedSoundService.PlaySound(ply, collision_sound)
	end
end)

