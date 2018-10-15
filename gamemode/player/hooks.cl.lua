-- # Spawning

local init_post_ent = false
local queued_player_init_spawn_hooks = {}
local queued_player_spawn_hooks = {}

hook.Add("OnReloaded", "ReloadInitPostEntity", function ()
	init_post_ent = true
end)

local function CallPlayerSpawnHook(queue, ply_index, func)
	if IsValid(Entity(ply_index)) then
		func()
	else
		queue[ply_index] = func
	end
end

local function CallPlayerInitialSpawnHooks(ply_index)
	if init_post_ent then
		CallPlayerSpawnHook(queued_player_init_spawn_hooks, ply_index, function ()
			local ply = Entity(ply_index)
		
			hook.Run("PlayerInitialSpawn", ply)
			hook.Run("InitPlayerProperties", ply)
		end)
	end
end
NetService.Receive("PlayerInitialSpawn", CallPlayerInitialSpawnHooks)

local function CallPlayerSpawnHooks(ply_index)
	if init_post_ent then
		CallPlayerSpawnHook(queued_player_spawn_hooks, ply_index, function ()
			local ply = Entity(ply_index)
			local is_local_ply = IsLocalPlayer(ply)

			ply.just_spawned = true

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
			ply:SetupCoreProperties()

			if is_local_ply then
				hook.Run("LocalPlayerProperties", ply)
			end

			if ply.lobby then
				if MinigameService.IsLocalLobby(ply) then
					hook.Run("LocalLobbyPlayerProperties", ply.lobby, ply)
				end

				MinigameService.CallHook(ply.lobby, "PlayerProperties", ply)
			end

			timer.Simple(SAFE_FRAME, function ()
				ply.just_spawned = nil
			end)
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
	hook.Run "InitUI"

	for _, ply in pairs(player.GetAll()) do
		hook.Run("PlayerInitialSpawn", ply)
		hook.Run("PlayerSpawn", ply)
		hook.Run("InitPlayerProperties", ply)
		hook.Run("PlayerProperties", ply)
		ply:SetupCoreProperties()
	end
end)

hook.Add("OnEntityCreated", "CallDelayedPlayerSpawnHooks", function (ent)
	for i, hk in pairs(queued_player_init_spawn_hooks) do
		if ent:EntIndex() == i then
			hk()
			queued_player_init_spawn_hooks[i] = nil
		end
	end

	for i, hk in pairs(queued_player_spawn_hooks) do
		if ent:EntIndex() == i then
			hk()
			queued_player_spawn_hooks[i] = nil
		end
	end
end)


-- # Disconnecting

hook.Add("EntityRemoved", "PlayerDisconnected", function (ply)
	if ply:IsPlayer() then
		hook.Run("PlayerDisconnected", ply)
	end
end)

NetService.Receive("PlayerDisconnected", function (ply)
	if IsValid(ply) then
		hook.Run("PlayerDisconnected", ply)
	end
end)


-- # Death

NetService.Receive("PrePlayerDeath", function (ply, attacker)
	hook.Run("PrePlayerDeath", ply, attacker)

	if IsLocalPlayer(ply) then
		hook.Run("LocalPrePlayerDeath", ply, attacker)
	end

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPrePlayerDeath", ply.lobby, ply)
		end

		MinigameService.CallHook(ply.lobby, "PrePlayerDeath", ply, attacker)
	end
end)

NetService.Receive("PlayerDeath", function (ply, inflictor, attacker)
	hook.Run("PlayerDeath", ply, inflictor, attacker)

	if IsLocalPlayer(ply) then
		hook.Run("LocalPlayerDeath", ply, inflictor, attacker)
	end

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPlayerDeath", ply.lobby, ply, inflictor, attacker)
		end

		MinigameService.CallHook(ply.lobby, "PlayerDeath", ply, inflictor, attacker)
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