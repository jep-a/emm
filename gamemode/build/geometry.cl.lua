-- # Classes

GeometryType = Class.New()

function GeometryType:Init()
    self.should_render = true
end

-- ## Point

local POINT_RADIUS = 2

GeometryPoint = Class.New(GeometryType)

function GeometryPoint:Init()
	self.super.Init(self)
	self.pos = Vector()
	self.should_render = false
	self.clickable = false
	self.attached_edges = {}
end

function GeometryPoint:Render()
    if self.should_render == false then return end
	render.SetColorMaterial()
    if self:IsHovered() then
        render.DrawSphere(self.pos, POINT_RADIUS, 20, 20, COLOR_RED)
    else
        render.DrawSphere(self.pos, POINT_RADIUS, 20, 20, COLOR_WHITE)
    end
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
	return self.clickable and (hit_pos ~= nil) or nil
end

function GeometryPoint:AttachEdge(edge)
	if table.HasValue(self.attached_edges, edge) then return end
	table.insert(self.attached_edges,edge)
end

function GeometryPoint:DetachEdge(edge)
	table.RemoveByValue(self.attached_edges, edge)
end

function GeometryPoint:SetShouldRender(value)
    self.should_render = true
end

-- ## Edge

local EDGE_SELECT_RADIUS = 2

GeometryEdge = Class.New(GeometryType)

function GeometryEdge:Init()
	self.super.Init(self)
	self.should_render = false
	self.clickable = false
	self.points = {}
end

function GeometryEdge:Render()
    if self.should_render == false then return end
    render.SetColorMaterial()
    if self:LookingAt() ~= nil then
        render.DrawBeam(self.points[1]:GetPos(), self.points[2]:GetPos(), 1, 0, 1, COLOR_RED)
    else
        render.DrawBeam(self.points[1]:GetPos(), self.points[2]:GetPos(), 1, 0, 1, COLOR_WHITE)
    end
end
Class.AddHook(GeometryEdge, "PostDrawTranslucentRenderables", "Render")

function GeometryEdge:GetCenter()
    return (self.points[1]:GetPos() + self.points[2]:GetPos())/2
end

function GeometryEdge:LookingAt()
    local start_pos = self.points[1]:GetPos()
    local end_pos = self.points[2]:GetPos()
    local edge_vec = end_pos - start_pos
    local edge_length = edge_vec:Length()

    local pitch_ang = -math.deg(math.atan2(edge_vec.z, edge_vec:Length2D()))
    local yaw_ang = math.deg(math.atan2(edge_vec.y, edge_vec.x))
    local angle = Angle(pitch_ang, yaw_ang, 0)

    box_corner = Vector(edge_length/2, EDGE_SELECT_RADIUS, EDGE_SELECT_RADIUS)
	local hit_pos,_,_ = util.IntersectRayWithOBB(EyePos(), EyeVector()*6000, (start_pos + end_pos)/2, angle, -box_corner, box_corner)
	return self.clickable and hit_pos or nil
end

function GeometryEdge:SetPoints(point_A, point_B)
    if #self.points ~= 0 then return end
    
    self.points = {
        point_A,
        point_B
    }
    point_A:AttachEdge(self)
    point_B:AttachEdge(self)
end

function GeometryEdge:SetShouldRender( value )
    self.should_render = value
    self.points[1]:SetShouldRender(value)
    self.points[2]:SetShouldRender(value)
end

-- ## Face

GeometryFace = Class.New(GeometryType)

function GeometryFace:Init()
    self.super.Init(self)
    self.edges = {}
    self.points = {}
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