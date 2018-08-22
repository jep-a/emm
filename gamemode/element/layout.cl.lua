local function RoundClamp(x)
	return math.max(math.Round(x), 0)
end

function Element:GetXCropOffset()
	return self:GetAttribute "width" * self:GetAttribute "crop_left"
end

function Element:GetYCropOffset()
	return self:GetAttribute "height" * self:GetAttribute "crop_top"
end

function Element:GetInnerWidth()
	return RoundClamp(self:GetAttribute "width" - self:GetAttribute "padding_left" - self:GetAttribute "padding_right")
end

function Element:GetInnerHeight()
	return RoundClamp(self:GetAttribute "height" - self:GetAttribute "padding_top" - self:GetAttribute "padding_bottom")
end

function Element:GetFinalWidth()
	local w = self:GetAttribute "width"

	return RoundClamp(w - (self:GetXCropOffset() + (w * self:GetAttribute "crop_right")))
end

function Element:GetFinalHeight()
	local h = self:GetAttribute "height"

	return RoundClamp(h - (self:GetYCropOffset() + (h * self:GetAttribute "crop_bottom")))
end

function Element:PositionFromOrigin()
	local x_origin_justify = self:GetAttribute "origin_justification_x"
	local y_origin_justify = self:GetAttribute "origin_justification_y"
	local x_pos_justify = self:GetAttribute "position_justification_x"
	local y_pos_justify = self:GetAttribute "position_justification_y"

	local parent = self.parent
	local parent_w = parent:GetAttribute "width"
	local parent_h = parent:GetAttribute "height"

	local w = self:GetFinalWidth()
	local h = self:GetFinalHeight()

	local start_x

	if x_origin_justify == JUSTIFY_START then
		start_x = 0
	elseif x_origin_justify == JUSTIFY_CENTER then
		start_x = parent_w/2
	elseif x_origin_justify == JUSTIFY_END then
		start_x = parent_w
	end

	local start_y

	if y_origin_justify == JUSTIFY_START then
		start_y = 0
	elseif y_origin_justify == JUSTIFY_CENTER then
		start_y = parent_h/2
	elseif y_origin_justify == JUSTIFY_END then
		start_y = parent_h
	end

	local offset_x

	if x_pos_justify == JUSTIFY_START then
		offset_x = 0
	elseif x_pos_justify == JUSTIFY_CENTER then
		offset_x = -w/2
	elseif x_pos_justify == JUSTIFY_END then
		offset_x = -w
	end

	local offset_y

	if y_pos_justify == JUSTIFY_START then
		offset_y = 0
	elseif y_pos_justify == JUSTIFY_CENTER then
		offset_y = -h/2
	elseif y_pos_justify == JUSTIFY_END then
		offset_y = -h
	end

	self:SetAttribute("x", math.floor(start_x + offset_x))
	self:SetAttribute("y", math.floor(start_y + offset_y))
end

local axis_property_keys = {
	[DIRECTION_ROW] = {
		position = "x",
		size = "width",
		fit = "fit_x",
		padding_start = "padding_left",
		padding_end = "padding_right",
		crop_start = "crop_left",
		crop_end = "crop_right"
	},
	[DIRECTION_COLUMN] = {
		position = "y",
		size = "height",
		fit = "fit_y",
		padding_start = "padding_top",
		padding_end = "padding_bottom",
		crop_start = "crop_top",
		crop_end = "crop_bottom"
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

	local children = self.layout_children

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

		local child_size
		local adj_child_size

		if static_attr.layout_direction == DIRECTION_ROW then
			child_size = child:GetFinalWidth()
			adj_child_size = child:GetFinalHeight()
		elseif static_attr.layout_direction == DIRECTION_COLUMN then
			child_size = child:GetFinalHeight()
			adj_child_size = child:GetFinalWidth()
		end

		if not static_attr.wrap or max_line_size >= (line_size + child_size) then
			child_positions[i] = line_size
			line_size = line_size + child_size

			if i ~= 1 then
				if i == 2 then
					local first_child = children[1]
					local cropped_first_child_margin = (
						child_margin * (
							1 - math.Clamp(first_child:GetAttribute(prop_keys.crop_start) + first_child:GetAttribute(prop_keys.crop_end), 0, 1)
						)
					)

					child_positions[i] = child_positions[i] + cropped_first_child_margin
					line_size = line_size + cropped_first_child_margin
				else
					child_positions[i] = child_positions[i] + child_margin
					line_size = line_size + child_margin
				end
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

	if #line_sizes > 1 then
		for i = 2, #line_sizes do
			adj_line_pos = adj_line_pos + adj_line_sizes[i - 1] + child_margin
			adj_line_start_positions[i] = adj_line_pos
		end
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

		if static_attr.layout_direction == DIRECTION_ROW then
			adj_child_size = child:GetFinalHeight()
		elseif static_attr.layout_direction == DIRECTION_COLUMN then
			adj_child_size = child:GetFinalWidth()
		end

		local child_adj_justify = child:GetAttribute "self_adjacent_justification"

		local inherit_adj_justify

		if child_adj_justify == JUSTIFY_INHERIT then
			inherit_adj_justify = true
		else
			inherit_adj_justify = false
		end

		local adj_pos = adj_line_start_positions[line]

		if inherit_adj_justify and adj_justify == JUSTIFY_CENTER or child_adj_justify == JUSTIFY_CENTER then
			adj_pos = adj_pos + (adj_line_sizes[line]/2) - adj_child_size/2
		elseif inherit_adj_justify and adj_justify == JUSTIFY_END or child_adj_justify == JUSTIFY_END then
			adj_pos = adj_pos + adj_line_sizes[line] - adj_child_size
		end

		child:SetAttribute(adj_prop_keys.position, adj_pos)
	end
end

function Element:LayoutText()
	local text = self.panel.text

	local padding_left = self:GetAttribute "padding_left"
	local padding_top = self:GetAttribute "padding_top"

	text.x = padding_left - self:GetXCropOffset()
	text.y = padding_top - self:GetYCropOffset()

	if self:GetAttribute "fit_x" then
		text:SizeToContentsX()
		self:SetAttribute("width", text:GetWide() + padding_left + self:GetAttribute "padding_right")
	else
		text:SetWide(self:GetInnerWidth())
	end

	if self:GetAttribute "fit_y" then
		text:SizeToContentsY()
		self:SetAttribute("height", text:GetTall() + padding_top + self:GetAttribute "padding_bottom")
	else
		text:SetTall(self:GetInnerHeight())
	end
end

function Element:GenerateSize()
	local parent = self.parent
	local overlay = self:GetAttribute "overlay"
	local width_percent = self:GetAttribute "width_percent"
	local height_percent = self:GetAttribute "height_percent"

	if parent then
		if width_percent then
			local padding

			if overlay then
				padding = 0
			else
				padding = self.parent:GetAttribute "padding_left" + self.parent:GetAttribute "padding_right"
			end

			self:SetAttribute("width", math.floor((self.parent:GetAttribute "width" - padding) * width_percent))
		end

		if height_percent then
			local padding

			if overlay then
				padding = 0
			else
				padding = self.parent:GetAttribute "padding_top" + self.parent:GetAttribute "padding_bottom"
			end

			self:SetAttribute("height", math.floor((self.parent:GetAttribute "height" - padding) * height_percent))
		end
	else
		if width_percent then
			self:SetAttribute("width", math.floor(ScrW() * width_percent))
		end

		if height_percent then
			self:SetAttribute("height", math.floor(ScrH() * height_percent))
		end
	end
end