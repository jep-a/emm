-- # Factories

function HUDService.CreateContainer()
	return Element.New {
		width_percent = 1,
		height_percent = 1,
		padding_x = HUD_PADDING_X,
		padding_y = HUD_PADDING_Y
	}
end

function HUDService.CreateSection(dist, ang)
	local element = HUDService.container:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		width_percent = 1/3,
		height_percent = 1,
		alpha = 0
	})

	CamUIService.AddPanel(element.panel, dist, ang)

	return element
end

function HUDService.CreateQuadrant(section, props)
	local element = section:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		wrap = false,
		width_percent = 1,
		height_percent = 1/3,
		child_margin = MARGIN
	})

	if props then
		element:SetAttributes(props)
	end

	return element
end

function HUDService.CreateCrosshairContainer()
	return Element.New {
		layout = false,
		origin_position = true,
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_CENTER,
		width = CROSSHAIR_CONTAINER_SIZE,
		height = CROSSHAIR_CONTAINER_SIZE
	}
end

function HUDService.CreateCrosshairLinesContainer()
	return Element.New {
		layout = false,
		origin_position = true,
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_CENTER,
		width = CROSSHAIR_LINES_SIZE,
		height = CROSSHAIR_LINES_SIZE
	}
end

function HUDService.CreateCrosshairMeter(props)
	return HUDService.crosshair_container:Add(CrosshairMeter.New(props))
end

function HUDService.CreateCrosshairLine(props)
	local element = HUDService.crosshair_lines_container:Add(Element.New {
		layout = false,
		origin_position = true,
		fill_color = true,
		border = 1,
		border_color = COLOR_BACKGROUND
	})

	local function Length()
		return (HUDService.crosshair_lines_container:GetAttribute "width"/2) - (CROSSHAIR_LINES_GAP/2)
	end

	if props.orientation == DIRECTION_ROW then
		element:SetAttributes {
			width = Length,
			height = CROSSHAIR_LINE_THICKNESS
		}
	else
		element:SetAttributes {
			width = CROSSHAIR_LINE_THICKNESS,
			height = Length
		}
	end

	element:SetAttributes(props)

	return element
end