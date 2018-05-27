VarDebugService = VarDebugService or {}


-- # Panels

surface.CreateFont("VarDebugFont", {font = "Roboto Mono", size = 16})

local VarDebugContainer = {}

function VarDebugContainer:PerformLayout()
	self:SetSize(ScrW()/2 - 32, ScrH()/2)
	self:AlignRight(0)
	self:AlignBottom(0)
end

vgui.Register("VarDebugContainer", VarDebugContainer, "EditablePanel")

local VarDebug = {}

function VarDebug:Init()
	VarDebugService.container:Add(self)
	self:Dock(TOP)
	self:SetTall(20)
end

function VarDebug:Paint(w, h)
	local ply = LocalPlayer()
	local label = string.upper(self.label or self.accessor or self.variable or "?")
	local val = self.func and self.func() or self.accessor and ply[self.accessor](ply) or ply:GetTable()[self.variable] or "?"
	local val_str = string.upper(istable(val) and table.ToString(val) or tostring(val))

	surface.SetFont("VarDebugFont")
	local label_w, label_h = surface.GetTextSize(label)
	local val_w, val_h = surface.GetTextSize(val_str)

	surface.SetTextColor(COLOR_WHITE)
	surface.SetTextPos(0, h/2 - label_h/2)
	surface.DrawText(label)

	local val_padding = 3
	local val_x, val_y = label_w + (val_padding * 2) + 2, h/2 - val_h/2
	surface.SetDrawColor(COLOR_BLUE)
	surface.DrawRect(val_x - val_padding, val_y + 1, val_w + (val_padding * 2), val_h)
	surface.SetTextPos(val_x, val_y)
	surface.DrawText(val_str)
end

vgui.Register("VarDebug", VarDebug, "EditablePanel")


-- # Init

function VarDebugService.Init()
	local ply = LocalPlayer()

	VarDebugService.container = vgui.Create("VarDebugContainer")
	CamUIService.AddPanel(VarDebugService.container)

	VarDebugService.lobby = vgui.Create("VarDebug")
	VarDebugService.lobby.label = "lobby.id"
	VarDebugService.lobby.func = function () return ply.lobby and ply.lobby.id end

	VarDebugService.player_class = vgui.Create("VarDebug")
	VarDebugService.player_class.label = "player_class.name"
	VarDebugService.player_class.func = function () return ply.player_class and ply.player_class.name end

	VarDebugService.health = vgui.Create("VarDebug")
	VarDebugService.health.accessor = "Health"

	VarDebugService.speed = vgui.Create("VarDebug")
	VarDebugService.speed.label = "Speed"
	VarDebugService.speed.func = function () return math.Round(ply:GetVelocity():Length()/10) end
end
hook.Add("InitPostEntity", "VarDebugService.Init", VarDebugService.Init)

function VarDebugService.Reload()
	VarDebugService.container:Remove()
	VarDebugService.Init()
end
hook.Add("OnReloaded", "VarDebugService", VarDebugService.Reload)