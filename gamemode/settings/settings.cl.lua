SettingsService = SettingsService or {}

SettingsService.convars = SettingsService.convars or {}
SettingsService.ordered_convars = {}
SettingsService.values = {}
SettingsService.hooks = SettingsService.hooks or {}

local gamemode_prefix = engine.ActiveGamemode().."_"

function SettingsService.New(name, props)
	if isbool(props.default) then
		default = props.default and 1 or 0
	else
		default = Default(props.default, 0)
	end

	if not SettingsService.convars[name] then
		CreateClientConVar(gamemode_prefix..name, default, true, props.userinfo, props.help)
		cvars.AddChangeCallback(gamemode_prefix..name, SettingsService.OnConvarChanged)
	end

	SettingsService.convars[name] = props
	table.insert(SettingsService.ordered_convars, name)
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

function SettingsService.ValidateNumber(name, v)
	local convar_props = SettingsService.convars[name]

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

	return v
end

function SettingsService.GetValidated(name)
	local v
	local convar_props = SettingsService.convars[name]
	local convar = GetConVar(gamemode_prefix..name)

	if convar_props.type == "string" then
		v = convar:GetString() or props.default or ""
	elseif convar_props.type == "number" then
		v = SettingsService.ValidateNumber(name, convar:GetFloat() or props.default or 0)
	else
		v = Default(convar:GetBool(), convar_props.default, false)
	end

	return v
end

function SettingsService.Get(name)
	local v

	if SettingsService.values[name] == nil then
		v = SettingsService.GetValidated(name)
		SettingsService.values[name] = v
	else
		v = SettingsService.values[name]
	end

	return v
end

function SettingsService.Set(name, v)
	local convar_props = SettingsService.convars[name]
	local convar = GetConVar(gamemode_prefix..name)

	if convar_props.type == "string" then
		local str = v or ""

		convar:SetString(str)
	elseif convar_props.type == "number" then
		local n = tonumber(v)

		if n == "" or Nily(n) then
			n = 0
		end

		local validated = SettingsService.ValidateNumber(name, number_v)

		convar:SetFloat(validated)
	else
		convar:SetBool(v)
	end
end

function SettingsService.OnConvarChanged(name)
	local unprefixed_name = string.sub(name, #gamemode_prefix + 1)
	local v = SettingsService.GetValidated(unprefixed_name)
	local callback = SettingsService.convars[unprefixed_name].callback

	SettingsService.values[unprefixed_name] = v

	if callback then
		callback(v)
	end

	if SettingsService.hooks[unprefixed_name] then
		for _, hk in pairs(SettingsService.hooks[unprefixed_name]) do
			hk(v)
		end
	end
end