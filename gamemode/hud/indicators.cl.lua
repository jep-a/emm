IndicatorService = IndicatorService or {}

local indicator_material = Material("emm2/shapes/arrow-2x.png", "noclamp smooth")
local circle_material = Material("emm2/shapes/circle.png", "noclamp smooth")


-- # Util

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


-- # Properties

function IndicatorService.InitPlayerProperties(ply)
	if not IsLocalPlayer(ply) then
		cam.Start3D()

		local x, y, visible, distance = IndicatorService.ScreenPosition(ply)

		cam.End3D()

		ply.visible = 0
		ply.pixel_visible_handle = util.GetPixelVisibleHandle()
		ply.indicator_x = x
		ply.indicator_y = y
		ply.indicator_is_visible = visible
		ply.indicator_distance = distance
	end
end
hook.Add("InitPlayerProperties", "IndicatorService.InitPlayerProperties", IndicatorService.InitPlayerProperties)


-- # Elements

function IndicatorService.CreateContainer()
	local element = Element.New {
		width_percent = 1,
		height_percent = 1
	}

	element.panel:SetPaintedManually(true)

	return element
end


-- # Calculating

function IndicatorService.Sort(ply, eye_pos)
	local eye_pos = LocalPlayer():EyePos()
	local indicators = IndicatorService.container.children

	for i = 1, #indicators do
		local indicator = indicators[i]
	
		if IsValid(indicator.player) then
			indicator.distance = indicator.player.indicator_distance
		elseif indicator.position then
			indicator.distance = eye_pos:Distance(indicator.position)
		end
	
		indicator.panel:SetZPos(i)
	end

	table.sort(indicators, function(a, b) return a.distance > b.distance end)
end
hook.Add("Think", "IndicatorService.Sort", IndicatorService.Sort)

function IndicatorService.ScreenPosition(ent_or_pos, eye_pos)
	local pos = IsValid(ent_or_pos) and ent_or_pos:WorldSpaceCenter() or ent_or_pos
	local distance = (eye_pos or LocalPlayer():EyePos()):Distance(pos)
	local screen_pos = (pos + Vector(0, 0, Lerp(distance/600, 40, 45))):ToScreen()

	return screen_pos.x, screen_pos.y, screen_pos.visible, distance
end

function IndicatorService.CalculateScreenPositions(ply, eye_pos)
	local eye_pos = LocalPlayer():EyePos()
	local plys = player.GetAll()

	cam.Start3D()

	for i = 1, #plys do
		local ply = plys[i]

		if IsValid(ply) and not IsLocalPlayer(ply) and ply.pixel_visible_handle then
			local x, y, visible, distance = IndicatorService.ScreenPosition(ply, eye_pos)

			ply.visible = util.PixelVisible(ply:WorldSpaceCenter(), 32, ply.pixel_visible_handle)
			ply.indicator_x = x
			ply.indicator_y = y
			ply.indicator_is_visible = visible
			ply.indicator_distance = distance
		end
	end

	cam.End3D()
end
hook.Add("HUDPaint", "IndicatorService.CalculateScreenPositions", IndicatorService.CalculateScreenPositions)

function IndicatorService.IndicatorPosition(indicator)
	local x
	local y
	local distance

	if IsValid(indicator.player) then
		x = indicator.player.indicator_x
		y = indicator.player.indicator_y
		distance = indicator.player.indicator_distance
	elseif indicator.position then
		x, y, _, distance = IndicatorService.ScreenPosition(indicator.position, LocalPlayer():EyePos())
	end

	local size = Lerp(distance/800, INDICATOR_WORLD_SIZE * 2, INDICATOR_WORLD_SIZE)
	local indicator_x = x - (size/2)
	local indicator_y = y - 6 - (size/2)

	return indicator_x, indicator_y, size
end


-- # Drawing/rendering

function IndicatorService.DrawWorldPositions(ply)
	local indicators = IndicatorService.container.children
	local container_alpha = IndicatorService.container.attributes.alpha.current

	for i = 1, #indicators do
		local indicator = indicators[i]
		local x, y, size = IndicatorService.IndicatorPosition(indicator)

		if x and y and size then
			indicator.x = x
			indicator.y = y
		
			surface.SetAlphaMultiplier(CombineAlphas(container_alpha, indicator.attributes.alpha.current, indicator.world_alpha.current))

			if IsValid(indicator.player) then
				Element.PaintTexture(indicator, indicator_material, x, y, size, size, 0, COLOR_BLACK)

				local health_percent = indicator.player:Health()/indicator.player.max_health

				local visual_health_percent

				if health_percent >= 1 then
					visual_health_percent = 1
				else
					visual_health_percent = (health_percent * 0.33) + 0.33
				end

				render.SetScissorRect(x, y + (size * (1 - visual_health_percent)), x + size, y + size, true)
				Element.PaintTexture(indicator, indicator_material, x, y, size, size, 0, indicator:GetColor())
				render.SetScissorRect(0, 0, 0, 0, false)
			else
				Element.PaintTexture(indicator, indicator_material, x, y, size, size, 0, indicator:GetColor())
			end
	
			surface.SetAlphaMultiplier(1)
		end
	end
end
hook.Add("DrawIndicators", "IndicatorService.DrawWorldPositions", IndicatorService.DrawWorldPositions)

function IndicatorService.RenderCoasters()
	local indicators = IndicatorService.container.children

	for i = 1, #indicators do
		local indicator = indicators[i]

		if IsValid(indicator.player) then
			local pos = indicator.player:GetPos() + Vector(0, 0, 5)

			local trace = util.TraceLine {
				start = pos,
				endpos = pos - Vector(0, 0, 100000),
				mask = MASK_NPCWORLDSTATIC
			}

			local alpha = CombineAlphas(indicator.attributes.alpha.current, Lerp(trace.Fraction * 8, 255, 50))

			if alpha > 0 then
				cam.Start3D2D(trace.HitPos + (trace.HitNormal * Vector(0.5, 0.5, 0.5)), trace.HitNormal:Angle() + Angle(90, 0, 0), 0.25)
				surface.SetAlphaMultiplier(alpha)
				surface.SetDrawColor(indicator.player.color)
				surface.SetMaterial(circle_material)
				surface.DrawTexturedRect(-INDICATOR_COASTER_SIZE/2, -INDICATOR_COASTER_SIZE/2, INDICATOR_COASTER_SIZE, INDICATOR_COASTER_SIZE)
				surface.SetAlphaMultiplier(1)
				cam.End3D2D()
			end
		end
	end
end
hook.Add("PreDrawOpaqueRenderables", "IndicatorService.RenderCoasters", IndicatorService.RenderCoasters)


-- # Hooks

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
