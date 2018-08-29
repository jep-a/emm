MinigamePrototype = MinigamePrototype or Class.New()

function MinigamePrototype:__newindex(k, v)
	if not self.key and k == "name" then
		rawset(self, "key", v)
	end

	rawset(self, k, v)
end

function MinigamePrototype:Init()
	self.player_classes = {}
	self.states = {}
	self.hooks = {}
	self.state_hooks = {}
	self.event_hooks = {}
	self.display = true
	self.default_state = "Waiting"
	self.required_players = 2

	self:SetModifiableVars {
		["states.Playing.time"] = {
			prereq = {
				label = "unlimited round time",
				opposite = true,
				override = 0
			},
			label = "round time",
			type = "time",
			default = 500,
			min = 5
		},
		["player_classes.*"] = {
			mods = {
				can_walljump = {label = "can walljump"},
				can_wallslide = {label = "can wallslide"},
				can_airaccel = {label = "can air accelerate"}
			}
		}
	}

	self:AddDefaultStates()
	self:AddDefaultHooks()

	if SERVER then
		self:AddRequirePlayersHooks()
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

hook.Add("CreateMinigameHookSchemas", "Default", function ()
	MinigameNetService.CreateHookSchema "StateExpired"
	MinigameNetService.CreateHookSchema("RandomPlayerClassesPicked", {"entities"})
	MinigameNetService.CreateHookSchema("PlayerClassForfeit", {"entity", "entity"})
	MinigameNetService.CreateHookSchema("PlayerClassChangeFromDeath", {"entity"})
end)