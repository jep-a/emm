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
	NetService.Send("PlayerClass", self, class.id)
end

function player_metatable:ClearPlayerClass(net)
	net = Default(net, true)

	local old_class = self.player_class

	table.RemoveByValue(self.lobby[self.player_class.key], self)
	self.player_class = nil
	self:EndPlayerClass()

	if net then
		MinigameService.CallHook(self.lobby, "PlayerClassChange", ply, old_class)
		NetService.Send("PlayerClass", self)
	end
end
hook.Add("LobbyPlayerLeave", "ClearPlayerClass", function (_, ply)
	if ply.player_class then
		ply:ClearPlayerClass()
	end
end)