MINIGAME.name = "Hunted"
MINIGAME.color = COLOR_BLUE
MINIGAME.default_player_class = "Hunter"

MINIGAME:AddPlayerClass {
	name = "Hunted",
	color = COLOR_ORANGE,
	can_tag = {"Hunter"}
}

MINIGAME:AddPlayerClass {
	name = "Hunter"
}

function MINIGAME:Tag(hunted, hunter)
	hunted:SetPlayerClass(self.player_classes.Hunter)
	hunter:SetPlayerClass(self.player_classes.Hunted)
	hunted:Kill()
end