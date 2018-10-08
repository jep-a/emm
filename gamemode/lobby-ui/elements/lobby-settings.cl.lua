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

	if table.Count(lobby.prototype.player_classes) > 1 then
		self.player_class_category = self:AddCategory "Player classes"
	else
		self.player_class_category = self:AddCategory "Player"
	end

	self.player_class_categories = {}

	self.original_values = {}
	self.changed_values = {}
	self.values = {}
	self.settings = {}
	self.inputs = {}

	self:InitSettings()
	self:CreateSaver()
end

function LobbySettings:CreateSaver()
	self.saver = self:Add(ButtonBar.New {
		background_color = self.lobby.prototype.color,
		color = COLOR_WHITE,
		material = PNGMaterial("emm2/ui/save.png"),
		text = "Save",

		on_click = function ()
			self:Save()
		end
	})

	self.saver:SetAttribute("crop_bottom", 1)
end

function LobbySettings:ShowSaver()
	self.saver:AnimateAttribute("crop_bottom", 0, ANIMATION_DURATION * 2)
	self.saver:AnimateAttribute("alpha", 255, ANIMATION_DURATION * 2)
end

function LobbySettings:HideSaver()
	self.saver:AnimateAttribute("crop_bottom", 1, ANIMATION_DURATION * 2)
	self.saver:AnimateAttribute("alpha", 0, ANIMATION_DURATION * 2)
end

function LobbySettings:AddCategory(label, color)
	return self.body:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width = COLUMN_WIDTH * 2,
		padding_bottom = MARGIN * 2,
		inherit_color = false,
		color = color,
		background_color = COLOR_GRAY,
		label = LobbyUIService.CreateLabels {label}
	})
end

function LobbySettings:AddPlayerClassSetting(setting)
	local setting_row = self.player_class_category:Add(InputBar.New(setting.label))

	for ply_class_k, ply_class in pairs(self.lobby.prototype.player_classes) do
		self:AddSetting(setting, ply_class_k, setting_row)
	end
end

function LobbySettings:AddPrerequisiteSetting(k, prereq, setting_v, category)
	local prereq_v

	if prereq.default then
		prereq_v = prereq.default
	else
		if Nily(setting_v) and Falsy(prereq.override_value) then
			prereq_v = prereq.opposite_value
		else
			prereq_v = prereq.opposite_value == (setting_v == prereq.override_value)
		end
	end

	self.inputs[k..".prerequisite"] = category:Add(InputBar.New(prereq.label, prereq.type, prereq_v, {
		on_change = function (input, v)
			self:OnPrerequisiteValueChanged(k, v)
		end
	}))

	return prereq_v
end

function LobbySettings:AddSetting(setting, ply_class_k, setting_row)
	local k

	if ply_class_k then
		k = "player_classes."..ply_class_k.."."..setting.key
	else
		k = setting.key
	end

	self.settings[k] = setting

	local category = self.player_class_categories[ply_class_k] or self.game_category
	local safe_v = MinigameSettingsService.Get(self.lobby, k)
	local actual_v = MinigameSettingsService.Get(self.lobby, k, true)
	local prereq_v
	
	if istable(safe_v) then
		for _k, _v in pairs(safe_v) do
			self.original_values[k..".".._k] = _v
		end
	else
		self.original_values[k] = safe_v
	end

	local prereq = setting.prerequisite

	if prereq then
		prereq_v = self:AddPrerequisiteSetting(k, prereq, actual_v, category)
	end

	local input_props = {options = setting.options}
	local list = setting.type == "list"

	if list then
		input_props.on_change = function (input, list_k, safe_v)
			self:OnSettingValueChanged(k.."."..list_k, safe_v)
		end
	else
		input_props.on_change = function (input, safe_v)
			self:OnSettingValueChanged(k, safe_v)
		end
	end

	if setting_row then
		self.inputs[k] = setting_row:Add(Element.New {
			layout_justification_x = JUSTIFY_END,
			height_percent = 1,
			width = 100,
			padding_left = 4,
			hidden = {alpha = 0},
			input = InputBar.Type(setting.type).New(actual_v, input_props)
		})
	else
		self.inputs[k] = category:Add(InputBar.New(setting.label, setting.type, actual_v, input_props))
	end

	if prereq and prereq_v == prereq.opposite_value then
		self.inputs[k]:SetState "hidden"
	end
end

function LobbySettings:RefreshOriginalValues(settings)
	table.Merge(self.original_values, settings)
	MinigameSettingsService.SortChanges(self.original_values, self.changed_values, settings)
	self:RefreshSaver()
end

function LobbySettings:OnPrerequisiteValueChanged(k, v)
	local setting = self.settings[k]

	if v ~= setting.prerequisite.opposite_value then
		self.inputs[k]:RevertState()
	else
		local override = setting.prerequisite.override_value

		if override then
			self.inputs[k]:SetValue(override)
			self.values[k] = override
		end

		self.inputs[k]:AnimateState "hidden"
	end
end

function LobbySettings:RefreshSaver()
	if table.Count(self.changed_values) > 0 then
		self:ShowSaver()
	else
		self:HideSaver()
	end
end

function LobbySettings:OnSettingValueChanged(k, v)
	self.values[k] = v

	MinigameSettingsService.SortChange(self.original_values, self.changed_values, k, v)

	self:RefreshSaver()
end

function LobbySettings:InitSettings()
	local proto = self.lobby.prototype

	if table.Count(proto.player_classes) > 1 then
		for ply_class_k, ply_class in pairs(proto.player_classes) do
			self.player_class_category.label:Add(LobbyUIService.CreateLabel {
				text = ply_class.name,
				justification = JUSTIFY_END,
				width = 100,
				color = ply_class.color
			})
		end
	end
	
	for _, setting in pairs(proto.adjustable_settings) do
		if string.match(setting.key, "player_classes%.%*") then
			for _, ply_class_setting in pairs(setting.settings) do
				self:AddPlayerClassSetting(ply_class_setting)
			end
		else
			self:AddSetting(setting)
		end
	end
end

function LobbySettings:Save()
	local changed_v = {}

	for k, _ in pairs(self.changed_values) do
		local v = self.values[k]

		if Falsy(v) and Nily(self.lobby.original_settings[k]) then
			changed_v[k] = "nil"
		else
			changed_v[k] = v
		end
	end

	NetService.Send("LobbySettings", self.lobby, changed_v)
end