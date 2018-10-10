MINIGAME.name = "Miscellaneous"
MINIGAME.color = COLOR_ROYAL
MINIGAME.default_state = "Playing"
MINIGAME.default_player_class = "Miscellaneous"
MINIGAME.required_players = 0

MINIGAME:AddPlayerClass {
	name = "Miscellaneous",
	display_name = false
}

MINIGAME:RemoveAdjustableSetting "states.Playing.time"