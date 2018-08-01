VarDebugService = VarDebugService or {}


-- # Panels

surface.CreateFont("VarDebugFont", {font = "Roboto Mono", size = 16})

local VarDebugContainer = {}

function VarDebugContainer:PerformLayout()
	self:SetSize(ScrW()/2 - 32, ScrH()/2 - 32)
	self:AlignRight(0)
	self:AlignTop(ScrH()/2)
end

vgui.Register("VarDebugContainer", VarDebugContainer, "EditablePanel")

local SideVarDebugContainer = {}

function SideVarDebugContainer:PerformLayout()
	self:SetSize(128, ScrH()/2 - 32)
	self:AlignRight(0)
	self:AlignTop(ScrH()/2)
end

vgui.Register("SideVarDebugContainer", SideVarDebugContainer, "EditablePanel")

local VarDebug = {}

function VarDebug:Init()
	self:Dock(TOP)
	self:SetTall(20)
end

function VarDebug:Paint(w, h)
	local ply = LocalPlayer()
	local label = string.upper(self.label or self.accessor or self.variable or "?")
	local val = self.func and self.func() or self.accessor and ply[self.accessor](ply) or ply:GetTable()[self.variable] or "?"
	local val_str = string.upper(istable(val) and table.ToString(val) or tostring(val))

	surface.SetFont "VarDebugFont"
	local label_w, label_h = surface.GetTextSize(label)
	local val_w, val_h = surface.GetTextSize(val_str)

	surface.SetTextColor(LocalPlayer().color)
	surface.SetTextPos(0, h/2 - label_h/2)
	surface.DrawText(label)

	local val_padding = 3
	local val_x, val_y = label_w + (val_padding * 2) + 2, h/2 - val_h/2
	surface.SetDrawColor(COLOR_GRAY)
	surface.DrawRect(val_x - val_padding, val_y + 1, val_w + (val_padding * 2), val_h)
	surface.SetTextPos(val_x, val_y)
	surface.DrawText(val_str)
end

vgui.Register("VarDebug", VarDebug, "EditablePanel")


-- # Init

function VarDebugService.Init()
	local ply = LocalPlayer()

	VarDebugService.container = vgui.Create "VarDebugContainer"
	VarDebugService.side_container = vgui.Create "SideVarDebugContainer"
	CamUIService.AddPanel(VarDebugService.container)
	CamUIService.AddPanel(VarDebugService.side_container)

	VarDebugService.health = vgui.Create "VarDebug"
	VarDebugService.health.accessor = "Health"
	VarDebugService.container:Add(VarDebugService.health)

	VarDebugService.speed = vgui.Create "VarDebug"
	VarDebugService.speed.label = "Speed"
	VarDebugService.speed.func = function ()
		return math.Round(ply:GetVelocity():Length()/10)
	end
	VarDebugService.container:Add(VarDebugService.speed)

	VarDebugService.airaccel = vgui.Create "VarDebug"
	VarDebugService.airaccel.label = "Airaccel"
	VarDebugService.airaccel.func = function ()
		return math.Round(ply.stamina.airaccel.amount)
	end
	VarDebugService.container:Add(VarDebugService.airaccel)
	
	VarDebugService.wallslide = vgui.Create "VarDebug"
	VarDebugService.wallslide.label = "Wallslide"
	VarDebugService.wallslide.func = function ()
		return math.Round(ply.stamina.wallslide.amount)
	end
	VarDebugService.container:Add(VarDebugService.wallslide)

	VarDebugService.lobby = vgui.Create "VarDebug"
	VarDebugService.lobby.label = "Lobby"
	VarDebugService.lobby.func = function () return ply.lobby and ply.lobby.id end
	VarDebugService.side_container:Add(VarDebugService.lobby)

	VarDebugService.state = vgui.Create "VarDebug"
	VarDebugService.state.label = "State"
	VarDebugService.state.func = function ()
		return ply.lobby and ply.lobby.state and ply.lobby.state.name
	end
	VarDebugService.side_container:Add(VarDebugService.state)

	VarDebugService.state_time = vgui.Create "VarDebug"
	VarDebugService.state_time.label = "Time"
	VarDebugService.state_time.func = function ()
		return (
			ply.lobby and
			ply.lobby.state and
			ply.lobby.state.time and
			ply.lobby.last_state_start and
			string.Trim(string.FormattedTime((ply.lobby.last_state_start + ply.lobby.state.time + 1) - CurTime(), "%2i:%02i"))
		)
	end
	VarDebugService.side_container:Add(VarDebugService.state_time)

	VarDebugService.player_class = vgui.Create "VarDebug"
	VarDebugService.player_class.label = "Class"
	VarDebugService.player_class.func = function () return ply.player_class and ply.player_class.name end
	VarDebugService.side_container:Add(VarDebugService.player_class)

	VarDebugService.can_build = vgui.Create "VarDebug"
	VarDebugService.can_build.label = "Can Build"
	VarDebugService.can_build.func = function ()
		return LocalPlayer().can_build
	end
	VarDebugService.side_container:Add(VarDebugService.can_build)
	
	VarDebugService.building = vgui.Create "VarDebug"
	VarDebugService.building.label = "Building"
	VarDebugService.building.func = function ()
		return LocalPlayer().building
	end
	VarDebugService.side_container:Add(VarDebugService.building)

	VarDebugService.current_tool = vgui.Create "VarDebug"
	VarDebugService.current_tool.label = "Current Tool"
	VarDebugService.current_tool.func = function ()
		return LocalPlayer().current_tool.show_name or ""
	end
	VarDebugService.container:Add(VarDebugService.current_tool)

	VarDebugService.tool_distance = vgui.Create "VarDebug"
	VarDebugService.tool_distance.label = "Tool distance"
	VarDebugService.tool_distance.func = function ()
		return LocalPlayer().tool_distance
	end
	VarDebugService.container:Add(VarDebugService.tool_distance)

	VarDebugService.snap_distance = vgui.Create "VarDebug"
	VarDebugService.snap_distance.label = "Snap distance"
	VarDebugService.snap_distance.func = function ()
		return LocalPlayer().snap_distance
	end
    VarDebugService.container:Add(VarDebugService.snap_distance)
    
    VarDebugService.drag_rel = vgui.Create "VarDebug"
	VarDebugService.drag_rel.label = "Face Drag Rel"
	VarDebugService.drag_rel.func = function ()
		return LocalPlayer().current_tool.drag_rel and LocalPlayer().current_tool.drag_rel:Length() or 0
	end
	VarDebugService.container:Add(VarDebugService.drag_rel)
end
hook.Add("InitPostEntity", "VarDebugService.Init", VarDebugService.Init)

function VarDebugService.AddDebugger(id, func)
	VarDebugService[id] = vgui.Create "VarDebug"
	VarDebugService[id].label = id
	VarDebugService[id].func = func
	VarDebugService.container:Add(VarDebugService[id])
end

function VarDebugService.Reload()
	VarDebugService.container:Remove()
	VarDebugService.side_container:Remove()
	VarDebugService.Init()
end
hook.Add("OnReloaded", "VarDebugService", VarDebugService.Reload)