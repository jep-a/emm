local player_metatable = FindMetaTable("Player")

function player_metatable:SetPlayerClass(ply_class)
	if self:HasPlayerClass() then
		self:EndPlayerClass()
	end

	self.player_class = ply_class
	self:SetupPlayerClass()
end

function player_metatable:ClearPlayerClass()
	if self.player_class then
		self.player_class = nil
		self:EndPlayerClass()
	end
end