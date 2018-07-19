# Extended Movement Mod Code Style Guide

## Naming Conventions

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

## 
