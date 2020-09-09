MINIGAME.name = "Freezetag"
MINIGAME.color = COLOR_RASPBERRY
MINIGAME.default_player_class = "Runner"
MINIGAME.required_players = 2

MINIGAME.states.Playing.time = 60 * 5

FREEZE_TIME = 30

MINIGAME.random_player_classes = {
	class_key = "Tagger",
	rejected_class_key = "Runner"
}

MINIGAME:AddPlayerClass {
	name = "Frozen",
	color = COLOR_WHITE,
	can_move = false
}

MINIGAME:AddPlayerClass {
	name = "Runner",
	can_tag = {Frozen = true},
	recruit_on_tag = true,
    end_on_none = true
}

MINIGAME:AddPlayerClass {
	name = "Tagger",
	color = COLOR_SKY,
	can_tag = {Runner = true},
	tag_on_damage = true,
	can_damage_everyone = false,
	player_class_on_tag = "Frozen",
	player_class_on_delay = "Tagger",
	delay_amount = FREEZE_TIME,
	minimum = 1,
    weapons = {
        weapon_rpg = true
	}
}

MINIGAME:AddAdjustableSetting {
	key = "player_classes.Tagger.tag_on_damage",
	label = "Runner can be frozen from damage"
}
