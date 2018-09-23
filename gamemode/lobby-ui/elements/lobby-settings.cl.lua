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

	self.original_values = {}
	self.changed_values = {}

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
	self.original_values[k] = MinigameSettingsService.Setting(self.lobby, k)

	local prereq = setting.prerequisite
	local curr_v = MinigameSettingsService.Setting(self.lobby, k, true)
	print(self.lobby.id, k, curr_v)

	local prereq_v

	if prereq then
		if prereq.default then
			prereq_v = prereq.default
		else
			if Nily(curr_v) and Falsy(prereq.override_value) then
				prereq_v = prereq.opposite_value
			else
				prereq_v = prereq.opposite_value == (curr_v == prereq.override_value)
			end
		end

		self.inputs[k..".prerequisite"] = category:Add(InputBar.New(prereq.label, prereq.type, prereq_v, {
			on_change = function (input, v)
				self:OnPrerequisiteValueChanged(k, v)
			end
		}))
	end

	self.inputs[k] = category:Add(InputBar.New(setting.label, setting.type, curr_v, {
		on_change = function (input, v)
			self:OnSettingValueChanged(k, v)
		end
	}))

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
	MinigameSettingsService.SortChange(self.original_values, self.changed_values, k, v)
	self:RefreshSaver()
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

function LobbySettings:Save()
	local changed_v = {}

	for k, _ in pairs(self.changed_values) do
		local v = self.inputs[k]:GetValue()

		if Falsy(v) and Nily(self.lobby.original_settings[k]) then
			changed_v[k] = "nil"
		else
			changed_v[k] = v
		end
	end

	NetService.Send("LobbySettings", self.lobby, changed_v)
end