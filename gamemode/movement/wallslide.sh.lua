WallslideService = WallslideService or {}

local SPARK_EFFECT_DELAY = 0.05


-- # Properties

function WallslideService.InitPlayerProperties(ply)
	ply.can_wallslide = true
	ply.wallslide_distance = 30
	ply.wallslide_stamina_regen = 0.25
	ply.wallslide_stamina_decay = 0.25
	ply.wallslide_stamina_cost = 5
	ply.wallslide_cooldown = 2

	if SERVER then
		ply.wallslide_sound = CreateSound(ply, "physics/body/body_medium_scrape_smooth_loop1.wav")
	end
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"WallslideService.InitPlayerProperties",
	WallslideService.InitPlayerProperties
)

function WallslideService.PlayerProperties(ply)
	ply.wallsliding = false
	ply.wallslide_velocity = Vector(0, 0, 0)
	ply.last_wallslide_time = 0
	ply.last_wallslide_spark_time = 0
	WallslideService.SetupStaminaValues(ply)
end
hook.Add(
	SERVER and "PlayerProperties" or "LocalPlayerProperties",
	"WallslideService.PlayerProperties",
	WallslideService.PlayerProperties
)

function WallslideService.SetupStaminaValues(ply)
	ply.stamina.wallslide = ply.stamina.wallslide or StaminaService.CreateStaminaType()
	ply.stamina.wallslide.amount = 100
	ply.stamina.wallslide.last_active = 0
	ply.stamina.wallslide.active = false	
	ply.stamina.wallslide.regen_step = ply.wallslide_stamina_regen
	ply.stamina.wallslide.decay_step = ply.wallslide_stamina_decay
	ply.stamina.wallslide.cooldown = ply.wallslide_cooldown
end


-- # Effects

function WallslideService.Effect(ply, trace)
	util.Effect("emm_spark", WalljumpService.EffectData(ply, trace), true, true)
end


-- # Wallsliding

function WallslideService.Trace(ply, dir)
	local ply_pos = ply:GetShootPos()
	local trace = util.TraceLine {
		start = ply_pos,
		endpos = ply_pos + (dir * ply.wallslide_distance),
		filter = ply
	}
	return trace
end

function WallslideService.Velocity(ply, trace)
	local frac = math.Clamp(math.TimeFraction(ply.last_wallslide_time, ply.last_wallslide_time + 2, CurTime()), 0, 1)
	local new_move_vel = ((1 - frac) * (ply.wallslide_velocity * Vector(1, 1, 0))) + (frac * (trace.Normal * Vector(1, 1, 0.1)) * 400) - Vector(0, 0, 5)
	new_move_vel.z = math.min(new_move_vel.z, 1)
	return new_move_vel
end

function WallslideService.SetupWallslide(ply, move)
	if ply:Alive() and ply.can_wallslide then
		local trace = WallslideService.Trace(ply, ply:GetAimVector())
		local cur_time = CurTime()
		if
			trace.HitWorld and
			not trace.HitSky and
			not ply:OnGround() and
			move:KeyDown(IN_ATTACK2) and
			ply.stamina.wallslide:GetAmount() > 0
		then
			if not ply.wallsliding then
				ply.wallslide_velocity = ply:GetVelocity()
				ply.last_wallslide_time = cur_time
				ply.stamina.wallslide:ReduceStamina(ply.wallslide_stamina_cost)
			end
			ply.wallsliding = true
			ply.stamina.wallslide:SetActive(true)
			move:SetVelocity(WallslideService.Velocity(ply, trace))
		else
			ply.wallsliding = false
			ply.stamina.wallslide:SetActive(false)
		end
	end
end
hook.Add("SetupMove", "WallslideService.SetupWallslide", WallslideService.SetupWallslide)