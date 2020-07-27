include "shared.lua"

ENT.RenderGroup	= RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	local min, max = self:GetBounds()

	self.can_tag_tables = {}

	self:SetRenderBounds(min, max)
	self:CallOnRemove("Finish", self.Finish)

	self.thickness = 4
	self.closest_player = self:GetClosestPlayer()

	self.animatable_color = AnimatableValue.New(self:GetColor(), {
		smooth = true
	})

	self.animatable_angle = AnimatableValue.New(Angle(0, 0, 0), {
		smooth = true,
		smooth_multiplier = 0.66
	})

	self.opacity = AnimatableValue.New()
	self.opacity:AnimateTo(255, 0.2)

	if IsValid(self.closest_player) then
		self.animatable_angle:SnapTo((self:GetPos() - self.closest_player:WorldSpaceCenter()):Angle())
	end
end

function ENT:GetIndicatorName()
	local name
	local owner = self:GetOwner()

	if self.indicator_name then
		name = self.indicator_name
	else
		local indicator_name = self:GetNWString "IndicatorName"

		if IsValid(owner) then
			if IsLocalPlayer(owner) then
				name = "your "..indicator_name
			else
				name = owner:GetName().."'s "..indicator_name
			end
		else
			name = indicator_name
		end
	end

	return name
end

function ENT:RenderSphere(pos, radius, thickness, color)
	render.ClearStencil()

	render.SetColorMaterial()
	render.SetStencilEnable(true)

	render.SetStencilReferenceValue(3)
	render.SetStencilWriteMask(3)
	render.SetStencilTestMask(2)

	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)

	render.DrawSphere(pos, -radius, 50, 50, COLOR_WHITE_CLEAR)

	render.SetStencilZFailOperation(STENCIL_INCR)
	render.DrawSphere(pos, radius, 50, 50, COLOR_WHITE_CLEAR)

	render.SetStencilZFailOperation(STENCIL_INCR)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.DrawSphere(pos, -radius + thickness, 50, 50, COLOR_WHITE_CLEAR)

	render.SetStencilZFailOperation(STENCIL_DECR)
	render.DrawSphere(pos, radius - thickness, 50, 50, COLOR_WHITE_CLEAR)

	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetColorMaterialIgnoreZ()
	render.DrawSphere(pos, -radius, 50, 50, color)

	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)

	render.DrawSphere(pos, -radius, 50, 50, COLOR_WHITE_CLEAR)

	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.DrawSphere(pos, radius, 50, 50, COLOR_WHITE_CLEAR)

	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilPassOperation(STENCIL_INCR)
	render.DrawSphere(pos, -radius + thickness, 50, 50, COLOR_WHITE_CLEAR)

	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.DrawSphere(pos, radius - thickness, 50, 50, COLOR_WHITE_CLEAR)

	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetColorMaterialIgnoreZ()
	render.DrawSphere(pos, -radius, 50, 50, color)

	render.SetStencilEnable(false)
end

function ENT:RenderBox(pos, width, height, depth, norm, thickness, color)
	local box_norm = Vector()
	box_norm:Set(norm)

	local box_norm_rotated = Vector()
	box_norm_rotated:Set(norm)
	box_norm_rotated:Rotate(Angle(0, -90, 0))

	local box_pos = pos + Vector(0, 0, thickness/2)
	local box_width = box_norm * width
	local box_height = Vector(0, 0, height - (thickness/2))
	local box_depth = box_norm_rotated * depth

	render.SetColorMaterialIgnoreZ()

	render.DrawBeam(box_pos, box_pos + box_width, thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_height, box_pos + box_width + box_height, thickness, 0, 1, color)
	render.DrawBeam(box_pos, box_pos + box_height, thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_width, box_pos + box_width + box_height, thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_depth, box_pos + box_width + box_depth , thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_height + box_depth, box_pos + box_width + box_height + box_depth, thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_depth, box_pos + box_height + box_depth, thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_width + box_depth, box_pos + box_width + box_height + box_depth, thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_depth, box_pos , thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_height + box_depth, box_pos + box_height, thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_width + box_depth, box_pos + box_width , thickness, 0, 1, color)
	render.DrawBeam(box_pos + box_width + box_height + box_depth, box_pos + box_width + box_height, thickness, 0, 1, color)

	render.DrawSphere(box_pos, thickness/2, 15, 15, color)
	render.DrawSphere(box_pos + box_width, thickness/2, 15, 15, color)
	render.DrawSphere(box_pos + box_height, thickness/2, 15, 15, color)
	render.DrawSphere(box_pos + box_width + box_height, thickness/2 , 15, 15, color)
	render.DrawSphere(box_pos + box_depth, thickness/2, 15, 15, color)
	render.DrawSphere(box_pos + box_width + box_depth, thickness/2, 15, 15, color)
	render.DrawSphere(box_pos + box_height + box_depth, thickness/2, 15, 15, color)
	render.DrawSphere(box_pos + box_width + box_height + box_depth, thickness/2, 15, 15, color)
end

function ENT:Think()
	if MinigameService.IsSharingLobby(self) then
		self.closest_player = self:GetClosestPlayer()
	end
end

function ENT:GetClosestPlayer()
	local closest_ply

	if self.lobby then
		local plys = self.lobby.players
		local pos = self:GetPos()

		for i = 1, #plys do
			local ply = plys[i]

			if IsValid(ply) and (not IsValid(closest_ply) or pos:Distance(closest_ply:GetPos()) > pos:Distance(ply:GetPos())) and ply ~= self:GetOwner() then
				closest_ply = ply
			else
				closest_ply = closest_ply
			end
		end
	end

	return closest_ply
end

function ENT:Draw()
	if MinigameService.IsSharingLobby(self) then
		local pos = self:GetPos()
		local radius = self:GetRadius()
		local width = self:GetWidth()
		local color = self.animatable_color.smooth

		surface.SetAlphaMultiplier(self.opacity.current/255)

		if self:GetModel() then
			self:DrawModel()

			if IsValid(self.closest_player) then
				self.animatable_angle.current = (self:GetPos() - self.closest_player:WorldSpaceCenter()):Angle()
				self.animatable_angle.current:Normalize()
			end

			self:SetRenderOrigin(self:GetPos() + Vector(0, 0, math.sin(CurTime() * 2)/16))
			self:SetRenderAngles(Angle(-self.animatable_angle.smooth.p, self.animatable_angle.smooth.y - 180, 0))
		elseif self:GetShape() == EMM_TRIGGER_SHAPE_SPHERE then
			self:RenderSphere(pos, self:GetRadius(), self.thickness, color)
		elseif self:GetShape() == EMM_TRIGGER_SHAPE_BOX then
			self:RenderBox(pos, width, self:GetHeight(), self:GetDepth(), self:GetNormal(), self.thickness, color)
		end

		surface.SetAlphaMultiplier(1)
	end
end

function ENT:Finish()
	self.animatable_color:Finish()
	self.animatable_angle:Finish()
	self.opacity:Finish()
end
