# Classes

This gamemode comes with its own object oriented class library tailored to Garry's Mod Lua. It provides inheritance and a simple way to attach class instances to Garry's Mod hooks.

## Creating a new class

New classes are created with `Class.New()`. By doing `OurClass = OurClass or Class.New()` it saves existing class instances from being ruined on auto refresh if you are developing in-game. The `Init` method is where you can work with the passed parameters and assign properties.

```lua
CheckpointMarkerFadeBeam = CheckpointMarkerFadeBeam or Class.New()

function CheckpointMarkerFadeBeam:Init(props)
	self.direction = props.direction or Vector(0, 0, 1)

	...
end
```

In the above example, `CheckpointMarkerFadeBeam.New({direction = Vector(0, 1, 0)})` will make a new class instance with the provided direction.


```lua
ButtonBar = ButtonBar or Class.New(Element)

function ButtonBar:Init(props)
	ButtonBar.super.Init(self, props)
	...
end
```

Inheritance is done by providing an existing class to `Class.New(OurClass)`. `ButtonBar.super.Method(self, ...)` accesses the inherited method.

## Hooks

If you need a class instance to think or render, `Class.AddHook(OurClass, "HookName", "ClassFunctionName")` lets you automatically attach new instances to these hooks.

```lua
function AnimatableValue:Think()
	...

	self:Animate()

	...
end
Class.AddHook(AnimatableValue, "Think")

function CheckpointMarkerFadeBeam:Render()
	render.SetColorMaterialIgnoreZ()
	render.StartBeam(3)
	...
	render.EndBeam()
end
Class.AddHook(CheckpointMarkerFadeBeam, "PostDrawTranslucentRenderables", "Render")
```

## Finishing a class instance

The `Finish` method is the end of a class instance's lifecycle. If you attached the class to a hook, you need to run `self:DisconnectFromHooks()` which removes the instance hooks.

```lua
function CheckpointMarkerFadeBeam:Finish()
	self.opacity:Finish()
	self:DisconnectFromHooks()

	...
end
```
