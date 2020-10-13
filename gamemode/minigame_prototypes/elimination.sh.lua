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
	color = COLOR_SKY,
	can_tag = {Hunted = true},
	minimum = 1,
	recruit_on_tag = true
}

MINIGAME:AddPlayerClass {
	name = "Hunted",
	end_on_none = true,
	player_class_on_death = "Hunter"
}

MINIGAME:AddAdjustableSetting {
	key = "player_classes.Hunter.can_tag.Hunted",
	label = "Hunted can be tagged"
}