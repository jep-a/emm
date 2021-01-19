IndicatorService = IndicatorService or {}

local indicator_material = PNGMaterial "emm2/shapes/arrow-2x.png"
local circle_material = PNGMaterial "emm2/shapes/circle.png"
local copy_material = Material "pp/copy"
local outline_material = CreateMaterial("OutlineMaterial", "UnlitGeneric", {
	["$ignorez"] = 1,
	["$alphatest"] = 1
})
local store_texture = render.GetScreenEffectTexture(0)
local draw_texture = render.GetScreenEffectTexture(1)
local render_entity = NULL


-- # Util

function IndicatorService.Visible()
	return SettingsService.Get "show_hud" and SettingsService.Get "show_indicators"
end

function IndicatorService.PlayerShouldHaveIndicator(ply)
	local should_have_indicator

	if ply.ghosting then
		should_have_indicator = true
	else
		should_have_indicator = not IsLocalPlayer(ply)
	end

	return should_have_indicator
end

function IndicatorService.IndicatorIcon(ent)
	return ent.indicator_icon or ent.GetIndicatorIcon and ent:GetIndicatorIcon() or ent:GetNWString "IndicatorIcon"
end


-- # Properties

function IndicatorService.InitPlayerProperties(ply)
	cam.Start3D()

	local x, y, visible, distance = IndicatorService.ScreenPosition(ply, nil, ply)

	cam.End3D()

	ply.visible = 0
	ply.pixel_visible_handle = util.GetPixelVisibleHandle()
	ply.indicator_x = x
	ply.indicator_y = y
	ply.indicator_is_visible = visible
	ply.indicator_distance = distance
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

		if IsValid(indicator.entity) then
			indicator.distance = indicator.entity.indicator_distance
		elseif indicator.position then
			indicator.distance = eye_pos:Distance(indicator.position)
		end

		indicator.panel:SetZPos(i)
	end

	table.sort(indicators, function(a, b) return a.distance and b.distance and a.distance > b.distance end)
end
hook.Add("Think", "IndicatorService.Sort", IndicatorService.Sort)

function IndicatorService.ScreenPosition(ent_or_pos, eye_pos, ent)
	if IsValid(LocalPlayer()) then
		local eye_pos = eye_pos or LocalPlayer():EyePos()
		local pos
		local y_offset
		local dist

		if IsValid(ent) then
			local radius = ent:GetModelRadius() * ent:GetModelScale()
			local pos_offset

			if ent.ghost and ent:GetClass() == "prop_ragdoll" then
				pos_offset = Vector(0, 0, -38)
			else
				pos_offset = Vector(0, 0, 0)
			end

			pos = (isvector(ent_or_pos) and ent_or_pos or ent:GetPos()) + Vector(0, 0, radius) + pos_offset
			dist = eye_pos:Distance(pos)

			local ang = math.abs(math.NormalizeAngle((pos - eye_pos):Angle().p))

			y_offset = RemapClamp(ang, 20, 70, 0, RemapClamp(radius, 72, 512, -4, -48) * RemapClamp(dist, 0, 6000, 4, 1))
		else
			pos = ent_or_pos
			dist = eye_pos:Distance(pos)
			y_offset = 0
		end

		local screen_pos = pos:ToScreen()

		return screen_pos.x, screen_pos.y + y_offset, screen_pos.visible, dist
	end
end

