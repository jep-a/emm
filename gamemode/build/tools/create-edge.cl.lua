local TOOL = ToolType.New()

TOOL.name           = "create_edge"
TOOL.show_name      = "Create Edge"

TOOL.description    = [[
    Left click and drag to create an edge between two points.
    Reload while dragging to cancel the edge.
    Scroll up and down to change the tool distance.
]]

TOOL.placing_edge = false
TOOL.start_point = Vector()

function TOOL:OnEquip()
    chat.AddText(self.description)
end

function TOOL:RenderCurrentEdge()
    if not self.placing_edge then return end

    local start_pos = self.start_point
    local tool_pos = BuildUtil.GetToolPosition()

    render.SetColorMaterial()
    render.DrawSphere(start_pos, 2, 10, 10, COLOR_WHITE)
    render.DrawSphere(tool_pos, 2, 10, 10, COLOR_LAVENDER)
    render.DrawLine(start_pos, tool_pos, COLOR_WHITE)
end

function TOOL:Render()
    BuildUtil.RenderToolCursor()
    self:RenderCurrentEdge()
end

TOOL.Press[IN_ATTACK] = function()
    self.placing_edge = true
    self.start_point = BuildUtil.GetToolPosition
end

TOOL.Release[IN_ATTACK] = function()
    self.placing_edge = false
end

BuildService.RegisterBuildTool(TOOL)