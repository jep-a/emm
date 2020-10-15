UnstuckService = UnstuckService or {}
UnstuckService.queue = UnstuckService.queue or {}

-- # https://github.com/MrGrim48/gmod_unstuck

UNSTUCK_FAILED = 0
UNSTUCK_PASSED = 1

function UnstuckService.Queue(ply)
	if not table.HasValue(UnstuckService.queue, ply) then
		table.insert(UnstuckService.queue, ply)
	end
end

function UnstuckService.CheckHull(ply, pos)
	local trace = util.TraceEntity({
		start = pos,
		endpos = pos,
		filter = ply,
		mask = MASK_PLAYERSOLID
	}, ply)

	return (not trace.StartSolid) or (not trace.AllSolid)
end

function UnstuckService.GetTiles(ply, pos)
	local tiles = {}
	local x, y, z
	local min_s, max_s = ply:GetHull()
	local range = math.max(32, max_s.x, max_s.y)

	for z = -1, 1, 1 do
		for y = -1, 1, 1 do
			for x = -1, 1, 1 do
				table.insert(tiles, pos + (Vector(x, y, z) * range))
			end
		end
	end

	return tiles
end

function UnstuckService.GetClearTiles(ply, pos, tiles)
	local clear_tiles = {}
	local filter = player.GetAll()

	table.Add(filter, ents.FindByClass "prop_physics")
	table.Add(filter, ents.FindByClass "prop_physics_multiplayer")
	table.Add(filter, ents.FindByClass "func_door")
	table.Add(filter, ents.FindByClass "prop_door_rotating")
	table.Add(filter, ents.FindByClass "func_door_rotating")

	for _, tile in pairs(tiles) do
		local trace = util.TraceLine {
			start = pos,
			endpos = tile,
			filter = filter,
			mask = MASK_PLAYERSOLID
		}

		if not trace.Hit and util.IsInWorld(tile) then
			table.insert(clear_tiles, tile)
		end
	end

	return clear_tiles
end

function UnstuckService.FindNewPosition(ply, pos, i)
	coroutine.yield()

	local tiles = UnstuckService.GetTiles(ply, pos)

	coroutine.yield()

	local clear_tiles = UnstuckService.GetClearTiles(ply, pos, tiles)
	local min_s, max_s = ply:GetHull()

	for _, tile in pairs(clear_tiles) do
		coroutine.yield()

		if UnstuckService.CheckHull(ply, tile) then
			ply:SetPos(tile)
			coroutine.yield(UNSTUCK_PASSED)
		end
	end

	if (i + 1) > 3 then
		coroutine.yield(UNSTUCK_FAILED)
	end

	for _, tile in pairs(clear_tiles) do
		coroutine.yield()

		local result = UnstuckService.NewPositionCoroutine(ply, tile, i + 1)

		if result == UNSTUCK_PASSED then
			coroutine.yield(UNSTUCK_PASSED)
		end
	end

	coroutine.yield(UNSTUCK_FAILED)
end

function UnstuckService.NewPositionCoroutine(ply, pos, i)
	local new_pos_co = coroutine.create(UnstuckService.FindNewPosition)
	local no_error, result

	repeat
		no_error, result = coroutine.resume(new_pos_co, ply, pos, i)
	until (
		result == UNSTUCK_FAILED or
		result == UNSTUCK_PASSED or
		not no_error
	)

	return result
end

function UnstuckService.Think()
	for k, ply in pairs(UnstuckService.queue) do
		if IsValid(ply) then
			local result = UnstuckService.NewPositionCoroutine(ply, ply:GetPos(), 1)

			if result == UNSTUCK_FAILED then
				ply:Spawn()
			end

			table.remove(UnstuckService.queue, k)
		end
	end
end
hook.Add("Think", "UnstuckService.Think", UnstuckService.Think)