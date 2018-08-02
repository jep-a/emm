local TOOL = ToolType.New()

TOOL.name           = "move_edge"
TOOL.show_name      = "Move Edge"

TOOL.description    = [[
    Move an edge by clicking and dragging.

    Left click and drag to create an edge between two points.
]]

function TOOL:OnEquip()
    self.moving_face = false
    self.selected_face = {}
    
    for _, edge in pairs(BuildService.BuildObjects.Edges) do
        edge.clickable = true
    end

    for _, face in pairs(BuildService.BuildObjects.Faces) do
        face:SetShouldRender(true)
    end

    chat.AddText(self.description)
end

function TOOL:OnHolster()
    for _, edge in pairs(BuildService.BuildObjects.Edges) do
        edge.clickable = false
    end

    for _, face in pairs(BuildService.BuildObjects.Faces) do
        face:SetShouldRender(false)
    end
end

function TOOL:Render()
    if not self.moving_edge then return end
    BuildService.RenderToolCursor()

    self.selected_edge:SetCenter(BuildService.cursor.smooth)
end

TOOL.Press[IN_ATTACK] = function()
    local hovered_edge = BuildService.GetHoveredEdge() 
    if hovered_edge == nil then return end
    
    TOOL.moving_edge = true
    TOOL.selected_edge = hovered_edge
    
    local edge_center = hovered_edge:GetCenter()
    local local_ply = LocalPlayer()
    TOOL.saved_tool_distance = local_ply.tool_distance
    TOOL.saved_edge_position = edge_center
    local_ply.tool_distance = local_ply:EyePos():Distance(edge_center)
    BuildService.LookAt(edge_center)
end

TOOL.Release[IN_ATTACK] = function()
    TOOL.moving_edge = false
end

TOOL.Release[IN_RELOAD] = function()
    TOOL.placing_edge = false
end

BuildService.RegisterBuildTool(TOOL)