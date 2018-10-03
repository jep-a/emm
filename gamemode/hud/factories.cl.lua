-- # Factories

function HUDService.CreateContainer()
	return Element.New {
		width_percent = 1,
		height_percent = 1,
		padding_x = SettingsService.Setting "emm_hud_padding_x",
		padding_y = SettingsService.Setting "emm_hud_padding_y"
	}
end

function HUDService.CreateSection(angle, dist)
	local element = HUDService.container:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		width_percent = 1/3,
		height_percent = 1
	})

	local rotate_origin_x

	if angle then
		if angle.y > 0 then
			rotate_origin_x = 1
		elseif 0 > angle.y then
			rotate_origin_x = 0
		end
	end

	CamUIService.AddPanel(element.panel, {distance = dist, angle = angle, rotate_origin_x = rotate_origin_x})

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

function HUDService.CreateCrosshairContainer(camui)
	local element = Element.New {
		overlay = true,
		layout = false,
		origin_position = true,
		width_percent = 1,
		height_percent = 1,
		alpha = 0
	}

	if camui then
		CamUIService.AddPanel(element.panel, {smooth_divider = 4})
	end

	return element
end