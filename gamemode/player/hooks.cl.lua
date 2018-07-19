-- # Spawning

local init_post_ent = false
local queued_ent_created_hooks = {}

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
			hook.Run("PlayerInitialSpawn", Entity(ply_index))
		end)
	end
end
net.Receive("PlayerInitialSpawn", CallPlayerInitialSpawnHooks)

local function CallPlayerSpawnHooks()
	if init_post_ent then
		local ply_index = net.ReadUInt(16)
		CallPlayerSpawnHook(ply_index, function ()
			local ply = Entity(ply_index)

			if ply == LocalPlayer() then
				hook.Run("LocalPlayerSpawn", ply)
			end

			hook.Run("PlayerSpawn", ply)
		end)
	end
end
net.Receive("PlayerSpawn", CallPlayerSpawnHooks)

hook.Add("InitPostEntity", "EMM.InitPostEntity", function ()
	init_post_ent = true

	local local_ply = LocalPlayer()
	hook.Run("LocalPlayerInitialSpawn", local_ply)
	hook.Run("LocalPlayerSpawn", local_ply)

	for _, ply in pairs(player.GetAll()) do
		hook.Run("PlayerInitialSpawn", ply)
		hook.Run("PlayerSpawn", ply)
	end
end)

hook.Add("LocalPlayerInitialSpawn", "InitLocalPlayerProperties", function (ply)
	hook.Run("InitLocalPlayerProperties", ply)
end)

hook.Add("LocalPlayerSpawn", "LocalPlayerProperties", function (ply)
	hook.Run("LocalPlayerProperties", ply)
end)

hook.Add("PlayerInitialSpawn", "InitPlayerProperties", function (ply)
	hook.Run("InitPlayerProperties", ply)
end)

hook.Add("PlayerSpawn", "MinigamePlayerSpawn", function (ply)
	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PlayerSpawn")
	end
end)

hook.Add("PlayerSpawn", "PlayerProperties", function (ply)
	hook.Run("PlayerProperties", ply)
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
	hook.Run("PlayerDisconnected", ply)
end)


-- # Death

net.Receive("PrePlayerDeath", function ()
	local ply = net.ReadEntity()
	local att = net.ReadEntity()

	hook.Run("PrePlayerDeath", ply, att)

	if ply.lobby then
		MinigameService.CallHook(ply.lobby, "PrePlayerDeath", att)
	end
end)

net.Receive("PlayerDeath", function ()
	local ply = net.ReadEntity()
	local infl = net.ReadEntity()
	local att = net.ReadEntity()
	hook.Run("PlayerDeath", ply, infl, att)
end)

net.Receive("PostPlayerDeath", function ()
	local ply = net.ReadEntity()
	hook.Run("PostPlayerDeath", ply)
end)