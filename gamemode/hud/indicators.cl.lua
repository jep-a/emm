IndicatorService = IndicatorService or {}


-- # Panels

local IndicatorContainer = {}

function IndicatorContainer:Init()
	self:SetSize(ScrW(), ScrH())
end

vgui.Register("IndicatorContainer", IndicatorContainer, "EditablePanel")

local Indicator = {}

local indicator_material = Material("emm/indicator/arrow.png", "noclamp smooth")
function Indicator:Paint(w, h)
	surface.SetDrawColor(self.ent and self.ent.color or COLOR_WHITE)
	surface.SetMaterial(indicator_material)
	surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("Indicator", Indicator, "EditablePanel")


-- # Calculating positions

function IndicatorService.CalculatePos()
	cam.Start3D()

	local eye_pos = LocalPlayer():EyePos()
	for _, indicator in pairs(IndicatorService.container:GetChildren()) do
		local pos = indicator.ent:WorldSpaceCenter()
		local dist = eye_pos:Distance(pos)
		local screen_pos = (pos + Vector(0, 0, Lerp(dist/600, 40, 45))):ToScreen()
		local s = Lerp(dist/800, 64, 20)
		local x, y = screen_pos.x - (s/2), screen_pos.y - 6 - (s/2)
		indicator:SetSize(s, s)
		indicator:SetPos(x, y)
	end

	cam.End3D()
end
hook.Add("InitPostEntity", "IndicatorService.DrawOverlay", function ()
	hook.Add("DrawOverlay", "IndicatorService.CalculatePos", IndicatorService.CalculatePos)
end)
hook.Add("OnReloaded", "IndicatorService.DrawOverlay", function ()
	hook.Add("DrawOverlay", "IndicatorService.CalculatePos", IndicatorService.CalculatePos)
end)


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
		ply.indicator.ent = ply
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

function IndicatorService.ReloadIndicators()
	local ply = LocalPlayer()
	if ply.lobby then
		IndicatorService.AddIndicators(ply.lobby, ply)
	end
end


-- # Init

function IndicatorService.Init()
	IndicatorService.container = vgui.Create "IndicatorContainer"
end
hook.Add("InitPostEntity", "IndicatorService.Init", IndicatorService.Init)

function IndicatorService.Reload()
	IndicatorService.container:Remove()
	IndicatorService.Init()
	IndicatorService.ReloadIndicators()
end
hook.Add("OnReloaded", "IndicatorService", IndicatorService.Reload)