HUDService = HUDService or {}

-- # Panels

local HUDContainer = {}

function HUDContainer:Init()
	self:SetSize(ScrW(), ScrH())
end

vgui.Register("HUDContainer", HUDContainer, "EditablePanel")

local HUDCrosshair = {}

function HUDCrosshair:Init()
	self:SetSize(8, 8)
	self:Center()
end

function HUDCrosshair:Paint(w, h)
	draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(COLOR_BLACK, COLOR_BLACK.a/6))
	draw.RoundedBox(4, 1, 1, w - 2, h - 2, ColorAlpha(COLOR_WHITE, COLOR_WHITE.a/4))
	surface.SetDrawColor(COLOR_WHITE)
	surface.DrawOutlinedRect(2, 2, w - 4, h - 4)
end

vgui.Register("HUDCrosshair", HUDCrosshair, "EditablePanel")

-- # Init

function HUDService.Init()
	HUDService.container = vgui.Create("HUDContainer")
	HUDService.crosshair = vgui.Create("HUDCrosshair")
	HUDService.container:Add(HUDService.crosshair)
end
hook.Add("InitPostEntity", "HUDService.Init", HUDService.Init)

function HUDService.Reload()
	HUDService.container:Remove()
	HUDService.Init()
end
hook.Add("OnReloaded", "HUDService", HUDService.Reload)

local hud_elements = {"CHudCrosshair", "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
function HUDService.ShouldDraw(name)
	if table.HasValue(hud_elements, name) then
		return false
	end
end
hook.Add("HUDShouldDraw", "HUDService.ShouldDraw", HUDService.ShouldDraw)