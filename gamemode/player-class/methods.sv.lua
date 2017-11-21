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
	self.player_class = nil
	table.RemoveByValue(self.minigame_lobby[ply_class.key], self)
	self:EndPlayerClass()
	PlayerClassService.NetworkPlayerClass(self)
end