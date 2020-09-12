MINIGAME.name = "Freezetag"
MINIGAME.color = COLOR_RASPBERRY
MINIGAME.default_player_class = "Tagger"
MINIGAME.required_players = 2

MINIGAME.states.Playing.time = 60 * 5

FREEZE_TIME = 30

MINIGAME.random_player_classes = {
	class_key = "Tagger",
	rejected_class_key = "Runner"
}

MINIGAME:AddPlayerClass {
	name = "Frozen",
	color = COLOR_WHITE,
	can_move = false
}

MINIGAME:AddPlayerClass {
    name = "Runner",
    tag_word = "unfroze",
	can_tag = {Frozen = true},
	recruit_on_tag = true,
    end_on_none = true
}

MINIGAME:AddPlayerClass {
    name = "Tagger",
    tag_word = "froze",
    color = COLOR_SKY,
	can_tag = {Runner = true},
	can_damage = {Tagger = true},
	tag_on_damage = true,
	can_damage_everyone = false,
	player_class_on_tag = "Frozen",
	minimum = 1,
    weapons = {
        weapon_rpg = true
	}
}

MINIGAME:AddAdjustableSetting {
	key = "player_classes.Tagger.tag_on_damage",
	label = "Runner can be frozen from damage"
}

hook.Add("CreateMinigameHookSchemas", "Freezetag", function ()
    MinigameNetService.CreateHookSchema("SetFrozen", {"entity"})
    MinigameNetService.CreateHookSchema("SetTagger", {"entity"})
end)

if CLIENT then
    MINIGAME:AddHookNotification("SetFrozen", function (self, involves_local_ply, tagger)
		if involves_local_ply then
			LocalPlayer().freeze_timer = NotificationService.PushCountdown(CurTime() + FREEZE_TIME, "frozen for", "FrozenCountdown")
        end
	end)
    MINIGAME:AddHookNotification("SetTagger", function (self, involves_local_ply, tagger)
		if involves_local_ply then
			NotificationService.PushText("you have become a tagger")
		else
			NotificationService.PushSideText(tagger:Nick() .. " has become a tagger")
		end
    end)
    timer.Create("freeze_timer", 1, 0, function()
        local ply = LocalPlayer()
        if ply.freeze_timer then
            if not (ply.player_class and ply.player_class.name == "Frozen") then
                ply.freeze_timer:Finish()
            end
        end
    end)
end

if SERVER then
    function MINIGAME:Tag(taggable, tagger)
        timer.Remove("freeze_" .. tagger:SteamID()) -- Remove any previous created timers for turning frozen into tagger
        timer.Create("freeze_" .. tagger:SteamID(), FREEZE_TIME, 1, function()
            if (tagger.player_class and tagger.player_class.name == "Frozen") then
                tagger:SetPlayerClass(taggable.lobby:GetPlayerClass("Tagger"))
                MinigameService.CallNetHookWithoutMethod(self, "SetTagger", tagger)
            end
        end)
        if (taggable.player_class and taggable.player_class.player_class_on_tag == "Frozen") then
            MinigameService.CallNetHookWithoutMethod(self, "SetFrozen", tagger)
        end
    end
end

local lobby = nil

for k, v in pairs(player:GetAll()) do
    if (k == 1) then
        lobby = v.lobby
	else
		if (v.lobby) then
			v.lobby:RemovePlayer(v)
		end
		if (lobby) then
			lobby:AddPlayer(v)
		end
    end
end
