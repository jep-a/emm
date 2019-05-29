MinigameService = MinigameService or {}
MinigameService.prototypes = MinigameService.prototypes or {}
MinigameService.lobbies = MinigameService.lobbies or {}

MINIGAME_WEAPONS = {
	"weapon_crowbar",
	"weapon_physcannon",
	"weapon_pistol",
	"weapon_357",
	"weapon_shotgun",
	"weapon_ar2",
	"weapon_crossbow",
	"weapon_rpg",
	"weapon_frag",
	-- "sfw_jotunn",
	-- "sfw_thunderbolt",
	-- "sfw_cryon",
	-- "sfw_blizzard",
	-- "sfw_trace",
	-- "sfw_hellfire",
	-- "sfw_neutrino",
	-- "sfw_aquamarine",
	-- "sfw_draco",
	-- "sfw_pandemic",
	-- "sfw_saphyre",
	-- "sfw_hwave",
	-- "sfw_pyre",
	-- "sfw_seraphim",
	-- "sfw_ember",
	-- "sfw_phoenix",
	-- "sfw_alchemy",
	-- "sfw_vectra",
	-- "sfw_supra",
	-- "sfw_prisma",
	-- "sfw_astra",
	-- "sfw_zeala",
	-- "sfw_storm",
	-- "sfw_fallingstar",
	-- "sfw_vapor",
	-- "sfw_lapis",
	-- "sfw_pulsar",
	-- "sfw_stinger",
	-- "sfw_hornet"
}

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

	MinigameService.CallHookWithoutMethod(lobby, hk_name, ...)
end

function MinigameService.CallHookWithoutMethod(lobby, hk_name, ...)
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

function MinigameService.SoundIsolation(snd)
	local ent = snd.Entity

	if IsValid(ent:GetOwner()) then
		ent = ent:GetOwner()
	end
	
	if CLIENT and snd.OriginalSoundName == "BaseExplosionEffect.Sound" then
		if LocalPlayer().lobby then
			return true
		end

		return false
	end

	if SERVER and IsPlayer(ent) and snd.DSP ~= 200 then
		if IsValid(ent:GetActiveWeapon()) then
			if table.HasValue(MINIGAME_WEAPONS, ent:GetActiveWeapon():GetKeyValues().classname) then
				if ent.lobby then
					local filter = RecipientFilter()

					for _, ply in pairs(ent.lobby.players) do
						if ply != ent then
							filter:AddPlayer(ply)
						end
					end
					
					local sound = CreateSound( ent, snd.SoundName, filter )
					
					sound:ChangeVolume(snd.Volume)
					sound:ChangePitch(snd.Pitch)
					sound:SetSoundLevel(snd.SoundLevel)
					sound:SetDSP(200)
					sound:Play()
				end

				return false
			end
		end
	end
end
hook.Add( "EntityEmitSound", "MinigameService.SoundIsolation", MinigameService.SoundIsolation)


-- # Init

local MINIGAME_PROTOTYPES_DIRECTORY = "minigame_prototypes/"
local minigame_prototype_files, minigame_prototype_dirs = file.Find(gamemode_lua_directory..MINIGAME_PROTOTYPES_DIRECTORY.."*", "LUA")
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
