SettingsService = SettingsService or {}

SettingsService.convar_properties = SettingsService.convar_properties or {}
SettingsService.hooks = SettingsService.hooks or {}

function SettingsService.New(name, props)
	if isbool(props.default) then
		default = props.default and 1 or 0
	else
		default = Default(props.default, 0)
	end
	
	if not SettingsService.convar_properties[name] then
		CreateClientConVar(name, default, true, false, props.help)
		cvars.AddChangeCallback(name, SettingsService.OnConvarChanged)
	end

	SettingsService.convar_properties[name] = props
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

function SettingsService.Setting(name)
	local v

	local convar_props = SettingsService.convar_properties[name]
	local convar = GetConVar(name)

	if convar_props.type == "string" then
		v = convar:GetString() or props.default or ""
	elseif convar_props.type == "number" then
		v = convar:GetFloat() or props.default or 0

		if convar_props.round then
			v = math.Round(v, isnumber(convar_props.round) and convar_props.round)
		end

		if convar_props.snap then
			v = Snap(v, convar_props.snap)
		end

		if convar_props.min then
			v = math.max(v, convar_props.min)
		end

		if convar_props.max then
			v = math.min(v, convar_props.max)
		end
	else
		v = Default(convar:GetBool(), convar_props.default, false)
	end

	return v
end

function SettingsService.OnConvarChanged(name)
	local v = SettingsService.Setting(name)

	local callback = SettingsService.convar_properties[name].callback

	if callback then
		callback(v)
	end

	if SettingsService.hooks[name] then
		for _, hk in pairs(SettingsService.hooks[name]) do
			hk(v)
		end
	end
end