local player_metatable = FindMetaTable("Player")

function player_metatable:SetPlayerClass(class)
	local old_class = self.player_class

	if old_class then
		self:ClearPlayerClass(false)
	end

	self.player_class = class
	table.insert(self.lobby[class.key], self)
	self:SetupPlayerClass()

	MinigameService.CallHook(self.lobby, "PlayerClassChange", ply, old_class, class)
	PlayerClassService.NetworkPlayerClass(self, class)
end

function player_metatable:ClearPlayerClass(net)
	net = net == nil and true or net

	local old_class = self.player_class

	table.RemoveByValue(self.lobby[self.player_class.key], self)
	self.player_class = nil
	self:EndPlayerClass()

	if net then
		MinigameService.CallHook(self.lobby, "PlayerClassChange", ply, old_class)
		PlayerClassService.NetworkPlayerClass(self)
	end
end
hook.Add("LobbyRemovePlayer", "ClearPlayerClass", function (_, ply)
	if ply.player_class then
		ply:ClearPlayerClass()
	end
end)