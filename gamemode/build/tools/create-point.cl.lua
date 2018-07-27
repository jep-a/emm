local BuildObjects = BuildService.BuildObjects

local TOOL = ToolType.New()

TOOL.name           = "create_point"
TOOL.show_name      = "Create Point"

TOOL.description    = [[
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
    BuildUtil.RenderToolCursor()
end

TOOL.Press[IN_ATTACK] = function()
    local new_point = GeometryPoint.New()
    new_point:SetPos(BuildUtil.GetToolPosition())
    new_point.should_render = true
    table.insert(BuildObjects.Points, new_point)
end

BuildService.RegisterBuildTool(TOOL)