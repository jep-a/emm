local player_metatable = FindMetaTable("Player")

function player_metatable:SetPlayerClass(class)
	local old_class = self.player_class

	if old_class then
		self:ClearPlayerClass(true)
	end

	self.player_class = class
	table.insert(self.lobby[class.key], self)
	self:SetupPlayerClass()

	MinigameService.CallHook(self.lobby, "PlayerClassChange", ply, old_class, class)
end

function player_metatable:ClearPlayerClass(switching)
	local old_class = self.player_class

	table.RemoveByValue(self.lobby[self.player_class.key], self)
	self.player_class = nil
	self:EndPlayerClass()

	if not switching then
		MinigameService.CallHook(self.lobby, "PlayerClassChange", ply, old_class)
	end
end