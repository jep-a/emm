include('shared.lua')
ENT.RenderGroup	= RENDERGROUP_TRANSLUCENT


-- # Initialize

function ENT:Initialize()
	local mins, maxs = self:GetBounds()
	local lobby = self:GetLobby()

	self.thickness = 2
	self:SetDrawColor(COLOR_WHITE, 2)
	self:SetNotSolid(false)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetRenderBounds(mins, maxs)

	if lobby > 0 then
		table.insert(MinigameService.lobbies[lobby].ents, self)
	end
	
	hook.Run("Emm_Trigger_Init", self)
end


-- # Utils

function ENT:SetDrawColor(color, smooth)
	if not self.color then
		self.color = AnimatableValue.New(ColorAlpha(color, 0), {
			smooth = true,
			smooth_multiplier = 2
		})
	end

	self.color.smooth_multiplier = smooth
	self.color.current = color
end

function ENT:GetDrawColor()
	if self.color then
		return self.color.smooth
	end

	return COLOR_WHITE
end


-- # Rendering

function ENT:RenderSphere(pos, radius, thickness, color, only_surface)
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(3)
	render.SetStencilWriteMask(3)
	render.SetStencilTestMask(2)
	render.SetStencilPassOperation((only_surface and STENCIL_KEEP) or STENCIL_REPLACE)
	render.SetStencilZFailOperation((only_surface and STENCIL_REPLACE) or STENCIL_KEEP)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetColorMaterial()
	render.DrawSphere(pos, -radius, 50, 50, Color(0,0,0,0))

	render.SetStencilZFailOperation((only_surface and STENCIL_INCR) or STENCIL_KEEP)
	render.DrawSphere(pos, radius, 50, 50, Color(0,0,0,0))

	render.SetStencilZFailOperation((only_surface and STENCIL_INCR) or STENCIL_KEEP)
	render.SetStencilPassOperation((not only_surface and STENCIL_INCR) or STENCIL_KEEP)
	render.DrawSphere(pos, -radius + thickness/2, 50, 50, Color(0,0,0,0))

	render.SetStencilZFailOperation((only_surface and STENCIL_DECR) or STENCIL_KEEP)
	render.DrawSphere(pos, radius - thickness/2, 50, 50, Color(0,0,0,0))

	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetColorMaterialIgnoreZ()
	render.DrawSphere(pos, -radius , 50, 50, color)

	render.SetStencilEnable(false)
end

function ENT:RenderBox(pos, width, height, depth, angle, thickness, color)
	height = height - (thickness/2)
	height = Vector(0, 0, height)
	pos.z = pos.z + (thickness/2)
	width = angle * width
	angle:Rotate(Angle(0, -90, 0))
	depth = angle * depth

	if color.a >= 1 then
		render.SetColorMaterial()
		render.DrawBeam(pos, pos + width, thickness, 0, 1, color)
		render.DrawBeam(pos + height, pos + width + height, thickness, 0, 1, color)
		render.DrawBeam(pos, pos + height, thickness, 0, 1, color)
		render.DrawBeam(pos + width, pos + width + height, thickness, 0, 1, color)
		render.DrawBeam(pos + depth, pos + width + depth , thickness, 0, 1, color)
		render.DrawBeam(pos + height + depth, pos + width + height + depth, thickness, 0, 1, color)
		render.DrawBeam(pos + depth, pos + height + depth, thickness, 0, 1, color)
		render.DrawBeam(pos + width + depth, pos + width + height + depth, thickness, 0, 1, color)
		render.DrawBeam(pos + depth, pos , thickness, 0, 1, color)
		render.DrawBeam(pos + height + depth, pos + height, thickness, 0, 1, color)
		render.DrawBeam(pos + width + depth, pos + width , thickness, 0, 1, color)
		render.DrawBeam(pos + width + height + depth, pos + width + height, thickness, 0, 1, color)

		render.DrawSphere(pos, thickness/2, 15, 15, color)
		render.DrawSphere(pos + width, thickness/2, 15, 15, color)
		render.DrawSphere(pos + height, thickness/2, 15, 15, color)
		render.DrawSphere(pos + width + height, thickness/2 , 15, 15, color)
		render.DrawSphere(pos + depth, thickness/2, 15, 15, color)
		render.DrawSphere(pos + width + depth, thickness/2, 15, 15, color)
		render.DrawSphere(pos + height + depth, thickness/2, 15, 15, color)
		render.DrawSphere(pos + width + height + depth, thickness/2, 15, 15, color)
	end
end

function ENT:Draw()
	local ply = GetPlayer()

	if self:PlayerInLobby(ply) then
		local color, thickness = self:GetDrawColor(), self.thickness
			
		if self:GetShape() == "sphere" then
			self:RenderSphere(self:GetPos(), self:GetWidth(), thickness, color)
		else
			self:RenderBox(self:GetPos(), self:GetWidth(), self:GetHeight(), self:GetDepth(), self:GetNormal(), thickness, color)
		end
	end
end
