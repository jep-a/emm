StaminaService = {}

Stamina = {}
Stamina.__index = Stamina


-- # Stamina Methods

function Stamina:Amount()
	return self.amount
end

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
	return setmetatable({
		amount = 100,
		decay_step = 0.1,
		regen_step = 0.1,
		last_used = 0,
		cooldown = 1,
		is_active = false
	}, Stamina)
end

function StaminaService.InitWallslideStamina(ply)
	ply.stamina.wallslide.amount = 100
	ply.stamina.wallslide.decay_step = 100 / 66 / ply.wallslide_time
	ply.stamina.wallslide.regen_step = ply.stamina.wallslide.decay_step
	ply.stamina.wallslide.last_used = 0
	ply.stamina.wallslide.cooldown = 0.5
	ply.stamina.wallslide.is_active = false
end

function StaminaService.InitAirAccelStamina(ply)
	ply.stamina.airaccel.amount = 100
	ply.stamina.airaccel.decay_step = ply.airaccel_decay_step
	ply.stamina.airaccel.regen_step = ply.airaccel_regen_step
	ply.stamina.airaccel.last_used = 0
	ply.stamina.airaccel.cooldown = ply.airaccel_cooldown
	ply.stamina.airaccel.is_active = false
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
	if ply.stamina then
		StaminaService.InitWallslideStamina(ply)
		StaminaService.InitAirAccelStamina(ply)
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