function IndicatorService.CalculateScreenPositions()
	local local_ply = LocalPlayer()
	local lobby = local_ply.lobby
	local eye_pos = local_ply:EyePos()
	local plys = player.GetAll()

	cam.Start3D()

	for i = 1, #plys do
		local ply = plys[i]

		if IsValid(ply) and ply.pixel_visible_handle then
			local ent = GhostService.Entity(ply)

			if IsValid(ent) then
				local pos = ent:GetPos()
				local x, y, vis, dist = IndicatorService.ScreenPosition(pos, eye_pos, ent)

				ply.visible = util.PixelVisible(pos + ply:OBBCenter(), 32, ply.pixel_visible_handle)
				ply.indicator_x = x
				ply.indicator_y = y - 10
				ply.indicator_is_visible = vis
				ply.indicator_distance = dist
			end
		end
	end

	if lobby then
		local ents = lobby.entities

		for i = 1, #ents do
			local ent = ents[i]

			if IsValid(ent) then
				local x, y, vis, dist = IndicatorService.ScreenPosition(ent, eye_pos, ent)

				ent.indicator_x = x
				ent.indicator_y = y
				ent.indicator_is_visible = vis
				ent.indicator_distance = dist
			end
		end
	end

	cam.End3D()
end
hook.Add("HUDPaint", "IndicatorService.CalculateScreenPositions", IndicatorService.CalculateScreenPositions)

function IndicatorService.IndicatorPosition(indicator)
	local x
	local y
	local distance

	if IsValid(indicator.entity) then
		x = indicator.entity.indicator_x or 0
		y = indicator.entity.indicator_y or 0
		distance = indicator.entity.indicator_distance or 0
	elseif indicator.position then
		x, y, _, distance = IndicatorService.ScreenPosition(indicator.position, LocalPlayer():EyePos())
	end

	local size = Lerp(distance/800, INDICATOR_WORLD_SIZE * 2, INDICATOR_WORLD_SIZE)
	local indicator_x = x - (size/2)
	local indicator_y = y - 6 - (size/2)

	return indicator_x, indicator_y, size
end

function IndicatorService.IndicatorIconPosition(indicator)
	local x = indicator.entity.indicator_x or 0
	local y = indicator.entity.indicator_y or 0
	local distance = indicator.entity.indicator_distance or 0
	local size = Lerp(distance/800, INDICATOR_ICON_SIZE * 2, INDICATOR_ICON_SIZE)
	local indicator_x = x - (size/2)
	local indicator_y = y - Lerp(distance/800, 64, 44) - (size/2)

	return indicator_x, indicator_y, size
end

function IndicatorService.GetIndicatorPercent(ent)
	local percent

	if ent.GetIndicatorPercent then
		percent = ent:GetIndicatorPercent()
	else
		local max_health = ent.max_health or 100

		if ent.savepoint and ent.savepoint.health then
			percent = ent.savepoint.health/max_health
		else
			percent = ent:Health()/max_health
		end
	end

	return percent
end


-- # Drawing/rendering

function IndicatorService.DrawWorldPositions()
	local indicators = IndicatorService.container.children
	local container_alpha = IndicatorService.container.attributes.alpha.current

	for i = 1, #indicators do
		local indicator = indicators[i]
		local x, y, size = IndicatorService.IndicatorPosition(indicator)

		if x and y and size then
			local indicator_ent = indicator.entity

			indicator.x = x
			indicator.y = y

			surface.SetAlphaMultiplier(CombineAlphas(container_alpha, indicator.attributes.alpha.current, indicator.world_alpha.current))

			if IsValid(indicator_ent) then
				Element.PaintTexture(indicator, indicator_material, x, y, size, size, 0, COLOR_BLACK)

				local indicator_percent

				if indicator_ent:IsPlayer() then
					local health_percent = IndicatorService.GetIndicatorPercent(indicator_ent)

					if GhostService.IsGhostingWithoutRagdoll(indicator_ent) or (health_percent >= 1) then
						indicator_percent = 1
					else
						indicator_percent = (health_percent * 0.33) + 0.33
					end
				else
					indicator_percent = 1
				end

				render.SetScissorRect(x, y + (size * (1 - indicator_percent)), x + size, y + size, true)
				Element.PaintTexture(indicator, indicator_material, x, y, size, size, 0, indicator:GetColor())
				render.SetScissorRect(0, 0, 0, 0, false)

				local indicator_material = IndicatorService.IndicatorIcon(indicator_ent)

				if not Falsy(indicator_material) then
					local icon_x, icon_y, icon_size = IndicatorService.IndicatorIconPosition(indicator)

					Element.PaintTexture(indicator, PNGMaterial(indicator_material), icon_x, icon_y, icon_size, icon_size, 0, indicator:GetColor())
				end
			else
				Element.PaintTexture(indicator, indicator_material, x, y, size, size, 0, indicator:GetColor())
			end

			surface.SetAlphaMultiplier(1)
		end
	end
