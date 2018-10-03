HUDService = HUDService or {}

local health_icon_material = Material("emm2/hud/health.png", "noclamp smooth")
local speed_icon_material = Material("emm2/hud/speed.png", "noclamp smooth")
local airaccel_icon_material = Material("emm2/hud/airaccel.png", "noclamp smooth")

function HUDService.InitContainers()
	HUDService.container = HUDService.CreateContainer()

	HUDService.container:AddConvarAnimator("emm_hud_padding_x", "padding_x")
	HUDService.container:AddConvarAnimator("emm_hud_padding_y", "padding_y")

	HUDService.container:SetAttribute("color", function ()
		return HUDService.animatable_color.smooth
	end)

	local ang = SettingsService.Setting "emm_hud_angle"

	HUDService.left_section = HUDService.CreateSection(Angle(0, -ang, 0))
	HUDService.middle_section = HUDService.CreateSection(nil, math.Remap(ang, 0, 35, 0, 0.41))
	HUDService.right_section = HUDService.CreateSection(Angle(0, ang, 0))

	HUDService.quadrant_a = HUDService.CreateQuadrant(HUDService.left_section)
	HUDService.quadrant_b = HUDService.CreateQuadrant(HUDService.middle_section, {layout_justification_x = JUSTIFY_CENTER})
	HUDService.quadrant_c = HUDService.CreateQuadrant(HUDService.right_section, {layout_justification_x = JUSTIFY_END})
	HUDService.quadrant_d = HUDService.CreateQuadrant(HUDService.left_section, {layout_justification_y = JUSTIFY_CENTER})

	HUDService.quadrant_e = HUDService.CreateQuadrant(HUDService.middle_section, {
		layout_justification_x = JUSTIFY_CENTER,
		layout_justification_y = JUSTIFY_CENTER
	})

	HUDService.quadrant_f = HUDService.CreateQuadrant(HUDService.right_section, {
		layout_justification_x = JUSTIFY_END,
		layout_justification_y = JUSTIFY_CENTER
	})

	HUDService.quadrant_g = HUDService.CreateQuadrant(HUDService.left_section, {
		layout_justification_y = JUSTIFY_END,
		alpha = 0,
		child_margin = MARGIN * 4
	})

	HUDService.quadrant_h = HUDService.CreateQuadrant(HUDService.middle_section, {
		layout_justification_x = JUSTIFY_CENTER,
		layout_justification_y = JUSTIFY_END,
		alpha = 0,
		child_margin = MARGIN * 4
	})

	HUDService.quadrant_i = HUDService.CreateQuadrant(HUDService.right_section, {
		layout_justification_x = JUSTIFY_END,
		layout_justification_y = JUSTIFY_END,
		alpha = 0,
		child_margin = MARGIN * 4
	})

	HUDService.crosshair_container = HUDService.container:Add(HUDService.CreateCrosshairContainer())
	HUDService.crosshair_meter_container = HUDService.container:Add(HUDService.CreateCrosshairContainer(true))
end

function HUDService.InitMeters()
	local function Health()
		return LocalPlayer():Health()
	end

	local function Speed()
		return math.Round(LocalPlayer():GetVelocity():Length2D())
	end

	local function Airaccel()
		return LocalPlayer().stamina.airaccel.amount
	end

	if SettingsService.Setting "emm_show_hud_meters" then
		HUDService.health_meter = HUDMeter.New("g", {
			show_value = true,
			hide_value_on_empty = true,
			hide_value_on_full = true,
			icon_material = health_icon_material,
			value_func = Health
		})

		HUDService.speed_meter = HUDMeter.New("h", {
			show_value = true,
			hide_value_on_empty = true,
			icon_material = speed_icon_material,
			value_func = Speed,
			value_divider = HUD_SPEED_METER_DIVIDER,
			sub_value = true,
			units = "u/s",
		})

		HUDService.airaccel_meter = HUDMeter.New("i", {
			icon_material = airaccel_icon_material,
			value_func = Airaccel
		})
	end

	if SettingsService.Setting "emm_show_crosshair_meters" then
		HUDService.crosshair_meter_container:Add(CrosshairMeter.New {
			value_func = Health,
			angle = CROSSHAIR_METER_ARC_ANGLE
		})
		
		HUDService.crosshair_meter_container:Add(CrosshairMeter.New {
			show_value = true,
			hide_value_on_empty = true,
			value_func = Speed,
			value_divider = HUD_SPEED_METER_DIVIDER,
			sub_value = true
		})
		
		HUDService.crosshair_meter_container:Add(CrosshairMeter.New {
			value_func = Airaccel,
			angle = -CROSSHAIR_METER_ARC_ANGLE
		})
	end
end

function HUDService.InitCrosshairLines()
	HUDService.crosshair_lines = HUDService.crosshair_container:Add(CrosshairLines.New())
end

