# Extended Movement Mod Code Style Guide

## Naming conventions

### Folders and Lua files

All folders and files should be lowercase-dashed. All Lua files should have a secondary extension defining what realm it is meant for (server, shared, client).

```
gamemode/
	util/
		palette.sh.lua
		pred-sound.cl.lua
		...
```

### Variables

All variables that are not constants should be lowercase_snake_case. All constant variables should be UPPERCASE_SNAKE_CASE. All module-like and class-like tables should be UppercaseCamelCase. All function parameters and local variables not inside the first scope should have shortened words when practical. The shortening of variable words should be consistent throughout the project.

```lua
global_variable = 1
CONSTANT_GLOBAL_VARIABLE = 2

local variable = 3
local CONSTANT_VARIABLE = 4
```

```lua
-- 'function' shortened to 'func', 'parameter ' shortened to 'param', and 'variable' shortened to 'var' inside a scope

local Module = {}

function Module.Function(func_param)
	local var_in_func_scope = func_param
end

if true then
	local var_in_statement = true
end
```

### Properties

All properties should be lowercase_snake_case with no shortened words.

```lua
local table_with_properties = {}
table_with_properties.property = 1
```

```lua
function WalljumpService.InitPlayerProperties(ply)
	ply.can_walljump = true
	ply.can_walljump_sky = false
	ply.walljump_delay = 0.2
	ply.walljump_distance = 30
...
```

### Functions

All functions should be UppercaseCamelCase with no shortened words (with exceptions like 'Initial' to 'Init').

```lua
function WalljumpService.InitPlayerProperties(...)
	...
end
```

## Structuring conventions

### Guarding
- Prefer wrapping the body inside an if-then statement over returning early
```lua
-- bad
function SpectateService.Spectate(...)
	if ply.spectate_timeout > CurTime() then
		return
	end

	if not target then
		...
		return
	end

	if ply:GetObserverMode() == OBS_MODE_NONE then
		if not ply:IsOnGround() then
			...
			return
		end
	end

	-- body
	...
end

-- good
function SpectateService.Spectate(...)
	if CurTime() > ply.spectate_timeout then
		if target then
			if ply:GetObserverMode() == OBS_MODE_NONE then
				if not ply:IsOnGround() then
					...
					return
				end
			end

			-- body
			...
		else
			...
		end
	end
end
```

### Classes
- Assign `class.__index` to `class`
- Create the factory function in the namespace
- If there are more than 2 optional parameters, use a property table to store them
```lua
function ClassNamespace.CreateClass(pos, props)
```
- Name the instanced table variable `instance`
- Instance the table inside `setmetatable()`
- Only assign properties that are unrelated to the class in the factory function like the `id` or `parent`
- Assign any class-related properties in an `Init` method in the class
```lua
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
```

### Function calls
- If you are repeating function calls when you do not need to, save it to a variable once
```lua
-- bad
function TimeAssociatedMap:Value(...)
	if not self.values[CurTime()] then
		self.values[CurTime()] = self.lookup_func(...)
	end

	return self.values[CurTime()]
end

-- good
function TimeAssociatedMap:Value(...)
	local cur_time = CurTime()

	if not self.values[cur_time] then
		self.values[cur_time] = self.lookup_func(...)
	end

	return self.values[cur_time]
end
```

### Equality statements
- Prefer using `~=` over `not` with `==` or `!=`
- Do not check if a variable is `nil` if you do not need to

```lua
-- bad
if foo != nil then

-- good
if foo then
```

### Comparison statements
- Prefer the greater than sign pointing right
- Wrap one side in parentheses if it combines or references multiple variables

```lua
-- bad
if time + cooldown < CurTime() then

-- good
if CurTime() > (time + cooldown) then
```