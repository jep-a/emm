local player_metatable = FindMetaTable "Player"

function player_metatable:SetupCoreProperties()
	if SERVER then
		self:SetMaxHealth(self.max_health)
		self:SetArmor(0)
		self:ShouldDropWeapon(false)
		self:Strip()
	end

	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	self:SetMoveType(MOVETYPE_WALK)
	self:SetCanWalk(false)
	self:SetWalkSpeed(self.run_speed)
	self:SetRunSpeed(self.run_speed)
	self:SetCrouchedWalkSpeed(0.5)
	self:SetDuckSpeed(0.3)
	self:SetUnDuckSpeed(0.3)
	self:SetJumpPower(self.jump_power)
	self:AllowFlashlight(true)
	self:SetAvoidPlayers(false)
end