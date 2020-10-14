TriggerService = TriggerService or {}

local owned_triggers = {}

function TriggerService.CreateTrigger(lobby, props)
	local trigger = ents.Create "emm_trigger"

	trigger.type = props.type or EMM_TRIGGER_START_POINT
	trigger.id = props.id or 0
	trigger.position = props.position or Vector()
	trigger.radius = props.radius or 0
	trigger.width = props.width or 0
	trigger.height = props.height or 0
	trigger.depth = props.depth or 0
	trigger.angle = props.angle or Angle()
	trigger.owner_tag = props.owner_tag
	trigger.can_tag = props.can_tag
	trigger.model = props.model
	trigger.model_scale = props.model_scale
	trigger.looks_at_players = props.looks_at_players
	trigger.floats = props.floats

	trigger:SetNWString("IndicatorName", props.indicator_name)
	trigger:SetNWString("IndicatorIcon", props.indicator_icon)

	if props.owner then
		trigger:SetOwner(props.owner)
		table.insert(owned_triggers, trigger)
	end

	trigger:Spawn()

	lobby:AddEntity(trigger)

	return trigger
end

function TriggerService.EndOwnedTriggers(ply)
	for _, trigger in pairs(owned_triggers)	do
		if ply == trigger:GetOwner() then
			table.RemoveByValue(owned_triggers, trigger)
			trigger:Remove()
		end
	end
end
hook.Add("FinishPlayerClass", "TriggerService.EndOwnedTriggers", TriggerService.EndOwnedTriggers)