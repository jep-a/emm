local player_metatable = FindMetaTable "Player"

function player_metatable:SetupCoreProperties()
	self:SetMaxHealth(self.max_health)
	self:SetArmor(0)
	self:SetMoveType(MOVETYPE_WALK)
	self:SetCanWalk(false)
	self:SetWalkSpeed(self.run_speed)
	self:SetRunSpeed(self.run_speed)
	self:SetCrouchedWalkSpeed(0.5)
	self:SetDuckSpeed(0.3)
	self:SetUnDuckSpeed(0.3)
	self:SetJumpPower(self.jump_power)
	self:SetNoCollideWithTeammates(true)
	self:AllowFlashlight(true)
	self:ShouldDropWeapon(false)
	self:SetAvoidPlayers(false)
end

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