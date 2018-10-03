-- # Spawning

local init_post_ent = false
local queued_ent_created_hooks = {}

hook.Add("OnReloaded", "ReloadInitPostEntity", function ()
	init_post_ent = true
end)

local function CallPlayerSpawnHook(ply_index, func)
	if IsValid(Entity(ply_index)) then
		func()
	else
		table.insert(queued_ent_created_hooks, {player_index = ply_index, func = func})
	end
end

local function CallPlayerInitialSpawnHooks(ply_index)
	if init_post_ent then
		CallPlayerSpawnHook(ply_index, function ()
			local ply = Entity(ply_index)

			hook.Run("PlayerInitialSpawn", ply)
			hook.Run("InitPlayerProperties", ply)
		end)
	end
end
NetService.Receive("PlayerInitialSpawn", CallPlayerInitialSpawnHooks)

local function CallPlayerSpawnHooks(ply_index)
	if init_post_ent then
		CallPlayerSpawnHook(ply_index, function ()
			local ply = Entity(ply_index)
			local is_local_ply = IsLocalPlayer(ply)

			if is_local_ply then
				hook.Run("LocalPlayerSpawn", ply)
			end

			hook.Run("PlayerSpawn", ply)

			if ply.lobby then
				if MinigameService.IsLocalLobby(ply) then
					hook.Run("LocalLobbyPlayerSpawn", ply.lobby, ply)
				end

				MinigameService.CallHook(ply.lobby, "PlayerSpawn", ply)
			end

			hook.Run("PlayerProperties", ply)

			if is_local_ply then
				hook.Run("LocalPlayerProperties", ply)
			end

			if ply.lobby then
				if MinigameService.IsLocalLobby(ply) then
					hook.Run("LocalLobbyPlayerProperties", ply.lobby, ply)
				end

				MinigameService.CallHook(ply.lobby, "PlayerProperties", ply)
			end
		end)
	end
end
NetService.Receive("PlayerSpawn", CallPlayerSpawnHooks)

hook.Add("InitPostEntity", "EMM.InitPostEntity", function ()
	init_post_ent = true

	local local_ply = LocalPlayer()

	hook.Run("LocalPlayerInitialSpawn", local_ply)
	hook.Run("LocalPlayerSpawn", local_ply)
	hook.Run("InitLocalPlayerProperties", local_ply)
	hook.Run("LocalPlayerProperties", local_ply)
	hook.Run("InitUI")

	for _, ply in pairs(player.GetAll()) do
		hook.Run("PlayerInitialSpawn", ply)
		hook.Run("PlayerSpawn", ply)
		hook.Run("InitPlayerProperties", ply)
		hook.Run("PlayerProperties", ply)
	end
end)

hook.Add("OnEntityCreated", "CallDelayedPlayerSpawnHooks", function (ent)
	local done_hks = {}

	for i, hk in pairs(queued_ent_created_hooks) do
		if ent:EntIndex() == hk.player_index then
			hk.func()
			table.insert(done_hks, i)
		end
	end

	for _, i in pairs(done_hks) do
		table.remove(queued_ent_created_hooks, i)
	end
end)


-- # Disconnecting

NetService.Receive("PlayerDisconnected", function (ply)
	hook.Run("PlayerDisconnected", ply)
end)


-- # Death

NetService.Receive("PrePlayerDeath", function (ply, att)
	hook.Run("PrePlayerDeath", ply, att)

	if IsLocalPlayer(ply) then
		hook.Run("LocalPrePlayerDeath", ply, att)
	end

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPrePlayerDeath", ply.lobby, ply)
		end

		MinigameService.CallHook(ply.lobby, "PrePlayerDeath", ply, att)
	end
end)

NetService.Receive("PlayerDeath", function (ply, infl, att)
	hook.Run("PlayerDeath", ply, infl, att)

	if IsLocalPlayer(ply) then
		hook.Run("LocalPlayerDeath", ply, infl, att)
	end

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPlayerDeath", ply.lobby, ply, infl, att)
		end

		MinigameService.CallHook(ply.lobby, "PlayerDeath", ply, infl, att)
	end
end)

NetService.Receive("PostPlayerDeath", function (ply)
	hook.Run("PostPlayerDeath", ply)

	if LocalPlayer() == ply then
		hook.Run("LocalPostPlayerDeath", ply)
	end

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPostPlayerDeath", ply.lobby, ply)
		end

		MinigameService.CallHook(ply.lobby, "PostPlayerDeath", ply)
	end
end)