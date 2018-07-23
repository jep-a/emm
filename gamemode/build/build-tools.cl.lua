BuildService = BuildService or {}
BuildService.BuildTools = {}

-- # Tool class

ToolType = Class.New()

function ToolType:Init()
    self.description = "Base tool"

    self.Do = {}
    -- # Default scrolling controls
    self.Do[IN_WEAPON1] = function()
        local local_ply = LocalPlayer()
        local tool_distance = local_ply.tool_distance
        local_ply.tool_distance = math.Clamp(tool_distance+5,0,10000)
    end
    self.Do[IN_WEAPON2] = function()
        local local_ply = LocalPlayer()
        local tool_distance = local_ply.tool_distance
        local_ply.tool_distance = math.Clamp(tool_distance-5,0,10000)
    end

    self.icon_path = "materials/build/tool-icons/default.png"
    self.name = "base"
    self.show_name = "Base Tool"
end

function ToolType:Render()
end

EMM.Include {
    "build/tools/no-tool"
}