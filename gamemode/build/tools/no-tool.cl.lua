local TOOL = ToolType.New()

TOOL.name           = "no_tool"
TOOL.show_name      = "None"
TOOL.description    = "No tool selected"
TOOL.icon_path      = "materials/build/tool-icons/"..TOOL.name..".png"

--TOOL.Control[IN_ATTACK] = function()
--    print("USED NOTHING")
--end

BuildService.RegisterBuildTool(TOOL)