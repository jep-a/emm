function MINIGAME:PickRandomHunted(excluded_ply)
	MinigameService.PickRandomPlayerClasses(self.players, 1, self.player_classes.Hunted, self.player_classes.Hunter, {excluded_ply}, 1)
end

function MINIGAME:PickClosestHunted(hunted)
	local candidates = {}

	for _, ply in pairs(self.players) do
		if (ply.player_class == self.player_classes.Hunter) and ply:Alive() then
			table.insert(candidates, ply)
		end
	end

	local hunted_pos = hunted:WorldSpaceCenter()
	table.sort(candidates, function (a, b)
		return hunted_pos:Distance(a:WorldSpaceCenter()) < hunted_pos:Distance(b:WorldSpaceCenter())
	end)

	hunted:SetPlayerClass(self.player_classes.Hunter)
	candidates[1]:SetPlayerClass(self.player_classes.Hunted)
end

function MINIGAME:StartStateWaiting()
	MinigameService.ClearPlayerClasses(self.players)
end

function MINIGAME:StartStatePlaying()
	self:PickRandomHunted()
end

MINIGAME:AddStateHook("Playing", "PlayerJoin", "SetHunter", function (self, ply)
	ply:SetPlayerClass(self.player_classes.Hunter)
end)

function MINIGAME:ResetHunted(ply)
	if ply.player_class == self.player_classes.Hunted then
		self:PickClosestHunted(ply)
	end
end
MINIGAME:AddStateHook("Playing", "PlayerDeath", "ResetHunted", MINIGAME.ResetHunted)
MINIGAME:AddStateHook("Playing", "PlayerLeave", "ResetHunted", MINIGAME.ResetHunted)

function MINIGAME:Tag(hunted, hunter)
	hunted:SetPlayerClass(self.player_classes.Hunter)
	hunter:SetPlayerClass(self.player_classes.Hunted)
	hunted:Kill()
end