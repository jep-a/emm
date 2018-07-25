local TOOL = ToolType.New()

TOOL.name           = "no_tool"
TOOL.show_name      = "None"
TOOL.description    = "No tool selected"

--TOOL.Control[IN_ATTACK] = function()
--    print("USED NOTHING")
--end

BuildService.RegisterBuildTool(TOOL)