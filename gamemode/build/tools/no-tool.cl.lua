local TOOL = ToolType.New()

TOOL.name           = "no_tool"
TOOL.show_name      = "None"
TOOL.description    = "No tool selected"

function TOOL:OnEquip()
    for _, primitive in pairs(BuildService.BuildObjects.Primitives) do
        primitive:SetShouldRender(true)
        primitive.clickable = true
    end
end
function TOOL:OnHolster()
    for _, primitive in pairs(BuildService.BuildObjects.Primitives) do
        primitive:SetShouldRender(false)
        primitive.clickable = false
    end
end


BuildService.RegisterBuildTool(TOOL)

