local TOOL = ToolType.New()

TOOL.name           = "create_edge"
TOOL.show_name      = "Create Edge"

TOOL.description    = [[
    Create an edge by clicking and dragging.

    Left click and drag to create an edge between two points.
    Reload while dragging to cancel the edge.
    Scroll up and down to change the tool distance.
]]

function TOOL:OnEquip()
    self.placing_edge = false
    self.start_point = Vector(0)
    
    chat.AddText(self.description)
end

function TOOL:RenderCurrentEdge()
    if not self.placing_edge then return end

    local start_pos = self.start_point
    local tool_pos = BuildService.GetToolPosition()

    render.SetColorMaterial()
    render.DrawSphere(start_pos, 2, 10, 10, COLOR_WHITE)
    render.DrawSphere(tool_pos, 2, 10, 10, COLOR_LAVENDER)
    render.DrawBeam(start_pos, tool_pos, 1, 0, 1, Color(255,255,255,150))
end

function TOOL:Render()
    BuildService.RenderToolCursor()
    self:RenderCurrentEdge()
end

TOOL.Press[IN_ATTACK] = function()
    TOOL.placing_edge = true
    TOOL.start_point = BuildService.GetToolPosition()
end

TOOL.Release[IN_ATTACK] = function()
    if not TOOL.placing_edge then return end

    TOOL.placing_edge = false
    local new_points = {
        GeometryPoint.New(),
        GeometryPoint.New()
    }

    new_points[1]:SetPos(TOOL.start_point)
    new_points[2]:SetPos(BuildService.GetToolPosition())

    BuildService.AddPoint(new_points[1])
    BuildService.AddPoint(new_points[2])

    local new_edge = GeometryEdge.New()
    new_edge.should_render = true
    new_edge.points = new_points

    BuildService.AddEdge(new_edge)
end

TOOL.Release[IN_RELOAD] = function()
    TOOL.placing_edge = false
end

BuildService.RegisterBuildTool(TOOL)