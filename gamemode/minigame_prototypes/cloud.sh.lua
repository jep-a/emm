MINIGAME.name = "Cloud"
MINIGAME.color = COLOR_ROYAL
MINIGAME.default_player_class = "Jumper"

MINIGAME.random_player_classes = {
	class_key = "Cloud",
	rejected_class_key = "Jumper"
}

MINIGAME:AddPlayerClass({
	name = "Cloud",
	color = COLOR_CLOUD,
	taggable_radius = 512,
	can_tag = {Jumper = true},
	tag_victim = true,
	swap_on_tag = true,
	swap_closest_on_death = true,
	swap_with_attacker = true
}, {
	taggable = false
})

MINIGAME:AddPlayerClass {
	name = "Jumper"
}

function MINIGAME.player_classes.Cloud:SetCloud()
	GhostService.Ghost(self)
	self.dynamic_player_class.taggable = true
end

function MINIGAME.player_classes.Cloud:SetupMove(move)
	if SERVER and IsFirstTimePredicted() and not self.taggable and move:KeyPressed(IN_ATTACK) then
		self:SetCloud()
	end
end