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

	self:SetAdjustableSettings {
		{
			key = "states.Playing.time",

			prerequisite = {
				label = "Unlimited round time",
				opposite_value = true,
				override_value = 0
			},

			label = "Round time",
			type = "time"
		},

		{
			key = "player_classes.*",

			settings = {
				{
					key = "air_accelerate",
					label = "Air acceleration",
					type = "number"
				},

				{
					key = "friction",
					label = "Friction",
					type = "number"
				},

				{
					key = "gravity",
					label = "Gravity",
					type = "number"
				},

				{
					key = "can_walljump",
					label = "Can walljump"
				},

				{
					key = "can_wallslide",
					label = "Can wallslide"
				},

				{
					key = "can_airaccel",
					label = "Can air-accelerate"
				},

				{
					key = "can_autojump",
					label = "Can auto-jump"
				},

				{
					key = "can_regenerate_health",
					label = "Can regenerate health"
				},

				{
					key = "can_take_fall_damage",
					label = "Can take fall damage"
				},

				{
					key = "has_infinite_wallslide",
					label = "Has infinite wallslide stamina"
				},

				{
					key = "has_infinite_airaccel",
					label = "Has infinite air-accelerate stamina"
				},

				{
					key = "weapons",
					label = "Weapons",
					type = "list",
					options = MINIGAME_WEAPONS
				}
			}
		}
	}

	self:AddDefaultStates()
	self:AddDefaultHooks()

	if SERVER then
		self:AddRequirePlayersHooks()
	end
end

function MinigamePrototype:AddPlayerClass(props, dynamic_props)
	ply_class = PlayerClassService.CreatePlayerClass(props, dynamic_props)
	ply_class.id = table.Count(self.player_classes) + 1
	ply_class.color = props.color or self.color
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
	MinigameNetService.CreateHookSchema("DeadPlayerClassForfeitToClosest", {"entity", "entity"})
	MinigameNetService.CreateHookSchema("DepartedPlayerClassForfeitToClosest", {"entity", "entity"})
	MinigameNetService.CreateHookSchema("PlayerClassForfeitToAttacker", {"entity", "entity"})
	MinigameNetService.CreateHookSchema("PlayerClassChangeFromDeath", {"entity"})
end)
