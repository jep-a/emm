PlayerClassService = PlayerClassService or {}

function PlayerClassService.CreatePlayerClass(props, dynamic_props)
	local ply_class = {
		key = props.key or props.name,
		display_name = true,
		color = props.color,

		can_regenerate_health = true,
		can_take_fall_damage = true,
		can_damage_everyone = true,
		can_damage = {},
		weapons = {},

		notify_player_class_on_death = true,
		notify_on_killed_by_player = true,
		notify_on_killed_by_other = false
	}

	hook.Run("InitPlayerClassProperties", ply_class, true)
	table.Merge(ply_class, props)
	ply_class.dynamic_properties = dynamic_props

	return ply_class
end

function PlayerClassService.AddLifecycleObject(ply, object)
	table.insert(ply.player_class_objects, object)
end

function PlayerClassService.MinigamePlayerClass(ply, id_or_key)
	for _, ply_class in pairs(ply.lobby.player_classes) do
		if id_or_key == ply_class.id or id_or_key == ply_class.key then
			return ply_class
		end
	end
end
