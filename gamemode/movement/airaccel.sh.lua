AiraccelService = AiraccelService or {}


-- # Properties

CreateConVar("emm_airaccelerate", 10, FCVAR_REPLICATED, "Air acceleration")

function AiraccelService.InitPlayerProperties(ply)
	ply.can_airaccel = true
	ply.has_infinite_airaccel = false
	ply.airaccel_regen_step = 0.1
	ply.airaccel_decay_step = 0.1
	ply.airaccel_cooldown = 2
	ply.airaccel_velocity_cost = 0.01
	ply.airaccel_boost_velocity = 10000
	ply.airaccel_sound = "player/suit_sprint.wav"
	ply.air_accelerate = GetConVar("emm_airaccelerate"):GetFloat()
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
	ply.stamina.airaccel.infinite = ply.has_infinite_airaccel
	ply.stamina.airaccel.amount = 100
end

function AiraccelService.LocalPlayerProperties(ply)
	AiraccelService.SetupStamina(ply)
end
hook.Add(
	"LocalPlayerProperties",
	"AiraccelService.LocalPlayerProperties",
	AiraccelService.LocalPlayerProperties
)

function AiraccelService.PlayerProperties(ply)
	if CLIENT then
		StaminaService.InitPlayerProperties(ply)
		AiraccelService.InitPlayerProperties(ply)
		AiraccelService.SetupStamina(ply)
	else
		AiraccelService.SetupStamina(ply)
	end
end
hook.Add(
	"PlayerProperties",
	"AiraccelService.PlayerProperties",
	AiraccelService.PlayerProperties
)

function AiraccelService.GetDefaultAiraccel()
	return GetConVar("emm_airaccelerate"):GetFloat()
end


-- # Util

function AiraccelService.KeyPress(ply, key)
	if IsFirstTimePredicted() and ply.can_airaccel and key == IN_SPEED and not ply.airaccel_started then
		ply.airaccel_started = true
		PredictedSoundService.PlaySound(ply, ply.airaccel_sound)
	end
end
hook.Add("KeyPress", "AiraccelService.KeyPress", AiraccelService.KeyPress)

function AiraccelService.WishDir(ply, fwd, fwd_speed, side_speed)
	return (Vector(fwd.x, fwd.y, 0):GetNormalized() * fwd_speed) + (Vector(fwd.y, -fwd.x, 0):GetNormalized() * side_speed * 1.05)
end


-- # Airacceling

function AiraccelService.Velocity(ply, move, amount)
	local strafe_vel = AiraccelService.WishDir(ply, move:GetMoveAngles():Forward(), move:GetForwardSpeed(), move:GetSideSpeed())
	local strafe_vel_length = math.Clamp(strafe_vel:Length(), 0, 300)
	local strafe_vel_norm = strafe_vel:GetNormalized()
	local vel_diff = strafe_vel_length/10 - move:GetVelocity():Dot(strafe_vel_norm)

	return vel_diff, move:GetVelocity() + (strafe_vel_norm * math.Clamp(ply:GetMaxSpeed() * amount * FrameTime(), 0, vel_diff))
end

function AiraccelService.SetupAiraccel(ply, move)
	if CLIENT then
		ply = GetPlayer()
	end

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

		if ply:Alive() and not ply:OnGround() then
			local vel_diff, new_vel = AiraccelService.Velocity(ply, move, ply.air_accelerate)
			
			if vel_diff > 0 then
				move:SetVelocity(new_vel)
			end
		end
	end
end
hook.Add("SetupMove", "AiraccelService.SetupAiraccel", AiraccelService.SetupAiraccel)