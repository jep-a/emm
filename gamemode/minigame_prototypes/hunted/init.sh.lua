MINIGAME.name = "Hunted"
MINIGAME.color = COLOR_BLUE
MINIGAME.required_players = 2

MINIGAME:AddPlayerClass {
	name = "Hunted",
	color = COLOR_ORANGE,
	can_tag = {"Hunter"}
}

MINIGAME:AddPlayerClass {
	name = "Hunter"
}