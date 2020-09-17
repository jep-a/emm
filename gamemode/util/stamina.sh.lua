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


-- # Utils

function StaminaService.ReceiveStamina()
	local ply = net.ReadEntity()
	local stamina_type = net.ReadString()
	local stamina_table = net.ReadTable()

	ply.stamina[stamina_type].active = stamina_table.active
	ply.stamina[stamina_type].amount = stamina_table.amount
	ply.stamina[stamina_type].regen_step = stamina_table.regen_step
	ply.stamina[stamina_type].decay_step = stamina_table.decay_step
	ply.stamina[stamina_type].cooldown = stamina_table.cooldown
	ply.stamina[stamina_type].last_active = stamina_table.last_active
end
net.Receive("UpdateStamina", StaminaService.ReceiveStamina)


-- # Types

StaminaType = StaminaType or {}
StaminaType.__index = StaminaType

function StaminaService.CreateStaminaType()
	local instance = setmetatable({}, StaminaType)
	instance:Init()

	return instance
end

function StaminaType:Init()
	self.active = false
	self.amount = 100
	self.regen_step = 0.1
	self.decay_step = 0.1
	self.cooldown = 1
	self.last_active = 0
end

function StaminaType:GetStamina()
	return self.infinite and 100 or self.amount
end

function StaminaType:HasStamina()
	return self.infinite or (self.amount > 0)
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

function StaminaService.UpdatePlayer(ply, cur_time)
	for _, stamina_type in pairs(ply.stamina) do
		if stamina_type.active then
			stamina_type:ReduceStamina(stamina_type.decay_step)
		elseif cur_time > (stamina_type.last_active + stamina_type.cooldown) then
			stamina_type:AddStamina(stamina_type.regen_step)
		end
	end
end

function StaminaService.Update()
	local cur_time = CurTime()

	if SERVER then
		for _, ply in pairs(player.GetAll()) do
			StaminaService.UpdatePlayer(ply, cur_time)
		end
	else
		local ply = GetObservingPlayer()

		if IsValid(ply) and ply.stamina then
			StaminaService.UpdatePlayer(GetObservingPlayer(), cur_time)
		end
	end
end
hook.Add("Tick", "StaminaService.Update", StaminaService.Update)


-- # Minigame settings reloading

function StaminaService.Reload(lobby, settings)
	local ply_classes_adjusted = {}
	local staminas = {}

	for k, v in pairs(settings) do
		local ply_class, stamina = string.match(k, "player_classes%.(.*)%.has_infinite_(.*)")

		if SERVER then
			if ply_class then
				ply_classes_adjusted[ply_class] = stamina
				staminas[stamina] = v
			end
		else
			local local_ply = LocalPlayer()

			if local_ply.player_class and ply_class == local_ply.player_class.key then
				local_ply.stamina[stamina].infinite = v
			end
		end
	end

	if SERVER and ply_classes_adjusted then
		for ply_class, stamina in pairs(ply_classes_adjusted) do
			for _, ply in pairs(lobby[ply_class]) do
				ply.stamina[stamina].infinite = staminas[stamina]
			end
		end
	end
end
hook.Add(SERVER and "LobbySettingsChange" or "LocalLobbySettingsChange", "StaminaService.Reload", StaminaService.Reload)