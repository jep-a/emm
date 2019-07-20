MINIGAME.name = "Cloud"
MINIGAME.color = COLOR_ROYAL
MINIGAME.default_player_class = "Jumper"

MINIGAME.random_player_classes = {
	class_key = "Cloud",
	rejected_class_key = "Jumper"
}

MINIGAME:AddPlayerClass {
	name = "Cloud",
	color = COLOR_CLOUD,
	can_tag = {Jumper = true},
	tag_victim = true,
	swap_on_tag = true,
	swap_closest_on_death = true,
	swap_with_attacker = true
}

MINIGAME:AddPlayerClass {
	name = "Jumper"
}

function MINIGAME.player_classes.Cloud:KeyPressed(key)
	print(key)
end