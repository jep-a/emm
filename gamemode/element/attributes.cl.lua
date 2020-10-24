local animatable_attributes = {
	"x",
	"y",
	"offset_x",
	"offset_y",
	"width",
	"height",
	"padding_left",
	"padding_top",
	"padding_right",
	"padding_bottom",
	"crop_left",
	"crop_top",
	"crop_right",
	"crop_bottom",
	"layout_crop_x",
	"layout_crop_y",
	"child_margin",

	color = COLOR_WHITE,
	background_color = COLOR_BLACK_CLEAR,
	alpha = 255,
	border = 0,
	border_alpha = 255
}

local optional_attributes = {
	"duration",
	"origin_x",
	"origin_y",
	"width_percent",
	"height_percent",
	"angle",
	"text_color",
	"border_color",
	"cursor"
}

local layout_invalidators = {
	"origin_x",
	"origin_y",
	"fit_x",
	"fit_y",
	"x",
	"y",
	"offset_x",
	"offset_y",
	"width",
	"height",
	"width_percent",
	"height_percent",
	"padding_left",
	"padding_top",
	"padding_right",
	"padding_bottom",
	"crop_left",
	"crop_top",
	"crop_right",
	"crop_bottom",
	"layout_crop_x",
	"layout_crop_y",
	"child_margin"
}

local function HorizontalShorthandAttributes(attr, x, y)
	return {attr.."_left", attr.."_right"}
end

local function VerticalShorthandAttributes(attr, x, y)
	return {attr.."_top", attr.."_bottom"}
end

local function ShorthandAttributes(attr, x, y)
	return table.Add(HorizontalShorthandAttributes(attr), VerticalShorthandAttributes(attr))
end

Element.static_shorthand_attributes = {
	fit = {"fit_x", "fit_y"}
}

Element.shorthand_attributes = {
	size = {"width", "height"},
	padding = ShorthandAttributes "padding",
	padding_x = HorizontalShorthandAttributes "padding",
	padding_y = VerticalShorthandAttributes "padding",
	crop = ShorthandAttributes "crop",
	crop_x = HorizontalShorthandAttributes "crop",
	crop_y = VerticalShorthandAttributes "crop"
}

function Element:InitAttributes()
	self.static_attributes = {
		paint = true,
		overlay = false,
		clamp_to_screen = false,
		layout = true,
		origin_position = false,
		origin_justification_x = JUSTIFY_START,
		origin_justification_y = JUSTIFY_START,
		position_justification_x = JUSTIFY_START,
		position_justification_y = JUSTIFY_START,
		self_justification = JUSTIFY_INHERIT,
		self_adjacent_justification = JUSTIFY_INHERIT,
		layout_justification_x = JUSTIFY_START,
		layout_justification_y = JUSTIFY_START,
		layout_direction = DIRECTION_ROW,
		wrap = true,
		fit_x = false,
		fit_y = false,
		crop_margin = true,
		inherit_color = true,
		fill_color = false,
		inherit_cursor = true,
		bubble_mouse = true
	}

	self.optional_attributes = {}

	for _, k in pairs(optional_attributes) do
		self.optional_attributes[k] = true
	end

	self.layout_invalidators = {}

	for _, k in pairs(layout_invalidators) do
		self.layout_invalidators[k] = true
	end

	self.attributes = {}

	for k, v in pairs(animatable_attributes) do
		local props

		if self.layout_invalidators[v] then
			props = {
				animate_callback = function ()
					if IsValid(self.panel) then
						self:Layout(true)
					end
				end
			}
		end

		if isnumber(k) then
			self.attributes[v] = AnimatableValue.New(0, props)
		else
			self.attributes[k] = AnimatableValue.New(v, props)
		end
	end
end

function Element:SetTextJustification(justify)
	self.panel.text:SetContentAlignment(justify)
end

function Element:SetFont(font)
	self.panel.text:SetFont(font)
end

function Element:SetText(text)
	text = tostring(text)

	local old_text = self.panel.text:GetText()

	if text ~= old_text then
		self.panel.text:SetText(text)
		self:Layout()
	end
end

function Element:SetAttribute(k, v, no_layout)
	local static_attr = self.static_attributes
	local attr = self.attributes
	local layout_invalidator = self.layout_invalidators[k]

	local old_v

	if layout_invalidator then
		old_v = self:GetAttribute(k)
	end

	if static_attr[k] ~= nil then
		if self.setters[k] then
			self.setters[k](self, static_attr, attr, v)
		else
			static_attr[k] = v
		end
	elseif attr[k] ~= nil then
		if self.optional_attributes[k] ~= nil and v == false then
			attr[k]:Finish()
			attr[k] = nil
		elseif Class.InstanceOf(v, AnimatableValue) then
			attr[k]:Finish()
			attr[k] = v
		elseif isfunction(v) then
			local old_v = attr[k].current

			attr[k]:Finish()
			attr[k] = AnimatableValue.New(old_v, {
				generate = v
			})
		else
			attr[k].current = v
		end
	elseif self.static_shorthand_attributes[k] then
		for _, _k in pairs(self.static_shorthand_attributes[k]) do
			static_attr[_k] = v
		end
	elseif self.shorthand_attributes[k] then
		for _, _k in pairs(self.shorthand_attributes[k]) do
			attr[_k].current = v
		end
	elseif self.setters[k] then
		self.setters[k](self, static_attr, attr, v)
	elseif self.optional_attributes[k] ~= nil then
		if Class.InstanceOf(v, AnimatableValue) then
			attr[k] = v
		else
			attr[k] = AnimatableValue.New(v)
		end
	elseif Class.InstanceOf(v, Element) then
		local element = self:Add(v)

		if isstring(k) then
			self[k] = element
		end
	elseif self.reserved_states[k] then
		self:AddState(k, v)
	else
		static_attr[k] = v
	end

	if not no_layout and layout_invalidator and (
		(static_attr[k] ~= nil) or (old_v and not self.laying_out and isnumber(v) and math.Round(v, 3) ~= math.Round(old_v, 3))
	) then
		self:Layout()
	end
end

function Element:SetAttributes(attr)
	if attr then
		for k, v in pairs(attr) do
			self:SetAttribute(k, v, true)
		end

		if not self.laying_out then
			self:Layout()
		end
	end
end

function Element:GetColor()
	local color

	local parent = self.parent

	if self.static_attributes.inherit_color and parent then
		color = parent:GetColor()
	else
		color = self.attributes.color.current
	end

	return color
end

function Element:GetAttribute(k)
	local attr

	if self.attributes[k] then
		attr = self.attributes[k].smooth or self.attributes[k].current
	elseif self.static_attributes[k] then
		attr = self.static_attributes[k]
	end

	return attr
end

function Element:AnimateAttribute(k, v, ...)
	local attr = self.attributes

	if attr[k] then
		attr[k]:AnimateTo(v, ...)
	elseif self.shorthand_attributes[k] then
		for _, _k in pairs(self.shorthand_attributes[k]) do
			attr[_k]:AnimateTo(v, ...)
		end
	elseif self.optional_attributes[k] then
		self:SetAttribute(k, v)
	end
end
