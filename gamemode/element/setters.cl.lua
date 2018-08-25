Element.setters = {
	duration = function (self, static_attr, attr, v)
		static_attr.duration = v
		static_attr.start_time = CurTime()
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

	fit = function (self, static_attr, attr, v)
		static_attr.fit_x = v
		static_attr.fit_y = v
	end,

	size = function (self, static_attr, attr, v)
		attr.width.current = v
		attr.height.current = v
	end,

	padding = function (self, static_attr, attr, v)
		attr.padding_left.current = v
		attr.padding_top.current = v
		attr.padding_right.current = v
		attr.padding_bottom.current = v
	end,

	padding_x = function (self, static_attr, attr, v)
		attr.padding_left.current = v
		attr.padding_right.current = v
	end,

	padding_y = function (self, static_attr, attr, v)
		attr.padding_top.current = v
		attr.padding_bottom.current = v
	end,

	crop = function (self, static_attr, attr, v)
		attr.crop_left.current = v
		attr.crop_top.current = v
		attr.crop_right.current = v
		attr.crop_bottom.current = v
	end,

	crop_x = function (self, static_attr, attr, v)
		attr.crop_left.current = v
		attr.crop_right.current = v
	end,

	crop_y = function (self, static_attr, attr, v)
		attr.crop_top.current = v
		attr.crop_bottom.current = v
	end,

	text_justification = function (self, static_attr, attr, v)
		self:SetTextJustification(v)
	end,

	font = function (self, static_attr, attr, v)
		self:SetFont(v)
	end,

	text = function (self, static_attr, attr, v)
		self:LayoutText(v)
		self:SetText(v)
	end
}
