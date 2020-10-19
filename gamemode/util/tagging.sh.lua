TaggingService = TaggingService or {}

hook.Add("CreateMinigameHookSchemas", "TaggingService", function ()
	MinigameNetService.CreateHookSchema("Tag", {"entity", "entity"})
	MinigameNetService.CreateHookSchema("EndTag", {"entity", "entity"})
end)