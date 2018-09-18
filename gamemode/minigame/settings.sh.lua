local function EscapeSettingsKey(str)
	return string.Replace(string.Replace(str, ".", "%."), "*", ".*")
end

local function SanitizeSettings(tab)
	local new_tab = {}
t5
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

	for k, v in pairs(tab) do
		if v.settings then
			new_tab[EscapeSettingsKey(k)] = MapSettings(v.settings)
		else
			new_tab[EscapeSettingsKey(k)] = true
		end
	end

	return new_tab
end

function MinigamePrototype:SetAdjustableSettings(vars)
	self.adjustable_settings = SanitizeSettings(vars)
	self.adjustable_settings_map = MapSettings(vars)
end