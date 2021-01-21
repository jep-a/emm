NetService.CreateSchema("PlayerInitialSpawn", {"player_index"})
NetService.CreateSchema("PlayerSpawn", {"player_index"})
NetService.CreateSchema("PlayerDisconnected", {"entity"})
NetService.CreateSchema("PrePlayerDeath", {"entity", "entity"})
NetService.CreateSchema("PlayerDeath", {"entity", "entity", "entity"})
NetService.CreateSchema("PostPlayerDeath", {"entity"})
NetService.CreateSchema("EntityTakeDamage", {"entity", "entity", "entity", "float"})

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

	ply.death_cooldown = 2
	ply.last_death_time = 0
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

	if a:GetClass() ~= "prop_ragdoll" and b:GetClass() ~= "prop_ragdoll" and MinigameService.IsSharingLobby(a, b) then
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

hook.Add("PlayerNoClip", "EMM.PlayerNoclip", function (ply, noclip)
	-- local should_noclip = noclip

	return false
end)