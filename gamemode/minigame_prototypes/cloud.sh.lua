MINIGAME.name = "Cloud"
MINIGAME.color = COLOR_ROYAL
MINIGAME.default_player_class = "Jumper"

MINIGAME.random_player_classes = {
	class_key = "Cloud",
	rejected_class_key = "Jumper"
}

hook.Add("CreateMinigameHookSchemas", "Cloud", function ()
	MinigameNetService.CreateHookSchema("SetCloud", {"entity"})
end)

if CLIENT then
	MINIGAME:AddHookNotification("SetCloud", function (self, involves_local_ply, cloud)
		if involves_local_ply then
			NotificationService.PushText("you set cloud")
		else
			NotificationService.PushAvatarText(cloud, "set cloud")
		end
	end)
end

MINIGAME:AddPlayerClass({
	name = "Cloud",
	color = COLOR_CLOUD,
	taggable_radius = 512,
	can_tag = {Jumper = true},
	tag_victim = true,
	swap_on_tag = true,
	swap_with_attacker = true
}, {
	taggable = false,
	swap_closest_on_death = true
})

MINIGAME:AddPlayerClass {
	name = "Jumper"
}

if SERVER then
	function MINIGAME:SetCloud(ply)
		GhostService.Ghost(ply)

		ply.dynamic_player_class.taggable = true
		ply.dynamic_player_class.swap_closest_on_death = false

		MinigameService.CallNetHookWithoutMethod(self, "SetCloud", ply)
	end
end

function MINIGAME.player_classes.Cloud:SetupMove(move)
	if SERVER and IsFirstTimePredicted() and not self.taggable and move:KeyPressed(IN_ATTACK) then
		self.lobby:SetCloud(self)
	end
end