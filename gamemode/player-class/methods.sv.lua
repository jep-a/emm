local player_metatable = FindMetaTable("Player")

function player_metatable:SetPlayerClass(ply_class)
	if self.player_class then
		self:ClearPlayerClass(false)
	end

	self.player_class = ply_class
	table.insert(self.lobby[ply_class.key], self)
	self:SetupPlayerClass()
	PlayerClassService.NetworkPlayerClass(self, ply_class)
end

function player_metatable:ClearPlayerClass(net)
	net = net == nil and true or net

	table.RemoveByValue(self.lobby[self.player_class.key], self)
	self.player_class = nil
	self:EndPlayerClass()

	if net then
		PlayerClassService.NetworkPlayerClass(self)
	end
end
hook.Add("LobbyRemovePlayer", "ClearPlayerClass", function (_, ply)
	if ply.player_class then
		ply:ClearPlayerClass()
	end
end)