# Creating Tools

## Starting out

All tools are stored in **gamemode/build/tools/** and are named according to the code style guide. Every tool should begin with a new instance being created.

```lua
local TOOL = ToolType.New()
```

Followed by its properties.
```lua
TOOL.name           = "create_point"
TOOL.show_name      = "Create Point"

TOOL.description    = [[
    Left click to place a point.
    Scroll up and down to change the distance of the point.
]]
```

## Hooks
### Base hooks
```lua
function TOOL:OnEquip()
    --Stuff that happens when the tool is equipped
end

function TOOL:OnHolster()
    --Stuff that happens before switching to a different tool
end

function TOOL:Render()
    --Render stuff when the tool is equipped.
end

function ToolType:OnMouseScroll(scroll_delta)
    --By default this hook changes the tool distance
    --The argument in this hook is a number that defines up or down motion of the mouse
    return true --Suppress mouse binds?
end
```
### Binding controls
Controls for the tools can be bound by creating an entry for its [IN_KEY](http://wiki.garrysmod.com/page/Enums/IN).

```lua
TOOL.Press[IN_ATTACK] = function()
    --Runs when in attack is pressed
end
TOOL.Release[IN_ATTACK] = function()
    --Runs when in attack is released
end
```

### Registering the tool

When the tool is finished it can be registered using ```BuildService.RegisterBuildTool(TOOL)```

## Example tool

```lua
local TOOL = ToolType.New()

TOOL.name           = "new_tool"
TOOL.show_name      = "New Tool"

TOOL.description    = [[
    Press left click to do something.
    Release left click to do something else.
]]

function TOOL:OnEquip()
    print("Equipped "..self.show_name)
end

function TOOL:OnHolster()
    print("Holstered "..self.show_name..":(")
end

function TOOL:Render()
    --Render stuff in the 3D context.
end

TOOL.Press[IN_ATTACK] = function()
    print("something")
end
TOOL.Release[IN_ATTACK] = function()
    print("something else")
end

BuildService.RegisterBuildTool(TOOL)
```