local BuildObjects = BuildService.BuildObjects

local TOOL = ToolType.New()

TOOL.name           = "delete_face"
TOOL.show_name      = "Delete Face"

TOOL.description    = [[
    Create a point by clicking anywhere.
    
    Left click to delete a face
]]

function TOOL:OnEquip()
    for _, face in pairs(BuildObjects.Faces) do
        face:SetShouldRender(true)
        face.clickable = true
    end

    chat.AddText(self.description)
end

function TOOL:OnHolster()
    for _, face in pairs(BuildObjects.Faces) do
        face:SetShouldRender(true)
        face.clickable = false
    end
end

function TOOL:Render()
end

TOOL.Press[IN_ATTACK] = function()
    local hovered_edge = BuildService.GetHoveredFace() 
    hovered_edge:Finish()
end

BuildService.RegisterBuildTool(TOOL)