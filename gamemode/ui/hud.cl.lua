HUDService = HUDService or {}


-- # Factories

function HUDService.CreateContainer()
	return Element.New {
		width_percent = 1,
		height_percent = 1,
		padding_x = HUD_PADDING_X,
		padding_y = HUD_PADDING_Y
	}
end

function HUDService.CreateSection(dist, ang)
	local element = HUDService.container:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		width_percent = 1/3,
		height_percent = 1,
		alpha = 0
	})

	CamUIService.AddPanel(element.panel, dist, ang)

	return element
end

function HUDService.CreateQuadrant(section, props)
	local element = section:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		wrap = false,
		width_percent = 1,
		height_percent = 1/3,
		child_margin = MARGIN
	})

	if props then
		element:SetAttributes(props)
	end

	return element
end

function HUDService.CreateCrosshairContainer()
	return Element.New {
		layout = false,
		origin_position = true,
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_CENTER,
		width = CROSSHAIR_CONTAINER_SIZE,
		height = CROSSHAIR_CONTAINER_SIZE
	}
end

function HUDService.CreateCrosshairMeter(props)
	return HUDService.crosshair_container:Add(CrosshairMeter.New(props))
end

function HUDService.CreateCrosshairLine(props)
	local element = HUDService.crosshair_container:Add(Element.New {
		layout = false,
		origin_position = true,
		border = 1
	})

	if props.orientation == DIRECTION_ROW then
		element:SetAttributes {
			width = CROSSHAIR_LINE_LENGTH,
			height = LINE_THICKNESS
		}
	else
		element:SetAttributes {
			width = LINE_THICKNESS,
			height = CROSSHAIR_LINE_LENGTH
		}
	end

	element:SetAttributes(props)

	return element
end


-- # Init

local health_icon_material = Material("emm2/hud/health.png", "noclamp smooth")
local speed_icon_material = Material("emm2/hud/speed.png", "noclamp smooth")
local airaccel_icon_material = Material("emm2/hud/airaccel.png", "noclamp smooth")

function HUDService.InitContainers()
	HUDService.container = HUDService.CreateContainer()
	HUDService.container:SetAttribute("color", function ()
		return HUDService.animatable_color.smooth
	end)

	HUDService.left_section = HUDService.CreateSection(HUD_SIDE_DISTANCE, Angle(0, -HUD_SIDE_ANGLE, 0))
	HUDService.middle_section = HUDService.CreateSection(HUD_MIDDLE_DISTANCE)
	HUDService.right_section = HUDService.CreateSection(HUD_SIDE_DISTANCE, Angle(0, HUD_SIDE_ANGLE, 0))

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
	HUDService.quadrant_g = HUDService.CreateQuadrant(HUDService.left_section, {layout_justification_y = JUSTIFY_END})
	HUDService.quadrant_h = HUDService.CreateQuadrant(HUDService.middle_section, {
		layout_justification_x = JUSTIFY_CENTER,
		layout_justification_y = JUSTIFY_END
	})
	HUDService.quadrant_i = HUDService.CreateQuadrant(HUDService.right_section, {
		layout_justification_x = JUSTIFY_END,
		layout_justification_y = JUSTIFY_END
	})

	HUDService.crosshair_container = HUDService.container:Add(HUDService.CreateCrosshairContainer())
end

function HUDService.InitMeters()
	local function Health()
		return LocalPlayer():Health()
	end

	local function Speed()
		return math.Round(LocalPlayer():GetVelocity():Length2D()/10)
	end

	local function Airaccel()
		return LocalPlayer().stamina.airaccel.amount
	end

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
		value_divider = HUD_SPEED_METER_DIVIDER
	})

	HUDService.speed_meter.value_text_container:Add(Element.New {
		fit = true,
		crop_y = 0.2,
		text = "0",
		font = "HUDMeterValueSmall"
	})

	HUDService.speed_meter.value_text_container:Add(Element.New {
		self_adjacent_justification = JUSTIFY_END,
		fit = true,
		crop_y = 0.1,
		text = "u/s",
		font = "HUDMeterValueSmall"
	})

	HUDService.airaccel_meter = HUDMeter.New("i", {
		icon_material = airaccel_icon_material,
		value_func = Airaccel
	})

	HUDService.CreateCrosshairMeter {
		angle = CROSSHAIR_METER_ARC_ANGLE,
		value_func = Health
	}

	HUDService.CreateCrosshairMeter {
		show_value = true,
		hide_value_on_empty = true,
		value_func = Speed,
		value_divider = HUD_SPEED_METER_DIVIDER
	}

	HUDService.CreateCrosshairMeter {
		angle = -CROSSHAIR_METER_ARC_ANGLE,
		value_func = Airaccel
	}
end

function HUDService.InitCrosshair()
	HUDService.CreateCrosshairLine {
		origin_justification_x = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_CENTER
	}

	HUDService.CreateCrosshairLine {
		orientation = DIRECTION_ROW,
		origin_justification_x = JUSTIFY_END,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_END,
		position_justification_y = JUSTIFY_CENTER
	}
end

function HUDService.Init()
	HUDService.animatable_color = AnimatableValue.New(COLOR_WHITE, {
		smooth = true,
		generate = function ()
			return LocalPlayer().color
		end
	})

	HUDService.InitContainers()
	HUDService.InitMeters()
	HUDService.InitCrosshair()
end
hook.Add("InitUI", "HUDService.Init", HUDService.Init)

function HUDService.Reload()
	HUDService.animatable_color:Finish()
	HUDService.container:Finish()
	HUDService.Init()
	HUDService.Show()
end
hook.Add("OnReloaded", "HUDService.Reload", HUDService.Reload)

local hud_elements = {"CHudCrosshair", "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
function HUDService.ShouldDraw(name)
	if table.HasValue(hud_elements, name) then
		return false
	end
end
hook.Add("HUDShouldDraw", "HUDService.ShouldDraw", HUDService.ShouldDraw)

function HUDService.Show()
	HUDService.crosshair_container:AnimateAttribute("alpha", 255)
	HUDService.left_section:AnimateAttribute("alpha", 255)
	HUDService.middle_section:AnimateAttribute("alpha", 255, {delay = ANIMATION_DURATION})
	HUDService.right_section:AnimateAttribute("alpha", 255, {delay = ANIMATION_DURATION * 2})
end
hook.Add("LocalPlayerSpawn", "HUDService.Show", HUDService.Show)

function HUDService.Hide()
	HUDService.crosshair_container:AnimateAttribute("alpha", 0)
	HUDService.left_section:AnimateAttribute("alpha", 0)
	HUDService.middle_section:AnimateAttribute("alpha", 0, {delay = ANIMATION_DURATION})
	HUDService.right_section:AnimateAttribute("alpha", 0, {delay = ANIMATION_DURATION * 2})
end
hook.Add("PrePlayerDeath", "HUDService.Hide", function (ply)
	if ply == LocalPlayer() then
		HUDService.Hide()
	end
end)

function HUDService.RenderHooks()
	hook.Run "DrawIndicators"
	hook.Run "DrawCamUI"
end
hook.Add("PostDrawHUD", "HUDService.RenderHooks", HUDService.RenderHooks)
