local player_metatable = FindMetaTable "Player"

function player_metatable:SetPlayerClass(class)
	local old_class = self.player_class

	if old_class then
		self:ClearPlayerClass(true)
	end

	self.player_class = class
	table.insert(self.lobby[class.key], self)
	self:SetupPlayerClass()

	hook.Run("PlayerClassChange", self, old_class, class)

	if self.lobby:IsLocal() then
		hook.Run("LocalLobbyPlayerClassChange", self.lobby, self, old_class, class)
	end

	MinigameService.CallHook(self.lobby, "PlayerClassChange", self, old_class, class)

	if IsLocalPlayer(self) and class.display_name then
		NotificationService.PushMetaText(class.name, "PlayerClass", 2)
	end
end

function player_metatable:ClearPlayerClass(switching)
	local old_class = self.player_class

	table.RemoveByValue(self.lobby[self.player_class.key], self)
	self.player_class = nil
	self:FinishPlayerClass()

	if not switching then
		hook.Run("PlayerClassChange", self, old_class)

		if self.lobby:IsLocal() then
			hook.Run("LocalLobbyPlayerClassChange", self.lobby, self, old_class)
		end

		MinigameService.CallHook(self.lobby, "PlayerClassChange", self, old_class)

		if IsLocalPlayer(self) then
			NotificationService.FinishSticky "PlayerClass"
		end
	end
end

function PlayerClassService.InitHUDElements()
	local ply_class = LocalPlayer().player_class

	if ply_class and ply_class.display_name then
		NotificationService.PushMetaText(ply_class.name, "PlayerClass", 2)
	end
end
hook.Add("InitHUDElements", "PlayerClassService.InitHUDElements", PlayerClassService.InitHUDElements)