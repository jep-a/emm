BuildService = BuildService or {}

function BuildService.HandleCurrentToolControls(local_ply,key)
	if not local_ply.building then return end
	local_ply.current_tool.Do[key]()
end
hook.Add("KeyPress", "HandleToolControls", BuildService.HandleToolControls)

function BuildService.RenderCurrentToolHUD()
    local local_ply = LocalPlayer()
    if not local_ply.building then return end
    local_ply.current_tool:Render()
end
hook.Add("PostDrawTranslucentRenderables", "RenderCurrentToolHUD", BuildService.RenderCurrentToolHUD)

function BuildService.SnapToGrid(pos, snap_dist)
    if snap_dist == 0 then return pos end

    local new_position = Vector()

    for axis, value in pairs(pos) do
        new_position[axis] = math.Round(value/snap_dist)
    end

    return new_position
end

function BuildService.GetToolPosition()
    return BuildService.SnapToGrid(EyePos()+EyeVector()*LocalPlayer().tool_distance,LocalPlayer().snap_distance)
end

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