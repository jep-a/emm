AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

function ENT:Initialize()
	local ang = self.angle
	local lobby = self.lobby

	self:SetWidth(self.width or 0)
	self:SetHeight(self.height or 0)
	self:SetDepth(self.depth or 0)
	self:SetNormal(ang:Right())
	self:SetPos(self.position)
	self:SetID(self.id)
	self:SetType(self.type)
	self:SetNotSolid(true)
	self:SetNoDraw(false)
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetTrigger(true)
	self:SetCollision()

	hook.Run("TriggerInit", self)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Sleep()
		phys:EnableCollisions(false)
	end
end

function ENT:SetCollision()
	self:SetSolid(SOLID_VPHYSICS)

	if self:GetShape() == EMM_TRIGGER_SHAPE_SPHERE then
		self:PhysicsInitSphere(self:GetWidth(), "default")
	else
		self:PhysicsInitConvex(self:GetCollision())
	end

	self:EnableCustomCollisions(true)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end