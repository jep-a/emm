-- # Meter

HUDMeter = HUDMeter or Class.New(Element)

function HUDMeter:Init(quadrant_or_props, props)
	local quadrant = isstring(quadrant_or_props) and quadrant_or_props
	local props = istable(quadrant_or_props) and quadrant_or_props or props

	HUDMeter.super.Init(self, {
		layout_justification_x = JUSTIFY_CENTER,
		layout_justification_y = JUSTIFY_START,
		layout_direction = DIRECTION_COLUMN,
		wrap = false,
		fit_y = true,
		width_percent = HUD_METER_SIZE,
		child_margin = MARGIN * 4
	})

	self:SetAttributes(props)

	self.value_func = props.value_func or function ()
		return 0
	end

	self.percent_func = props.percent_func
	self.text_func = props.text_func
	self.value_divider = props.value_divider or 100
	self.hide_value_on_empty = props.hide_value_on_empty
	self.hide_value_on_full = props.hide_value_on_full

	local init_v = self.value_func()

	self.debounced_value = AnimatableValue.New(init_v, {
		callback = function (v)
			self:OnValueChanged(v)
		end
	})

	if quadrant then
		HUDService["quadrant_"..quadrant]:Add(self)
	end

	local init_percent

	if self.percent_func then
		init_percent = self.percent_func()
	else
		init_percent = init_v/self.value_divider
	end

	self.bar = self:Add(2, MeterBar.New {
		percent = init_percent,
		height = props.line_thickness or HUD_LINE_THICKNESS
	})

	if props.show_value then
		self.text_container = self:Add(props.top_layout and 3 or 1, Element.New {
			fit = true,
			wrap = false,
			child_margin = 2,
			alpha = not self:ShouldHideValueText() and 255 or 0
		})

		self.text = self.text_container:Add(Element.New {
			fit = true,
			crop_top = 0.225,
			crop_bottom = 0.125,
			font = "HUDMeterValue"
		})

		if props.sub_value then
			self.sub_text = self.text_container:Add(Element.New {
				fit = true,
				crop_top = 0.225,
				crop_bottom = 0.125,
				font = "HUDMeterValueSmall"
			})
		end

		if props.units then
			self.text_container:Add(Element.New {
				self_adjacent_justification = JUSTIFY_END,
				fit = true,
				crop_top = 0.225,
				crop_bottom = 0.1,
				text = props.units,
				font = "HUDMeterValueSmall"
			})
		end
	end

	self:OnValueChanged(self.debounced_value)

	self:Add(props.top_layout and 1 or 3, Element.New {
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
	if self.text then
		if self.text_func then
			self.text:SetText(self.text_func(self.debounced_value.debounce))
		else
			local v = tostring(self.debounced_value.debounce)

			if self.sub_text then
				self.text:SetText(string.sub(v, 1, -2))

				if not round_sub_value then
					self.sub_text:SetText(string.sub(v, -1))
				end
			else
				self.text:SetText(v)
			end
		end
	end
end

function HUDMeter:Think()
	HUDMeter.super.Think(self)

	if not self.animating_finish then
		local value = self.value_func()
		local width_percent

		if self.percent_func then
			width_percent = self.percent_func()
		else
			width_percent = value/self.value_divider
		end

		self.debounced_value.current = value
		self.bar:SetPercent(width_percent)

		if self.text then
			self:SetValueText()
		end
	end
end

function HUDMeter:ShouldHideValueText(v)
	v = (v or self.debounced_value).current

	return (self.hide_value_on_empty and v == 0) or (self.hide_value_on_full and v == self.value_divider)
end

function HUDMeter:OnValueChanged(v)
	if self.text then
		if not self.hid_value and HUDMeter.ShouldHideValueText(self, v) then
			self.text_container:AnimateAttribute("alpha", 0)
			self.hid_value = true
		elseif self.hid_value then
			self.text_container:AnimateAttribute("alpha", 255)
			self.hid_value = false
		end
	end
end