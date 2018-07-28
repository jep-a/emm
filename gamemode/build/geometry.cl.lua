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
	self.should_render = false
	self.clickable = false
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
local EDGE_SELECT_RADIUS = 2
GeometryEdge = Class.New(GeometryType)

function GeometryEdge:Init()
	self.super.Init(self)
	self.pos = Vector()
	self.should_render = false
	self.clickable = false
	self.points = {}
end

function GeometryEdge:Render()
    if self.should_render == false then return end
    render.SetColorMaterial()
    if self:IsHovered() then
        render.DrawBeam(self.points[1]:GetPos(), self.points[2]:GetPos(), 1, 0, 1, COLOR_RED)
    else
        render.DrawBeam(self.points[1]:GetPos(), self.points[2]:GetPos(), 1, 0, 1, COLOR_WHITE)
    end
end
Class.AddHook(GeometryEdge, "PostDrawTranslucentRenderables", "Render")

function GeometryEdge:SetPos(position)
	self.pos = position
end

function GeometryEdge:GetPos()
	return self.pos
end

function GeometryEdge:IsHovered()
    local start_pos = self.points[1]:GetPos()
    local end_pos = self.points[2]:GetPos()
    local edge_vec = end_pos - start_pos
    local edge_length = edge_vec:Length()

    local pitch_ang = -math.deg(math.atan2(edge_vec.z, edge_vec:Length2D()))
    local yaw_ang = math.deg(math.atan2(edge_vec.y, edge_vec.x))
    local angle = Angle(pitch_ang, yaw_ang, 0)

    box_corner = Vector(edge_length/2, EDGE_SELECT_RADIUS, EDGE_SELECT_RADIUS)
	local hit_pos,_,_ = util.IntersectRayWithOBB(EyePos(), EyeVector()*6000, (start_pos + end_pos)/2, angle, -box_corner, box_corner)
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