end
hook.Add("DrawIndicators", "IndicatorService.DrawWorldPositions", IndicatorService.DrawWorldPositions)

function IndicatorService.RenderOutlines()
	local indicators = IndicatorService.container.children

	if SettingsService.Get "show_outlines" and #indicators > 0 then
		local scene = render.GetRenderTarget()
		local scr_w = ScrW()
		local scr_h = ScrH()

		render.CopyRenderTargetToTexture(store_texture)
		render.Clear(0, 0, 0, 0, true, true)
		render.SetStencilEnable(true)

		cam.IgnoreZ(true)

		render.SuppressEngineLighting(true)
		render.SetStencilWriteMask(0xFF)
		render.SetStencilTestMask(0xFF)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_REPLACE)
		render.SetStencilPassOperation(STENCIL_REPLACE)

		cam.Start3D()

		for i = 1, #indicators do
			local indicator = indicators[i]
			local ent = GhostService.Entity(indicator.entity)

			render.SetStencilReferenceValue(i)

			if IsValid(ent) then
				local alpha = indicator.attributes.alpha.current

				if alpha > 0 then
					render_entity = ent
					ent:DrawModel()
				end
			end
		end

		render_entity = NULL

		cam.End3D()

		render.SetStencilCompareFunction(STENCIL_EQUAL)

		cam.Start2D()

		for i = 1, #indicators do
			local indicator = indicators[i]
			local ent = indicator.entity

			render.SetStencilReferenceValue(i)

			if IsValid(ent) then
				local alpha = indicator.attributes.alpha.current

				if alpha > 0 then
					surface.SetDrawColor(GetAnimatableEntityColor(ent))
					surface.DrawRect(0, 0, scr_w, scr_h)
				end
			end
		end

		cam.End2D()

		render.SuppressEngineLighting(false)

		cam.IgnoreZ(false)

		render.SetStencilEnable(false)
		render.CopyRenderTargetToTexture(draw_texture)
		render.SetRenderTarget(scene)

		copy_material:SetTexture("$basetexture", store_texture)

		render.SetMaterial(copy_material)
		render.DrawScreenQuad()
		render.SetStencilEnable(true)
		render.SetStencilReferenceValue(0)
		render.SetStencilCompareFunction(STENCIL_EQUAL)

		outline_material:SetTexture("$basetexture", draw_texture)

		render.SetMaterial(outline_material)
		render.DrawScreenQuadEx(-1, -1, scr_w, scr_h)
		render.DrawScreenQuadEx(-1, 0, scr_w, scr_h)
		render.DrawScreenQuadEx(-1, 1, scr_w, scr_h)
		render.DrawScreenQuadEx(0, -1, scr_w, scr_h)
		render.DrawScreenQuadEx(0, 1, scr_w, scr_h)
		render.DrawScreenQuadEx(1, 1, scr_w, scr_h)
		render.DrawScreenQuadEx(1, 0, scr_w, scr_h)
		render.DrawScreenQuadEx(1, 1, scr_w, scr_h)
		render.SetStencilEnable(false)
	end
end
hook.Add("PostDrawEffects", "IndicatorService.RenderOutlines", IndicatorService.RenderOutlines)

