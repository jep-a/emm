local player_metatable = FindMetaTable "Player"

function player_metatable:SetPlayerClass(class)
	local old_class = self.player_class

	if old_class then
		self:ClearPlayerClass(false)
	end

	self.player_class = class
	table.insert(self.lobby[class.key], self)
	self:SetupPlayerClass()

	hook.Run("PlayerClassChange", self, old_class, class)
	MinigameService.CallHook(self.lobby, "PlayerClassChange", ply, old_class, class)
	NetService.Broadcast("PlayerClass", self, class.id)
end

function player_metatable:ClearPlayerClass(net)
	net = Default(net, true)

	local old_class = self.player_class

	table.RemoveByValue(self.lobby[self.player_class.key], self)
	self.player_class = nil
	self:FinishPlayerClass()

	if net then
		hook.Run("PlayerClassChange", self, old_class)
		MinigameService.CallHook(self.lobby, "PlayerClassChange", ply, old_class)
		NetService.Broadcast("PlayerClass", self)
	end
end
hook.Add("LobbyPlayerLeave", "ClearPlayerClass", function (_, ply)
	if ply.player_class then
		ply:ClearPlayerClass()
	end
end)