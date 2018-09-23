AiraccelService = AiraccelService or {}


-- # Properties

function AiraccelService.InitPlayerProperties(ply)
	ply.can_airaccel = true
	ply.airaccel_regen_step = 0.1
	ply.airaccel_decay_step = 0.1
	ply.airaccel_cooldown = 2
	ply.airaccel_velocity_cost = 0.01
	ply.airaccel_boost_velocity = 10000
	ply.airaccel_sound = "player/suit_sprint.wav"
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"AiraccelService.InitPlayerProperties",
	AiraccelService.InitPlayerProperties
)

function AiraccelService.SetupStamina(ply)
	ply.stamina.airaccel = ply.stamina.airaccel or StaminaService.CreateStaminaType()
	ply.stamina.airaccel.active = false
	ply.stamina.airaccel.regen_step = ply.airaccel_regen_step
	ply.stamina.airaccel.decay_step = ply.airaccel_decay_step
	ply.stamina.airaccel.cooldown = ply.airaccel_cooldown
	ply.stamina.airaccel.amount = 100
end

function AiraccelService.PlayerProperties(ply)
	AiraccelService.SetupStamina(ply)
end
hook.Add(
	SERVER and "PlayerProperties" or "LocalPlayerProperties",
	"AiraccelService.PlayerProperties",
	AiraccelService.PlayerProperties
)


-- # Util

function AiraccelService.KeyPress(ply, key)
	if IsFirstTimePredicted() and ply.can_airaccel and key == IN_SPEED and not ply.airaccel_started then
		ply.airaccel_started = true
		PredictedSoundService.PlaySound(ply, ply.airaccel_sound)
	end
end
hook.Add("KeyPress", "AiraccelService.KeyPress", AiraccelService.KeyPress)


-- # Airacceling

function AiraccelService.Velocity(ply, move, amount)
	local fwd = move:GetMoveAngles():Forward()
	local strafe_vel = (Vector(fwd.x, fwd.y, 0):GetNormalized() * move:GetForwardSpeed()) + (Vector(fwd.y, -fwd.x, 0):GetNormalized() * move:GetSideSpeed())
	local strafe_vel_length = math.Clamp(strafe_vel:Length(), 0, 50)
	local strafe_vel_norm = strafe_vel:GetNormalized()
	local vel_diff = strafe_vel_length - move:GetVelocity():Dot(strafe_vel_norm)

	return vel_diff, move:GetVelocity() + (strafe_vel_norm * math.Clamp(strafe_vel_length * amount * FrameTime(), 0, vel_diff))
end

function AiraccelService.SetupAiraccel(ply, move)
	if
		ply:Alive() and
		ply.can_airaccel and
		not ply:IsOnGround() and
		move:KeyDown(IN_SPEED) and
		AiraccelService.HasStamina(ply)
	then
		ply.stamina.airaccel:SetActive(true)

		local vel_diff, new_vel = AiraccelService.Velocity(ply, move, ply.airaccel_boost_velocity)

		if vel_diff > 0 then
			move:SetVelocity(new_vel)
			AiraccelService.ReduceStamina(ply, vel_diff * ply.airaccel_velocity_cost)
		end
	else
		if IsFirstTimePredicted() and ply.airaccel_started then
			if CLIENT and ply.can_airaccel then
				PredictedSoundService.PlaySound(ply, ply.airaccel_sound, 100, 75, 0.2)
			end

			ply.airaccel_started = false
		end

		ply.stamina.airaccel:SetActive(false)
	end
end
hook.Add("SetupMove", "AiraccelService.SetupAiraccel", AiraccelService.SetupAiraccel)