MINIGAME.name = "Freezetag"
MINIGAME.color = COLOR_ICE
MINIGAME.default_player_class = "Hunter"
MINIGAME.required_players = 3

MINIGAME.states.Playing.time = 60 * 5

MINIGAME.random_player_classes = {
	class_key = "Hunter",
	rejected_class_key = "Hunted"
}

MINIGAME:AddPlayerClass {
	name = "Hunter",
	can_tag = {Hunted = true},
	minimum = 1,
	give_player_class_on_tag = "Frozen"
}

MINIGAME:AddPlayerClass {
	name = "Hunted",
	color = COLOR_PEACH,
	end_on_none = true
}

MINIGAME:AddPlayerClass {
	name = "Frozen",
	color = COLOR_WHITE,
	can_tag = {Hunted = true},
	player_class_on_tag = "Hunted"
}

if SERVER then
	function MINIGAME.player_classes.Frozen:StartPlayerClass()
		GhostService.Ghost(self, {
			kill = true,
			ragdoll = true,
			statue = true,
			savepoint = true
		})

		self.frozen_timer = Timer.New(30, function ()
			self:SetPlayerClass(MINIGAME.player_classes.Hunter)
		end)

		PlayerClassService.AddLifecycleObject(self, self.frozen_timer)
	end
end
