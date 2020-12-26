MINIGAME.name = "Cloud"
MINIGAME.color = COLOR_ROYAL
MINIGAME.default_player_class = "Climber"
MINIGAME.required_players = 1

MINIGAME.random_player_classes = {
	class_key = "Cloud",
	rejected_class_key = "Climber"
}

hook.Add("CreateMinigameHookSchemas", "Cloud", function ()
	MinigameNetService.CreateHookSchema("SetCloud", {"entity"})
end)

MINIGAME:AddPlayerClass({
	name = "Cloud",
	color = COLOR_CLOUD,
	tag_word = "reached",
	tag_victim = true,
	swap_on_tag = true,
	swap_closest_on_leave = true
}, {
	cloud_set = false,
	swap_closest_on_death = true
})

MINIGAME:AddPlayerClass {
	name = "Climber"
}

if SERVER then
	function MINIGAME:SetCloud(ply)
		ply.cloud_trigger = TriggerService.CreateTrigger(self, {
			owner = ply,
			position = ply:GetPos(),
			radius = 512,
			owner_tag = true,
			can_tag = {Climber = true},
			indicator_name = "cloud",
			model = "models/emm2/cloud.mdl",
			model_scale = 3.33,
			looks_at_players = true,
			floats = true
		})

		self.cloud_trigger = ply.cloud_trigger

		local dynamic_ply_class = ply.dynamic_player_class
		dynamic_ply_class.cloud_set = true
		dynamic_ply_class.swap_closest_on_death = false

		PlayerClassService.AddLifecycleObject(ply, "cloud_trigger")
		MinigameStateService.AddLifecycleObject(self, "cloud_trigger")
		MinigameService.CallNetHookWithoutMethod(self, "SetCloud", ply)
	end

	function MINIGAME.player_classes.Cloud:Tag(tagger)
		self.cloud_trigger:Remove()
	end

	function MINIGAME.player_classes.Cloud:SetupMove(move)
		if IsFirstTimePredicted() and not self.cloud_set and GhostService.Alive(self) and move:KeyPressed(IN_ATTACK) then
			self.lobby:SetCloud(self)
		end
	end
else
	MINIGAME:AddHookNotification("SetCloud", function (self, involves_local_ply, cloud)
		if involves_local_ply then
			NotificationService.PushText "you set cloud"
		else
			NotificationService.PushAvatarText(cloud, "set cloud")
		end
	end)
end