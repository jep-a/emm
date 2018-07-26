-- # Classes

GeometryType = Class.New()

function GeometryType:Init()
    self.should_render = true
end

-- ## Point

GeometryPoint = Class.New(GeometryType)

function GeometryPoint:Init()
	self.super.Init(self)
	self.pos = Vector()
	self.should_render = true
end

function GeometryPoint:Render()
    if self.should_render == false then return end
	render.SetColorMaterial()
	render.DrawSphere(self.pos, 5, 20, 20, Color(255,255,255))
end

function GeometryPoint:SetPos(position)
	self.pos = position
end

function GeometryPoint:GetPos()
	return self.pos
end
Class.AddHook(GeometryPoint, "PostDrawTranslucentRenderables", "Render")

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