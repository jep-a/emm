-- # Spawning

local queued_ent_created_hooks = {}

local function CallPlayerSpawnHook(ply_index, func)
	if IsValid(Entity(ply_index)) then
		func()
	else
		table.insert(queued_ent_created_hooks, {player_index = ply_index, func = func})
	end
end

local function CallPlayerInitialSpawnHooks()
	local ply_index = net.ReadUInt(16)
	CallPlayerSpawnHook(ply_index, function ()
		hook.Run("PlayerInitialSpawn", Entity(ply_index))
	end)
end
net.Receive("PlayerInitialSpawn", CallPlayerInitialSpawnHooks)

local function CallPlayerSpawnHooks()
	local ply_index = net.ReadUInt(16)
	CallPlayerSpawnHook(ply_index, function ()
		hook.Run("PlayerSpawn", Entity(ply_index))
	end)
end
net.Receive("PlayerSpawn", CallPlayerSpawnHooks)

hook.Add("InitPostEntity", "InitLocalPlayerProperties", function ()
	local ply = LocalPlayer()

	hook.Run("InitLocalPlayerProperties", ply)
	ply.initialized = true
	hook.Run("LocalPlayerProperties", ply)
end)

hook.Add("InitPostEntity", "PlayersSpawn", function ()
	for _, ply in pairs(player.GetAll()) do
		if not (ply == LocalPlayer()) then
			hook.Run("PlayerSpawn", ply)
		end
	end
end)

hook.Add("PlayerInitialSpawn", "InitPlayerProperties", function (ply)
	hook.Run("InitPlayerProperties", ply)
end)

hook.Add("PlayerSpawn", "LocalPlayerSpawn", function (ply)
	print(ply)
	if ply == LocalPlayer() then
		hook.Run("LocalPlayerSpawn", ply)
	end
end)

hook.Add("PlayerSpawn", "PlayerProperties", function (ply)
	hook.Run("PlayerProperties", ply)
end)

hook.Add("LocalPlayerSpawn", "LocalPlayerProperties", function (ply)
	if ply.initialized then
		hook.Run("LocalPlayerProperties", ply)
	end
end)

hook.Add("OnEntityCreated", "CallDelayedPlayerSpawn", function (ent)
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


-- # Death

net.Receive("PrePlayerDeath", function ()
	local ply = net.ReadEntity()
	local att = net.ReadEntity()
	hook.Run("PrePlayerDeath", ply, att)
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