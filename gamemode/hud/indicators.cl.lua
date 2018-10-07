IndicatorService = IndicatorService or {}

local indicator_material = Material("emm2/shapes/arrow-2x.png", "noclamp smooth")
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

function IndicatorService.ScreenPosition(indicator)
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

		return x, y, size
	end
end

function IndicatorService.DrawWorldPositions(ply, eye_pos)
	local eye_pos = LocalPlayer():EyePos()
	local indicators = IndicatorService.container.children
	local container_alpha = IndicatorService.container.attributes.alpha.current

	for i = 1, #indicators do
		local indicator = indicators[i]
		local x, y, size = IndicatorService.ScreenPosition(indicator)

		if x and y and size then
			indicator.x = x
			indicator.y = y
		
			surface.SetAlphaMultiplier(CombineAlphas(container_alpha, indicator.attributes.alpha.current, indicator.world_alpha.current))
			Element.PaintTexture(indicator, indicator_material, x, y, size, size, 0, indicator:GetColor())
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

function IndicatorService.Visible()
	return SettingsService.Get "show_hud" and SettingsService.Get "show_indicators"
end

function IndicatorService.PlayerShouldHaveIndicator(ply)
	local should_have_indicator

	if IsLocalPlayer(ply) then
		should_have_indicator = false
	elseif ply.player_class then
		should_have_indicator = true
	else
		should_have_indicator = false
	end

	return should_have_indicator
end

function IndicatorService.Init()
	IndicatorService.container = IndicatorService.CreateContainer()
end
hook.Add("InitUI", "IndicatorService.Init", IndicatorService.Init)

function IndicatorService.Reload(soft_reload)
	if soft_reload then
		IndicatorService.Clear()
	else
		IndicatorService.container:Finish()
		IndicatorService.Init()
	end

	if IndicatorService.Visible() then
		local lobby = LocalPlayer().lobby
	
		if lobby then
			IndicatorService.InitLobby(lobby)
		end
	end
end
hook.Add("OnReloaded", "IndicatorService.Reload", IndicatorService.Reload)

function IndicatorService.InitLobby(lobby)
	for _, ply in pairs(lobby.players) do
		if IndicatorService.PlayerShouldHaveIndicator(ply) then
			IndicatorService.AddPlayerIndicator(ply)
		end
	end
end

function IndicatorService.Clear()
	IndicatorService.container:Clear()
end

function IndicatorService.AddPlayerIndicator(ply)
	IndicatorService.container:Add(Indicator.New(ply))

	if ply.just_spawned or ply:Alive() then
		ply.indicator:AnimateAttribute("alpha", 255)
	end
end

function IndicatorService.LobbyPlayerJoin(lobby, ply)
	if IndicatorService.Visible() then
		if IsLocalPlayer(ply) then
			IndicatorService.InitLobby(lobby)
		elseif IndicatorService.PlayerShouldHaveIndicator(ply) then
			IndicatorService.AddPlayerIndicator(ply)
		end
	end
end
hook.Add("LocalLobbyPlayerJoin", "IndicatorService.LobbyPlayerJoin", IndicatorService.LobbyPlayerJoin)

function IndicatorService.LobbyPlayerLeave(lobby, ply)
	if IndicatorService.Visible() then
		if IsLocalPlayer(ply) then
			IndicatorService.Clear()
		elseif IndicatorService.PlayerShouldHaveIndicator(ply) then
			ply.indicator:Finish()
		end
	end
end
hook.Add("LocalLobbyPlayerLeave", "IndicatorService.LobbyPlayerLeave", IndicatorService.LobbyPlayerLeave)

function IndicatorService.LobbyPlayerSpawn(lobby, ply)
	if IndicatorService.Visible() and IndicatorService.PlayerShouldHaveIndicator(ply) then
		ply.indicator:AnimateAttribute("alpha", 255)
	end
end
hook.Add("LocalLobbyPlayerSpawn", "IndicatorService.LobbyPlayerSpawn", IndicatorService.LobbyPlayerSpawn)

function IndicatorService.LobbyPlayerDeath(lobby, ply)
	if IndicatorService.Visible() and IndicatorService.PlayerShouldHaveIndicator(ply) then
		ply.indicator:AnimateAttribute("alpha", 0)
	end
end
hook.Add("LocalLobbyPlayerDeath", "IndicatorService.LobbyPlayerDeath", IndicatorService.LobbyPlayerDeath)

function IndicatorService.LobbyPlayerClassChange(ply)
	if IndicatorService.Visible() then
		local should_have_indicator = IndicatorService.PlayerShouldHaveIndicator(ply)

		if should_have_indicator and not ply.indicator then
			IndicatorService.AddPlayerIndicator(ply)
		elseif not should_have_indicator and ply.indicator then
			ply.indicator:Finish()
		end
	end
end
hook.Add("LocalLobbyPlayerClassChange", "IndicatorService.LobbyPlayerClassChange", IndicatorService.LobbyPlayerClassChange)

function IndicatorService.Show()
	if IndicatorService.Visible() then
		IndicatorService.container:AnimateAttribute("alpha", 255)
	end
end

function IndicatorService.Hide()
	if IndicatorService.Visible() then
		IndicatorService.container:AnimateAttribute("alpha", 0)
	end
end

function IndicatorService.Draw()
	if IndicatorService.Visible() then
		IndicatorService.container.panel:PaintManual()
	end
end
hook.Add("DrawIndicators", "IndicatorService.Draw", IndicatorService.Draw)
