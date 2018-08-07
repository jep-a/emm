JUSTIFY_START = 0
JUSTIFY_CENTER = 1
JUSTIFY_END = 2

DIRECTION_ROW = 0
DIRECTION_COLUMN = 1


-- # Panel

local ElementPanel = {}

function ElementPanel:Init()
	self.text = self:Add(vgui.Create "DLabel")
	self.text:SetText ""
end

function ElementPanel:SetAttribute(k, v)
	self.element:SetAttribute(k, v)
end

function ElementPanel:GetAttribute(k)
	return self.element:GetAttribute(k)
end

function ElementPanel:OnRemove()
	self.removing = true
	self.element:Finish()
end

function ElementPanel:Think()
	self.element:Think()
end

function ElementPanel:PerformLayout()
	self.element:PerformLayout()
end

function ElementPanel:PaintTexture(material, props)
	props = props or {}

	local x = props.x or 0
	local y = props.y or 0
	local w = props.width or self:GetAttribute "width"
	local h = props.height or self:GetAttribute "height"
	local color = props.color or self:GetAttribute "color"

	surface.SetDrawColor(color)
	surface.SetMaterial(material)
	surface.DrawTexturedRect(x, y, w, h)
end

function ElementPanel:PaintRect(props)
	props = props or {}

	local x = props.x or 0
	local y = props.y or 0
	local w = props.width or self:GetAttribute "width"
	local h = props.height or self:GetAttribute "height"
	local color = props.color or self:GetAttribute "color"

	surface.SetDrawColor(color)
	surface.DrawRect(x, y, w, h)
end

function ElementPanel:Paint(w, h)
	self:PaintRect {color = not self:GetAttribute "fill_color" and self:GetAttribute "background_color"}

	local mat = self:GetAttribute "material"

	if mat then
		self:PaintTexture(mat)
	end

	-- surface.SetDrawColor(ColorAlpha(COLOR_RED, 100))
	-- surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("ElementPanel", ElementPanel, "EditablePanel")


-- # Class

Element = Element or Class.New()

function Element:Init(props)
	self.children = {}

	self.panel = vgui.Create "ElementPanel"
	self.panel.element = self

	self.static_attributes = {
		layout_justification_x = JUSTIFY_START,
		layout_justification_y = JUSTIFY_START,
		layout_direction = DIRECTION_ROW,
		wrap = true,
		fit_x = false,
		fit_y = false,
		inherit_color = true,
		fill_color = false
	}

	self.attributes = {
		x = AnimatableValue.New(0),
		y = AnimatableValue.New(0),
		width = AnimatableValue.New(256),
		height = AnimatableValue.New(64),
		padding_left = AnimatableValue.New(0),
		padding_top = AnimatableValue.New(0),
		padding_right = AnimatableValue.New(0),
		padding_bottom = AnimatableValue.New(0),
		child_margin = AnimatableValue.New(0),
		color = AnimatableValue.New(COLOR_WHITE),
		background_color = AnimatableValue.New(COLOR_BLACK_CLEAR),
		alpha = AnimatableValue.New(255)
	}

	self.optional_attributes = {
		width_percent = true,
		height_percent = true
	}

	if props then
		self:SetAttributes(props)
	end
end

function Element:Add(element)
	element.parent = self

	self.panel:Add(element.panel)

	table.insert(self.children, element)

	return element
end

function Element:Finish()
	if not IsValid(self.panel) or self.panel.removing then
		if self.parent then
			table.RemoveByValue(self.parent.children, self)
			self.parent = nil
		end

		for k, v in pairs(self.attributes) do
			v:Finish()
		end
	else
		self.panel:Remove()
	end
end

function Element:SetTextJustification(justify)
	self.panel.text:SetContentAlignment(justify)
end

function Element:SetFont(font)
	self.panel.text:SetFont(font)
end

function Element:SetText(text)
	self.panel.text:SetText(text)
	self.panel:InvalidateLayout()
end

