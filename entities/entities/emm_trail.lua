AddCSLuaFile()

ENT.Type = "anim"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Sprite")
	self:NetworkVar("Bool", 0, "Remove")

	if SERVER then
		self:NetworkVarNotify("Remove", self.StartRemove)
	end
end

function ENT:Initialize()
	self:DrawShadow(false)

	if SERVER then
		local sprite = util.SpriteTrail(self, 0, COLOR_WHITE, false, 25, 25, 4, 0.125, "emm/trail/flat.vmt")

		self:SetSprite(sprite)
		self:DeleteOnRemove(sprite)
	else
		self.width = AnimatableValue.New(25)
	end
end

local REMOVE_DURATION = 4

function ENT:StartRemove()
	if SERVER then
		local trail_pos = trail:GetPos()

		self:SetParent(nil)
		self:SetPos(trail_pos)
		self:SetRemove(true)

		timer.Simple(REMOVE_DURATION, function ()
			self:Remove()
		end)
	else
		self.width:AnimateTo(0, REMOVE_DURATION)
	end
end

function ENT:SetWidth(w)
	local sprite = self:GetSprite()

	if IsValid(sprite) then
		sprite:SetKeyValue("startwidth", w)
		sprite:SetKeyValue("endwidth", w)
	end
end

function ENT:Think()
	self:NextThink(CurTime())

	if CLIENT then
		local owner = self:GetOwner()
		local parent = self:GetParent()
		local sprite = self:GetSprite()

		self:SetWidth(self.width.current)

		if IsValid(sprite) then
			sprite:SetColor(self:GetColor())
		end

		local render_pos

		if IsValid(owner) and owner:IsPlayer() then
			local parent_is_valid = IsValid(parent)

			local pos

			if parent_is_valid then
				pos = parent:GetPos() + Vector(0, 0, 4)
			else
				pos = self:GetPos()
			end

			if parent_is_valid and owner == LocalPlayer() and owner:Alive() then
				local eye_norm = Angle(0, owner:EyeAngles().y, 0):Forward()

				local trace = util.TraceLine({
					start = pos,
					endpos = pos + (eye_norm * Vector(-50, -50, 0)),
					mask = MASK_NPCWORLDSTATIC
				})

				render_pos = trace.HitPos - eye_norm * Vector(-4, -4, 0)
			else
				render_pos = pos
			end
		else
			render_pos = parent_is_valid and parent:GetPos() or self:GetPos()
		end

		self:SetRenderOrigin(render_pos)
	end

	return true
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Draw()
	--
end
