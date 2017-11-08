MINIGAME.name = "Hunted"
MINIGAME.color = COLOR_BLUE
MINIGAME.default_player_class = "Hunter"

MINIGAME:AddPlayerClass {
	name = "Hunted",
	color = COLOR_ORANGE,
	can_contact = {"Hunter"}
}

MINIGAME:AddPlayerClass {
	name = "Hunter"
}