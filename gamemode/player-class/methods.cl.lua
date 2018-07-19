local player_metatable = FindMetaTable("Player")

function player_metatable:SetPlayerClass(ply_class)
	if self.player_class then
		self:ClearPlayerClass()
	end

	self.player_class = ply_class
	table.insert(self.lobby[ply_class.key], self)
	self:SetupPlayerClass()
end

function player_metatable:ClearPlayerClass()
	table.RemoveByValue(self.lobby[self.player_class.key], self)
	self.player_class = nil
	self:EndPlayerClass()
end