MINIGAME.name = "Hunted"
MINIGAME.color = COLOR_SKY
MINIGAME.default_player_class = "Hunter"

MINIGAME.random_player_classes = {
	class_key = "Hunted",
	rejected_class_key = "Hunter"
}

MINIGAME:AddPlayerClass {
	name = "Hunted",
	color = COLOR_PEACH,
	can_tag = {"Hunter"},
	swap_on_tag = true,
	kill_on_tag = true,
	swap_closest_on_death = true
}

MINIGAME:AddPlayerClass {
	name = "Hunter"
}