WallslideService = WallslideService or {}


-- # Properties

function WallslideService.InitPlayerProperties(ply)
	ply.can_wallslide = true
	ply.wallslide_distance = 30
	ply.wallslide_regen_step = 0.25
	ply.wallslide_decay_step = 0.25
	ply.wallslide_cooldown = 2
	ply.wallslide_init_cost = 5

	if SERVER then
		ply.wallslide_sound = CreateSound(ply, "physics/body/body_medium_scrape_smooth_loop1.wav")
	end
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"WallslideService.InitPlayerProperties",
	WallslideService.InitPlayerProperties
)

function WallslideService.SetupStamina(ply)
	ply.stamina.wallslide = ply.stamina.wallslide or StaminaService.CreateStaminaType()
	ply.stamina.wallslide.active = false
	ply.stamina.wallslide.regen_step = ply.wallslide_regen_step
	ply.stamina.wallslide.decay_step = ply.wallslide_decay_step
	ply.stamina.wallslide.cooldown = ply.wallslide_cooldown
	ply.stamina.wallslide.amount = 100
end

function WallslideService.PlayerProperties(ply)
	ply.wallsliding = false
	ply.wallslide_velocity = Vector(0, 0, 0)
	ply.last_wallslide_time = 0
	ply.last_wallslide_spark_time = 0
	WallslideService.SetupStamina(ply)
end
hook.Add(
	SERVER and "PlayerProperties" or "LocalPlayerProperties",
	"WallslideService.PlayerProperties",
	WallslideService.PlayerProperties
)


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
		if
			trace.HitWorld and
			not trace.HitSky and
			not ply:OnGround() and
			move:KeyDown(IN_ATTACK2) and
			WallslideService.HasStamina(ply)
		then
			if not ply.wallsliding then
				ply.wallslide_velocity = ply:GetVelocity()
				ply.last_wallslide_time = CurTime()
				ply.wallsliding = true
				ply.stamina.wallslide:SetActive(true)
				if IsFirstTimePredicted() then
					print("started wall slide")
					ply.stamina.wallslide:ReduceStamina(ply.wallslide_init_cost)
				end
			end
			
			move:SetVelocity(WallslideService.Velocity(ply, trace))
		elseif ply.wallsliding then
			ply.wallsliding = false
			ply.stamina.wallslide:SetActive(false)
		end
	end
end
hook.Add("SetupMove", "WallslideService.SetupWallslide", WallslideService.SetupWallslide)