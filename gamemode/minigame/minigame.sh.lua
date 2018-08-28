MinigameService = MinigameService or {}
MinigameService.prototypes = MinigameService.prototypes or {}
MinigameService.lobbies = MinigameService.lobbies or {}

function MinigameService.Prototype(id)
	for _, proto in pairs(MinigameService.prototypes) do
		if id == proto.id then
			return proto
		end
	end
end

function MinigameService.RegisterPrototype(proto)
	if MinigameService.prototypes[proto.key] then
		proto.id = MinigameService.prototypes[proto.key].id
		table.Empty(MinigameService.prototypes[proto.key])
		table.Merge(MinigameService.prototypes[proto.key], proto)
	else
		proto.id = table.Count(MinigameService.prototypes) + 1
		MinigameService.prototypes[proto.key] = proto
	end
end

function MinigameService.CallHook(lobby, hk_name, ...)
	if lobby[hk_name] then
		lobby[hk_name](lobby, ...)
	end

	lobby.hooks[hk_name] = lobby.hooks[hk_name] or {}

	for _, hk in pairs(lobby.hooks[hk_name]) do
		hk(lobby, ...)
	end

	if lobby.state and lobby.state_hooks[lobby.state.key] and lobby.state_hooks[lobby.state.key][hk_name] then
		for _, hk in pairs(lobby.state_hooks[lobby.state.key][hk_name]) do
			hk(lobby, ...)
		end
	end
end


-- # Init

local MINIGAME_PROTOTYPES_DIRECTORY = "minigame_prototypes/"
local minigame_prototype_files, minigame_prototype_dirs = file.Find(EMM_GAMEMODE_DIRECTORY..MINIGAME_PROTOTYPES_DIRECTORY.."*", "LUA")
local minigame_fenv_metatable = {__index = _G}

function MinigameService.LoadPrototype(path)
	local proto_fenv = {}

	proto_fenv.MINIGAME = MinigamePrototype.New()
	setmetatable(proto_fenv, minigame_fenv_metatable)

	setfenv(0, proto_fenv)
	EMM.Include(path)
	setfenv(0, _G)

	MinigameService.RegisterPrototype(proto_fenv.MINIGAME)
end

function MinigameService.LoadPrototypes()
	for _, proto in pairs(minigame_prototype_files) do
		MinigameService.LoadPrototype(MINIGAME_PROTOTYPES_DIRECTORY..proto)
	end

	for _, proto in pairs(minigame_prototype_dirs) do
		MinigameService.LoadPrototype(MINIGAME_PROTOTYPES_DIRECTORY..proto.."/init")
	end

	hook.Run "LoadMinigamePrototypes"
end
hook.Add("Initialize", "MinigameService.LoadPrototypes", MinigameService.LoadPrototypes)
hook.Add("OnReloaded", "MinigameService.ReloadPrototypes", MinigameService.LoadPrototypes)

function MinigameService.ReloadLobbies()
	for _, lobby in pairs(MinigameService.lobbies) do
		lobby.prototype = MinigameService.prototypes[lobby.prototype.key]
	end
end
hook.Add("OnReloaded", "MinigameService.ReloadLobbies", MinigameService.ReloadLobbies)
