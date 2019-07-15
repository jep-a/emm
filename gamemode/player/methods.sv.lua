local player_metatable = FindMetaTable "Player"

function player_metatable:SetupModel()
	local mdl = self.model or player_manager.TranslatePlayerModel(self:GetInfo "cl_playermodel")

	util.PrecacheModel(mdl)
	self:SetModel(mdl)
end

function player_metatable:FreezeMovement()
	self:SetWalkSpeed(1)
	self:SetRunSpeed(1)
end

function player_metatable:Strip()
	self:StripWeapons()
	self:StripAmmo()
end

local ammo_type_count = 27

function player_metatable:SetupLoadout()
	self:Strip()

	if self.weapons then
		for i = 1, ammo_type_count do
			self:GiveAmmo(9999, game.GetAmmoName(i), true)
		end
	
		for k, v in pairs(self.weapons) do
			if v then
				self:Give(k)
			end
		end
	end
end