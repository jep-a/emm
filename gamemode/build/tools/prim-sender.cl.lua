local TOOL = ToolType.New()

TOOL.name           = "prim_sender"
TOOL.show_name      = "Send Primitive"
TOOL.description    = [[
    Click to send a primitive
]]

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

TOOL.Press[IN_ATTACK] = function()
    local primitive = BuildService.GetHoveredPrimitive()
    local vertices = {}
    for _, point in pairs(primitive.points) do
        table.insert(vertices, point:GetPos())
    end

    BuildService.SpawnPrimitive(vertices)
end


BuildService.RegisterBuildTool(TOOL)