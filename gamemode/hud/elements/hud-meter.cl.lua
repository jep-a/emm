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
	self.hide_value_on_empty = props.hide_value_on_empty
	self.hide_value_on_full = props.hide_value_on_full

	local init_v = self.value_func()

	self.debounced_value = AnimatableValue.New(init_v, {
		callback = function (v)
			self:OnValueChanged(v)
		end
	})

	HUDService["quadrant_"..quadrant]:Add(self)

	if props.show_value then
		self.value_text_container = self:Add(Element.New {
			fit = true,
			wrap = false,
			child_margin = 2,
			alpha = not self:ShouldHideValueText() and 255 or 0
		})

		self.value_text = self.value_text_container:Add(Element.New {
			fit = true,
			crop_top = 0.225,
			crop_bottom = 0.125,
			font = "HUDMeterValue"
		})

		if props.sub_value then
			self.sub_value_text = self.value_text_container:Add(Element.New {
				fit = true,
				crop_top = 0.225,
				crop_bottom = 0.125,
				font = "HUDMeterValueSmall"
			})
		end
	
		if props.units then
			self.value_text_container:Add(Element.New {
				self_adjacent_justification = JUSTIFY_END,
				fit = true,
				crop_top = 0.225,
				crop_bottom = 0.1,
				text = props.units,
				font = "HUDMeterValueSmall"
			})
		end
	end

	local init_percent = init_v/self.value_divider

	self.bar = self:Add(MeterBar.New {
		percent = init_percent,
		height = props.line_thickness or HUD_LINE_THICKNESS
	})

	self:OnValueChanged(self.debounced_value)

	self:Add(Element.New {
		width = HUD_ICON_SIZE,
		height = HUD_ICON_SIZE,
		crop_y = 0.25,
		material = props.icon_material
	})
end

function HUDMeter:Finish()
	self.debounced_value:Finish()
	HUDMeter.super.Finish(self)
end

function HUDMeter:SetValueText(round_sub_value)
	local v = tostring(self.debounced_value.debounce)

	if self.sub_value_text then
		self.value_text:SetText(string.sub(v, 1, -2))

		if not round_sub_value then
			self.sub_value_text:SetText(string.sub(v, -1))
		end
	else
		self.value_text:SetText(v)
	end
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
		self:SetValueText()
	end
end

function HUDMeter:ShouldHideValueText(v)
	v = (v or self.debounced_value).current

	return (self.hide_value_on_empty and v == 0) or (self.hide_value_on_full and v == self.value_divider)
end

function HUDMeter:OnValueChanged(v)
	if self.value_text then
		if not self.hid_value and HUDMeter.ShouldHideValueText(self, v) then
			self.value_text_container:AnimateAttribute("alpha", 0)
			self.hid_value = true
		elseif self.hid_value then
			self.value_text_container:AnimateAttribute("alpha", 255)
			self.hid_value = false
		end
	end
end
