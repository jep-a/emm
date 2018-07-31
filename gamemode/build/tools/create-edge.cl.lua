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
    
    for _, edge in pairs(BuildService.BuildObjects.Edges) do
        edge.should_render = true
        for _, point in pairs(edge.points) do
            point.should_render = true
        end
    end
    chat.AddText(self.description)
end

function TOOL:OnHolster()
    for _, edge in pairs(BuildService.BuildObjects.Edges) do
        edge.should_render = false
        for _, point in pairs(edge.points) do
            point.should_render = false
        end
    end
end

function TOOL:Render()
    BuildService.RenderToolCursor()
    
    if not self.placing_edge then return end
    local start_pos = self.start_point
    local tool_pos = BuildService.cursor.smooth

    render.SetColorMaterial()
    render.DrawSphere(start_pos, 2, 10, 10, COLOR_WHITE)
    render.DrawSphere(tool_pos, 2, 10, 10, COLOR_LAVENDER)
    render.DrawBeam(start_pos, tool_pos, 1, 0, 1, Color(255,255,255,150))
end

TOOL.Press[IN_ATTACK] = function()
    TOOL.placing_edge = true
    TOOL.start_point = BuildService.GetToolPosition()
end

TOOL.Release[IN_ATTACK] = function()
    if not TOOL.placing_edge then return end
    if TOOL.start_point:Distance(BuildService.GetToolPosition()) < 4 then 
        TOOL.placing_edge = false
        return 
    end

    TOOL.placing_edge = false
    
    local point_A = GeometryPoint.New()
    local point_B = GeometryPoint.New()

    point_A:SetPos(TOOL.start_point)
    point_B:SetPos(BuildService.GetToolPosition())

    local edge_A = GeometryEdge.New()
    edge_A.should_render = true
    edge_A.points = {
        point_A,
        point_B
    }

    point_A:AttachEdge(edge_A)
    point_A.should_render = true

    point_B:AttachEdge(edge_A)
    point_B.should_render = true

    BuildService.RegisterEdges{edge_A}
    BuildService.RegisterPoints{point_A, point_B}
end

TOOL.Release[IN_RELOAD] = function()
    TOOL.placing_edge = false
end

BuildService.RegisterBuildTool(TOOL)