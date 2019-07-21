TriggerService = TriggerService or {}

function TriggerService.CreateTrigger(lobby, props)
	local trigger = ents.Create "emm_trigger"
	trigger.type = props.type or EMM_TRIGGER_START_POINT
	trigger.id = props.id or 0
	trigger.position = props.position or Vector()
	trigger.width = props.width or 0
	trigger.height = props.height or 0
	trigger.depth = props.depth or 0
	trigger.angle = props.angle or Angle()
	trigger:Spawn()

	lobby:AddEntity(trigger)

	return trigger
end