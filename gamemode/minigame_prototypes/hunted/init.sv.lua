function MINIGAME:PickRandomHunted(excluded_ply)
	MinigameService.PickRandomPlayerClasses(self.players, 1, self.player_classes.Hunted, self.player_classes.Hunter, {excluded_ply}, 1)
end

function MINIGAME:Start()
	self.started = true
	self:PickRandomHunted()
end

function MINIGAME:Stop()
	self.started = false
	for _, ply in pairs(self.players) do
		ply:ClearPlayerClass()
	end
end

function MINIGAME:PlayerJoin(ply)
	if self.started then
		ply:SetPlayerClass(self.player_classes.Hunter)
	end
end

function MINIGAME:PlayerDeath(ply)
	if table.HasValue(self.Hunted, ply) then
		self:PickRandomHunted(ply)
	end
end

function MINIGAME:Tag(hunted, hunter)
	hunted:SetPlayerClass(self.player_classes.Hunter)
	hunter:SetPlayerClass(self.player_classes.Hunted)
	hunted:Kill()
end