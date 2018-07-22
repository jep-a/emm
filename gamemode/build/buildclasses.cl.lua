BuildService = BuildService or {}

-- # Classes
-- # POINT
BuildPoint = BuildPoint or {}
BuildPoint.__index = BuildPoint

function BuildService.CreatePoint( pos )
    local instance = setmetatable({}, BuildPoint)

	return instance
end
function BuildPoint:Init( p0, p1 )
	self.points = { p0, p1 }
end

-- # EDGE
BuildEdge = BuildEdge or {}
BuildEdge.__index = BuildEdge

function BuildService.CreateEdge( p0, p1 )
    local instance = setmetatable({}, BuildEdge)
	instance:Init( p0, p1 )

	return instance
end
function BuildEdge:Init( p0, p1 )
	self.points = { p0, p1 }
end

-- # FACE

BuildFace = BuildFace or {}
BuildFace.__index = BuildFace

function BuildService.CreateFace( edges )
    local instance = setmetatable({}, BuildEdge)
	instance:Init(cooldown, lookup_func)

	return instance
end

-- # PRIMITIVE
BuildPrim = BuildPrim or {}
BuildPrim.__index = BuildPrim

function BuildService.CreatePrimitive( vertices )
    local instance = setmetatable({}, BuildEdge)
	instance:Init(cooldown, lookup_func)

	table.insert(TimeAssociatedMapService.maps, instance)

	return instance
end

-- # MAP
BuildMap = BuildMap or {}
BuildMap.__index = BuildMap

function BuildService.CreateMap( name )
    local instance = setmetatable({}, BuildEdge)
	instance:Init(cooldown, lookup_func)

	table.insert(TimeAssociatedMapService.maps, instance)

	return instance
end