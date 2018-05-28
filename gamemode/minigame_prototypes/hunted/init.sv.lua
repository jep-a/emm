function MINIGAME:PickRandomHunted(excluded_ply)
	MinigameService.PickRandomPlayerClasses(self.players, 1, self.player_classes.Hunted, self.player_classes.Hunter, {excluded_ply}, 1)
end

function MINIGAME:Tag(hunted, hunter)
	hunted:SetPlayerClass(self.player_classes.Hunter)
	hunter:SetPlayerClass(self.player_classes.Hunted)
	hunted:Kill()
end