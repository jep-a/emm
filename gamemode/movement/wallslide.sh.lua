WallslideService = WallslideService or {}

local wallslide_effect_cooldown = SAFE_FRAME
local wallslide_transition_velocity = 400


-- # Properties

function WallslideService.InitPlayerProperties(ply, ply_class)
	ply.can_wallslide = true
	ply.has_infinite_wallslide = false

	if not ply_class then
		ply.wallsliding = false
		ply.wallslide_velocity = Vector(0, 0, 0)
		ply.wallslide_distance = 40
		ply.wallslide_regen_step = 0.2
		ply.wallslide_decay_step = 0.2
		ply.wallslide_cooldown = 2
		ply.wallslide_init_cost = 5
		ply.wallslide_sound_file = "physics/body/body_medium_scrape_smooth_loop1.wav"

		ply.last_wallslide_time = 0
		ply.last_wallslide_effect_time = 0
	end
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"WallslideService.InitPlayerProperties",
	WallslideService.InitPlayerProperties
)
hook.Add(
	"InitPlayerClassProperties",
	"WallslideService.InitPlayerClassProperties",
	WallslideService.InitPlayerProperties
)

function WallslideService.SetupStamina(ply)
	ply.stamina.wallslide = ply.stamina.wallslide or StaminaService.CreateStaminaType()
	ply.stamina.wallslide.active = false
	ply.stamina.wallslide.regen_step = ply.wallslide_regen_step
	ply.stamina.wallslide.decay_step = ply.wallslide_decay_step
	ply.stamina.wallslide.cooldown = ply.wallslide_cooldown
	ply.stamina.wallslide.infinite = ply.has_infinite_wallslide
	ply.stamina.wallslide.amount = 100
end

function WallslideService.PlayerProperties(ply)
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

function WallslideService.Velocity(trace, last_wallslide_time, wallslide_velocity)
	local frac = math.Clamp(math.TimeFraction(last_wallslide_time, last_wallslide_time + 2, CurTime()), 0, 1)

	local new_move_vel =  (
		((1 - frac) * Vector(wallslide_velocity.x, wallslide_velocity.y, 0)) +
		(frac * Vector(trace.Normal.x, trace.Normal.y, trace.Normal.z * 0.1) * wallslide_transition_velocity) -
		Vector(0, 0, 5)
	)

	new_move_vel.z = math.min(new_move_vel.z, 1)

	return new_move_vel
end

function WallslideService.ValidTrace(trace)
	return trace.HitWorld and not trace.HitSky
end

function WallslideService.SetupWallslide(ply, move)
	if ply:Alive() and ply.can_wallslide then
		local cur_time = CurTime()
		local aim = ply:GetAimVector()
		local trace = WallslideService.Trace(ply, aim)

		if not WallslideService.ValidTrace(trace) then
			trace = WallslideService.Trace(ply, -aim)

			if not WallslideService.ValidTrace(trace) then
				trace = nil
			end
		end

		if
			trace and
			not ply:OnGround() and
			move:KeyDown(IN_ATTACK2) and
			WallslideService.HasStamina(ply)
		then
			if not WallslideService.Wallsliding(ply) and not WallslideService.StartedWallslide(ply) then
				ply.wallslide_velocity = ply:GetVelocity()
				ply.wallsliding = true
				ply.last_wallslide_time = cur_time

				ply.stamina.wallslide:SetActive(true)
				ply.stamina.wallslide:ReduceStamina(ply.wallslide_init_cost)

				PredictedSoundService.PlayWallslideSound(ply)

				if CLIENT then
					WallslideService.UpdateWallsliding(ply)
				end
			end

			if SERVER or SettingsService.Get "clientside_wallslide" then
				move:SetVelocity(WallslideService.Velocity(trace, WallslideService.LastWallslideTime(ply), WallslideService.WallslideVelocity(ply)))
			end

			if SERVER and cur_time > (ply.last_wallslide_effect_time + wallslide_effect_cooldown) then
				WallslideService.Effect(ply, trace)
				ply.last_wallslide_effect_time = cur_time
			end
		elseif WallslideService.Wallsliding(ply) and not WallslideService.FinishedWallslide(ply) then
			ply.wallsliding = false
			ply.stamina.wallslide:SetActive(false)

			PredictedSoundService.StopWallslideSound(ply)

			if CLIENT then
				WallslideService.UpdateWallsliding(ply)
			end
		end
	end
end
hook.Add("SetupMove", "WallslideService.SetupWallslide", WallslideService.SetupWallslide)