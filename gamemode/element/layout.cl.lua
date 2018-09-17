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
	local origin_x = self:GetAttribute "origin_x"
	local origin_y = self:GetAttribute "origin_y"
	local x_origin_justify = self:GetAttribute "origin_justification_x"
	local y_origin_justify = self:GetAttribute "origin_justification_y"
	local x_pos_justify = self:GetAttribute "position_justification_x"
	local y_pos_justify = self:GetAttribute "position_justification_y"

	local parent = self.parent

	local parent_w
	local parent_h

	if parent then
		parent_w = parent:GetFinalWidth()
		parent_h = parent:GetFinalHeight()
	else
		parent_w = ScrW()
		parent_h = ScrH()
	end

	local w = self:GetFinalWidth()
	local h = self:GetFinalHeight()

	local start_x

	if origin_x then
		start_x = origin_x
	elseif x_origin_justify == JUSTIFY_START then
		start_x = 0
	elseif x_origin_justify == JUSTIFY_CENTER then
		start_x = parent_w/2
	elseif x_origin_justify == JUSTIFY_END then
		start_x = parent_w
	end

	local start_y

	if origin_y then
		start_y = origin_y
	elseif y_origin_justify == JUSTIFY_START then
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

	self:SetAttributes {
		x = math.floor(start_x + offset_x),
		y = math.floor(start_y + offset_y)
	}
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
	local crop_offset
	local adj_crop_offset

	if static_attr.layout_direction == DIRECTION_ROW then
		adj_prop_keys = axis_property_keys[DIRECTION_COLUMN]
		main_justify = static_attr.layout_justification_x
		adj_justify = static_attr.layout_justification_y
		crop_offset = self:GetXCropOffset()
		adj_crop_offset = self:GetYCropOffset()
	elseif static_attr.layout_direction == DIRECTION_COLUMN then
		adj_prop_keys = axis_property_keys[DIRECTION_ROW]
		main_justify = static_attr.layout_justification_y
		adj_justify = static_attr.layout_justification_x
		crop_offset = self:GetYCropOffset()
		adj_crop_offset = self:GetXCropOffset()
	end

	local fit = static_attr[prop_keys.fit]
	local size = self:GetAttribute(prop_keys.size)
	local padding_start = self:GetAttribute(prop_keys.padding_start)
	local padding_end = self:GetAttribute(prop_keys.padding_end)
	local child_margin = self:GetAttribute "child_margin"
	local adj_fit = static_attr[adj_prop_keys.fit]
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

		if fit or not static_attr.wrap or max_line_size >= (line_size + child_size) then
			child_positions[i] = line_size
			line_size = line_size + child_size

			if i ~= 1 then
				local prev_child = children[i - 1]
				local cropped_prev_child_margin = (
					child_margin * (
						1 - math.Clamp(prev_child:GetAttribute(prop_keys.crop_start) + prev_child:GetAttribute(prop_keys.crop_end), 0, 1)
					)
				)

				child_positions[i] = child_positions[i] + cropped_prev_child_margin
				line_size = line_size + cropped_prev_child_margin
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

	if fit then
		self:SetAttribute(prop_keys.size, largest_line_size)
	end

	if adj_fit then
		self:SetAttribute(adj_prop_keys.size, total_adj_line_size)
	end

	line = 1

	for i = 1, #children do
		if new_lines[i] then
			line = line + 1
		end

		local child = children[i]

		child:SetAttribute(prop_keys.position, line_start_positions[line] + child_positions[i] - crop_offset)

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

		child:SetAttribute(adj_prop_keys.position, adj_pos - adj_crop_offset)
	end
end

function Element:Fit()
	local fit_x = self:GetAttribute "fit_x"
	local fit_y = self:GetAttribute "fit_y"

	local padding_left = self:GetAttribute "padding_left"
	local padding_right = self:GetAttribute "padding_right"
	local padding_top = self:GetAttribute "padding_top"
	local padding_bottom = self:GetAttribute "padding_bottom"

	local children = self.children

	local largest_w = 0
	local largest_h = 0

	for i = 1, #children do
		local child = children[i]
		local child_w = child:GetFinalWidth()
		local child_h = child:GetFinalHeight()
		local overlay = child:GetAttribute "overlay"

		if fit_x and not child:GetAttribute "width_percent" and child_w > largest_w then
			largest_w = child_w

			if overlay then
				largest_w = largest_w + padding_left + padding_right
			end
		end

		if fit_y and not child:GetAttribute "height_percent" and child_h > largest_h then
			largest_h = child_h

			if overlay then
				largest_h = largest_h + padding_top + padding_bottom
			end
		end
	end

	if fit_x then
		self:SetAttribute("width", largest_w)
	end
	
	if fit_y then
		self:SetAttribute("height", largest_h)
	end
end

function Element:LayoutText(new_text)
	local text = self.panel.text

	local padding_left = self:GetAttribute "padding_left"
	local padding_top = self:GetAttribute "padding_top"

	text.x = padding_left - self:GetXCropOffset()
	text.y = padding_top - self:GetYCropOffset()

	surface.SetFont(text:GetFont())
	local text_w, text_h = surface.GetTextSize(new_text or text:GetText())

	if self:GetAttribute "fit_x" then
		self:SetAttribute("width", text_w + padding_left + self:GetAttribute "padding_right")
		text:SizeToContentsX()
	else
		text:SetWide(self:GetInnerWidth())
	end

	if self:GetAttribute "fit_y" then
		self:SetAttribute("height", text_h + padding_top + self:GetAttribute "padding_bottom")
		text:SizeToContentsY()
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