StaminaService = {}

Stamina = {}
Stamina.__index = Stamina


-- # Stamina Methods

function Stamina:AddStamina(value)
	self.amount = math.Clamp(self.amount + value, 0, 100)
end

function Stamina:ReduceStamina(value)
	self.amount = math.Clamp(self.amount - value, 0, 100)
end

function Stamina:IsActive()
	return self.is_active
end

function Stamina:SetActive(is_active)
	if self.is_active and not is_active then
		self.last_used = CurTime()
	end

	self.is_active = is_active
end


-- # Stamina Creation
function StaminaService.New()
	local self = {}

	self.airaccel = StaminaService.CreateStaminaType()
	self.wallslide = StaminaService.CreateStaminaType()

	return self
end

function StaminaService.CreateStaminaType()
	return setmetatable(StaminaService.InitStaminaType({}), Stamina)
end

function StaminaService.InitStaminaType(stamina_type)
	stamina_type.amount = 100
	stamina_type.decay_step = 0.1
	stamina_type.regen_step = 0.1
	stamina_type.last_used = 0
	stamina_type.cooldown = 1
	stamina_type.is_active = false

	return stamina_type
end


-- # Properties

function StaminaService.InitPlayerProperties(ply)
	ply.stamina = StaminaService.New()
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"StaminaService.InitPlayerProperties",
	StaminaService.InitPlayerProperties
)

function StaminaService.PlayerProperties(ply)
	for _, stamina_type in pairs(ply.stamina or {}) do
		StaminaService.InitStaminaType(stamina_type)
	end
end
hook.Add(
	SERVER and "PlayerProperties" or "LocalPlayerProperties",
	"StaminaService.PlayerProperties",
	StaminaService.PlayerProperties
)


-- # Stamina Decay Handling

function StaminaService.TickUpdate()
	local cur_time = CurTime()

	for _, ply in pairs(SERVER and player.GetAll() or {LocalPlayer()}) do
		for _, stamina_type in pairs(ply.stamina or {}) do
			if stamina_type.is_active then
				stamina_type:ReduceStamina(stamina_type.decay_step)
			elseif cur_time > stamina_type.last_used + stamina_type.cooldown then
				stamina_type:AddStamina(stamina_type.regen_step)
			end
		end
	end
end
hook.Add("Tick", "StaminaService.TickUpdate", StaminaService.TickUpdate)