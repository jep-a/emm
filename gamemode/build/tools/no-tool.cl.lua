local TOOL = ToolType.New()

TOOL.name           = "no_tool"
TOOL.show_name      = "None"
TOOL.description    = "No tool selected"

function TOOL:OnEquip()
end
function TOOL:OnHolster()
end


BuildService.RegisterBuildTool(TOOL)

