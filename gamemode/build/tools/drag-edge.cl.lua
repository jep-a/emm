local TOOL = ToolType.New()

TOOL.name           = "drag_edge"
TOOL.show_name      = "Drag Edge"

TOOL.description    = [[
    Create a face by dragging out an edge.

    Press left click and drag an edge out.
    Press reload while dragging to cancel.
    Press use while dragging to switch dragging modes.
]]

function TOOL:OnEquip()
    self.dragging = false
    self.selected_edge = {}
    self.drag_rel = Vector(0,0,0)
    self.place_plane = true
    self.saved_tool_distance = Vector(0,0,0)
    self.previous_cursor_position = Vector(0,0,0)
    self.plane_hitpos = Vector(0,0,0)
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

local CrossMat = Material("decals/light")
function TOOL:Render()
    if not self.dragging then return end

    local local_ply = LocalPlayer()
    local edge_startpoint = self.selected_edge.points[1]:GetPos()
    local edge_endpoint = self.selected_edge.points[2]:GetPos()
    local plane_origin = (edge_startpoint + edge_endpoint)/2
    local plane_normal = (edge_endpoint - edge_startpoint):GetNormalized()
    local cursor_pos = local_ply:EyePos() + local_ply:EyeAngles():Forward()*local_ply.tool_distance
    local cursor_pos_rel = cursor_pos - plane_origin
    local cursor_proj = (cursor_pos - plane_origin):Dot(plane_normal) * plane_normal
    local ray_trace = util.IntersectRayWithPlane(LocalPlayer():EyePos(), LocalPlayer():EyeAngles():Forward()*6000, plane_origin, plane_normal)
    self.plane_hitpos = (ray_trace and self.place_plane) and ray_trace or (cursor_pos - cursor_proj)
    
    if self.place_plane then
        local_ply.tool_distance = local_ply:EyePos():Distance(self.plane_hitpos)
    end

    self.drag_rel = self.plane_hitpos and (self.plane_hitpos - plane_origin) or plane_origin
    local drag_world_start = edge_startpoint + self.drag_rel
    local drag_world_end = edge_endpoint + self.drag_rel

    local edge_radius = (edge_endpoint - edge_startpoint):Length()/2
    if not self.place_plane and cursor_proj:Length() > edge_radius then
        BuildService.LookAt(self.plane_hitpos + cursor_proj:GetNormalized()*edge_radius)
    end

    render.SetColorMaterial()
    render.DrawBeam(edge_startpoint, drag_world_start, 1, 0, 1, Color(255,255,255,255))
    render.DrawBeam(edge_endpoint, drag_world_end, 1, 0, 1, Color(255,255,255,255))
    render.DrawBeam(drag_world_start, drag_world_end, 1, 0, 1, Color(255,255,255,255))
    render.DrawBeam(plane_origin, self.plane_hitpos, 1, 0, 1, COLOR_LAVENDER)

    render.SetMaterial(CrossMat)
    local drag_cross_h = self.drag_rel:GetNormalized()*10
    local drag_cross_v = drag_cross_h:Cross(plane_normal):GetNormalized()*10
    render.DrawBeam(self.plane_hitpos - drag_cross_h, self.plane_hitpos + drag_cross_h, 1, 0, 1, COLOR_WHITE)
    render.DrawBeam(self.plane_hitpos + drag_cross_v, self.plane_hitpos - drag_cross_v, 1, 0, 1, COLOR_WHITE)
end

TOOL.Press[IN_ATTACK] = function()
    local hovered_edge = BuildService.GetHoveredEdge() 
    if hovered_edge == nil then return end

    TOOL.dragging = true
    TOOL.selected_edge = hovered_edge
    
    local edge_center = hovered_edge:GetCenter()
    local local_ply = LocalPlayer()
    TOOL.saved_tool_distance = local_ply.tool_distance
    local_ply.tool_distance = local_ply:EyePos():Distance(edge_center)

    TOOL.previous_cursor_position = edge_center
    BuildService.LookAt(hovered_edge:GetCenter())
end

TOOL.Press[IN_RELOAD] = function()
    TOOL.dragging = false
    TOOL.select_edge = {}
    TOOL.place_plane = true
    LocalPlayer().tool_distance = TOOL.saved_tool_distance
end

TOOL.Press[IN_USE] = function()
    if not TOOL.place_plane then
        BuildService.LookAt(TOOL.plane_hitpos)
    end
    TOOL.place_plane = not TOOL.place_plane
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
    TOOL.place_plane = true
    LocalPlayer().tool_distance = TOOL.saved_tool_distance
end

BuildService.RegisterBuildTool(TOOL)