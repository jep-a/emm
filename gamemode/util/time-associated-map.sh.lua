TimeAssociatedMapService = TimeAssociatedMapService or {}
TimeAssociatedMapService.maps = TimeAssociatedMapService.maps or {}


-- # Class

TimeAssociatedMap = TimeAssociatedMap or {}
TimeAssociatedMap.__index = TimeAssociatedMap

function TimeAssociatedMapService.CreateMap(cooldown, lookup_func)
	local instance = setmetatable({}, TimeAssociatedMap)
	instance:Init(cooldown, lookup_func)

	table.insert(TimeAssociatedMapService.maps, instance)

	return instance
end

function TimeAssociatedMap:Init(cooldown, lookup_func)
	self.cooldown = cooldown
	self.lookup_func = lookup_func
	self.values = {}
end

function TimeAssociatedMap:Value(...)
	local cur_time = CurTime()

	if not self.values[cur_time] then
		self.values[cur_time] = self.lookup_func(args)
	end

	return self.values[cur_time]
end

function TimeAssociatedMap:Update(...)
	self.values[CurTime()] = self.lookup_func(args)
end

function TimeAssociatedMap:HasChecked()
	return self.values[CurTime()] ~= nil
end

function TimeAssociatedMap:Set(value)
	self.values[CurTime()] = value
end


-- # Cleanup

function TimeAssociatedMapService.Cleanup()
	local cur_time = CurTime()

	for _, map in pairs(TimeAssociatedMapService.maps) do
		for time, _ in pairs(map.values) do
			if cur_time > (time + map.cooldown)  then
				map.values[time] = nil
			end
		end
	end
end
hook.Add("Think", "TimeAssociatedMapService.Cleanup",  TimeAssociatedMapService.Cleanup)