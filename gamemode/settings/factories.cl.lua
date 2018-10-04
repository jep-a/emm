function SettingsUIService.CreateContainer()
	return ScrollContainer.New({
		width_percent = 1,
		height_percent = 1,
		alpha = 0
	}, {
		wrap = false,
		width_percent = 1,
		fit = true,
		padding = MARGIN * 4,
		child_margin = MARGIN * 4
	})
end

function SettingsUIService.CreateCategory()
	return Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width = COLUMN_WIDTH * 1.5,
		padding_bottom = MARGIN * 2,
		background_color = COLOR_GRAY,
		LobbyUIService.CreateLabels {"Settings"}
	}
end