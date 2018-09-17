-- # Util

function LobbyUIService.CreateHeader(text, fit)
	local element = Element.New {
		width_percent = 1,
		fit_y = true,
		padding_y = MARGIN * 4,
		font = "Header",
		text_justification = 5,
		text = string.upper(text),
		border = LINE_THICKNESS/2
	}

	if fit then
		element:SetAttributes {
			width_percent = false,
			fit_x = true,
			padding_left = MARGIN * 8,
			padding_right = MARGIN * 7
		}
	end

	return element
end

function LobbyUIService.CreateLabel(text)
	return Element.New {
		fit = true,
		crop_top = 0.125,
		crop_bottom = 0.01,
		font = "Label",
		text_justification = 4,
		text = string.upper(text)
	}
end

function LobbyUIService.CreateLabels(left_labels, right_labels)
	local element = Element.New {
		layout_direction = DIRECTION_ROW,
		layout_justification_y = JUSTIFY_END,
		fit_y = true,
		width_percent = 1,
		padding_left = MARGIN * 8,
		padding_right = MARGIN * 6,
		padding_top = MARGIN * 5,
		inherit_color = false
	}

	element.left_section = element:Add(Element.New {
		layout_direction = DIRECTION_ROW,
		layout_justification_y = JUSTIFY_TOP,
		fit_y = true,
		width_percent = 0.5,
		padding_bottom = MARGIN * 4,
		child_margin = MARGIN * 8
	})

	element.right_section = element:Add(Element.New {
		layout_direction = DIRECTION_ROW,
		layout_justification_x = JUSTIFY_END,
		layout_justification_y = JUSTIFY_TOP,
		fit_y = true,
		width_percent = 0.5,
		padding_bottom = MARGIN * 4,
		child_margin = MARGIN * 8
	})

	element:Add(Element.New {
		width_percent = 1,
		height = LINE_THICKNESS/2,
		fill_color = true
	})

	for _, label in pairs(left_labels) do
		element.left_section:Add(LobbyUIService.CreateLabel(label))
	end

	if right_labels then
		for _, label in pairs(right_labels) do
			element.right_section:Add(LobbyUIService.CreateLabel(label))
		end
	end

	return element
end


-- # Main elements

function LobbyUIService.CreateContainer()
	return Element.New {
		width_percent = 1,
		height_percent = 1,
		padding = 64,
		child_margin = MARGIN * 4,
		alpha = 0
	}
end

function LobbyUIService.CreateNewLobbySection()
	return Element.New {
		layout_direction = DIRECTION_COLUMN,
		width = COLUMN_WIDTH,
		height_percent = 1,
		child_margin = MARGIN * 4,
		LobbyUIService.CreateHeader "Make a new lobby"
	}
end

function LobbyUIService.CreatePrototypeList()
	return Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width_percent = 1,
		background_color = COLOR_GRAY
	}
end

function LobbyUIService.CreatePrototypeBar(proto)
	return ButtonBar.New {
		color = proto.color,
		material = Material("emm2/minigames/"..proto.key..".png", "nocull smooth"),
		text = proto.name,
		divider = true,

		on_click = function (self)
			NetService.Send("RequestLobby", proto)
		end
	}
end

function LobbyUIService.CreateLobbySection()
	return Element.New {
		width_percent = 0.25,
		height_percent = 1,
		child_margin = MARGIN * 4,
		header = LobbyUIService.CreateHeader("No open lobbies", true)
	}
end

function LobbyUIService.CreateLobbyList()
	local element = Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width_percent = 1,
		padding_bottom = MARGIN * 6.5,
		background_color = COLOR_GRAY,
		LobbyUIService.CreateLabels({"Type", "Host"}, {"Players"})
	}

	element:AddState("contains_children", {
		padding_bottom = MARGIN * 4
	})

	return element
end

function LobbyUIService.CreateLobbyCardSection()
	return Element.New {
		layout_direction = DIRECTION_COLUMN,
		width = COLUMN_WIDTH,
		height_percent = 1,
		child_margin = MARGIN * 4
	}
end