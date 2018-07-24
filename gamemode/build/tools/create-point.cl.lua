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
end

BuildService.RegisterBuildTool(TOOL)