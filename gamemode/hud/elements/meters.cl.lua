-- # Meter

HUDMeter = HUDMeter or Class.New(Element)

function HUDMeter:Init(quadrant, props)
	HUDMeter.super.Init(self, {
		layout_justification_x = JUSTIFY_CENTER,
		layout_justification_y = JUSTIFY_START,
		layout_direction = DIRECTION_COLUMN,
		wrap = false,
		fit_y = true,
		width_percent = HUD_METER_SIZE,
		child_margin = MARGIN * 4
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
			fit = true,
			wrap = false,
			child_margin = HUD_METER_VALUE_TEXT_MARGIN
		})

		self.value_text = self.value_text_container:Add(Element.New {
			fit = true,
			crop_top = 0.24,
			crop_bottom = 0.125,
			font = "HUDMeterValue"
		})
	end

	self.bar = self:Add(MeterBar.New {height = props.line_thickness or HUD_LINE_THICKNESS})

	self:Add(Element.New {
		width = HUD_ICON_SIZE,
		height = HUD_ICON_SIZE,
		crop_y = 0.25,
		material = props.icon_material
	})
end

function HUDMeter:Finish()
	HUDMeter.super.Finish(self)
	self.debounced_value:Finish()
end

function HUDMeter:Think()
	HUDMeter.super.Think(self)

	local value = self.value_func()

	local width_percent
	
	if self.bar_value_func then
		width_percent = self.bar_value_func()
	else
		width_percent = value/self.value_divider
	end
	
	self.debounced_value.current = value
	self.bar:SetPercent(width_percent)

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


-- # Crosshair meter

CrosshairMeter = CrosshairMeter or Class.New(Element)

function CrosshairMeter:Init(props)
	props = props or {}

	CrosshairMeter.super.Init(self, {
		layout = false,
		origin_position = true,
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_CENTER,
		width_percent = 1,
		height_percent = 1,
		background_color = COLOR_BACKGROUND
	})

	self.line_thickness = AnimatableValue.New(props.line_thickness or HUD_LINE_THICKNESS)
	self.angle = props.angle or 0
	self.value_func = props.value_func
	self.value_divider = props.value_divider or 100
	
	self.debounced_value = AnimatableValue.New(0, {
		callback = function (v)
			self:OnValueChange(v)
		end
	})

	self.hide_value_on_empty = props.hide_value_on_empty
	self.hide_value_on_full = props.hide_value_on_full

	self.percent = AnimatableValue.New(0, {smooth = true})

	if props.show_value then
		self.value_text_container = self:Add(Element.New {
			layout = false,
			origin_position = true,
			origin_justification_x = JUSTIFY_CENTER,
			origin_justification_y = JUSTIFY_END,
			position_justification_x = JUSTIFY_CENTER,
			position_justification_y = JUSTIFY_END,
			fit = true,
			wrap = false,
			child_margin = MARGIN/4
		})

		self.value_text = self.value_text_container:Add(Element.New {
			fit = true,
			crop_y = 0.125,
			font = "CrosshairMeterValue",
			text = "100"
		})

		self.value_text_container:Add(Element.New {
			fit = true,
			crop_y = 0.125,
			font = "CrosshairMeterValueSmall",
			text = "0"
		})
	end
end

local circle_material = Material("emm2/shapes/circle.png", "noclamp smooth")

function CrosshairMeter:Think()
	CrosshairMeter.super.Think(self)

	local value = self.value_func()

	self.debounced_value.current = value
	self.percent.current = value/self.value_divider

	if self.value_text then
		self.value_text:SetText(self.debounced_value.debounce)
	end
end

function CrosshairMeter:OnValueChange(v)
	HUDMeter.OnValueChange(self, v)
end

function CrosshairMeter:Paint()
	local attr = self.attributes
	local half_w = attr.width.current/2
	local half_h = attr.height.current/2
	local radius = half_w - CROSSHAIR_METER_ARC_PADDING
	local half_arc = CROSSHAIR_METER_ARC_LENGTH/2
	local ang = self.angle + 90 - half_arc
	
	draw.NoTexture()

	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilTestMask(255)
	render.SetStencilWriteMask(255)
	render.SetStencilReferenceValue(1)

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)

	surface.SetDrawColor(COLOR_WHITE)
	surface.DrawPoly(GenerateSurfaceCircle(half_w, half_h, radius - self.line_thickness.current, CROSSHAIR_METER_ARC_LENGTH, ang, 720))

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

	local percent = (self.percent.smooth * CROSSHAIR_METER_ARC_LENGTH) - 1

	if 1 > math.Round(self.percent.smooth, 4) then
		surface.SetDrawColor(self.attributes.background_color.current)
		surface.DrawPoly(GenerateSurfaceCircle(half_w, half_h, radius, CROSSHAIR_METER_ARC_LENGTH, ang, 720))
	end

	surface.SetDrawColor(self:GetColor())
	surface.DrawPoly(GenerateSurfaceCircle(half_w, half_h, radius, percent, ang + half_arc - (percent/2), 720))

	render.SetStencilEnable(false)
end

function CrosshairMeter:Finish()
	CrosshairMeter.super.Finish(self)
	self.line_thickness:Finish()
	self.debounced_value:Finish()
	self.percent:Finish()
end
