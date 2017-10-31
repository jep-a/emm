AiraccelService = AiraccelService or {}


-- # Properties

function AiraccelService.InitPlayerProperties(ply)
	ply.can_airaccel = true
	ply.airaccel_regen_step = 0.1
	ply.airaccel_decay_step = 0.1
	ply.airaccel_cooldown = 2
	ply.airaccel_stamina_coefficient = 0.01
	ply.airaccel_sound = "player/suit_sprint.wav"
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"AiraccelService.InitPlayerProperties",
	AiraccelService.InitPlayerProperties
)

function AiraccelService.PlayerProperties(ply)
	AiraccelService.SetupStamina(ply)
end
hook.Add(
	SERVER and "PlayerProperties" or "LocalPlayerProperties",
	"AiraccelService.PlayerProperties",
	AiraccelService.PlayerProperties
)

function AiraccelService.SetupStamina(ply)
	ply.stamina.airaccel = ply.stamina.airaccel or StaminaService.CreateStaminaType()
	ply.stamina.airaccel.amount = 100
	ply.stamina.airaccel.last_active = 0
	ply.stamina.airaccel.active = false
	ply.stamina.airaccel.regen_step = ply.airaccel_regen_step
	ply.stamina.airaccel.decay_step = ply.airaccel_decay_step
	ply.stamina.airaccel.cooldown = ply.airaccel_cooldown
end


-- # Airacceling

function AiraccelService.Velocity(ply, move)
	local fwd = move:GetMoveAngles():Forward()
	local strafe_vel = (Vector(fwd.x, fwd.y, 0):GetNormalized() * move:GetForwardSpeed()) + (Vector(fwd.y, -fwd.x, 0):GetNormalized() * move:GetSideSpeed())
	local strafe_vel_length = math.Clamp(strafe_vel:Length(), 0, 50)
	local strafe_vel_norm = strafe_vel:GetNormalized()
	local vel_diff = strafe_vel_length - move:GetVelocity():Dot(strafe_vel_norm)
	return vel_diff, move:GetVelocity() + (strafe_vel_norm * math.Clamp(strafe_vel_length * 100, 0, vel_diff))
end

function AiraccelService.SetupAiraccel(ply, move)
	if
		ply:Alive() and
		ply.can_airaccel and
		not ply:IsOnGround() and
		move:KeyDown(IN_SPEED) and
		ply.stamina.airaccel:GetAmount() > 0
	then
		ply.stamina.airaccel:SetActive(true)
		local vel_diff, new_vel = AiraccelService.Velocity(ply, move)
		if vel_diff > 0 then
			move:SetVelocity(new_vel)
			if IsFirstTimePredicted() then ply.stamina.airaccel:ReduceStamina(vel_diff * ply.airaccel_stamina_coefficient) end
		end
	else
		ply.stamina.airaccel:SetActive(false)
	end
end
hook.Add("SetupMove", "AiraccelService.SetupAiraccel", AiraccelService.SetupAiraccel)