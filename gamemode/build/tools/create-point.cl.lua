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
    local point_A = GeometryPoint.New()
    point_A:SetPos(BuildService.GetToolPosition())
    point_A.should_render = true
    BuildService.RegisterPoints{point_A}
end

BuildService.RegisterBuildTool(TOOL)