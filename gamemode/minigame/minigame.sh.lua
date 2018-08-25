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


-- # Init

local MINIGAME_PROTOTYPES_DIRECTORY = "minigame_prototypes/"
local _, minigame_prototypes_dirs = file.Find(EMM_GAMEMODE_DIRECTORY..MINIGAME_PROTOTYPES_DIRECTORY.."*", "LUA")
local minigame_fenv_metatable = {__index = _G}

function MinigameService.LoadPrototypes()
	for _, proto in pairs(minigame_prototypes_dirs) do
		local proto_fenv = {}

		proto_fenv.MINIGAME = MinigamePrototype.New()
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
