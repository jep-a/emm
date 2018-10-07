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
		child_margin = MARGIN * 4,
		background_color = COLOR_BACKGROUND
	})

	self.value_func = props.value_func
	self.value_divider = props.value_divider or 100
	self.hide_value_on_empty = props.hide_value_on_empty
	self.hide_value_on_full = props.hide_value_on_full
	self.hid_value = true

	local layout_props = {
		animate_callback = function ()
			if IsValid(self.panel) then
				self:Layout(true)
			end
		end
	}

	local init_v = self.value_func()

	self.debounced_value = AnimatableValue.New(init_v, {
		callback = function (v)
			self:OnValueChanged(v)
		end
	})

	self.percent = AnimatableValue.New(init_v/self.value_divider, {smooth = true})
	self.angle = AnimatableValue.New(props.angle, layout_props)
	self.radius = props.radius and AnimatableValue.New(props.radius, layout_props) or AnimatableValue.NewFromSetting("crosshair_meter_radius", layout_props)
	self.line_thickness = AnimatableValue.New(props.line_thickness or HUD_LINE_THICKNESS)
	self.arc_length = props.arc_length and AnimatableValue.New(props.arc_length) or AnimatableValue.NewFromSetting "crosshair_meter_arc_length"

	if props.show_value then
		local origin_x, origin_y = self:CalculateValueTextPosition()
		local pos_justify_x, pos_justify_y = self:CalculateValueTextJustification()

		self.value_text_container = self:Add(Element.New {
			layout = false,
			origin_position = true,
			origin_x = origin_x,
			origin_y = origin_y,
			origin_justification_x = JUSTIFY_INHERIT,
			origin_justification_y = JUSTIFY_INHERIT,
			position_justification_x = pos_justify_x,
			position_justification_y = pos_justify_y,
			fit = true,
			wrap = false,
			child_margin = MARGIN/8,
			alpha = not HUDMeter.ShouldHideValueText(self) and 255 or 0
		})

		self.value_text = self.value_text_container:Add(Element.New {
			fit = true,
			crop_y = 0.125,
			font = "CrosshairMeterValue"
		})

		if props.sub_value then
			self.sub_value_text = self.value_text_container:Add(Element.New {
				fit = true,
				crop_y = 0.125,
				font = "CrosshairMeterValueSmall"
			})
		end
	end
end

function CrosshairMeter:Finish()
	self.debounced_value:Finish()
	self.percent:Finish()
	self.angle:Finish()
	self.radius:Finish()
	self.line_thickness:Finish()
	self.arc_length:Finish()
	CrosshairMeter.super.Finish(self)
end

function CrosshairMeter:Think()
	CrosshairMeter.super.Think(self)

	local v = self.value_func()

	self.debounced_value.current = v
	self.percent.current = v/self.value_divider

	if self.value_text then
		HUDMeter.SetValueText(self)
	end
end

function CrosshairMeter:CalculateValueTextJustification()
	local pos_justify_x
	local pos_justify_y

	local x, y = self:CalculateValueTextPosition(true)

	if x == 0 then
		pos_justify_x = JUSTIFY_CENTER
	elseif x > 0 then
		pos_justify_x = JUSTIFY_START
	elseif 0 > x then
		pos_justify_x = JUSTIFY_END
	end

	if y == 1 then
		pos_justify_y = JUSTIFY_START
	elseif y == -1 then
		pos_justify_y = JUSTIFY_END
	else
		pos_justify_y = JUSTIFY_CENTER
	end
	
	return pos_justify_x, pos_justify_y
end

function CrosshairMeter:CalculateValueTextPosition(local_pos)
	local x
	local y

	local attr = self.attributes
	local child_margin = attr.child_margin.current

	local rad_ang = math.rad(90 - self.angle.current)
	local radius = self.radius.current + child_margin

	local local_x = -math.cos(rad_ang)
	local local_y = math.sin(rad_ang)

	if local_pos then
		x = local_x
		y = local_y
	else
		x = (local_x * radius) + (attr.width.current/2)
		y = (local_y * radius) + (attr.height.current/2)
	end

	return math.Round(x), math.Round(y)
end

function CrosshairMeter:LayoutValueText()
	local v_text_container_attr = self.value_text_container.attributes
	local v_text_container_static_attr = self.value_text_container.static_attributes

	local pos_justify_x, pos_justify_y = self:CalculateValueTextJustification()

	v_text_container_static_attr.position_justification_x = pos_justify_x
	v_text_container_static_attr.position_justification_y = pos_justify_y

	local x, y = self:CalculateValueTextPosition()

	v_text_container_attr.origin_x.current = x
	v_text_container_attr.origin_y.current = y
end

function CrosshairMeter:Layout()
	self.laying_out = true

	self:GenerateSize()
	self:PositionFromOrigin()

	if self.value_text then
		self:LayoutValueText()
	end

	self:SetPanelBounds()

	self.laying_out = false
end

function CrosshairMeter:OnValueChanged(v)
	HUDMeter.OnValueChanged(self, v)
end

function CrosshairMeter:Paint()
	local attr = self.attributes
	local half_w = attr.width.current/2
	local half_h = attr.height.current/2

	local radius = self.radius.current
	local quality = math.Remap(radius, 64, 980, 1200, 3600)
	local padding = quality/360
	
	local arc = self.arc_length.current
	local half_arc = arc/2

	local ang = self.angle.current + 90 - half_arc
	
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
	surface.DrawPoly(GenerateSurfaceCircle(half_w, half_h, radius - self.line_thickness.current, arc + (padding * 2), ang - padding, quality))

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

	local percent = self.percent.smooth * arc

	if 1 > math.Round(self.percent.smooth, 4) then
		surface.SetDrawColor(self.attributes.background_color.current)
		surface.DrawPoly(GenerateSurfaceCircle(half_w, half_h, radius, arc, ang, quality))
	end

	surface.SetDrawColor(self:GetColor())
	surface.DrawPoly(GenerateSurfaceCircle(half_w, half_h, radius, percent, ang + half_arc - (percent/2), quality))

	render.SetStencilEnable(false)
end