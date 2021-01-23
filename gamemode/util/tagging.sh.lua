TaggingService = TaggingService or {}

hook.Add("CreateMinigameHookSchemas", "TaggingService", function ()
	MinigameNetService.CreateHookSchema("Tag", {"entity", "entity"})
	MinigameNetService.CreateHookSchema("PostTag", {"entity", "entity"})
	MinigameNetService.CreateHookSchema("EndTag", {"entity", "entity"})
	MinigameNetService.CreateHookSchema("PostEndTag", {"entity", "entity"})
end)

function TaggingService.InitPlayerProperties(ply)
	ply.taggable = true
	ply.taggable_radius = 80
	ply.taggable_cooldown = 1
	ply.tagging = {}
	ply.last_tag_time = 0
end
hook.Add("InitPlayerProperties", "TaggingService.InitPlayerProperties", TaggingService.InitPlayerProperties)

function TaggingService.InitPlayerClassProperties(ply_class)
	ply_class.can_tag = {}
	ply_class.notify_on_tag = true
	ply_class.tag_on_damage = false
end
hook.Add("InitPlayerClassProperties", "TaggingService.InitPlayerClassProperties", TaggingService.InitPlayerClassProperties)