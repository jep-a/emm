MINIGAME.name = "Base"
MINIGAME.display = false
MINIGAME.color = COLOR_WHITE
MINIGAME.required_players = 2
MINIGAME.default_state = "Waiting"

MINIGAME:AddState {
	name = "Waiting",
	next = "Starting"
}

MINIGAME:AddState {
	name = "Starting",
	time = 5,
	next = "Playing"
}

MINIGAME:AddState {
	name = "Playing",
	next = "Ending"
}

MINIGAME:AddState {
	name = "Ending",
	time = 5,
	next = "Starting"
}

MINIGAME:AddStateHook("Waiting", "PlayerJoin", "RequirePlayers", function (self, ply)
	if #self.players >= self.required_players then
		self:NextState()
	end
end)

MINIGAME:AddHook("PlayerLeave", "RequirePlayers", function (self, ply)
	if not (self.state == self.states.Waiting) and ((#self.players - 1) < self.required_players) then
		self:SetState(self.states.Waiting)
	end
end)