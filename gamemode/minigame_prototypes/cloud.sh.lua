MINIGAME.name = "Cloud"
MINIGAME.color = COLOR_ROYAL
MINIGAME.default_player_class = "Tagger"

MINIGAME.random_player_classes = {
	class_key = "Cloud",
	rejected_class_key = "Tagger"
}

hook.Add("CreateMinigameHookSchemas", "Cloud", function ()
	MinigameNetService.CreateHookSchema("SetCloud", {"entity"})
end)

if CLIENT then
	MINIGAME:AddHookNotification("SetCloud", function (self, involves_local_ply, cloud)
		if involves_local_ply then
			NotificationService.PushText "you set cloud"
		else
			NotificationService.PushAvatarText(cloud, "set cloud")
		end
	end)
end

MINIGAME:AddPlayerClass({
	name = "Cloud",
	color = COLOR_CLOUD,
	taggable_radius = 512,
	can_tag = {Tagger = true},
	tag_victim = true,
	swap_on_tag = true
}, {
	cloud_set = false,
	taggable = false,
	swap_closest_on_death = true
})

MINIGAME:AddPlayerClass {
	name = "Tagger"
}

MINIGAME:AddAdjustableSetting {
	key = "player_classes.Cloud.taggable_radius",
	label = "Cloud tag radius",
	type = "number"
}

if SERVER then
	function MINIGAME:SetCloud(ply)
		GhostService.Ghost(ply)

		local dynamic_ply_class = ply.dynamic_player_class
		dynamic_ply_class.cloud_set = true
		dynamic_ply_class.taggable = true
		dynamic_ply_class.swap_closest_on_death = false

		MinigameService.CallNetHookWithoutMethod(self, "SetCloud", ply)
	end

	function MINIGAME.player_classes.Cloud:SetupMove(move)
		if IsFirstTimePredicted() and not self.cloud_set and self:Alive() and move:KeyPressed(IN_ATTACK) then
			self.lobby:SetCloud(self)
		end
	end
end