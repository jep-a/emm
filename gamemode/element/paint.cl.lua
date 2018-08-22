function Element:PaintTexture(material, props)
	props = props or {}

	local x = props.x or self:GetAttribute "padding_left" - self:GetXCropOffset()
	local y = props.y or self:GetAttribute "padding_top" - self:GetYCropOffset()
	local w = props.width or self:GetAttribute "width"
	local h = props.height or self:GetAttribute "height"
	local ang = props.angle or self:GetAttribute "angle"
	local color = props.color or self:GetAttribute "color"

	surface.SetDrawColor(color)
	surface.SetMaterial(material)

	if ang then
		surface.DrawTexturedRectRotated(x + (w/2), y + (h/2), w, h, ang)
	else
		surface.DrawTexturedRect(x, y, w, h)
	end
end

function Element:PaintRect(props)
	props = props or {}

	local x = props.x or 0
	local y = props.y or 0
	local w = props.width or self:GetAttribute "width"
	local h = props.height or self:GetAttribute "height"
	local color = props.color or self:GetAttribute "color"

	surface.SetDrawColor(color)
	surface.DrawRect(x, y, w, h)
end

function Element:PaintBorder(props)
	props = props or {}

	local w = props.width or self:GetAttribute "width"
	local h = props.height or self:GetAttribute "height"
	w = w - ((w * self:GetAttribute "crop_left") + (w * self:GetAttribute "crop_right"))
	h = h - ((h * self:GetAttribute "crop_top") + (h * self:GetAttribute "crop_bottom"))
	local color = props.color or self:GetAttribute "border_color" or self:GetAttribute "color"
	local thickness = props.thickness or self:GetAttribute "border"

	surface.SetDrawColor(color)
	surface.DrawRect(0, 0, w, thickness)
	surface.DrawRect(w - thickness, 0, thickness, h)
	surface.DrawRect(0, h - thickness, w, thickness)
	surface.DrawRect(0, 0, thickness, h)
end

function Element:Paint()
	self:PaintRect {color = not self:GetAttribute "fill_color" and self:GetAttribute "background_color"}

	local mat = self:GetAttribute "material"

	if mat then
		self:PaintTexture(mat)
	end

	if self:GetAttribute "border" then
		self:PaintBorder()
	end
end