function IndicatorService.RenderCoasters()
	local indicators = IndicatorService.container.children

	for i = 1, #indicators do
		local indicator = indicators[i]
		local ent = indicator.entity

		if IsValid(ent) and IsValid(GhostService.Entity(ent)) then
			local pos = GhostService.Entity(ent):GetPos() + Vector(0, 0, 5)

			local trace = util.TraceLine {
				start = pos,
				endpos = pos - Vector(0, 0, 100000),
				mask = MASK_NPCWORLDSTATIC
			}

			local alpha = CombineAlphas(indicator.attributes.alpha.current, Lerp(trace.Fraction * 8, 255, 50))

			if alpha > 0 then
				cam.Start3D2D(trace.HitPos + (trace.HitNormal * Vector(0.5, 0.5, 0.5)), trace.HitNormal:Angle() + Angle(90, 0, 0), 0.25)
				surface.SetAlphaMultiplier(alpha)
				surface.SetDrawColor(GetAnimatableEntityColor(indicator.entity))
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
			IndicatorService.AddEntityIndicator(ply)
		end
	end

	for _, ent in pairs(lobby.entities) do
		IndicatorService.AddEntityIndicator(ent)
	end
end

function IndicatorService.Clear()
	IndicatorService.container:Clear()
end

function IndicatorService.AddEntityIndicator(ent)
	IndicatorService.container:Add(Indicator.New(ent))

	if not IsPlayer(ent) or ent.just_spawned or GhostService.Alive(ent) then
		ent.indicator:AnimateAttribute("alpha", 255)
	end
end

function IndicatorService.RefreshPlayerIndicator(ply, hide)
	if IndicatorService.Visible() then
		local should_have_indicator = IndicatorService.PlayerShouldHaveIndicator(ply)

		if should_have_indicator then
			if ply.indicator and not GhostService.IsGhostingWithoutRagdoll(ply) then
				ply.indicator:AnimateAttribute("alpha", hide and 0 or 255)
			elseif not ply.indicator then
				IndicatorService.AddEntityIndicator(ply)
			end
		elseif not should_have_indicator and ply.indicator then
			ply.indicator:Finish()
		end
	end
end

function IndicatorService.LobbyPlayerJoin(lobby, ply)
	if IndicatorService.Visible() then
		if IsLocalPlayer(ply) then
			IndicatorService.InitLobby(lobby)
		elseif IndicatorService.PlayerShouldHaveIndicator(ply) then
			IndicatorService.AddEntityIndicator(ply)
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
	IndicatorService.RefreshPlayerIndicator(ply)
end
hook.Add("LocalLobbyPlayerSpawn", "IndicatorService.LobbyPlayerSpawn", IndicatorService.LobbyPlayerSpawn)

function IndicatorService.LobbyPlayerDeath(lobby, ply)
	IndicatorService.RefreshPlayerIndicator(ply, true)
end
hook.Add("LocalLobbyPlayerDeath", "IndicatorService.LobbyPlayerDeath", IndicatorService.LobbyPlayerDeath)

function IndicatorService.LobbyPlayerClassChange(lobby, ply)
	IndicatorService.RefreshPlayerIndicator(ply)
end
hook.Add("LocalLobbyPlayerClassChange", "IndicatorService.LobbyPlayerClassChange", IndicatorService.LobbyPlayerClassChange)

hook.Add("LocalPlayerGhost", "IndicatorService.RefreshPlayerIndicator", IndicatorService.RefreshPlayerIndicator)
hook.Add("LocalPlayerUnGhost", "IndicatorService.RefreshPlayerIndicator", IndicatorService.RefreshPlayerIndicator)

function IndicatorService.LobbyEntityAdd(lobby, ent)
	if IndicatorService.Visible() then
		IndicatorService.AddEntityIndicator(ent)
	end
end
hook.Add("LocalLobbyEntityAdd", "IndicatorService.LobbyEntityAdd", IndicatorService.LobbyEntityAdd)

function IndicatorService.LobbyEntityRemove(lobby, ent)
	if IndicatorService.Visible() then
		ent.indicator:Finish()
	end
end
hook.Add("LocalLobbyEntityRemove", "IndicatorService.LobbyEntityRemove", IndicatorService.LobbyEntityRemove)

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
