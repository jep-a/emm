local function EscapeModKey(str)
	return string.Replace(string.Replace(str, ".", "%."), "*", ".*")
end

local function SanitizeMods(tab)
	local new_tab = {}

	for k, v in pairs(tab) do
		if istable(v) and v.mods then
			table.insert(new_tab, {k, SanitizeMods(v.mods)})
		else
			table.insert(new_tab, {k, v})
		end
	end

	return new_tab
end

local function MapMods(tab)
	local new_tab = {}

	for k, v in pairs(tab) do
		if v.mods then
			new_tab[EscapeModKey(k)] = MapMods(v.mods)
		else
			new_tab[EscapeModKey(k)] = true
		end
	end

	return new_tab
end

function MinigamePrototype:SetModifiableVars(vars)
	self.modifiable_vars = SanitizeMods(vars)
	self.modifiable_vars_map = MapMods(vars)
end