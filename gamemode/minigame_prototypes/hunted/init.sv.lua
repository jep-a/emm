function MINIGAME:PickRandomHunted(excluded_ply)
	local hunted = MinigameService.PickRandomPlayerClasses(self, {
		class_key = "Hunted",
		rejected_class_key = "Hunter",
		less_probable_players = {excluded_ply},
		less_probable_player_chance = 1
	})[1]

	MinigameEventService.Call(self, "RandomHunted", hunted)
end

function MINIGAME:PickClosestHunted(hunted)
	return MinigameService.PickClosestPlayerClass(self, hunted, {
		class_key = "Hunted",
		origin_player_class_key = "Hunter"
	})
end

function MINIGAME:StartStateWaiting()
	MinigameService.ClearPlayerClasses(self)
end

function MINIGAME:StartStatePlaying()
	self:PickRandomHunted()
end

MINIGAME:AddStateHook("Playing", "PlayerJoin", "SetHunter", function (self, ply)
	ply:SetPlayerClass(self.player_classes.Hunter)
end)

function MINIGAME:ResetHunted(ply)
	if ply.player_class == self.player_classes.Hunted then
		local new_hunted = self:PickClosestHunted(ply)
		MinigameEventService.Call(self, "ResetHunted", ply, new_hunted)
	end
end
MINIGAME:AddStateHook("Playing", "PlayerDeath", "ResetHunted", MINIGAME.ResetHunted)
MINIGAME:AddStateHook("Playing", "PlayerLeave", "ResetHunted", MINIGAME.ResetHunted)

MINIGAME:AddStateHook("Playing", "Tag", "SetHunted", function (self, hunted, hunter)
	MinigameService.SwapPlayerClass(hunted, hunter, true)
end)