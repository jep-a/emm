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
	trigger.can_tag = props.can_tag
	trigger.model = props.model
	trigger.model_scale = props.model_scale

	trigger:SetNWString("IndicatorName", props.indicator_name)
	trigger:SetNWString("IndicatorIcon", props.indicator_icon)

	if props.owner then
		trigger:SetOwner(props.owner)
	end

	trigger:Spawn()

	lobby:AddEntity(trigger)

	return trigger
end