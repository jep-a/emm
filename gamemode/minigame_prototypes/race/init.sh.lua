EMM.Include "minigame_prototypes/race/timer"

MINIGAME.name = "Race"
MINIGAME.color = COLOR_YELLOW
MINIGAME.default_player_class = "Racer"
MINIGAME.default_state = "Playing"
MINIGAME.required_players = 0
MINIGAME.ZONES = {
	["start"] = COLOR_GREEN,
	["end"] = COLOR_RED,
	["checkpoint"] = COLOR_YELLOW,
	["checkpoint_active"] = COLOR_ROYAL,
	["checkpoint_activated"] = ColorAlpha(COLOR_ROYAL, 0)
}

MINIGAME.DEFAULT = {
	can_airaccel = true,
	can_autojump = false,
	can_regenerate_health = true,
	can_take_fall_damage = true,
	can_walljump = true,
	can_wallslide = true,
	friction = 8,
	gravity = 300,
	has_infinite_airaccel = false,
	has_infinite_wallslide = false,
	weapons = {}
}

MINIGAME.MODES = {
	["normal"] = {},
	["no-shift"] = {
		can_airaccel = false,
	}
}

MINIGAME:AddPlayerClass {
	name = "Racer"
}
MINIGAME:RemoveAdjustableSetting "states.Playing.time"


-- # Properties

function MINIGAME.InitPlayerProperties(ply)
	ply.race_mode = "normal"
	ply.race_checkpoints = {}
	ply.race_timer = 0
	ply.race_start_time = 0
	ply.race_frozen = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"Race.InitPlayerProperties",
	MINIGAME.InitPlayerProperties
)


-- # Utils

function MINIGAME.LobbyInit(lobby)
	if lobby.key == "Race" then
		lobby.zones = {}
		lobby.leaderboard = {}
	end
end
hook.Add("LobbyInit", "MINIGAME.LobbyInit", MINIGAME.LobbyInit)

function MINIGAME.CanNoclip(ply)
	MINIGAME.StopTimer(ply)

	return (ply.lobby and ply.lobby.key == "Race" and ply.lobby.host == ply)
end
hook.Add("PlayerNoClip", "MINIGAME.CanNoclip", MINIGAME.CanNoclip)

function MINIGAME.GetMode(ply)
	local ply_class = ply.player_class
	local race_mode = "unofficial"
	local last_mode = "none"
	local new_settings = table.Copy(MINIGAME.DEFAULT)

	for mode, settings in pairs(MINIGAME.MODES) do
		table.Merge(new_settings, settings)
		
		for setting, v in pairs(new_settings) do
			if ply_class[setting] ~= v and not istable(ply_class[setting]) then
				race_mode = "unofficial"
				break
			elseif istable(ply_class[setting]) then
				if #ply_class[setting] == #v then
					local equals = true

					for k, val in pairs(ply_class[setting]) do
						if v[k] then
							if val ~= v[k] then
								equals = false
								break
							end
						else
							equals = false
							break
						end
					end

					if not equals then
						race_mode = "unofficial"
						break
					end
				end
			else
				if mode ~= last_mode and race_mode == "unofficial" then
					race_mode = mode
				end
			end
		end

		if race_mode ~= "unofficial" then
			break
		end

		last_mode = mode
	end

	return race_mode
end


function MINIGAME.GetPlayers(lobby)
	local rf = RecipientFilter()

	for k, v in pairs(lobby.players) do
		rf:AddPlayer(v)
	end

	return rf
end


-- # Zone

function MINIGAME.CheckpointsLeft(ply)
	if ply.lobby.zones.checkpoint then
		return #ply.lobby.zones.checkpoint - #ply.race_checkpoints
	end
	
	return 0
end

function MINIGAME.NextCheckpoint(ply)
	return math.min(#ply.race_checkpoints+1, #ply.lobby.zones.checkpoint)
end

function MINIGAME.RemoveZone(zone_type, zone_id, lobby_id)
	local zones = MinigameService.lobbies[lobby_id].zones[zone_type]

	if istable(zones) then
		if SERVER then
			zones[zone_id]:Finish()
		end

		table.remove(MinigameService.lobbies[lobby_id].zones[zone_type], zone_id)

		for i = zone_id, #MinigameService.lobbies[lobby_id].zones[zone_type] do
			MinigameService.lobbies[lobby_id].zones[zone_type][i]:SetID(i)
		end
	else
		if SERVER then
			zones:Finish()
		end
	end
end

function MINIGAME.AddCheckpoint(ply, id, sync)
	local next_checkpoint = MINIGAME.NextCheckpoint(ply)
	
	if MINIGAME.CheckpointsLeft(ply) ~= 0 and ply.race_timer ~= 0 and next_checkpoint == id then
		if not ply.race_checkpoints[id] then
			ply.race_checkpoints[id] = ply.race_timer

			if CLIENT then
				ply.lobby.zones.checkpoint[next_checkpoint]:SetDrawColor(MINIGAME.ZONES["checkpoint_activated"], 2)

				if ply.lobby.zones.checkpoint[next_checkpoint+1] then
					ply.lobby.zones.checkpoint[next_checkpoint+1]:SetDrawColor(MINIGAME.ZONES["checkpoint_active"], 2)
				end

				if sync then
					net.Start "Race_UpdateEnt"
						net.WriteInt(next_checkpoint, 8)
						net.WriteEntity(ply)
					net.SendToServer()
				end
			elseif SERVER and sync then
				net.Start "Race_UpdateEnt"
					net.WriteInt(next_checkpoint, 8)
					net.WriteEntity(ply)
				net.Send(ply)
			end
		end
	end
end

function MINIGAME.UpdateCheckpoint()
	local zone_id = net.ReadInt(8)
	local ply = net.ReadEntity()

	if SERVER then
		if zone_id == MINIGAME.NextCheckpoint(ply) then
			net.Start "Race_UpdateEnt"
				net.WriteInt(zone_id, 8)
				net.WriteEntity(ply)
			net.Send(ply)
		end
	else
		if ply == GetPlayer() then
			if zone_id < MINIGAME.NextCheckpoint(ply) then
				table.remove(ply.race_checkpoints, zone_id)
			elseif zone_id == MINIGAME.NextCheckpoint(ply) then
				MINIGAME.AddCheckpoint(ply, zone_id)
			end
		end
	end
end
net.Receive("Race_UpdateEnt", MINIGAME.UpdateCheckpoint)

function MINIGAME.InCheckPoint(ply, zone)
	if zone:GetType() == "checkpoint" then
		MINIGAME.AddCheckpoint(ply, zone:GetID(), true)
	end
end
hook.Add("Emm_Trigger_StartTouch", "MINIGAME.InCheckPoint", MINIGAME.InCheckPoint)

function MINIGAME.InEnd(ply, zone)
	if zone:GetType() == "end" and MINIGAME.CheckpointsLeft(ply) == 0 and ply.race_start_time ~= 0 then
		local mode = MINIGAME.GetMode(ply)

		MINIGAME.StopTimer(ply)
		MINIGAME.UpdateLeaderboard(ply, mode, ply.race_timer)

		if SERVER then
			net.Start "Race_Timer"
				net.WriteEntity(ply)
				net.WriteFloat(ply.race_timer)
				net.WriteString(mode)
			net.Send(MINIGAME.GetPlayers(ply.lobby))
		end
	end
end
hook.Add("Emm_Trigger_StartTouch", "MINIGAME.InEnd", MINIGAME.InEnd)