function Element:SetAttribute(k, v)
	local static_attr = self.static_attributes
	local attr = self.attributes

	if static_attr[k] ~= nil then
		static_attr[k] = v
	elseif attr[k] ~= nil then
		if isfunction(v) then
			attr[k].generate = v
		else
			attr[k].current = v
		end
	elseif self.optional_attributes[k] ~= nil then
		if istable(v) and v.current then
			attr[k] = v
		else
			attr[k] = AnimatableValue.New(v)
		end
	elseif k == "fit" then
		static_attr.fit_x = v
		static_attr.fit_y = v
	elseif k == "padding" then
		attr.padding_left.current = v
		attr.padding_top.current = v
		attr.padding_right.current = v
		attr.padding_bottom.current = v
	elseif k == "padding_x" then
		attr.padding_left.current = v
		attr.padding_right.current = v
	elseif k == "padding_y" then
		attr.padding_top.current = v
		attr.padding_bottom.current = v
	elseif k == "text_justification" then
		self:SetTextJustification(v)
	elseif k == "font" then
		self:SetFont(v)
	elseif k == "text" then
		self:SetText(v)
	else
		static_attr[k] = v
	end
end

function Element:SetAttributes(attr)
	for k, v in pairs(attr) do
		self:SetAttribute(k, v)
	end
end

function Element:GetAttribute(k)
	local attr

	if k == "color" and self.static_attributes.inherit_color and self.parent then
		attr = self.parent:GetAttribute "color"
	elseif self.attributes[k] then
		attr = self.attributes[k].smooth or self.attributes[k].current
	elseif self.static_attributes[k] then
		attr = self.static_attributes[k]
	end

	return attr
end

function Element:AnimateAttribute(k, v, ...)
	self.attributes[k]:AnimateTo(v, ...)
end

local axis_property_keys = {
	[DIRECTION_ROW] = {
		position = "x",
		size = "width",
		fit = "fit_x",
		padding_start = "padding_left",
		padding_end = "padding_right"
	},
	[DIRECTION_COLUMN] = {
		position = "y",
		size = "height",
		fit = "fit_y",
		padding_start = "padding_top",
		padding_end = "padding_bottom"
	}
}

function Element:StackChildren()
	local static_attr = self.static_attributes
	local prop_keys = axis_property_keys[static_attr.layout_direction]
	local adj_prop_keys
	local main_justify
	local adj_justify

	if static_attr.layout_direction == DIRECTION_ROW then
		adj_prop_keys = axis_property_keys[DIRECTION_COLUMN]
		main_justify = static_attr.layout_justification_x
		adj_justify = static_attr.layout_justification_y
	elseif static_attr.layout_direction == DIRECTION_COLUMN then
		adj_prop_keys = axis_property_keys[DIRECTION_ROW]
		main_justify = static_attr.layout_justification_y
		adj_justify = static_attr.layout_justification_x
	end

	local size = self:GetAttribute(prop_keys.size)
	local padding_start = self:GetAttribute(prop_keys.padding_start)
	local padding_end = self:GetAttribute(prop_keys.padding_end)
	local child_margin = self:GetAttribute "child_margin"
	local adj_size = self:GetAttribute(adj_prop_keys.size)
	local adj_padding_start = self:GetAttribute(adj_prop_keys.padding_start)
	local adj_padding_end = self:GetAttribute(adj_prop_keys.padding_end)

	local children = self.children

	local max_line_size = size - padding_start - padding_end

	local new_lines = {}
	local line_sizes = {}
	local adj_line_sizes = {}
	local line_start_positions = {}
	local adj_line_start_positions = {}
	local child_positions = {}

	local line = 1
	local line_size = 0
	local adj_line_size = 0
	local largest_line_size = 0

	for i = 1, #children do
		local child = children[i]
		local child_size = child:GetAttribute(prop_keys.size)
		local adj_child_size = child:GetAttribute(adj_prop_keys.size)

		if not static_attr.wrap or max_line_size >= (line_size + child_size) then
			child_positions[i] = line_size
			line_size = line_size + child_size

			if i ~= 1 then
				child_positions[i] = child_positions[i] + child_margin
				line_size = line_size + child_margin
			end

			if adj_child_size > adj_line_size then
				adj_line_size = adj_child_size
			end
		else
			new_lines[i] = true
			line_sizes[line] = line_size
			adj_line_sizes[line] = adj_line_size
			child_positions[i] = 0

			line = line + 1
			line_size = child_size
			adj_line_size = adj_child_size
		end

		if i == #children then
			line_sizes[line] = line_size
			adj_line_sizes[line] = adj_line_size
		end

		if line_size > largest_line_size then
			largest_line_size = line_size
		end
	end
	
	largest_line_size = largest_line_size + padding_start + padding_end
	local total_adj_line_size = adj_padding_start + adj_padding_end

	for i = 1, #line_sizes do
		if main_justify == JUSTIFY_START then
			line_start_positions[i] = padding_start
		elseif main_justify == JUSTIFY_CENTER then
			line_start_positions[i] = (size/2) - (line_sizes[i]/2)
		elseif main_justify == JUSTIFY_END then
			line_start_positions[i] = size - line_sizes[i] - padding_end
		end

		total_adj_line_size = total_adj_line_size + adj_line_sizes[i]

		if i < #line_sizes then
			total_adj_line_size = total_adj_line_size + child_margin
		end
	end

	if adj_justify == JUSTIFY_START then
		adj_line_start_positions[1] = adj_padding_start
	elseif adj_justify == JUSTIFY_CENTER then
		adj_line_start_positions[1] = adj_padding_start + (adj_size/2) - (total_adj_line_size/2)
	elseif adj_justify == JUSTIFY_END then
		adj_line_start_positions[1] = adj_padding_start + adj_size - total_adj_line_size
	end

	local adj_line_pos = adj_line_start_positions[1]

	for i = 2, #line_sizes do
		adj_line_pos = adj_line_pos + adj_line_sizes[i - 1] + child_margin
		adj_line_start_positions[i] = adj_line_pos
	end

	if static_attr[prop_keys.fit] then
		self:SetAttribute(prop_keys.size, largest_line_size + padding_start + padding_end)
	end

	if static_attr[adj_prop_keys.fit] then
		self:SetAttribute(adj_prop_keys.size, total_adj_line_size + adj_padding_start + adj_padding_end)
	end

	line = 1

	for i = 1, #children do
		if new_lines[i] then
			line = line + 1
		end

		local child = children[i]

		child:SetAttribute(prop_keys.position, line_start_positions[line] + child_positions[i])
		child:SetAttribute(adj_prop_keys.position, adj_line_start_positions[line])
	end
