local TOOL = ToolType.New()

TOOL.name           = "drag_edge"
TOOL.show_name      = "Drag Edge"

TOOL.description    = [[
    Create a face by dragging out an edge.

    Click and drag an edge out.
]]

function TOOL:OnEquip()
    self.dragging = false
    self.selected_edge = {}
    self.drag_rel = Vector(0,0,0)

    for _, edge in pairs(BuildService.BuildObjects.Edges) do
        edge.should_render = true
        edge.clickable = true
        for _, point in pairs(edge.points) do
            point.should_render = true
        end
    end

    chat.AddText(self.description)
end

function TOOL:OnHolster()
    for _, edge in pairs(BuildService.BuildObjects.Edges) do
        edge.should_render = false
        edge.clickable = false
        for _, point in pairs(edge.points) do
            point.should_render = false
        end
    end

    chat.AddText(self.description)
end

function TOOL:Render()
    if not self.dragging then return end

    local edge_startpoint = self.selected_edge.points[1]:GetPos()
    local edge_endpoint = self.selected_edge.points[2]:GetPos()
    local plane_origin = (edge_startpoint + edge_endpoint)/2
    local plane_normal = edge_endpoint - edge_startpoint

    local plane_hitpos = util.IntersectRayWithPlane(EyePos(), EyeVector()*6000, plane_origin, plane_normal)

    self.drag_rel = plane_hitpos and (plane_hitpos - plane_origin) or plane_origin
    
    local drag_world_start = edge_startpoint + self.drag_rel
    local drag_world_end = edge_endpoint + self.drag_rel

    render.SetColorMaterial()
    render.DrawBeam(edge_startpoint, drag_world_start, 1, 0, 1, Color(255,255,255,255))
    render.DrawBeam(edge_endpoint, drag_world_end, 1, 0, 1, Color(255,255,255,255))
    render.DrawBeam(drag_world_start, drag_world_end, 1, 0, 1, Color(255,255,255,255))
    render.DrawBeam(plane_origin, plane_origin + self.drag_rel, 1, 0, 1, COLOR_LAVENDER)
end

TOOL.Press[IN_ATTACK] = function()
    local hovered_edge = BuildService.GetHoveredEdge() 
    if hovered_edge == nil then return end

    TOOL.dragging = true
    TOOL.selected_edge = hovered_edge

    BuildService.LookAt(hovered_edge:GetCenter())
    
end

TOOL.Press[IN_RELOAD] = function()
    TOOL.dragging = false
    TOOL.select_edge = {}
end

TOOL.Release[IN_ATTACK] = function()
    if not TOOL.dragging then return end 
    
    local edge_A = GeometryEdge.New()
    local point_A = GeometryPoint.New()
    point_A:SetPos(TOOL.selected_edge.points[1]:GetPos() + TOOL.drag_rel)
    edge_A:SetPoints(TOOL.selected_edge.points[1], point_A)
    
    local edge_B = GeometryEdge.New()
    local point_B = GeometryPoint.New()
    point_B:SetPos(TOOL.selected_edge.points[2]:GetPos() + TOOL.drag_rel)
    edge_B:SetPoints(TOOL.selected_edge.points[2], point_B)

    local edge_C = GeometryEdge.New()
    edge_C:SetPoints(point_A, point_B)

    --edge_A:SetShouldRender(true)
    --edge_B:SetShouldRender(true)
    --edge_C:SetShouldRender(true)
    
    edge_A.clickable = true
    edge_B.clickable = true
    edge_C.clickable = true
    BuildService.RegisterEdges{edge_A, edge_B, edge_C}
    BuildService.RegisterPoints{point_A, point_B}

    face_A = GeometryFace.New()
    face_A:SetPoints(point_A, point_B, TOOL.selected_edge.points[1], TOOL.selected_edge.points[2], false)
    face_A:SetEdges(edge_A, edge_B, edge_C, TOOL.selected_edge)
    face_A:SetShouldRender(true)
    BuildService.RegisterFaces{face_A}

    TOOL.dragging = false
    TOOL.selected_edge = {}
end

BuildService.RegisterBuildTool(TOOL)