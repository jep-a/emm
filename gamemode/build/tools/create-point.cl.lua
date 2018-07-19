local TOOL = ToolType:New()

TOOL.name           = "createpoint"
TOOL.show_name      = "Create Point"

TOOL.description    = [[
    Left click to place a point.
    Scroll up and down to change the distance of the point.
]]

TOOL.icon_path      = "materials/build/tool-icons/"..TOOL.name..".png"

function TOOL:Render()
    local pointPos = BuildService.GetToolPosition()
end