MINIGAME.name = "Hunted"
MINIGAME.color = COLOR_BLUE

MINIGAME:SetModifiableVars {
	["states.Playing.time"] = {
		["prereq"] = {
			["label"] = "unlimited round time",
			["opposite"] = true,
			["override"] = 0
		},
		["label"] = "round time",
		["type"] = "time",
		["default"] = 500,
		["min"] = 5
	},
	["player_classes.*"] = {
		["mods"] = {
			["can_walljump"] = {["label"] = "can walljump"},
			["can_wallslide"] = {["label"] = "can wallslide"},
			["can_airaccel"] = {["label"] = "can air accelerate"}
		}
	}
}

MINIGAME:AddPlayerClass {
	name = "Hunted",
	color = COLOR_ORANGE,
	can_tag = {"Hunter"}
}

MINIGAME:AddPlayerClass {
	name = "Hunter"
}

MINIGAME:AddEvent("RandomHunted", {"entity"})
MINIGAME:AddEvent("ResetHunted", {"entity", "entity"})