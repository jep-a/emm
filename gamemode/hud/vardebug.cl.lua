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

	surface.SetTextColor(COLOR_WHITE)
	surface.SetTextPos(0, h/2 - label_h/2)
	surface.DrawText(label)

	local val_padding = 3
	local val_x, val_y = label_w + (val_padding * 2) + 2, h/2 - val_h/2
	surface.SetDrawColor(LocalPlayer().color or COLOR_GRAY)
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
	VarDebugService.speed.func = function () return math.Round(ply:GetVelocity():Length()/10) end
	VarDebugService.container:Add(VarDebugService.speed)

	VarDebugService.airaccel = vgui.Create "VarDebug"
	VarDebugService.airaccel.label = "Airaccel"
	VarDebugService.airaccel.func = function () return math.Round(ply.stamina.airaccel.amount) end
	VarDebugService.container:Add(VarDebugService.airaccel)
	
	VarDebugService.lobby = vgui.Create "VarDebug"
	VarDebugService.lobby.label = "Lobby"
	VarDebugService.lobby.func = function () return ply.lobby and ply.lobby.id end
	VarDebugService.side_container:Add(VarDebugService.lobby)

	VarDebugService.state = vgui.Create "VarDebug"
	VarDebugService.state.label = "State"
	VarDebugService.state.func = function () return ply.lobby and ply.lobby.state and ply.lobby.state.name end
	VarDebugService.side_container:Add(VarDebugService.state)

	VarDebugService.player_class = vgui.Create "VarDebug"
	VarDebugService.player_class.label = "Class"
	VarDebugService.player_class.func = function () return ply.player_class and ply.player_class.name end
	VarDebugService.side_container:Add(VarDebugService.player_class)
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