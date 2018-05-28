TimeAssociatedMapService = TimeAssociatedMapService or {}
TimeAssociatedMapService.maps = TimeAssociatedMapService.maps or {}


-- # Type definition

TimeAssociatedMap = TimeAssociatedMap or {}
TimeAssociatedMap.__index = TimeAssociatedMap

function TimeAssociatedMapService.CreateMap(cooldown, lookup_func)
	local result = setmetatable({
		cooldown = cooldown,
		lookup_func = lookup_func,
		values = {}
	}, TimeAssociatedMap)

	table.insert(TimeAssociatedMapService.maps, result)

	return result
end

function TimeAssociatedMap:Value(...)
	local cur_time = CurTime()

	if self.values[cur_time] == nil then
		self.values[cur_time] = self.lookup_func(args)
	end

	return self.values[cur_time]
end

function TimeAssociatedMap:Update(...)
	self.values[CurTime()] = self.lookup_func(args)
end

function TimeAssociatedMap:HasChecked()
	return not (self.values[CurTime()] == nil)
end

function TimeAssociatedMap:Set(value)
	self.values[CurTime()] = value
end


-- # Auto cleanup

function TimeAssociatedMapService.Cleanup()
	local cur_time = CurTime()
	for _, map in pairs(TimeAssociatedMapService.maps) do
		for t, _ in pairs(map.values) do
			if cur_time > t + map.cooldown  then
				map.values[t] = nil
			end
		end
	end
end
hook.Add("Think", " TimeAssociatedMapService.Cleanup",  TimeAssociatedMapService.Cleanup)