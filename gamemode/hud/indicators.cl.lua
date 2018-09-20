IndicatorService = IndicatorService or {}

local indicator_material = Material("emm2/shapes/arrow.png", "noclamp smooth")
local circle_material = Material("emm2/shapes/circle.png", "noclamp smooth")


-- # Init

function IndicatorService.CreateContainer()
	local element = Element.New {
		width_percent = 1,
		height_percent = 1
	}

	element.panel:SetPaintedManually(true)

	return element
end

function IndicatorService.Sort(ply, eye_pos)
	local eye_pos = LocalPlayer():EyePos()
	local indicators = IndicatorService.container.children

	for i = 1, #indicators do
		local indicator = indicators[i]

		local pos
	
		if IsValid(indicator.entity) then
			pos = indicator.entity:WorldSpaceCenter()
		elseif indicator.position then
			pos = indicator.position
		end
	
		if pos then
			indicator.distance = eye_pos:Distance(pos)
			indicator.panel:SetZPos(i)
		end
	end

	table.sort(indicators, function(a, b) return a.distance > b.distance end)
end
hook.Add("Think", "IndicatorService.Sort", IndicatorService.Sort)

function IndicatorService.DrawWorldPositions(ply, eye_pos)
	local eye_pos = LocalPlayer():EyePos()
	local indicators = IndicatorService.container.children
	local container_alpha = IndicatorService.container.attributes.alpha.current

	for i = 1, #indicators do
		local indicator = indicators[i]

		local pos
	
		if IsValid(indicator.entity) then
			pos = indicator.entity:WorldSpaceCenter()
		elseif indicator.position then
			pos = indicator.position
		end

		if pos then
			cam.Start3D()

			local screen_pos = (pos + Vector(0, 0, Lerp(indicator.distance/600, 40, 45))):ToScreen()
		
			cam.End3D()

			local size = Lerp(indicator.distance/800, INDICATOR_WORLD_SIZE * 2, INDICATOR_WORLD_SIZE)
			local x, y = screen_pos.x - (size/2), screen_pos.y - 6 - (size/2)
		
			indicator.x = x
			indicator.y = y
		
			surface.SetAlphaMultiplier(CombineAlphas(container_alpha, indicator.attributes.alpha.current, indicator.world_alpha.current))
			Element.PaintTexture(nil, indicator_material, x, y, 0, size, size, indicator:GetColor())
			surface.SetAlphaMultiplier(1)
		end
	end
end
hook.Add("DrawIndicators", "IndicatorService.DrawWorldPositions", IndicatorService.DrawWorldPositions)

function IndicatorService.RenderCoasters()
	local indicators = IndicatorService.container.children

	for i = 1, #indicators do
		local indicator = indicators[i]

		if IsValid(indicator.entity) then
			local pos = indicator.entity:GetPos() + Vector(0, 0, 5)

			local trace = util.TraceLine {
				start = pos,
				endpos = pos - Vector(0, 0, 100000),
				mask = MASK_NPCWORLDSTATIC
			}

			local alpha = CombineAlphas(indicator.attributes.alpha.current, Lerp(trace.Fraction * 8, 255, 50))

			if alpha > 0 then
				cam.Start3D2D(trace.HitPos + (trace.HitNormal * Vector(0.5, 0.5, 0.5)), trace.HitNormal:Angle() + Angle(90, 0, 0), 0.25)
				surface.SetAlphaMultiplier(alpha)
				surface.SetDrawColor(indicator.entity.color)
				surface.SetMaterial(circle_material)
				surface.DrawTexturedRect(-INDICATOR_COASTER_SIZE/2, -INDICATOR_COASTER_SIZE/2, INDICATOR_COASTER_SIZE, INDICATOR_COASTER_SIZE)
				surface.SetAlphaMultiplier(1)
				cam.End3D2D()
			end
		end
	end
end
hook.Add("PreDrawOpaqueRenderables", "IndicatorService.RenderCoasters", IndicatorService.RenderCoasters)

function IndicatorService.Add(lobby, ply)
	if IsLocalPlayer(ply) then
		for _, _ply in pairs(lobby.players) do
			if ply ~= _ply then
				_ply.indicator = Indicator.New(_ply)
				IndicatorService.container:Add(_ply.indicator)
			end
		end
	else
		ply.indicator = Indicator.New(ply)
		IndicatorService.container:Add(ply.indicator)
	end
end
hook.Add("LocalLobbyPlayerJoin", "IndicatorService.Add", IndicatorService.Add)
hook.Add("LocalLobbyPlayerSpawn", "IndicatorService.Add", function (lobby, ply)
	if not IsLocalPlayer(ply) and not ply.indicator then
		IndicatorService.Add(lobby, ply)
	end
end)

hook.Add("LocalLobbyPlayerDeath", "IndicatorService.Remove", function (lobby, ply)
	if not IsLocalPlayer(ply) and ply.indicator then
		ply.indicator:Finish()
	end
end)

function IndicatorService.Clear(lobby, ply)
	if IsLocalPlayer(ply) then
		IndicatorService.container:Clear()
	elseif ply.indicator then
		ply.indicator:Finish()
	end
end
hook.Add("LocalLobbyPlayerLeave", "IndicatorService.Clear", IndicatorService.Clear)

function IndicatorService.ReloadIndicators()
	local ply = LocalPlayer()

	if ply.lobby then
		IndicatorService.Add(ply.lobby, ply)
	end
end

function IndicatorService.Init()
	IndicatorService.container = IndicatorService.CreateContainer()
end
hook.Add("InitUI", "IndicatorService.Init", IndicatorService.Init)

function IndicatorService.Reload()
	IndicatorService.container:Finish()
	IndicatorService.Init()
	IndicatorService.ReloadIndicators()
end
hook.Add("OnReloaded", "IndicatorService.Reload", IndicatorService.Reload)

function IndicatorService.Show()
	IndicatorService.container:AnimateAttribute("alpha", 255)
end

hook.Add("LocalPlayerSpawn", "IndicatorService.Show", function ()
	if not LobbyUIService.open then
		IndicatorService.Show()
	end
end)

hook.Add("OnLobbyUIClose", "IndicatorService.Show", IndicatorService.Show)

function IndicatorService.Hide()
	IndicatorService.container:AnimateAttribute("alpha", 0)
end
hook.Add("LocalPlayerDeath", "IndicatorService.Hide", IndicatorService.Hide)
hook.Add("OnLobbyUIOpen", "IndicatorService.Hide", IndicatorService.Hide)

function IndicatorService.Draw()
	IndicatorService.container.panel:PaintManual()
end
hook.Add("DrawIndicators", "IndicatorService.Draw", IndicatorService.Draw)
