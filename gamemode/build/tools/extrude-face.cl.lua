local TOOL = ToolType.New()

TOOL.name           = "extrude_face"
TOOL.show_name      = "Extrude Face"

TOOL.description    = [[
    Create a primitive by dragging out a face.

    Press left click and drag a face out.
    Press reload while dragging to cancel.
]]

function TOOL:OnEquip()
    self.dragging = false
    self.selected_face = {}
    self.drag_rel = Vector(0,0,0)
    self.new_positions = {}
    for _, primitive in pairs(BuildService.BuildObjects.Primitives) do
        primitive:SetShouldRender(true)
    end
    for _, face in pairs(BuildService.BuildObjects.Faces) do
        face:SetShouldRender(true)
        face.clickable = true
    end

    chat.AddText(self.description)
end

function TOOL:OnHolster()
    for _, primitive in pairs(BuildService.BuildObjects.Primitives) do
        primitive:SetShouldRender(false)
    end
    for _, face in pairs(BuildService.BuildObjects.Faces) do
        face:SetShouldRender(false)
        face.clickable = false
    end
end

function TOOL:Render()
    if not self.dragging then return end
    local face_normal = self.selected_face:GetNormal()
    local face_center = self.selected_face:GetCenter()
    local local_ply = LocalPlayer()
    local eye_vec = local_ply:EyeAngles():Forward()
    local eye_pos = local_ply:EyePos()
    local plane_norm = face_normal:Cross(eye_vec):Cross(face_normal)
    local cursor_pos = util.IntersectRayWithPlane(eye_pos, eye_vec, face_center, plane_norm)
    local cursor_rel = cursor_pos - face_center
    self.drag_rel = cursor_rel:Dot(face_normal)*face_normal

    render.SetColorMaterial()
    render.DrawBeam(face_center, face_center + self.drag_rel, 1, 0, 1, COLOR_LAVENDER)
    local first_point = nil
    for i = 1, 4 do
        local point_pos = self.selected_face.points[i]:GetPos()
        self.new_positions[i] = self.selected_face.points[i]:GetPos() + self.drag_rel

        render.DrawBeam(point_pos, self.new_positions[i], 1, 0, 1, COLOR_WHITE)

        if i == 1 then
            render.DrawBeam(self.selected_face.points[4]:GetPos() + self.drag_rel, self.new_positions[i], 1, 0, 1, COLOR_WHITE)
        else
            render.DrawBeam(self.new_positions[i-1], self.new_positions[i], 1, 0, 1, COLOR_WHITE)
        end
    end

end

TOOL.Press[IN_ATTACK] = function()
    local hovered_face = BuildService.GetHoveredFace() 
    if hovered_face == nil then return end

    BuildService.LookAt(hovered_face:GetCenter())
    TOOL.dragging = true
    TOOL.selected_face = hovered_face
end

TOOL.Press[IN_RELOAD] = function()
    TOOL.dragging = false
end
TOOL.Release[IN_ATTACK] = function()
    if not TOOL.dragging then return end
    TOOL.dragging = false

    local new_points = {}
    local side_edges = {}
    local top_edges = {}
    for i = 1,4 do
        new_points[i] = GeometryPoint.New()
        new_points[i]:SetPos(TOOL.new_positions[i])

        side_edges[i] = GeometryEdge.New()
        side_edges[i]:SetPoints(TOOL.selected_face.points[i], new_points[i])
        
        if i > 1 then
            top_edges[i-1] = GeometryEdge.New()
            top_edges[i-1]:SetPoints(new_points[i-1], new_points[i])
        end
    end
    top_edges[4] = GeometryEdge.New()
    top_edges[4]:SetPoints(new_points[1], new_points[4])

    local side_faces = {}
    for i = 1,3 do
        side_faces[i] = GeometryFace.New()
        side_faces[i]:SetPoints(TOOL.selected_face.points[i], new_points[i], new_points[i+1], TOOL.selected_face.points[i+1])
        side_faces[i]:SetEdges(TOOL.selected_face.edges[i], side_edges[i], side_edges[i+1], top_edges[i])
        side_faces[i]:SetShouldRender(true)
        side_faces[i].clickable = true
    end
    side_faces[4] = GeometryFace.New()
    side_faces[4]:SetPoints(TOOL.selected_face.points[4], new_points[4], new_points[1], TOOL.selected_face.points[1])
    side_faces[4]:SetEdges(TOOL.selected_face.edges[4], side_edges[4], side_edges[1], top_edges[4])
    side_faces[4]:SetShouldRender(true)
    side_faces[4].clickable = true

    local top_face = GeometryFace.New()
    top_face:SetPoints(new_points[1], new_points[2], new_points[3], new_points[4])
    top_face:SetEdges(top_edges[1], top_edges[2], top_edges[3], top_edges[4])
    top_face:SetShouldRender(true)
    top_face.clickable = true

    local new_primitive = GeometryPrimitive.New()
    new_primitive:SetFaces {
        side_faces[1],
        side_faces[2],
        side_faces[3],
        side_faces[4],
        TOOL.selected_face,
        top_face
    }
    new_primitive.should_render = true

    BuildService.RegisterPoints(new_points)
    BuildService.RegisterEdges(side_edges)
    BuildService.RegisterEdges(top_edges)
    BuildService.RegisterFaces(side_faces)
    BuildService.RegisterFaces{top_face}
    BuildService.RegisterPrimitives{new_primitive}

    local undo_data = {}
    table.Add(undo_data, new_points)
    table.Add(undo_data, side_edges)
    table.Add(undo_data, top_edges)
    table.Add(undo_data, side_faces)
    table.insert(undo_data, top_face)
    table.insert(undo_data, new_primitive)
    BuildService.AddUndoHistory("Extruded face", undo_data)
end

BuildService.RegisterBuildTool(TOOL)