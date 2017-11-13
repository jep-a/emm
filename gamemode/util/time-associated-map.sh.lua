TimeAssociatedMapService = TimeAssociatedMapService or {}


-- # Global values
maps = maps or {}


-- # Type definition

TimeAssociatedMap = TimeAssociatedMap or {}
TimeAssociatedMap.__index = TimeAssociatedMap

function TimeAssociatedMapService.CreateMap(cooldown, lookup_func)
	local result = setmetatable({
		cooldown = cooldown,
		lookup_func = lookup_func,
		values = {}
	}, TimeAssociatedMap)

	table.insert(maps, result)

	return result
end

function TimeAssociatedMap:Value(...)
	local cur_time = CurTime()

	if self.values[cur_time] == nil then
		self.values[cur_time] = self.lookup_func(args)
	end

	return self.values[cur_time]
end

function TimeAssociatedMap:HasChecked()
	return self.values[CurTime()] != nil
end


-- # Auto cleanup

function TimeAssociatedMapService.Cleanup()
	local cur_time = CurTime()

	for _, map in pairs(maps) do
		for t, _ in pairs(map.values) do
			if cur_time > t + map.cooldown  then
				map.values[t] = nil
			end
		end
	end
end
hook.Add("Think", " TimeAssociatedMapService.Cleanup",  TimeAssociatedMapService.Cleanup)