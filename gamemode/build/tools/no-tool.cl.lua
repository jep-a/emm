local TOOL = ToolType:New()

TOOL.name           = "no_tool"
TOOL.show_name      = "None"
TOOL.description    = "No tool selected"
TOOL.icon_path      = "materials/build/tool-icons/"..TOOL.name..".png"

BuildService.RegisterBuildTool(TOOL)