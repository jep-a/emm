SettingsService = SettingsService or {}

SettingsService.convar_properties = {}
SettingsService.hooks = SettingsService.hooks or {}

function SettingsService.New(name, props)
	local default

	if isbool(props.default) then
		default = props.default and 1 or 0
	else
		default = props.default
	end

	SettingsService.convar_properties[name] = props
	CreateClientConVar(name, default, true, false, props.help)
	cvars.AddChangeCallback(name, SettingsService.OnConvarChanged)
end

function SettingsService.AddHook(name, id, callback)
	SettingsService.hooks[name] = SettingsService.hooks[name] or {}
	SettingsService.hooks[name][id] = callback
end

function SettingsService.RemoveHook(name, id)
	if SettingsService.hooks[name] then
		SettingsService.hooks[name][id] = nil
	end
end

function SettingsService.Setting(name, v)
	local v

	local convar_prop = SettingsService.convar_properties[name]
	local convar = GetConVar(name)

	if convar_prop.type == "string" then
		v = convar:GetString() or props.default or ""
	elseif convar_prop.type == "number" then
		local number = convar:GetFloat() or props.default or 0

		if convar_prop.round then
			v = math.Round(number, isnumber(convar_prop.round) and convar_prop.round)
		end

		if convar_prop.snap then
			v = Snap(v, convar_prop.snap)
		end

		if convar_prop.min then
			v = math.max(v, convar_prop.min)
		end

		if convar_prop.max then
			v = math.min(v, convar_prop.max)
		end
	else
		v = convar:GetBool() or props.default or false
	end

	return v
end

function SettingsService.OnConvarChanged(name)
	if SettingsService.hooks[name] then
		local v = SettingsService.Setting(name)

		for _, hk in pairs(SettingsService.hooks[name]) do
			hk(v)
		end
	end
end