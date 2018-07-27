-- # Classes

GeometryType = Class.New()

function GeometryType:Init()
    self.should_render = true
end

-- ## Point

local POINT_RADIUS = 5

GeometryPoint = Class.New(GeometryType)

function GeometryPoint:Init()
	self.super.Init(self)
	self.pos = Vector()
	self.should_render = true
	self.clickable = true
end

function GeometryPoint:Render()
    if self.should_render == false then return end
	render.SetColorMaterial()
	render.DrawSphere(self.pos, POINT_RADIUS, 20, 20, Color(255,255,255))

	if not self:IsHovered() then return end
	render.DrawWireframeSphere(self.pos, POINT_RADIUS+1, 20, 20, Color(255,0,255))
end
Class.AddHook(GeometryPoint, "PostDrawTranslucentRenderables", "Render")

function GeometryPoint:SetPos(position)
	self.pos = position
end

function GeometryPoint:GetPos()
	return self.pos
end

function GeometryPoint:IsHovered()
	local box_corner = Vector(1,1,1)*(POINT_RADIUS/2)
	local hit_pos,_,_ = util.IntersectRayWithOBB(EyePos(), EyeVector()*6000, self.pos, Angle(0), -box_corner, box_corner)
	return (hit_pos ~= nil)
end

-- ## Edge

GeometryEdge = Class.New(GeometryType)

function GeometryEdge:Init()
	self.super.Init(self)
	self.pos = Vector()
	self.should_render = true
	self.clickable = true
	self.points = {}
end

function GeometryEdge:Render()
    if self.should_render == false then return end
end
Class.AddHook(GeometryEdge, "PostDrawTranslucentRenderables", "Render")

function GeometryEdge:SetPos(position)
	self.pos = position
end

function GeometryEdge:GetPos()
	return self.pos
end

function GeometryEdge:IsHovered()
	local box_corner = Vector(1,1,1)*(POINT_RADIUS/2)
	local hit_pos,_,_ = util.IntersectRayWithOBB(EyePos(), EyeVector()*6000, self.pos, Angle(0), -box_corner, box_corner)
	return (hit_pos ~= nil)
end

-- ## Face

GeometryFace = Class.New(GeometryType)

function GeometryFace:Init()
	self.super.Init(self)
end

function GeometryFace:Render()
end
-- ## Primitive

GeometryPrimitive = Class.New(GeometryType)

function GeometryPrimitive:Init()
	self.super.Init(self)
end

function GeometryPrimitive:Render()
end

-- ## Primitve group

GeometryPrimitiveGroup = Class.New(GeometryType)

function GeometryPrimitiveGroup:Init()
	self.super.Init(self)
end