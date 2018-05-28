IndicatorService = IndicatorService or {}


-- # Panels

local IndicatorContainer = {}

function IndicatorContainer:Init()
	self:SetSize(ScrW(), ScrH())
end

vgui.Register("IndicatorContainer", IndicatorContainer, "EditablePanel")

local Indicator = {}

function Indicator:Init()
	self:SetSize(24, 24)
end

function Indicator:Think()
	if IsValid(self.ent) then
		local pos = self.ent:WorldSpaceCenter()
		local dist = LocalPlayer():EyePos():Distance(pos)

		cam.Start3D()
		local screen_pos = (pos + Vector(0, 0, Lerp(dist/600, 40, 45))):ToScreen()
		cam.End3D()

		local s = Lerp(dist/800, 64, 20)
		local x, y = screen_pos.x, screen_pos.y - 6
		self:SetSize(s, s)
		self:SetPos(x - s/2, y - s/2)
	else
		self:Remove()
	end
end

local indicator_material = Material("emm/indicator/arrow.png", "noclamp smooth")
function Indicator:Paint(w, h)
	surface.SetDrawColor(self.ent.color or COLOR_WHITE)
	surface.SetMaterial(indicator_material)
	surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("Indicator", Indicator, "EditablePanel")


-- # Adding

function IndicatorService.AddIndicator(lobby, ent)
	if not (ent == LocalPlayer()) then
		if IsValid(ent.indicator) then
			ErrorNoHalt "still has indicator"
		end

		ent.indicator = vgui.Create "Indicator"
		ent.indicator.ent = ent
		IndicatorService.container:Add(ent.indicator)
	end
end
hook.Add("LocalLobbyAddPlayer", "IndicatorService.AddIndicator", IndicatorService.AddIndicator)

function IndicatorService.RemoveIndicator(lobby, ent)
	if not (ent == LocalPlayer()) then
		ent.indicator:Remove()
	end
end
hook.Add("LocalLobbyRemovePlayer", "IndicatorService.RemoveIndicator", IndicatorService.RemoveIndicator)


-- # Init

function IndicatorService.Init()
	IndicatorService.container = vgui.Create "IndicatorContainer"
end
hook.Add("InitPostEntity", "IndicatorService.Init", IndicatorService.Init)

function IndicatorService.Reload()
	IndicatorService.container:Remove()
	IndicatorService.Init()
end
hook.Add("OnReloaded", "IndicatorService", IndicatorService.Reload)