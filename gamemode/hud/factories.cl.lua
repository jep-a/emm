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
		height_percent = 1
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