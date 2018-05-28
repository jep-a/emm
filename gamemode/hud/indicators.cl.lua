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

function IndicatorService.AddIndicators(lobby, ply)
	if ply == LocalPlayer() then
		for _, _ply in pairs(lobby.players) do
			if not (ply == _ply) then
				_ply.indicator = vgui.Create "Indicator"
				_ply.indicator.ent = _ply
				IndicatorService.container:Add(_ply.indicator)
			end
		end
	else
		ply.indicator = vgui.Create "Indicator"
		ply.indicator.player = ply
		IndicatorService.container:Add(ply.indicator)
	end
end
hook.Add("LocalLobbyAddPlayer", "IndicatorService.AddIndicators", IndicatorService.AddIndicators)

function IndicatorService.RemoveIndicators(lobby, ply)
	if ply == LocalPlayer() then
		IndicatorService.container:Clear()
	else
		ply.indicator:Remove()
	end
end
hook.Add("LocalLobbyRemovePlayer", "IndicatorService.RemoveIndicators", IndicatorService.RemoveIndicators)


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