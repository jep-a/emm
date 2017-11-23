local player_metatable = FindMetaTable("Player")

function player_metatable:SetPlayerClass(ply_class)
	if self:HasPlayerClass() then
		self:EndPlayerClass()
	end

	self.player_class = ply_class
	table.insert(self.minigame_lobby[ply_class.key], self)
	self:SetupPlayerClass()
	PlayerClassService.NetworkPlayerClass(self, ply_class)
end

function player_metatable:ClearPlayerClass()
	if self.player_class then
		table.RemoveByValue(self.minigame_lobby[self.player_class.key], self)
		self.player_class = nil
		self:EndPlayerClass()
		PlayerClassService.NetworkPlayerClass(self)
	end
end