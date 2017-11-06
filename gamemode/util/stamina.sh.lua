StaminaService = StaminaService or {}


-- # Properties

function StaminaService.InitPlayerProperties(ply)
	ply.stamina = ply.stamina or {}
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"StaminaService.InitPlayerProperties",
	StaminaService.InitPlayerProperties
)


-- # Types

StaminaType = StaminaType or {}
StaminaType.__index = StaminaType

function StaminaService.CreateStaminaType()
	return setmetatable({
		active = false,
		regen_step = 0.1,
		decay_step = 0.1,
		cooldown = 1,
		amount = 100,
		last_active = 0
	}, StaminaType)
end

function StaminaType:GetStamina()
	return self.amount
end

function StaminaType:HasStamina()
	return self.amount > 0
end

function StaminaType:SetStamina(value)
	self.amount = math.Clamp(value, 0, 100)
end

function StaminaType:AddStamina(value)
	self.amount = math.Clamp(self.amount + value, 0, 100)
end

function StaminaType:ReduceStamina(value)
	self.amount = math.Clamp(self.amount - value, 0, 100)
end

function StaminaType:IsActive()
	return self.active
end

function StaminaType:SetActive(active)
	if not active and self.active then
		self.last_active = CurTime()
	end

	self.active = active
end


-- # Updating

function StaminaService.Update()
	local cur_time = CurTime()
	for _, ply in pairs(SERVER and player.GetAll() or {LocalPlayer()}) do
		for _, stamina_type in pairs(ply.stamina or {}) do
			if stamina_type.active then
				stamina_type:ReduceStamina(stamina_type.decay_step)
			elseif cur_time > (stamina_type.last_active + stamina_type.cooldown) then
				stamina_type:AddStamina(stamina_type.regen_step)
			end
		end
	end
end
hook.Add("Tick", "StaminaService.Update", StaminaService.Update)