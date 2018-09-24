CrosshairLine = CrosshairLine or Class.New(Element)

function CrosshairLine:Init(props)
	local orientation = props.orientation or DIRECTION_ROW

	CrosshairLine.super.Init(self, {
		layout = false,
		origin_position = true,
		fill_color = true,
		border = 1,
		border_color = COLOR_BACKGROUND
	})

	self.orientation = orientation

	if props then
		self:SetAttributes(props)
	end
end

function CrosshairLine:GenerateSize()
	if self.parent then
		local parent_attr = self.parent.attributes
		local attr = self.attributes
		local length = (parent_attr.width.current/2) - (parent_attr.child_margin.current/2)

		if self.orientation == DIRECTION_ROW then
			attr.width.current = length
			attr.height.current = CROSSHAIR_LINE_THICKNESS
		elseif self.orientation == DIRECTION_COLUMN then
			attr.width.current = CROSSHAIR_LINE_THICKNESS
			attr.height.current = length
		end
	end
end

function CrosshairLine:Layout()
	self.laying_out = true

	self:GenerateSize()
	self:PositionFromOrigin()
	self:SetPanelBounds()

	self.laying_out = false
end

CrosshairLines = CrosshairLines or Class.New(Element)

function CrosshairLines:Init(size, gap)
	CrosshairLines.super.Init(self, {
		layout = false,
		origin_position = true,
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_CENTER,
		size = size or SettingsService.Setting "emm_crosshair_size",
		child_margin = gap or SettingsService.Setting "emm_crosshair_gap",

		CrosshairLine.New {
			orientation = DIRECTION_COLUMN,
			origin_justification_x = JUSTIFY_CENTER,
			position_justification_x = JUSTIFY_CENTER
		},
	
		CrosshairLine.New {
			origin_justification_x = JUSTIFY_END,
			origin_justification_y = JUSTIFY_CENTER,
			position_justification_x = JUSTIFY_END,
			position_justification_y = JUSTIFY_CENTER
		},
	
		CrosshairLine.New {
			orientation = DIRECTION_COLUMN,
			origin_justification_x = JUSTIFY_CENTER,
			origin_justification_y = JUSTIFY_END,
			position_justification_x = JUSTIFY_CENTER,
			position_justification_y = JUSTIFY_END,
		},
	
		CrosshairLine.New {
			origin_justification_y = JUSTIFY_CENTER,
			position_justification_y = JUSTIFY_CENTER
		}
	})

	if not size then
		self:AddConvarAnimator("emm_crosshair_size", "size")
	end

	if not gap then
		self:AddConvarAnimator("emm_crosshair_gap", "child_margin")
	end
end