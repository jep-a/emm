MinigameEventService = MinigameEventService or {}

function MinigamePrototype:AddEvent(name, struct)
	if self.key then
		name = self.key.."."..name
	end

	MinigameEventService.Create(name, struct)
end

hook.Add("Initialize", "MinigameEventService.CreateGlobalEvents", function ()
	hook.Run "CreateGlobalMinigameEvents"
end)