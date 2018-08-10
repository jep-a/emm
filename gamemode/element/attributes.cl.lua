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

local function IsAnimatableValue(anim_v)
	local is_anim_v

	if getmetatable(anim_v) == AnimatableValue then
		is_anim_v = true
	else
		is_anim_v = false
	end

	return is_anim_v
end


function Element:SetAttribute(k, v)
	local static_attr = self.static_attributes
	local attr = self.attributes

	if static_attr[k] ~= nil then
		static_attr[k] = v
	elseif attr[k] ~= nil then
		if IsAnimatableValue(v) then
			attr[k]:Finish()
			attr[k] = v
		elseif isfunction(v) then
			attr[k].generate = v
		else
			attr[k].current = v
		end
	elseif self.setters[k] then
		self.setters[k](self, static_attr, attr, v)
	elseif self.optional_attributes[k] ~= nil then
		if istable(v) and v.current then
			attr[k] = v
		else
			attr[k] = AnimatableValue.New(v)
		end
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
