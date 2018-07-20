MinigameService = MinigameService or {}
MinigameService.prototypes = MinigameService.prototypes or {}
MinigameService.lobbies = MinigameService.lobbies or {}


-- # Prototypes/lobbies

MinigamePrototype = MinigamePrototype or {}
MinigamePrototype.__index = MinigamePrototype

function MinigameService.Prototype(id)
	for _, proto in pairs(MinigameService.prototypes) do
		if id == proto.id then
			return proto
		end
	end
end

function MinigameService.CreatePrototype()
	local bare_base = {
		player_classes = {},
		states = {},
		hooks = {},
		state_hooks = {}
	}

	local base = table.Copy(MinigameService.prototypes.Base or {})
	base.id = nil
	base.name = nil
	base.key = nil
	base.display = true

	proto = setmetatable(table.Merge(bare_base, base), MinigamePrototype)

	return proto
end

function MinigameService.RegisterPrototype(proto)
	proto.key = proto.key or proto.name
	
	if MinigameService.prototypes[proto.key] then
		proto.id = MinigameService.prototypes[proto.key].id
		table.Empty(MinigameService.prototypes[proto.key])
		table.Merge(MinigameService.prototypes[proto.key], proto)
	else
		proto.id = table.Count(MinigameService.prototypes) + 1
		MinigameService.prototypes[proto.key] = proto
	end
end

function MinigamePrototype:AddPlayerClass(ply_class)
	ply_class.id = table.Count(self.player_classes) + 1
	ply_class.key = ply_class.key or ply_class.name
	ply_class.color = ply_class.color or self.color
	self.player_classes[ply_class.key] = ply_class
end

function MinigamePrototype:AddHook(hk_name, hk_id, func)
	self.hooks[hk_name] = self.hooks[hk_name] or {}
	self.hooks[hk_name][hk_id] = func
end

function MinigamePrototype:RemoveHook(hk_name, hk_id)
	self.hooks[hk_name][hk_id] = nil
end

function MinigamePrototype:AddStateHook(state_key, hk_name, hk_id, func)
	self.state_hooks[state_key] = self.state_hooks[state_key] or {}
	self.state_hooks[state_key][hk_name] = self.state_hooks[state_key][hk_name] or {}
	self.state_hooks[state_key][hk_name][hk_id] = func
end

function MinigamePrototype:RemoveStateHook(state_key, hk_name, hk_id)
	self.state_hooks[state_key][hk_name][hk_id] = nil
end

function MinigameService.CallHook(lobby, hk_name, ...)
	if lobby[hk_name] then
		lobby[hk_name](lobby, ...)
	end

	lobby.hooks[hk_name] = lobby.hooks[hk_name] or {}

	local hks = table.Copy(lobby.hooks[hk_name])

	if lobby.state and lobby.state_hooks[lobby.state.key] and lobby.state_hooks[lobby.state.key][hk_name] then
		for _, hk in pairs(lobby.state_hooks[lobby.state.key][hk_name]) do
			table.insert(hks, hk)
		end
	end

	for _, hk in pairs(hks) do
		hk(lobby, ...)
	end
end

MinigameLobby = MinigameLobby or {}

function MinigameLobby:__index(key)
	local proto_mt_val = rawget(rawget(self, "prototype"), key)

	if proto_mt_val ~= nil then
		return proto_mt_val
	end

	local lobby_mt_val = rawget(MinigameLobby, key)
	if lobby_mt_val ~= nil then
		return lobby_mt_val
	end
end


-- # Init

local MINIGAME_PROTOTYPES_DIRECTORY = "minigame_prototypes/"
local _, minigame_prototypes_dirs = file.Find(EMM_GAMEMODE_DIRECTORY..MINIGAME_PROTOTYPES_DIRECTORY.."*", "LUA")
local minigame_fenv_metatable = {}

minigame_fenv_metatable.__index = _G

function MinigameService.LoadPrototypes()
	for _, proto in pairs(minigame_prototypes_dirs) do
		local proto_fenv = {}

		proto_fenv.MINIGAME = MinigameService.CreatePrototype()
		setmetatable(proto_fenv, minigame_fenv_metatable)

		setfenv(0, proto_fenv)
		EMM.Include(MINIGAME_PROTOTYPES_DIRECTORY..proto.."/init")
		setfenv(0, _G)

		MinigameService.RegisterPrototype(proto_fenv.MINIGAME)
	end
end
hook.Add("Initialize", "MinigameService.LoadPrototypes", MinigameService.LoadPrototypes)
hook.Add("OnReloaded", "MinigameService.ReloadPrototypes", MinigameService.LoadPrototypes)

function MinigameService.ReloadLobbies()
	for _, lobby in pairs(MinigameService.lobbies) do
		lobby.prototype = MinigameService.prototypes[lobby.prototype.key]
	end
end
hook.Add("OnReloaded", "MinigameService.ReloadLobbies", MinigameService.ReloadLobbies)