function HUDService.Init()
	if SettingsService.Setting "emm_show_hud" then
		HUDService.animatable_color = AnimatableValue.New(COLOR_WHITE, {
			smooth = true,

			generate = function ()
				return LocalPlayer().color
			end
		})

		HUDService.InitContainers()
		HUDService.InitMeters()

		if SettingsService.Setting "emm_show_crosshair" then
			HUDService.InitCrosshairLines()
		end

		if not LobbyUIService.open then
			if LocalPlayer():Alive() then
				HUDService.ShowAll()
			else
				HUDService.ShowNotifications()
			end
		end

		hook.Run("InitHUDElements")
	end
end
hook.Add("InitUI", "HUDService.Init", HUDService.Init)

function HUDService.Reload()
	if HUDService.animatable_color then
		HUDService.animatable_color:Finish()
	end

	local old_container = HUDService.container

	if old_container then
		old_container:AnimateAttribute("alpha", 0, {
			callback = function ()
				old_container:Finish()
			end
		})

		HUDService.container = nil
	end

	if SettingsService.Setting "emm_show_hud" then
		HUDService.Init()
		HUDService.ShowAll()
	end
end
hook.Add("OnReloaded", "HUDService.Reload", HUDService.Reload)

local native_hud_elements = {
	"CHudCrosshair",
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo"
}

function HUDService.ShouldDraw(name)
	if table.HasValue(native_hud_elements, name) then
		return false
	end
end
hook.Add("HUDShouldDraw", "HUDService.ShouldDraw", HUDService.ShouldDraw)

function HUDService.ShowMeters()
	HUDService.quadrant_g:AnimateAttribute("alpha", 255)
	HUDService.quadrant_h:AnimateAttribute("alpha", 255)
	HUDService.quadrant_i:AnimateAttribute("alpha", 255)
end

function HUDService.ShowCrosshair()
	HUDService.crosshair_container:AnimateAttribute("alpha", 255)
	HUDService.crosshair_meter_container:AnimateAttribute("alpha", 255)
end

function HUDService.ShowNotifications()
	HUDService.quadrant_a:AnimateAttribute("alpha", 255)
	HUDService.quadrant_b:AnimateAttribute("alpha", 255)
	HUDService.quadrant_c:AnimateAttribute("alpha", 255)
end

function HUDService.HideMeters()
	HUDService.quadrant_g:AnimateAttribute("alpha", 0)
	HUDService.quadrant_h:AnimateAttribute("alpha", 0)
	HUDService.quadrant_i:AnimateAttribute("alpha", 0)
end

function HUDService.HideCrosshair()
	HUDService.crosshair_container:AnimateAttribute("alpha", 0)
	HUDService.crosshair_meter_container:AnimateAttribute("alpha", 0)
end

function HUDService.HideNotifications()
	HUDService.quadrant_a:AnimateAttribute("alpha", 0)
	HUDService.quadrant_b:AnimateAttribute("alpha", 0)
	HUDService.quadrant_c:AnimateAttribute("alpha", 0)
end

function HUDService.ShowAll()
	HUDService.ShowMeters()
	HUDService.ShowCrosshair()
	HUDService.ShowNotifications()
end

function HUDService.HideAll()
	HUDService.HideMeters()
	HUDService.HideCrosshair()
	HUDService.HideNotifications()
end

function HUDService.SpawnShow()
	if SettingsService.Setting "emm_show_hud" and not LobbyUIService.open then
		if HUDService.container then
			HUDService.ShowMeters()
			HUDService.ShowCrosshair()
		end

		if IndicatorService.container and IndicatorService.Visible() then
			IndicatorService.Show()
		end
	end
end
hook.Add("LocalPlayerSpawn", "HUDService.SpawnShow", HUDService.SpawnShow)

function HUDService.DeathHide()
	if SettingsService.Setting "emm_show_hud" and not LobbyUIService.open then
		HUDService.HideMeters()
		HUDService.HideCrosshair()

		if IndicatorService.Visible() then
			IndicatorService.Hide()
		end
	end
end
hook.Add("LocalPlayerDeath", "HUDService.DeathHide", HUDService.DeathHide)

function HUDService.LobbyUIShow()
	if SettingsService.Setting "emm_show_hud" then
		if LocalPlayer():Alive() then
			HUDService.ShowAll()

			if IndicatorService.Visible() then
				IndicatorService.Show()
			end
		else
			HUDService.ShowNotifications()
		end
	end
end
hook.Add("OnLobbyUIClose", "HUDService.LobbyUIShow", HUDService.LobbyUIShow)

function HUDService.LobbyUIHide()
	if SettingsService.Setting "emm_show_hud" then
		HUDService.HideAll()

		if IndicatorService.Visible() then
			IndicatorService.Hide()
		end
	end
end
hook.Add("OnLobbyUIOpen", "HUDService.LobbyUIHide", HUDService.LobbyUIHide)

function HUDService.RenderHooks()
	hook.Run "DrawIndicators"
	hook.Run "DrawCamUI"
end
hook.Add("PostDrawHUD", "HUDService.RenderHooks", HUDService.RenderHooks)
