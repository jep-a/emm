LobbySettings = LobbySettings or Class.New(Element)

function LobbySettings:Init(lobby)
	LobbySettings.super.Init(self, {
		layout_direction = DIRECTION_COLUMN,
		fit = true,
		child_margin = MARGIN * 4,
		LobbyUIService.CreateHeader "Lobby settings"
	})

	self.lobby = lobby

	self.body = self:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit = true,
		child_margin = MARGIN * 4,
	})

	self.game_category = self:AddCategory "Game"
	self.player_class_categories = {}
	self.inputs = {}

	self:InitSettings()
end

function LobbySettings:AddCategory(label, color)
	return self.body:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width = COLUMN_WIDTH,
		padding_bottom = MARGIN * 2,
		inherit_color = false,
		color = color,
		background_color = COLOR_GRAY,
		LobbyUIService.CreateLabels {label}
	})
end

function LobbySettings:AddSetting(setting, ply_class_k)
	local category = self.player_class_categories[ply_class_k] or self.game_category

	local key

	if ply_class_k then
		key = "player_classes."..ply_class_k.."."..setting.key
	else
		key = setting.key
	end

	self.inputs[key] = category:Add(InputBar.New(setting.label, setting.type))
end

function LobbySettings:InitSettings()
	local proto = self.lobby.prototype

	for _, ply_class in pairs(proto.player_classes) do
		self.player_class_categories[ply_class.key] = self:AddCategory(ply_class.name, ply_class.color)
	end
	
	for _, setting in pairs(proto.adjustable_settings) do
		if string.match(setting.key, "player_classes%.%*") then
			for ply_class_k, ply_class_category in pairs(self.player_class_categories) do
				for _, ply_class_setting in pairs(setting.settings) do
					self:AddSetting(ply_class_setting, ply_class_k)
				end
			end
		else
			self:AddSetting(setting)
		end
	end
end