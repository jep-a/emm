local function RoundClamp(x)
	return math.max(math.Round(x), 0)
end

function Element:GetXCropOffset()
	local attr = self.attributes

	return attr.width.current * attr.crop_left.current
end

function Element:GetYCropOffset()
	local attr = self.attributes

	return attr.height.current * attr.crop_top.current
end

function Element:GetInnerWidth()
	local attr = self.attributes

	return RoundClamp(attr.width.current - attr.padding_left.current - attr.padding_right.current)
end

function Element:GetInnerHeight()
	local attr = self.attributes

	return RoundClamp(attr.height.current - attr.padding_top.current - attr.padding_bottom.current)
end

function Element:GetFinalWidth()
	local attr = self.attributes
	local w = attr.width.current

	return RoundClamp(w - (self:GetXCropOffset() + (w * attr.crop_right.current)))
end

function Element:GetFinalHeight()
	local attr = self.attributes
	local h = attr.height.current

	return RoundClamp(h - (self:GetYCropOffset() + (h * attr.crop_bottom.current)))
end

function Element:PositionFromOrigin()
	local attr = self.attributes
	local static_attr = self.static_attributes
	local origin_x = attr.origin_x and attr.origin_x.current
	local origin_y = attr.origin_y and attr.origin_y.current
	local x_origin_justify = static_attr.origin_justification_x
	local y_origin_justify = static_attr.origin_justification_y
	local x_pos_justify = static_attr.position_justification_x
	local y_pos_justify = static_attr.position_justification_y

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

	attr.x.current = math.floor(start_x + offset_x)
	attr.y.current = math.floor(start_y + offset_y)
end

function Element:Fit()
	local attr = self.attributes
	local static_attr = self.static_attributes

	local fit_x = static_attr.fit_x
	local fit_y = static_attr.fit_y

	local padding_left = attr.padding_left.current
	local padding_right = attr.padding_right.current
	local padding_top = attr.padding_top.current
	local padding_bottom = attr.padding_bottom.current

	local children = self.children

	local largest_w = 0
	local largest_h = 0

	for i = 1, #children do
		local child = children[i]
		local child_attr = child.attributes
		local child_static_attr = child.static_attributes
	
		local child_w = child:GetFinalWidth()
		local child_h = child:GetFinalHeight()
		local overlay = child_static_attr.overlay

		if fit_x and not (attr.width_percent and attr.width_percent.current) and not child_attr.width_percent and child_w > largest_w then
			largest_w = child_w

			if overlay then
				largest_w = largest_w + padding_left + padding_right
			end
		end

		if fit_y and not (attr.height_percent and attr.height_percent.current) and not child_attr.height_percent and child_h > largest_h then
			largest_h = child_h

			if overlay then
				largest_h = largest_h + padding_top + padding_bottom
			end
		end
	end

	if fit_x then
		attr.width.current = largest_w
	end
	
	if fit_y then
		attr.height.current = largest_h
	end
end

function Element:LayoutText(new_text)
	local attr = self.attributes
	local static_attr = self.static_attributes
	local text = self.panel.text

	local padding_left = attr.padding_left.current
	local padding_top = attr.padding_top.current

	text.x = padding_left - self:GetXCropOffset()
	text.y = padding_top - self:GetYCropOffset()

	surface.SetFont(text:GetFont())
	local text_w, text_h = surface.GetTextSize(new_text or text:GetText())

	if static_attr.fit_x then
		attr.width.current = text_w + padding_left + attr.padding_right.current
		text:SizeToContentsX()
	else
		text:SetWide(self:GetInnerWidth())
	end

	if static_attr.fit_y then
		attr.height.current = text_h + padding_top + attr.padding_bottom.current
		text:SizeToContentsY()
	else
		text:SetTall(self:GetInnerHeight())
	end
end

function Element:GenerateSize()
	local attr = self.attributes
	local static_attr = self.static_attributes
	local parent = self.parent

	local overlay = static_attr.overlay
	local width_percent = attr.width_percent and attr.width_percent.current
	local height_percent = attr.height_percent and attr.height_percent.current

	local parent_attr
	if parent then
		parent_attr = parent.attributes

		if width_percent then
			local padding

			if overlay then
				padding = 0
			else
				padding = parent_attr.padding_left.current + parent_attr.padding_right.current
			end

			attr.width.current = math.floor((parent_attr.width.current - padding) * width_percent)
		end

		if height_percent then
			local padding

			if overlay then
				padding = 0
			else
				padding = parent_attr.padding_top.current + parent_attr.padding_bottom.current
			end

			attr.height.current = math.floor((parent_attr.height.current - padding) * height_percent)
		end
	else
		if width_percent then
			attr.width.current = math.floor(ScrW() * width_percent)
		end

		if height_percent then
			attr.height.current = math.floor(ScrH() * height_percent)
		end
	end
end

function Element:SetPanelBounds(x, y, w, h)
	local attr = self.attributes

	self.panel:SetSize(w or self:GetFinalWidth(), h or self:GetFinalHeight())

	self.panel:SetPos(
		math.Round(x or (attr.x.current + attr.offset_x.current)),
		math.Round(x or (attr.y.current + attr.offset_y.current))
	)
end

function Element:ClampToScreen()
	local attr = self.attributes
	local x = attr.x.current
	local y = attr.y.current
	local w = self:GetFinalWidth()
	local h = self:GetFinalHeight()
	local scr_w = ScrW()
	local scr_h = ScrH()

	if 0 > x then
		attr.x.current = 0
	elseif (x + w) > scr_w then
		attr.x.current = scr_w - w
	end

	if 0 > y then
		attr.y.current = 0
	elseif (y + h) > scr_h then
		attr.y.current = scr_h - h
	end
end

function Element:LayoutFamily()
	for _, child in pairs(self.children) do
		if not child.laying_out then
			child:Layout()
		end
	end

	local parent = self.parent

	if parent and not parent.laying_out then
		parent:Layout(true)
	end
end

function Element:Layout(force_family_layout)
	self.laying_out = true

	local attr = self.attributes
	local static_attr = self.static_attributes

	local old_x = attr.x.current
	local old_y = attr.y.current
	local old_w = attr.width.current
	local old_h = attr.height.current

	if static_attr.origin_position then
		self:PositionFromOrigin()
	end

	if static_attr.font then
		self:LayoutText()
	end

	if #self.layout_children > 0 then
		self:StackChildren()
	else
		if static_attr.font then
			self:LayoutText()
		elseif #self.children > 0 then
			self:Fit()
		end
	end

	self:GenerateSize()

	if static_attr.clamp_to_screen then
		self:ClampToScreen()
	end

	local new_x = attr.x.current
	local new_y = attr.y.current
	local new_w = attr.width.current
	local new_h = attr.height.current

	if force_family_layout or old_x ~= new_x or old_y ~= new_y or old_w ~= new_w or old_h ~= new_h then
		self:LayoutFamily()
	end

	self:SetPanelBounds()

	self.laying_out = false
end