AddCSLuaFile()

ENT.Type = "anim"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Sprite")
end

function ENT:Initialize()
	self:DrawShadow(false)

	if SERVER then
		local sprite = util.SpriteTrail(self, 0, COLOR_WHITE, false, 4, 4, 4, 0.125, "emm2/trails/flat.vmt")

		self:SetSprite(sprite)
		self:DeleteOnRemove(sprite)
		self.width = AnimatableValue.New(4)
	end
end

local REMOVE_DURATION = 4

function ENT:StartRemove()
	local owner = self:GetOwner()
	local trail_pos = self:GetPos()

	if IsValid(owner) then
		owner.trail = nil
	end

	self:SetParent(nil)
	self:SetPos(trail_pos)
	self.width:AnimateTo(0, {
		duration = REMOVE_DURATION,
		finish = true,
		callback = function ()
			self:Remove()
		end
	})
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

	if SERVER then
		self:SetWidth(self.width.current)
	else
		local owner = self:GetOwner()
		local parent = self:GetParent()
		local sprite = self:GetSprite()

		if IsValid(sprite) then
			sprite:SetColor(GetAnimatableEntityColor(owner))
		end

		local render_pos

		if IsPlayer(owner) then
			local parent_is_valid = IsValid(parent)

			local pos

			if parent_is_valid then
				pos = parent:GetPos() + Vector(0, 0, 4)
			else
				pos = self:GetPos()
			end

			if parent_is_valid and IsLocalPlayer(owner) and owner:Alive() then
				local eye_norm = Angle(0, owner:EyeAngles().y, 0):Forward()

				local trace = util.TraceLine({
					start = pos,
					endpos = pos + (eye_norm * Vector(-70, -70, 0)),
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
