local BuildObjects = BuildService.BuildObjects

local TOOL = ToolType.New()

TOOL.name           = "create_point"
TOOL.show_name      = "Create Point"

TOOL.description    = [[
    Create a point by clicking anywhere.
    
    Left click to place a point.
    Scroll up and down to change the tool distance of the point.
]]

function TOOL:OnEquip()
    for _, point in pairs(BuildObjects.Points) do
        point.should_render = true
    end
    
    for _, edge in pairs(BuildObjects.Edges) do
        edge.should_render = false
    end

    chat.AddText(self.description)
end

function TOOL:OnHolster()
    for _, point in pairs(BuildObjects.Points) do
        point.should_render = false
    end
end

function TOOL:Render()
    BuildService.RenderToolCursor()
end

TOOL.Press[IN_ATTACK] = function()
    local new_point = GeometryPoint.New()
    new_point:SetPos(BuildService.GetToolPosition())
    new_point.should_render = true
    BuildService.AddPoint(new_point)
end

BuildService.RegisterBuildTool(TOOL)