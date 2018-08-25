MinigameEventService = MinigameEventService or {}

function MinigamePrototype:AddEvent(name, struct)
	MinigameEventService.Create(self.key.."."..name, struct)
end