end

function Element:FitText()
	local text = self.panel.text

	if self:GetAttribute "fit_x" then
		text:SizeToContentsX()
		
		local padding_left = self:GetAttribute "padding_left"

		text.x = padding_left
		self:SetAttribute("width", text:GetWide() + padding_left + self:GetAttribute "padding_right")
	else
		self.panel.text:SetWide(self:GetAttribute "width")
	end

	if self:GetAttribute "fit_y" then
		text:SizeToContentsY()

		local padding_top = self:GetAttribute "padding_top"

		text.y = padding_top
		self:SetAttribute("height", text:GetTall() + padding_top + self:GetAttribute "padding_bottom")
	else
		self.panel.text:SetTall(self:GetAttribute "height")
	end
end

function Element:PerformLayout()
	if #self.children > 0 then
		self:StackChildren()
	else
		self:FitText()
	end
end

function Element:GenerateSize()
	local parent = self.parent
	local width_percent = self:GetAttribute "width_percent"
	local height_percent = self:GetAttribute "height_percent"

	if parent then
		if width_percent then
			self:SetAttribute("width", math.Round((self.parent:GetAttribute "width" - self.parent:GetAttribute "padding_left" - self.parent:GetAttribute "padding_right") * width_percent))
		end

		if height_percent then
			self:SetAttribute("height", math.Round((self.parent:GetAttribute "height" - self.parent:GetAttribute "padding_top" - self.parent:GetAttribute "padding_bottom") * height_percent))
		end
	else
		if width_percent then
			self:SetAttribute("width", math.Round(ScrW() * width_percent))
		end

		if height_percent then
			self:SetAttribute("height", math.Round(ScrH() * height_percent))
		end
	end
end

function Element:Think()
	self.panel:SetSize(math.Round(self:GetAttribute "width"), math.Round(self:GetAttribute "height"))
	self.panel:SetPos(math.Round(self:GetAttribute "x"), math.Round(self:GetAttribute "y"))
	self.panel:SetAlpha(math.Round(self:GetAttribute "alpha"))
	self.panel.text:SetTextColor(self:GetAttribute "color")
	self:GenerateSize()
end