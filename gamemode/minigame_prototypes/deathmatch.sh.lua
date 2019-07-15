MINIGAME.name = "Deathmatch"
MINIGAME.color = COLOR_RED
MINIGAME.default_state = "Playing"
MINIGAME.default_player_class = "Fragger"
MINIGAME.required_players = 0

MINIGAME:AddPlayerClass {
	name = "Fragger",
	display_name = false,

	weapons = {
		weapon_crowbar = true,
		weapon_357 = true,
		weapon_crossbow = true
	}
}