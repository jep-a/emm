Element.setters = {
	duration = function (self, static_attr, attr, v)
		if v > 0 then
			static_attr.duration = v
			static_attr.start_time = CurTime()
		end
	end,

	layout = function (self, static_attr, attr, v)
		static_attr.layout = v

		local parent = self.parent

		if parent then
			local in_layout_children = table.HasValue(parent.layout_children, self)

			if v then
				if not in_layout_children then
					table.insert(parent.layout_children, self)
				end
			else
				if in_layout_children then
					table.RemoveByValue(parent.layout_children, self)
				end
			end
		end
	end,

	cursor = function (self, static_attr, attr, v)
		static_attr.cursor = v

		self.panel:SetCursor(v or "none")

		for _, child in pairs(self.children) do
			if child.static_attributes.inherit_cursor and not child.static_attributes.cursor then
				child:SetAttribute("cursor", v)
			end
		end
	end,

	text_justification = function (self, static_attr, attr, v)
		static_attr.text_justification = v
		self:SetTextJustification(v)
	end,

	font = function (self, static_attr, attr, v)
		static_attr.font = v
		self:SetFont(v)
	end,

	text = function (self, static_attr, attr, v)
		static_attr.text = v
		self:SetText(v)
	end
}
