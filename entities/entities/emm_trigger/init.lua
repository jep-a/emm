AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

function ENT:Initialize()
	local ang = self.angle
	local lobby = self.lobby

	self.can_tag_tables = {}

	self:SetPos(self.position)
	self:SetRadius(self.radius or 0)
	self:SetWidth(self.width or 0)
	self:SetHeight(self.height or 0)
	self:SetDepth(self.depth or 0)
	self:SetNormal(ang:Right())
	self:SetID(self.id)
	self:SetType(self.type)
	self:SetLooksAtPlayers(self.looks_at_players)
	self:SetFloats(self.floats)
	self:SetOwnerTag(self.owner_tag)

	if self.can_tag then
		self:SetCanTag(self.can_tag)
	end

	self:SetNoDraw(!self.model)
	self:DrawShadow(false)
	self:SetTrigger(true)
	self:SetCollision()

	if self.model then
		self:SetModel(self.model)
		self:SetModelScale(self.model_scale or 1)
	end

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Sleep()
		phys:EnableCollisions(false)
	end

	hook.Run("TriggerInit", self)
end

function ENT:SetCollision()
	if self:GetShape() == EMM_TRIGGER_SHAPE_BOX then
		self:PhysicsInitConvex(self:GetCollision())
	end

	self:EnableCustomCollisions(true)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:StartTouch(ent)
	if self:CanTouchEntity(ent) then
		hook.Run("TriggerStartTouch", self, ent)
	end
end

function ENT:EndTouch(ent)
	if self:CanTouchEntity(ent) then
		hook.Run("TriggerEndTouch", self, ent)
	end
end

function ENT:Think()
	if self:GetShape() == EMM_TRIGGER_SHAPE_SPHERE then
		local ents = ents.FindInSphere(self:GetPos(), self:GetRadius())

		for i = 1, #ents do
			local ent = ents[i]

			if
				self ~= ent and
				ent:IsPlayer() and
				ent:Alive() and
				MinigameService.IsSharingLobby(self, ent) and
				ent.player_class and
				self.can_tag[ent.player_class.key]
			then
				hook.Run("TriggerStartTouch", self, ent)
			end
		end
	end
end