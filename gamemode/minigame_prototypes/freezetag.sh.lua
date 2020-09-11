MINIGAME.name = "Freezetag"
MINIGAME.color = COLOR_RASPBERRY
MINIGAME.default_player_class = "Runner"
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

if SERVER then
    function MINIGAME:Tag(taggable, tagger)
        timer.Remove("freeze_" .. tagger:SteamID()) -- Remove any previous created timers for turning frozen into tagger
        timer.Create("timer_for_player_class_on_delay_" .. tagger:SteamID(), FREEZE_TIME, 1, function()
            if (tagger.player_class and tagger.player_class.name == "Frozen") then
                tagger:SetPlayerClass(taggable.lobby:GetPlayerClass("Tagger"))
            end
        end)
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
