LobbySettings = LobbySettings or Class.New(Element)

function LobbySettings:Init(lobby)
	LobbySettings.super.Init(self, {
		layout_direction = DIRECTION_COLUMN,
		fit = true,
		child_margin = MARGIN * 4,
		inherit_color = false,
		LobbyUIService.CreateHeader "Lobby settings",
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
		self.player_class_category = self:AddCategory "Players"
	end

	self.disabled = not IsLocalPlayer(lobby.host)

	self.original_values = {}
	self.changed_values = {}
	self.values = {}

	self.game_settings = {}
	self.settings = {}

	self.inputs = {}
	self.input_containers = {}
	self.list_inputs = {}

	self:InitSettings()
	self:CreateSaver()

	if table.Count(self.game_settings) == 0 then
		self.game_category:Finish()
	end
end

function LobbySettings:Finish()
	self.original_values = {}
	self.changed_values = {}
	self.values = {}

	self.settings = {}

	self.inputs = {}
	self.input_containers = {}
	self.list_inputs = {}

	LobbySettings.super.Finish(self)
end

function LobbySettings:Disable()
	self.disabled = true

	for _, input_container in pairs(self.input_containers) do
		input_container.input:Disable()
	end
end

function LobbySettings:Enable()
	self.disabled = false

	for _, input_container in pairs(self.input_containers) do
		input_container.input:Enable()
	end
end

function LobbySettings:CreateSaver()
	self.saver = self:Add(ButtonBar.New {
		background_color = self.lobby.prototype.color,
		color = COLOR_WHITE,
		material = PNGMaterial "emm2/ui/save.png",
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

function LobbySettings:AddCategory(label)
	return self.body:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width = COLUMN_WIDTH * (LobbyUIService.HellaSmallScreen() and 1.5 or 2),
		padding_bottom = 8,
		background_color = COLOR_GRAY,
		label = LobbyUIService.CreateLabels {label}
	})
end

function LobbySettings:AddPlayerClassSetting(setting)
	local setting_row = self.player_class_category:Add(InputBar.New(setting.label))

	for ply_class_k, ply_class in pairs(self.lobby.prototype.player_classes) do
		if ply_class.adjustable then
			self:AddSetting(setting, ply_class_k, setting_row)
		end
	end
end

function LobbySettings:GetPrerequisiteValue(k, setting_v)
	setting_v = setting_v or MinigameSettingsService.Get(self.lobby, k, true)

	local prereq_v

	local prereq = self.settings[k].prerequisite

	if prereq.default then
		prereq_v = prereq.default
	else
		if Nily(setting_v) and Falsy(prereq.override_value) then
			prereq_v = prereq.opposite_value
		else
			prereq_v = prereq.opposite_value == (setting_v == prereq.override_value)
		end
	end

	return prereq_v
end

function LobbySettings:AddPrerequisiteSetting(k, prereq, setting_v, category)
	local prereq_v = self:GetPrerequisiteValue(k, setting_v)
	local input_k = k..".prerequisite"

	self.input_containers[input_k] = category:Add(InputBar.New(prereq.label, prereq.type, prereq_v, {
		read_only = self.disabled,

		on_change = function (input, v)
			self:OnPrerequisiteValueChanged(k, v)
		end
	}))

	self.inputs[input_k] = self.input_containers[input_k].input

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

	local category = self.game_category
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

	local input_props = {
		read_only = self.disabled,
		options = setting.options
	}

	local list = setting.type == "list"

	if list then
		input_props.on_change = function (input, list_k, v)
			self:OnSettingValueChanged(k.."."..list_k, v)
		end
	else
		input_props.on_change = function (input, v)
			self:OnSettingValueChanged(k, v)
		end
	end

	if setting_row then
		self.inputs[k] = InputBar.Type(setting.type).New(actual_v, input_props)

		self.input_containers[k] = setting_row:Add(Element.New {
			layout_justification_x = JUSTIFY_END,
			height_percent = 1,
			width = 100,
			padding_left = 4,
			hidden = {alpha = 0},
			input = self.inputs[k]
		})
	else
		self.game_settings[k] = setting
		self.input_containers[k] = category:Add(InputBar.New(setting.label, setting.type, actual_v, input_props))
		self.inputs[k] = self.input_containers[k].input
	end

	if list then
		for _, option in pairs(setting.options) do
			self.list_inputs[k.."."..option] = self.inputs[k]
		end
	end

	if prereq and prereq_v == prereq.opposite_value then
		self.input_containers[k]:SetState "hidden"
	end
end

function LobbySettings:Refresh(settings)
	for k, v in pairs(settings) do
		local prereq_k = k..".prerequisite"

		if self.inputs[prereq_k] then
			self.inputs[prereq_k]:SetValue(self:GetPrerequisiteValue(k, v))
		end

		local list_k = string.match(k, "%.([^.]*)$")

		if self.inputs[k] then
			self.inputs[k]:SetValue(v, true)
		elseif self.list_inputs[k] then
			self.list_inputs[k]:SetValue(list_k, v, true)
		end
	end

	table.Merge(self.original_values, settings)
	MinigameSettingsService.SortChanges(self.original_values, self.changed_values, settings)

	self:RefreshSaver()
end

function LobbySettings:OnPrerequisiteValueChanged(k, v)
	local setting = self.settings[k]

	if v ~= setting.prerequisite.opposite_value then
		self.input_containers[k]:RevertState()
	else
		local override = setting.prerequisite.override_value

		if override then
			self.input_containers[k]:SetValue(override)
			self.values[k] = override
		end

		self.input_containers[k]:AnimateState "hidden"
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
			if ply_class.adjustable then
				self.player_class_category.label:Add(LobbyUIService.CreateLabel {
					text = ply_class.name,
					justification = JUSTIFY_END,
					width = 100,
					color = ply_class.color
				})
			end
		end
	end

	for i, setting in pairs(proto.adjustable_settings) do
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

	NetService.SendToServer("LobbySettings", self.lobby, changed_v)
end