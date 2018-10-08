local axis_property_keys = {
	[DIRECTION_ROW] = {
		position = "x",
		size = "width",
		fit = "fit_x",
		padding_start = "padding_left",
		padding_end = "padding_right",
		crop_start = "crop_left",
		crop_end = "crop_right",
		layout_crop = "layout_crop_x"
	},

	[DIRECTION_COLUMN] = {
		position = "y",
		size = "height",
		fit = "fit_y",
		padding_start = "padding_top",
		padding_end = "padding_bottom",
		crop_start = "crop_top",
		crop_end = "crop_bottom",
		layout_crop = "layout_crop_y"
	}
}

function Element:StackChildren()
	local attr = self.attributes
	local static_attr = self.static_attributes
	local children = self.layout_children
	local prop_keys = axis_property_keys[static_attr.layout_direction]

	local adj_prop_keys
	local main_justify
	local adj_justify
	local crop_offset
	local adj_crop_offset

	if static_attr.layout_direction == DIRECTION_ROW then
		adj_prop_keys = axis_property_keys[DIRECTION_COLUMN]
		main_justify = main_justify or static_attr.layout_justification_x
		adj_justify = adj_justify or static_attr.layout_justification_y
		crop_offset = self:GetXCropOffset()
		adj_crop_offset = self:GetYCropOffset()
	elseif static_attr.layout_direction == DIRECTION_COLUMN then
		adj_prop_keys = axis_property_keys[DIRECTION_ROW]
		main_justify = main_justify or static_attr.layout_justification_y
		adj_justify = adj_justify or static_attr.layout_justification_x
		crop_offset = self:GetYCropOffset()
		adj_crop_offset = self:GetXCropOffset()
	end

	local main_children

	local start_children = {}
	local center_children = {}
	local end_children = {}

	if main_justify == JUSTIFY_START then
		main_children = start_children
	elseif main_justify == JUSTIFY_CENTER then
		main_children = center_children
	elseif main_justify == JUSTIFY_END then
		main_children = end_children
	end

	for i = 1, #children do
		local child = children[i]
		local justify = child.static_attributes.self_justification

		if justify == JUSTIFY_INHERIT or main_justify == justify then
			main_children[#main_children + 1] = child
		elseif justify == JUSTIFY_START then
			start_children[#start_children + 1] = child
		elseif justify == JUSTIFY_CENTER then
			center_children[#center_children + 1] = child
		elseif justify == JUSTIFY_END then
			end_children[#end_children + 1] = child
		end
	end

	if #start_children > 0 then
		self:Stack(prop_keys, adj_prop_keys, JUSTIFY_START, adj_justify, crop_offset, adj_crop_offset, start_children)
	end

	if #center_children > 0 then
		self:Stack(prop_keys, adj_prop_keys, JUSTIFY_CENTER, adj_justify, crop_offset, adj_crop_offset, center_children)
	end

	if #end_children > 0 then
		self:Stack(prop_keys, adj_prop_keys, JUSTIFY_END, adj_justify, crop_offset, adj_crop_offset, end_children)
	end
end

function Element:Stack(prop_keys, adj_prop_keys, main_justify, adj_justify, crop_offset, adj_crop_offset, children)
	children = children or self.layout_children

	local attr = self.attributes
	local static_attr = self.static_attributes
	local layout_dir = static_attr.layout_direction

	local fit = static_attr[prop_keys.fit]
	local size = attr[prop_keys.size].current
	local padding_start = attr[prop_keys.padding_start].current
	local padding_end = attr[prop_keys.padding_end].current
	local child_margin = attr.child_margin.current
	local adj_fit = static_attr[adj_prop_keys.fit]
	local adj_size = attr[adj_prop_keys.size].current
	local adj_padding_start = attr[adj_prop_keys.padding_start].current
	local adj_padding_end = attr[adj_prop_keys.padding_end].current

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
	local children_count = #children

	for i = 1, children_count do
		local child = children[i]
		local child_attr = child.attributes

		local child_size
		local adj_child_size

		local layout_crop_x = child_attr.layout_crop_x.current
		local layout_crop_y = child_attr.layout_crop_y.current
		local final_w = child:GetFinalWidth()
		local final_h = child:GetFinalHeight()

		if layout_dir == DIRECTION_ROW then
			child_size = final_w - (final_w * layout_crop_x)
			adj_child_size = final_h - (final_h * layout_crop_y)
		elseif layout_dir == DIRECTION_COLUMN then
			child_size = final_h - (final_h * layout_crop_y)
			adj_child_size = final_w - (final_w * layout_crop_x)
		end

		if fit or not static_attr.wrap or max_line_size >= (line_size + child_size) then
			child_positions[i] = line_size
			line_size = line_size + child_size

			if i ~= 1 then
				local prev_child = children[i - 1]
				local prev_child_attr = prev_child.attributes

				local cropped_prev_child_margin

				if prev_child.static_attributes.crop_margin then
					local total_prev_crop = math.Clamp(prev_child_attr[prop_keys.crop_start].current + prev_child_attr[prop_keys.crop_end].current, 0, 1)

					cropped_prev_child_margin = (1 - total_prev_crop) * (1 - prev_child_attr[prop_keys.layout_crop].current)
				else
					cropped_prev_child_margin = 1
				end

				local total_crop
				local cropped_child_margin

				if i == children_count and child.static_attributes.crop_margin then
					total_crop = math.Clamp(child_attr[prop_keys.crop_start].current + child_attr[prop_keys.crop_end].current, 0, 1)
					cropped_child_margin = (1 - total_crop) * (1 - child_attr[prop_keys.layout_crop].current)
				else
					cropped_child_margin = 1
				end

				local cropped_margin = math.Clamp(child_margin * cropped_prev_child_margin * cropped_child_margin, 0, child_margin)

				child_positions[i] = child_positions[i] + cropped_margin
				line_size = line_size + cropped_margin

				if i == children_count and total_crop == 1 then
					prev_child.last = true
				elseif prev_child.last then
					prev_child.last = false
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

		if i == children_count then
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
		attr[prop_keys.size].current = largest_line_size
	end

	if adj_fit then
		attr[adj_prop_keys.size].current = total_adj_line_size
	end

	line = 1

	for i = 1, children_count do
		if new_lines[i] then
			line = line + 1
		end

		local child = children[i]
		local child_attr = child.attributes
		local child_static_attr = child.static_attributes

		local old_w = child_attr.width.current
		local old_h = child_attr.height.current

		child_attr[prop_keys.position].current = line_start_positions[line] + child_positions[i] - crop_offset

		local layout_crop_x = child_attr.layout_crop_x.current
		local layout_crop_y = child_attr.layout_crop_y.current
		local final_w = child:GetFinalWidth()
		local final_h = child:GetFinalHeight()

		if layout_dir == DIRECTION_ROW then
			adj_child_size = final_h - (final_h * layout_crop_y)
		elseif layout_dir == DIRECTION_COLUMN then
			adj_child_size = final_w - (final_w * layout_crop_x)
		end

		local child_adj_justify = child_static_attr.self_adjacent_justification

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

		child_attr[adj_prop_keys.position].current = adj_pos - adj_crop_offset
	end
end
