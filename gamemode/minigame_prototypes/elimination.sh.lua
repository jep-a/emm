MINIGAME.name = "Elimination"
MINIGAME.color = COLOR_PEACH
MINIGAME.default_player_class = "Hunter"
MINIGAME.required_players = 3

MINIGAME.states.Playing.time = 60 * 5

MINIGAME.random_player_classes = {
	class_key = "Hunter",
	rejected_class_key = "Hunted"
}

MINIGAME:AddPlayerClass {
	name = "Hunter",
	can_tag = {"Hunted"},
	minimum = 1,
	recruit_on_tag = true
}

MINIGAME:AddPlayerClass {
	name = "Hunted",
	color = COLOR_SKY,
	end_on_none = true,
	player_class_on_death = "Hunter"
}