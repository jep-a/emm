MINIGAME.name = "Freezetag"
MINIGAME.color = COLOR_ICE
MINIGAME.default_player_class = "Hunter"
MINIGAME.required_players = 3
MINIGAME.frozen_time = 30
MINIGAME.save_time = 5

MINIGAME.states.Playing.time = 60 * 5

MINIGAME.random_player_classes = {
	class_key = "Hunter",
	rejected_class_key = "Hunted"
}

MINIGAME:AddPlayerClass {
	name = "Hunter",
	can_tag = {Hunted = true},
	minimum = 1,
	give_player_class_on_tag = "Frozen"
}

MINIGAME:AddPlayerClass {
	name = "Hunted",
	color = COLOR_PEACH,
	end_on_none = true
}

MINIGAME:AddPlayerClass {
	name = "Frozen",
	color = COLOR_WHITE,
	can_tag = {Hunted = true},
	notify_on_tag = false
}

function MINIGAME.player_classes.Hunter:PostTag(tagger)
	if SERVER then
		GhostService.Ghost(tagger, {
			kill = true,
			ragdoll = true,
			statue = true,
			savepoint = true
		})
	end

	tagger.frozen_timer = Timer.New(self.lobby.frozen_time, function ()
		if SERVER then
			tagger:SetPlayerClass(MINIGAME.player_classes.Hunter)
		end
	end)

	PlayerClassService.AddLifecycleObject(tagger, tagger.frozen_timer)

	if CLIENT and LocalPlayer() == tagger then
		local frozen_time = self.lobby.frozen_time
		local save_time = self.lobby.save_time

		local notification = NotificationService.PushMeter({
			icon_material = PNGMaterial "emm2/minigames/freezetag-2x.png",
			show_value = true,
			percent_func = function ()
				local v
				local frozen_timer = tagger.frozen_timer
				local save_timer = tagger.save_timer
				local curr_frozen_time = frozen_timer and frozen_timer.timeleft or 0
				local curr_save_time = save_timer and save_timer.timeleft or 0

				if save_timer and frozen_timer then
					v = (curr_save_time/save_time) * (1 - (curr_frozen_time/frozen_time))
				elseif frozen_timer then
					v = 1 - (curr_frozen_time/frozen_time)
				end

				return v
			end,
			text_func = function ()
				local text

				local frozen_timer = tagger.frozen_timer
				local save_timer = tagger.save_timer
				local curr_frozen_time = frozen_timer and frozen_timer.timeleft or 0
				local curr_save_time = save_timer and save_timer.timeleft or 0

				if save_timer then
					text = curr_save_time
				elseif frozen_timer then
					text = curr_frozen_time
				end

				return math.ceil(text)
			end
		}, "frozen_timer", 1)

		PlayerClassService.AddLifecycleObject(tagger, notification)
	end
end

function MINIGAME.player_classes.Frozen:PostTag(tagger)
	self.frozen_timer:Pause()

	if not self.save_timer then
		self.save_timer = Timer.New(self.lobby.save_time, function ()
			if SERVER then
				self:SetPlayerClass(MINIGAME.player_classes.Hunted)
			end
		end)
	end

	PlayerClassService.AddLifecycleObject(self, self.save_timer)

	if CLIENT and LocalPlayer() == tagger then
		local save_time = self.lobby.save_time

		local notification = NotificationService.PushMeter({
			icon_material = PNGMaterial "emm2/minigames/freezetag-2x.png",
			show_value = true,
			percent_func = function ()
				return self.save_timer and (self.save_timer.timeleft/save_time) or 0
			end,
			text_func = function ()
				return math.ceil(self.save_timer and self.save_timer.timeleft or 0)
			end
		}, "save_timer", 1)

		PlayerClassService.AddLifecycleObject(tagger, notification)
	end
end

function MINIGAME.player_classes.Frozen:EndTag(tagger)
	self.frozen_timer:Resume()
	self.save_timer:Finish()
	self.save_timer = nil

	if CLIENT and LocalPlayer() == tagger then
		NotificationService.stickies.save_timer:Finish()
	end
end

-- TODO: frozen indicator health status
-- TODO: remove frozen player class lobby settings
-- TODO: respawn freezetag states