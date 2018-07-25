local BuildObjects = BuildService.BuildObjects

local TOOL = ToolType.New()

TOOL.name           = "create-point"
TOOL.show_name      = "Create Point"

TOOL.description    = [[
    Left click to place a point.
    Scroll up and down to change the distance of the point.
]]

TOOL.icon_path      = "materials/build/tool-icons/"..TOOL.name..".png"

function TOOL:Render()
    local point_pos = BuildService.GetToolPosition()
    render.DrawWireframeSphere(point_pos, 5, 10, 10, Color(255,255,255,255))

    for _, point in pairs(BuildObjects.Points) do
        if point.should_render then
            point:Render()
        end
    end
end

TOOL.Control[IN_ATTACK] = function()
    local new_point = GeometryPoint.New()
    new_point:SetPos(BuildService.GetToolPosition())
    new_point.should_render = true
    table.insert(BuildObjects.Points, new_point)
end
BuildService.RegisterBuildTool(TOOL)