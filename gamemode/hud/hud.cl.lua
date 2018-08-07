HUDService = HUDService or {}

local LINE_THICKNESS = 4


-- # Factories

function HUDService.CreateContainer()
	return Element.New {
		width_percent = 1,
		height_percent = 1,
		padding_x = 256,
		padding_y = 64
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
		height_percent = 1/3
	})

	if props then
		element:SetAttributes(props)
	end

	return element
end

surface.CreateFont("HUDMeterValue", {
	font = "Roboto Mono",
	size = 36,
	weight = 700
})

surface.CreateFont("HUDMeterValueSmall", {
	font = "Roboto Mono",
	size = 22,
	weight = 900
})

HUDMeter = HUDMeter or Class.New(Element)

function HUDMeter:Init(quadrant, props)
	self.super.Init(self, {
		layout_justification_x = JUSTIFY_CENTER,
		layout_justification_y = JUSTIFY_CENTER,
		layout_direction = DIRECTION_ROW,
		wrap = true,
		fit_y = true,
		width_percent = 3/4
	})

	self.value_func = props.value_func
	self.bar_value_func = props.bar_value_func
	self.value_divider = props.value_divider or 100

	self.debounced_value = AnimatableValue.New(0, {
		callback = function (v)
			self:OnValueChange(v)
		end
	})

	self.hide_value_on_empty = props.hide_value_on_empty
	self.hide_value_on_full = props.hide_value_on_full

	HUDService["quadrant_"..quadrant]:Add(self)

	if props.show_value then
		self.value_text_container = self:Add(Element.New {
			layout_justification_y = JUSTIFY_START,
			fit = true,
			wrap = false,
			padding_bottom = 8,
			child_margin = 2
		})

		self.value_text = self.value_text_container:Add(Element.New {
			fit = true,
			padding_top = -8,
			padding_bottom = -6,
			font = "HUDMeterValue"
		})
	end

	local bar_container = self:Add(Element.New {
		layout_justification_x = JUSTIFY_CENTER,
		width_percent = 1,
		height = LINE_THICKNESS,
		background_color = COLOR_BACKGROUND
	})

	self.bar = bar_container:Add(Element.New {
		width_percent = AnimatableValue.New(0, {smooth = true}),
		height_percent = 1,
		fill_color = true
	})

	self:Add(Element.New {
		width = 64,
		height = 64,
		material = props.icon_material
	})
end

function HUDMeter:Finish()
	self.super.Finish(self)
	self.debounced_value:Finish()
end

function HUDMeter:Think()
	self.super.Think(self)

	local value = self.value_func()

	local width_percent
	
	if self.bar_value_func then
		width_percent = self.bar_value_func()
	else
		width_percent = value/self.value_divider
	end
	
	self.debounced_value.current = value
	self.bar:SetAttribute("width_percent", math.Clamp(width_percent, 0, 1))

	if self.value_text then
		self.value_text:SetText(self.debounced_value.debounce)
	end
end

function HUDMeter:OnValueChange(v)
	if self.value_text then
		if not self.hid_value and ((self.hide_value_on_empty and v.current == 0) or (self.hide_value_on_full and v.current == self.value_divider)) then
			self.value_text_container:AnimateAttribute("alpha", 0)
			self.hid_value = true
		elseif self.hid_value then
			self.value_text_container:AnimateAttribute("alpha", 255)
			self.hid_value = false
		end
	end
end


-- # Init

local health_icon_material = Material("emm2/hud/health.png", "noclamp smooth")
local speed_icon_material = Material("emm2/hud/speed.png", "noclamp smooth")
local airaccel_icon_material = Material("emm2/hud/airaccel.png", "noclamp smooth")

function HUDService.Init()
	HUDService.animatable_color = AnimatableValue.New(COLOR_WHITE, {
		smooth = true,
		generate = function ()
			return LocalPlayer().color
		end
	})

	HUDService.container = HUDService.CreateContainer()
	HUDService.container:SetAttribute("color", function ()
		return HUDService.animatable_color.smooth
	end)

	HUDService.left_section = HUDService.CreateSection(15, Angle(0, -10, 0))
	HUDService.middle_section = HUDService.CreateSection(10.75)
	HUDService.right_section = HUDService.CreateSection(15, Angle(0, 10, 0))

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

	HUDService.health_meter = HUDMeter.New("g", {
		show_value = true,
		hide_value_on_empty = true,
		hide_value_on_full = true,
		icon_material = health_icon_material,

		value_func = function ()
			return LocalPlayer():Health()
		end
	})

	HUDService.speed_meter = HUDMeter.New("h", {
		show_value = true,
		hide_value_on_empty = true,
		icon_material = speed_icon_material,

		value_func = function ()
			return math.Round(LocalPlayer():GetVelocity():Length2D()/10)
		end,

		value_divider = 700
	})

	HUDService.speed_meter.value_text_container:Add(Element.New {
		fit = true,
		padding_top = -4,
		text = "0",
		font = "HUDMeterValueSmall"
	})

	HUDService.speed_meter.value_text_container:Add(Element.New {
		fit = true,
		padding_top = 4,
		padding_bottom = -3,
		text = "u/s",
		font = "HUDMeterValueSmall"
	})

	HUDService.airaccel_meter = HUDMeter.New("i", {
		icon_material = airaccel_icon_material,
		value_func = function ()
			return LocalPlayer().stamina.airaccel.amount
		end
	})
end
hook.Add("InitPostEntity", "HUDService.Init", HUDService.Init)

function HUDService.Reload()
	HUDService.animatable_color:Finish()
	HUDService.health_meter:Finish()
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
	HUDService.left_section:AnimateAttribute("alpha", 255)
	HUDService.middle_section:AnimateAttribute("alpha", 255, {delay = 0.2})
	HUDService.right_section:AnimateAttribute("alpha", 255, {delay = 0.4})
end
hook.Add("LocalPlayerSpawn", "HUDService.Show", HUDService.Show)

function HUDService.Hide()
	HUDService.left_section:AnimateAttribute("alpha", 0)
	HUDService.middle_section:AnimateAttribute("alpha", 0, {delay = 0.2})
	HUDService.right_section:AnimateAttribute("alpha", 0, {delay = 0.4})
end
hook.Add("PrePlayerDeath", "HUDService.Hide", function (ply)
	if ply == LocalPlayer() then
		HUDService.Hide()
	end
end)