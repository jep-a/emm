function Element:PaintTexture(mat, x, y, w, h, ang, color)
	local attr = self.attributes

	x = x + attr.padding_left.current - self:GetXCropOffset()
	y = y + attr.padding_top.current - self:GetYCropOffset()
	w = w or attr.width.current
	h = h or attr.height.current
	ang = ang or (attr.angle and attr.angle.current) or 0
	color = color or self:GetColor()

	draw.NoTexture()
	surface.SetDrawColor(color)
	surface.SetMaterial(mat)

	if ang then
		surface.DrawTexturedRectRotated(x + (w/2), y + (h/2), w, h, ang)
	else
		surface.DrawTexturedRect(x, y, w, h)
	end
end

function Element:PaintRect(x, y, w, h, color)
	local attr = self.attributes

	x = x or 0
	y = y or 0
	w = w or attr.width.current
	h = h or attr.height.current
	color = color or self:GetColor()

	surface.SetDrawColor(color)
	surface.DrawRect(x, y, w, h)
end

function Element:PaintBorder(w, h, color, thickness)
	local attr = self.attributes

	w = w or attr.width.current
	h = h or attr.height.current
	color = color or (attr.border_color and attr.border_color.current) or self:GetColor()
	thickness = thickness or attr.border.current

	local cropped_w = w - ((w * attr.crop_left.current) + (w * attr.crop_right.current))
	local cropped_h = h - ((h * attr.crop_top.current) + (h * attr.crop_bottom.current))
	local color_with_alpha = ColorAlpha(color, CombineAlphas(color.a, attr.border_alpha.current) * 255)
	local double_thickness = (thickness * 2)

	surface.SetDrawColor(color_with_alpha)
	surface.DrawRect(0, 0, cropped_w, thickness)
	surface.DrawRect(cropped_w - thickness, thickness, thickness, cropped_h - double_thickness)
	surface.DrawRect(0, cropped_h - thickness, cropped_w, thickness)
	surface.DrawRect(0, thickness, thickness, cropped_h - double_thickness)
end

function Element:Paint()
	local static_attr = self.static_attributes

	if static_attr.paint then
		local attr = self.attributes
		local x = 0
		local y = 0
		local w = attr.width.current
		local h = attr.height.current
		local color = self:GetColor()

		self:PaintRect(x, y, w, h, not static_attr.fill_color and attr.background_color.current or color)

		local mat = static_attr.material

		if mat then
			self:PaintTexture(mat, x, y, w, h, attr.angle and attr.angle.current or 0, color)
		end
	end
end

function Element:PaintOver()
	local static_attr = self.static_attributes

	if static_attr.paint then
		if self.attributes.border then
			self:PaintBorder()
		end
	end
end