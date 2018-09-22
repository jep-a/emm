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
	self.settings = {}
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

	local k

	if ply_class_k then
		k = "player_classes."..ply_class_k.."."..setting.key
	else
		k = setting.key
	end

	self.settings[k] = setting

	local prereq = setting.prerequisite

	if prereq then
		self.inputs[k..".prerequisite"] = category:Add(InputBar.New(prereq.label, prereq.type, nil, {
			on_change = function (input, v)
				self:OnPrerequisiteValueChanged(k, v)
			end
		}))
	end

	self.inputs[k] = category:Add(InputBar.New(setting.label, setting.type, nil, {
		on_change = function (input, v)
			self:OnSettingValueChanged(k, v)
		end
	}))
end

function LobbySettings:OnPrerequisiteValueChanged(k, v)
	local setting = self.settings[k]

	if v ~= (setting.prerequisite and not setting.prerequisite.opposite) then
		self.inputs[k]:RevertState()
	else
		self.inputs[k]:AnimateState "hidden"
	end
end

function LobbySettings:OnSettingValueChanged(k, v)
	print(k, v)
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