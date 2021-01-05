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

local function CallPlayerInitialSpawnHooks()
	if init_post_ent then
		local ply_index = net.ReadUInt(16)

		CallPlayerSpawnHook(ply_index, function ()
			local ply = Entity(ply_index)

			hook.Run("PlayerInitialSpawn", ply)
			hook.Run("InitPlayerProperties", ply)
		end)
	end
end
net.Receive("PlayerInitialSpawn", CallPlayerInitialSpawnHooks)

local function CallPlayerSpawnHooks()
	if init_post_ent then
		local ply_index = net.ReadUInt(16)

		CallPlayerSpawnHook(ply_index, function ()
			local ply = Entity(ply_index)
			local is_local_ply = ply == LocalPlayer()

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
net.Receive("PlayerSpawn", CallPlayerSpawnHooks)

hook.Add("InitPostEntity", "EMM.InitPostEntity", function ()
	print "emm.init"
	init_post_ent = true

	local local_ply = LocalPlayer()

	hook.Run("InitUI")
	hook.Run("LocalPlayerInitialSpawn", local_ply)
	hook.Run("LocalPlayerSpawn", local_ply)
	hook.Run("InitLocalPlayerProperties", local_ply)
	hook.Run("LocalPlayerProperties", local_ply)

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

net.Receive("PlayerDisconnected", function ()
	local ply = net.ReadEntity()

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPlayerDisconnected", ply.lobby, ply)
		end

		MinigameService.CallHook(ply.lobby, "PlayerDisconnected", ply)
	end

	hook.Run("PlayerDisconnected", ply)
end)


-- # Death

net.Receive("PrePlayerDeath", function ()
	local ply = net.ReadEntity()
	local att = net.ReadEntity()

	hook.Run("PrePlayerDeath", ply, att)

	if ply == LocalPlayer() then
		hook.Run("LocalPrePlayerDeath", ply, att)
	end

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPrePlayerDeath", ply.lobby, ply)
		end

		MinigameService.CallHook(ply.lobby, "PrePlayerDeath", ply, att)
	end
end)

net.Receive("PlayerDeath", function ()
	local ply = net.ReadEntity()
	local infl = net.ReadEntity()
	local att = net.ReadEntity()

	hook.Run("PlayerDeath", ply, infl, att)

	if ply == LocalPlayer() then
		hook.Run("LocalPlayerDeath", ply, infl, att)
	end

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPlayerDeath", ply.lobby, ply, infl, att)
		end

		MinigameService.CallHook(ply.lobby, "PlayerDeath", ply, infl, att)
	end
end)

net.Receive("PostPlayerDeath", function ()
	local ply = net.ReadEntity()
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