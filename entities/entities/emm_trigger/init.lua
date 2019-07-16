AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


-- # Initialize

function ENT:Initialize()
	local angle = self.angle or Vector(0,0,0)
	local lobby = self.lobby
	
	angle:Rotate(Angle(0, 90, 0))
	self:SetWidth(self.width or 0) 
	self:SetHeight((self.height ~= 0 and self.height) or 0)
	self:SetNormal(angle)
	self:SetDepth(self.depth or 0)
	self:SetPos(self.pos)
	self:SetID(self.id)
	self:SetLobby(self.lobby)
	self:SetType(self.type)
	self:SetNotSolid(true)
	self:SetNoDraw(false)
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetTrigger(true)
	self:SetCollision()
	
	if lobby > 0 then
		table.insert(MinigameService.lobbies[lobby].ents, self)
	end
	
	hook.Run("Emm_Trigger_Init", self)

	if self.Phys and self.Phys:IsValid() then
		self.Phys:Sleep()
		self.Phys:EnableCollisions(false)
	end
end


-- # Utils

function ENT:SetCollision()
	if self:GetShape() == "sphere" then
		self:PhysicsInitSphere(self:GetWidth(), "default")
	else
		self:PhysicsInitConvex(self:GetCollision())
	end

	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end