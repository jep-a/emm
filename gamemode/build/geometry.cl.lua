local POINT_RADIUS = 2
local EDGE_SELECT_RADIUS = 2

local POINT_DRAW_COLOR = COLOR_WHITE
local POINT_TINT_STRENGTH = 2

local EDGE_DRAW_COLOR = COLOR_WHITE
local EDGE_TINT_STRENGTH = 2000

local FACE_DRAW_COLOR = COLOR_SKY
local FACE_TINT_STRENGTH = 4

local SELECTION_TINT = COLOR_RED

local QUAD_MATERIAL = CreateMaterial( "HUD_debugwhite", "UnlitGeneric", {
 ["$basetexture"] = "models/debug/debugwhite",
 ["$model"] = 1,
 ["$translucent"] = 1,
 ["$vertexalpha"] = 1,
 ["$vertexcolor"] = 1
} )

local function MixColors(pool_color, drop_color, drop_strength)
    return Color(
        (pool_color.r + drop_color.r*drop_strength)/(1+drop_strength),
        (pool_color.g + drop_color.g*drop_strength)/(1+drop_strength),
        (pool_color.b + drop_color.b*drop_strength)/(1+drop_strength),
        (pool_color.a + drop_color.a*drop_strength)/(1+drop_strength)
    )
end

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
	self.should_render = false
	self.clickable = false
    self.attached_edges = {}
    self.attached_faces = {}
end

local POINT_SELECTION_COLOR = MixColors(POINT_DRAW_COLOR, SELECTION_TINT, POINT_TINT_STRENGTH)
function GeometryPoint:Render()
    if self.should_render == false then return end
    render.SetColorMaterial()

    if self:IsHovered() then
        local draw_color = POINT_SELECTION_COLOR
    else
        local draw_color = POINT_DRAW_COLOR
    end
    render.DrawSphere(self.pos, POINT_RADIUS, 20, 20, draw_color)
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

function GeometryPoint:AttachFace(face)
	if table.HasValue(self.attached_faces, face) then return end
	table.insert(self.attached_faces,face)
end

function GeometryPoint:DetachFace(face)
	table.RemoveByValue(self.attached_faces, face)
end

function GeometryPoint:SetShouldRender(value)
    self.should_render = true
end

-- ## Edge

GeometryEdge = Class.New(GeometryType)

function GeometryEdge:Init()
	self.super.Init(self)
	self.should_render = false
	self.clickable = false
    self.points = {}
    self.attached_faces = {}
end

local EDGE_SELECTION_COLOR = MixColors(EDGE_DRAW_COLOR, SELECTION_TINT, EDGE_TINT_STRENGTH)
function GeometryEdge:Render()
    if self.should_render == false then return end
    render.SetColorMaterial()
    local draw_color = Color(0,0,0)
    if self:IsHovered() then
        draw_color = EDGE_SELECTION_COLOR
    else
        draw_color = EDGE_DRAW_COLOR
    end

    render.DrawBeam(self.points[1]:GetPos(), self.points[2]:GetPos(), 1, 0, 1, draw_color)
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
    
    local angle = edge_vec:Angle()
    box_corner = Vector(edge_length/2, EDGE_SELECT_RADIUS, EDGE_SELECT_RADIUS)
	local hit_pos,_,_ = util.IntersectRayWithOBB(EyePos(), EyeVector()*6000, (start_pos + end_pos)/2, angle, -box_corner, box_corner)
	return self.clickable and hit_pos or nil
end

function GeometryEdge:IsHovered()
    return self:LookingAt() ~= nil
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
    for _, point in pairs(self.points) do
        point:SetShouldRender(value)
    end
end

function GeometryEdge:AttachFace(face)
	if table.HasValue(self.attached_faces, face) then return end
	table.insert(self.attached_faces,face)
end

function GeometryEdge:DetachFace(face)
	table.RemoveByValue(self.attached_faces, face)
end


-- ## Face

GeometryFace = Class.New(GeometryType)

function GeometryFace:Init()
    self.super.Init(self)
    self.edges = {}
    self.points = {}
    self.should_render = false
    self.normal = Vector(0)
    self.clickable = false
end

