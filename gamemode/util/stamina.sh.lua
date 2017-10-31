StaminaService = StaminaService or {}
Stamina = Stamina or {}
Stamina.__index = Stamina


-- # Properties

function StaminaService.InitPlayerProperties(ply)
	ply.stamina = ply.stamina or {}
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"StaminaService.InitPlayerProperties",
	StaminaService.InitPlayerProperties
)

function StaminaService.PlayerProperties(ply)

end
hook.Add(
	SERVER and "PlayerProperties" or "LocalPlayerProperties",
	"StaminaService.PlayerProperties",
	StaminaService.PlayerProperties
)


-- # Stamina Methods

function Stamina:GetAmount()
	return self.amount
end

function Stamina:SetStamina(value)
	self.amount = math.Clamp(value, 0, 100)
end

function Stamina:AddStamina(value)
	self.amount = math.Clamp(self.amount + value, 0, 100)
end

function Stamina:ReduceStamina(value)
	self.amount = math.Clamp(self.amount - value, 0, 100)
end

function Stamina:IsActive()
	return self.active
end

function Stamina:SetActive(active)
	if self.active and not active then
		self.last_active = CurTime()
	end

	self.active = active
end


-- # Stamina Creation
function StaminaService.CreateStaminaType()
	return setmetatable({
		amount = 100,
		regen_step = 0.1,
		decay_step = 0.1,
		cooldown = 1,
		last_active = 0,
		active = false
	}, Stamina)
end


-- # Stamina Decay Handling

function StaminaService.TickUpdate()
	local cur_time = CurTime()
	for _, ply in pairs(SERVER and player.GetAll() or {LocalPlayer()}) do
		for _, stamina_type in pairs(ply.stamina or {}) do
			if stamina_type.active then
				stamina_type:ReduceStamina(stamina_type.decay_step)
			elseif cur_time > stamina_type.last_active + stamina_type.cooldown then
				stamina_type:AddStamina(stamina_type.regen_step)
			end
		end
	end
end
hook.Add("Tick", "StaminaService.TickUpdate", StaminaService.TickUpdate)