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
	can_tag = {Hunter = true},
	tag_victim = true,
	swap_on_tag = true,
	kill_on_tag = true,
	swap_closest_on_death = true,
	swap_closest_on_leave = true,
	swap_with_attacker = true
}

MINIGAME:AddPlayerClass {
	name = "Hunter"
}

MINIGAME:AddAdjustableSetting {
	key = "player_classes.Hunted.can_tag.Hunter",
	label = "Hunted can be tagged"
}