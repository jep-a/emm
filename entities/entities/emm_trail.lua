AddCSLuaFile()

ENT.Type = "anim"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Sprite")
end

function ENT:Initialize()
	self:DrawShadow(false)

	if SERVER then
		local sprite = util.SpriteTrail(self, 0, COLOR_WHITE, false, 25, 25, 4, 0.125, "emm/trail/flat.vmt")

		self:SetSprite(sprite)
		self:DeleteOnRemove(sprite)
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
