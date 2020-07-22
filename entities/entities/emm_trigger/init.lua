AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

function ENT:Initialize()
	local ang = self.angle
	local lobby = self.lobby

	self.can_tag_tables = {}

	self:SetPos(self.position)
	self:SetWidth(self.width or 0)
	self:SetHeight(self.height or 0)
	self:SetDepth(self.depth or 0)
	self:SetNormal(ang:Right())
	self:SetID(self.id)
	self:SetType(self.type)

	if self.can_tag then
		self:SetCanTag(self.can_tag)
	end

	self:SetNotSolid(true)
	self:SetNoDraw(!self.model)
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetTrigger(true)
	self:SetCollision()

	if self.model then
		self:SetModel(self.model)
		self:SetModelScale(self.model_scale or 1)
	end

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
		local size = self:GetWidth()

		self:PhysicsInitSphere(self:GetWidth(), "default")
		self:SetCollisionBounds(Vector(-size, -size, -size ), Vector(size, size, size))
	else
		self:PhysicsInitConvex(self:GetCollision())
	end

	self:EnableCustomCollisions(true)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end