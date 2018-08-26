MINIGAME.name = "Hunted"
MINIGAME.color = COLOR_BLUE

MINIGAME:SetModifiableVars {
	["states.Playing.time"] = {
		prereq = {
			label = "unlimited round time",
			opposite = true,
			override = 0
		},
		label = "round time",
		type = "time",
		default = 500,
		min = 5
	},
	["player_classes.*"] = {
		mods = {
			can_walljump = {label = "can walljump"},
			can_wallslide = {label = "can wallslide"},
			can_airaccel = {label = "can air accelerate"}
		}
	}
}

MINIGAME.default_player_class = "Hunter"

MINIGAME.random_player_classes = {
	class_key = "Hunted",
	rejected_class_key = "Hunter"
}

MINIGAME:AddPlayerClass {
	name = "Hunted",
	color = COLOR_ORANGE,
	can_tag = {"Hunter"},
	swap_on_tag = true,
	kill_on_tag = true,
	swap_closest_on_death = true
}

MINIGAME:AddPlayerClass {
	name = "Hunter"
}