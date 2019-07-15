MinigameSettingsService = MinigameSettingsService or {}

local function EscapeSettingsKey(str)
	return string.Replace(string.Replace(str, ".", "%."), "*", ".*")
end

local function SanitizeSettings(tab)
	local new_tab = {}

	for k, v in pairs(tab) do
		if istable(v) and v.settings then
			table.insert(new_tab, {k, SanitizeSettings(v.settings)})
		else
			table.insert(new_tab, {k, v})
		end
	end

	return new_tab
end

local function MapSettings(tab)
	local new_tab = {}

	for _, v in pairs(tab) do
		if v.settings then
			new_tab[EscapeSettingsKey(v.key)] = MapSettings(v.settings)
		else
			new_tab[EscapeSettingsKey(v.key)] = true
		end
	end

	return new_tab
end

NetService.CreateSchema("LobbySettings", {"minigame_lobby", "table"})
NetService.CreateUpstreamSchema("LobbySettings", {"minigame_lobby", "table"})

function MinigameSettingsService.SortChange(original_tab, changes_tab, k, v)
	if istable(v) and istable(original_tab[k]) then
		for _k, _v in pairs(v) do
			if _v ~= original_tab[k][_k] and not (Falsy(_v) and Nily(original_tab[k][_k])) then
				changes_tab[k..".".._k] = true
			else
				changes_tab[k..".".._k] = nil
			end
		end
	elseif v ~= original_tab[k] and not (Falsy(v) and Nily(original_tab[k])) then
		changes_tab[k] = true
	elseif changes_tab[k] then
		changes_tab[k] = nil
	end
end

function MinigameSettingsService.SortChanges(original_tab, changes_tab, new_tab)
	for k, v in pairs(new_tab) do
		MinigameSettingsService.SortChange(original_tab, changes_tab, k, v)
	end
end

function MinigameSettingsService.AdjustedSettings(lobby)
	local settings = {}

	for k, _ in pairs(lobby.changed_settings) do
		settings[k] = MinigameSettingsService.Get(lobby, k)
	end

	return settings
end

function MinigameSettingsService.Get(lobby, k, use_nil)
	local v

	local tab = lobby
	local exploded_k = string.Explode(".", k)

	for i, lobby_k in pairs(exploded_k) do
		local last = i == #exploded_k

		if tab[lobby_k] ~= nil then
			if last then
				v = tab[lobby_k]
			else
				tab = tab[lobby_k]
			end
		elseif not use_nil and last then
			v = "nil"
		else
			break
		end
	end

	return v
end

function MinigameSettingsService.Adjust(lobby, settings)
	for k, setting in pairs(settings) do
		local adjustable
		local adjusted

		for _k, _setting in pairs(lobby.prototype.adjustable_settings_map) do
			if string.find(k, _k) then
				if istable(_setting) then
					for __k, _ in pairs(_setting) do
						if string.find(k, _k.."%."..__k) then
							adjustable = true

							break
						end
					end
				else
					adjustable = true

					break
				end
			end
		end

		if adjustable then
			local tab = lobby
			local exploded_k = string.Explode(".", k)

			for i, lobby_k in pairs(exploded_k) do
				if #exploded_k == i then
					if setting == "nil" then
						tab[lobby_k] = nil
						adjusted = true
					elseif istable(setting) then
						for _k, v in pairs(setting) do
							tab[lobby_k][_k] = v
							adjusted = true
						end
					else
						tab[lobby_k] = setting
						adjusted = true
					end
				else
					tab = tab[lobby_k]
					adjusted = true
				end
			end

			if adjusted then
				hook.Run("LobbySettingChange", lobby, k, setting)
				MinigameService.CallHook(lobby, "SettingChange", k, setting)
			end
		end
	end
end

function MinigamePrototype:MapSettings()
	self.adjustable_settings_map = MapSettings(self.adjustable_settings)
end

function MinigamePrototype:SetAdjustableSettings(settings)
	self.adjustable_settings = settings
	self:MapSettings()
end

function MinigamePrototype:AddAdjustableSetting(setting)
	table.insert(self.adjustable_settings, setting)
	self:MapSettings()
end

function MinigamePrototype:AddAdjustableSettings(settings)
	table.Add(self.adjustable_settings, settings)
	self:MapSettings()
end

function MinigamePrototype:RemoveAdjustableSetting(k)
	for i, setting in pairs(self.adjustable_settings) do
		if k == setting.key then
			table.remove(self.adjustable_settings, i)

			break
		end
	end

	self.adjustable_settings_map[EscapeSettingsKey(k)] = nil
end

function MinigamePrototype:RemoveAdjustableSettings(settings)
	local removing = {}

	for _, k in pairs(settings) do
		for i, setting in pairs(self.adjustable_settings) do
			if k == setting.key then
				table.insert(removing, i)

				break
			end
		end

		self.adjustable_settings_map[EscapeSettingsKey(k)] = nil
	end

	for _, i in pairs(removing) do
		table.remove(self.adjustable_settings, i)
	end
end

function MinigameLobby:SaveOriginalSetting(k)
	local setting_v = MinigameSettingsService.Get(self, k)

	if istable(setting_v) then
		for _k, v in pairs(setting_v) do
			self.original_settings[k..".".._k] = v
		end
	else
		self.original_settings[k] = setting_v
	end
end

function MinigameLobby:InitSettings()
	self.original_settings = {}
	self.changed_settings = {}

	for _, setting in pairs(self.prototype.adjustable_settings) do
		if string.match(setting.key, "player_classes%.%*") then
			for ply_class_k, ply_class in pairs(self.prototype.player_classes) do
				for _, ply_class_setting in pairs(setting.settings) do
					self:SaveOriginalSetting("player_classes."..ply_class_k.."."..ply_class_setting.key)
				end
			end
		else
			self:SaveOriginalSetting(setting.key)
		end
	end
end
