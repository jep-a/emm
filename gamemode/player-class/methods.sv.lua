local player_metatable = FindMetaTable("Player")

function player_metatable:SetPlayerClass(ply_class)
	if self:HasPlayerClass() then
		self:EndPlayerClass()
	end

	self.player_class = ply_class
	self:SetupPlayerClass()
	PlayerClassService.NetworkPlayerClass(ply, ply_class)
end

function player_metatable:ClearPlayerClass()
	self.player_class = nil
	self:EndPlayerClass()
	PlayerClassService.NetworkPlayerClass(ply)
end