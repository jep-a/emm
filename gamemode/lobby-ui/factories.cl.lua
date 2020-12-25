-- # Util

function LobbyUIService.CreateHeader(text, fit)
	local element = Element.New {
		fit_y = true,
		width = COLUMN_WIDTH,
		padding_y = 16,
		font = "Header",
		text_justification = 5,
		text = text,
		background_color = COLOR_BACKGROUND_LIGHT,
		border = LINE_THICKNESS
	}

	if fit then
		element:SetAttributes {
			fit_x = true,
			padding_y = 32
		}
	end

	return element
end

function LobbyUIService.CreateLabel(props)
	local element = Element.New {
		layout_justification_x = props.justification,
		self_justification = props.justification or JUSTIFY_INHERIT,
		fit_x = not props.width,
		width_percent = props.width_percent,
		height_percent = 1,
		width = props.width,
		inherit_color = not props.color,
		color = props.color
	}

	element:Add(Element.New {
		fit = true,
		crop_top = 0.125,
		crop_bottom = 0.01,
		font = "Label",
		text = string.upper(props.text),
	})

	element:Add(Element.New {
		layout = false,
		origin_position = true,
		origin_justification_y = JUSTIFY_END,
		position_justification_y = JUSTIFY_END,
		width_percent = 1,
		height = LINE_THICKNESS,
		fill_color = props.color,
		inherit_color = not props.color,
		color = props.color
	})

	return element
end

function LobbyUIService.CreateLabels(left_labels, right_labels)
	local element = Element.New {
		width_percent = 1,
		height = 52,
		padding_x = 32,
		padding_top = 20
	}

	element:Add(Element.New {
		layout = false,
		origin_position = true,
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_END,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_END,
		width_percent = 1,
		height = LINE_THICKNESS,
		fill_color = true
	})

	for _, label in pairs(left_labels) do
		if istable(label) then
			element:Add(LobbyUIService.CreateLabel(label))
		else
			element:Add(LobbyUIService.CreateLabel {text = label})
		end
	end

	if right_labels then
		for _, label in pairs(right_labels) do
			if istable(label) then
				label.justification = label.justification or JUSTIFY_END
				element:Add(LobbyUIService.CreateLabel(label))
			else
				element:Add(LobbyUIService.CreateLabel {text = label, justification = JUSTIFY_END})
			end
		end
	end
	return element
end


-- # Main elements

function LobbyUIService.CreateContainer()
	return ScrollContainer.New({
		origin_position = true,
		origin_justification_x = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_CENTER,
		width_percent = 2,
		height_percent = 1,
		alpha = 0
	}, {
		layout_justification_x = JUSTIFY_CENTER,
		wrap = false,
		width_percent = 1,
		fit_y = true,
		padding_y = 16,
		child_margin = 16
	})
end

function LobbyUIService.CreateNewLobbySection()
	return Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width = COLUMN_WIDTH,
		child_margin = 16,
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

local lobby_request_cooldown = 5
local last_request_lobby_time = 0

function LobbyUIService.CreatePrototypeBar(proto)
	return ButtonBar.New {
		color = proto.color,
		material = PNGMaterial("emm2/minigames/"..proto.key..".png"),
		text = proto.name,
		divider = true,

		on_click = function (self)
			local cur_time = CurTime()

			if cur_time > (last_request_lobby_time + lobby_request_cooldown) then
				NetService.SendToServer("RequestLobby", proto)
				last_request_lobby_time = CurTime()
			else
				chat.AddText(COLOR_RED, "Please wait ", tostring(-math.Round(cur_time - (last_request_lobby_time + lobby_request_cooldown))), " seconds before making a new lobby")
			end
		end
	}
end

function LobbyUIService.CreateLobbySection()
	return Element.New {
		fit_y = true,
		width = COLUMN_WIDTH * (LobbyUIService.HellaSmallScreen() and 1 or 2),
		child_margin = 16,
		header = LobbyUIService.CreateHeader "No open lobbies"
	}
end

function LobbyUIService.CreateLobbyList()
	local element = Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width_percent = 1,
		padding_bottom = 26,
		background_color = COLOR_GRAY,
		LobbyUIService.CreateLabels({
			{
				text = "Type",
				width = 64
			},

			"Host"
		}, {"Players"})
	}

	element:AddState("contains_children", {
		padding_bottom = 16
	})

	return element
end

function LobbyUIService.CreateLobbyCardSection()
	return Element.New {
		fit_y = true,
		width = (COLUMN_WIDTH * 3) + 16,
		layout_crop_x = 1
	}
end