local FACE_SELECTION_COLOR = MixColors(FACE_DRAW_COLOR, SELECTION_TINT, FACE_TINT_STRENGTH)
function GeometryFace:Render()
    if not self.should_render then return end
    render.SetColorMaterial()
    local face_center = self:GetCenter()

    local draw_color = Color(0,0,0)
    if self:IsHovered() then
        draw_color = FACE_SELECTION_COLOR
    else
        draw_color = FACE_DRAW_COLOR
    end

    for _, point in pairs(self.points) do
        render.DrawLine(face_center, point:GetPos(), draw_color, true)
    end
    for _, edge in pairs(self.edges) do
        render.DrawLine(face_center, edge:GetCenter(), draw_color, true)
    end
    
    render.SetMaterial(QUAD_MATERIAL)
    render.DrawQuad(self.points[1]:GetPos(), self.points[2]:GetPos(), self.points[3]:GetPos(), self.points[4]:GetPos(), ColorAlpha(draw_color,100))
    render.DrawQuad(self.points[4]:GetPos(), self.points[3]:GetPos(), self.points[2]:GetPos(), self.points[1]:GetPos(), ColorAlpha(draw_color,100))
end
Class.AddHook(GeometryFace, "PostDrawTranslucentRenderables", "Render")

function GeometryFace:SetPoints(point_A, point_B, point_C, point_D, autodetect_edges)
    if #self.points > 0 then return end
    self.points = {point_A, point_B, point_C, point_D}

    for _, point in pairs(self.points) do
        point:AttachFace(self)
    end

    if not autodetect_edges then return end
    local branching_points = {point_A}
    local hidden_points = {point_B, point_C, point_D}
    local loop = {}

    while #loop ~= 4 do
        for _, branching_point in pairs(branching_points) do
            for _, edge in pairs(branching_point.attached_edges) do
                local branch_end = (edge.points[1] == branching_point) and edge.points[1] or edge_points[2]
                if table.HasValue(hidden_points, branch_end) then
                    table.RemoveByValue(hidden_points, branch_end)
                    table.insert(loop, edge)
                    table.insert(branching_points, branch_end)
                    edge:AttachFace(self)
                end
            end
            table.RemoveByValue(branching_points, branching_point)
        end
    end

    self.edges = loop
    
    --Only neccessary when drawing quads
    self:OrderPoints()
end

function GeometryFace:SetEdges(edge_A, edge_B, edge_C, edge_D)
    if #self.edges > 0 then return end
    self.edges = {edge_A, edge_B, edge_C, edge_D}
    
    --Only neccessary when drawing quads
    self:OrderPoints()
end

function GeometryFace:OrderPoints()
    local edge_points = self.edges[1].points
    local unkown_points = {}
    for _, point in pairs(self.points) do
        if point ~= edge_points[1] and point ~= edge_points[2] then
            table.insert(unkown_points, point)
        end
    end
    local origin = edge_points[1]:GetPos()
    local starting_vector = edge_points[2]:GetPos() - edge_points[1]:GetPos()

    table.sort(self.points, function(point_A, point_B)
        local vector_A = point_A:GetPos() - origin
        local vector_B = point_B:GetPos() - origin

        if vector_B == Vector(0,0,0) then return true end --Move the origin to the top
        if vector_B == starting_vector then return true end --Move the origin to the top
        
        local cross_A = starting_vector:Cross(vector_A):Length()
        local cross_B = starting_vector:Cross(vector_B):Length()

        return cross_B < cross_A --Move up points with lower angles
    end)

    local vector_i = self.points[2]:GetPos() - self.points[1]:GetPos()
    local vector_j = self.points[3]:GetPos() - self.points[1]:GetPos()

    self.normal = vector_i:Cross(vector_j):GetNormalized()
end

function GeometryFace:SetShouldRender( value )
    self.should_render = value
    for _, edge in pairs(self.edges) do
        edge:SetShouldRender(value)
    end
end

function GeometryFace:GetCenter()
    local sum = Vector(0,0,0)
    for _, point in pairs(self.points) do
        sum = sum + point:GetPos()
    end
    return sum/4
end

function GeometryFace:LookingAt()
    local angle = self.normal:Angle()
    local select_radius = 32000
    local face_center = self:GetCenter()

    for _, point in pairs(self.points) do
        local radius = point:GetPos():Distance(face_center)
        if radius < select_radius then
            select_radius = radius
        end
    end
    select_radius = select_radius

    box_corner = Vector(2, select_radius/2, select_radius/2)
	local hit_pos,_,_ = util.IntersectRayWithOBB(EyePos(), EyeVector()*6000, face_center, angle, -box_corner, box_corner)
	return self.clickable and hit_pos or nil
end

function GeometryFace:IsHovered()
    return self:LookingAt() ~= nil
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