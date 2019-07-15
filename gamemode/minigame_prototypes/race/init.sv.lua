util.AddNetworkString "Race_Timer"
util.AddNetworkString "Race_Reset"

util.AddNetworkString "Race_CreateEnt"
util.AddNetworkString "Race_RemoveEnt"
util.AddNetworkString "Race_UpdateEnt"

function MINIGAME:StartStatePlaying()
	--
end


-- # Race

function MINIGAME.Commands(ply, txt)
    local prefix = txt:sub(1, 1)

	if (prefix == "!" or prefix == "/") and ply.lobby.key == "Race" then
		local args = string.Split(txt:sub(2), " ")
		local cmd = string.lower(table.remove(args, 1))
		
		if cmd == "r" or cmd == "restart" then
			MINIGAME.Reset(ply)

			return ""	
		end
	end
end
hook.Add("PlayerSay", "MINIGAME.Commands", MINIGAME.Commands)


-- # Zone

function MINIGAME.CorrectTrace(center, radius, height)
	local trace_line = util.TraceLine
	local diameter, trace_up, trace_down
	local corner1, corner2, corner3, corner4
	local corner1_2, corner2_3, corner3_4, corner4_1
	local new_center = Vector()

	radius = math.abs(radius) - 0.1
	diameter = radius * 2
	corner1 = center + Vector(radius, radius)
	corner2 = center + Vector(-radius, radius)
	corner3 = center + Vector(-radius, -radius)
	corner4 = center + Vector(radius, -radius)
	new_center:Set(center)
	corner1_2 = trace_line{
		start = corner1,
		endpos = corner2,
		mask = CONTENTS_SOLID
	}

	if corner1_2.Hit and not (corner1_2.AllSolid or corner1_2.StartSolid) then
		new_center.x = new_center.x + (diameter * (1 - corner1_2.Fraction))
	end

	if corner1_2.StartSolid then
		local corner2_1 = trace_line{
			start = corner2,
			endpos = corner1,
			mask = CONTENTS_SOLID
		}

		if corner2_1.Hit and not corner2_1.AllSolid and not corner2_1.StartSolid then
			new_center.x = new_center.x - (diameter * (1 - corner2_1.Fraction))
		end
	end
	
	corner2 = new_center + Vector(-radius, radius)
	corner3 = new_center + Vector(-radius, -radius)
	corner2_3 = trace_line{
		start = corner2,
		endpos = corner3,
		mask = CONTENTS_SOLID
	}

	if corner2_3.Hit and (not corner2_3.AllSolid or not corner2_3.StartSolid) then
		new_center.y = new_center.y + (diameter * (1 - corner2_3.Fraction))
	end

	if corner2_3.StartSolid then
		local corner3_2 = trace_line{
			start = corner3,
			endpos = corner2,
			mask = CONTENTS_SOLID
		}

		if corner3_2.Hit and not corner3_2.AllSolid and not corner3_2.StartSolid then
			new_center.y = new_center.y - (diameter * (1 - corner3_2.Fraction))
		end
	end
	
	corner3 = new_center + Vector(-radius, -radius)
	corner4 = new_center + Vector(radius, -radius)
	corner3_4 = trace_line{
		start = corner3,
		endpos = corner4,
		mask = CONTENTS_SOLID
	}

	if corner3_4.Hit and (not corner3_4.AllSolid or not corner3_4.StartSolid) then
		new_center.x = new_center.x - (diameter * (1 - corner3_4.Fraction))
	end

	if corner3_4.StartSolid then
		local corner4_3 = trace_line{
			start = corner4,
			endpos = corner3,
			mask = CONTENTS_SOLID
		}

		if corner4_3.Hit and not corner4_3.AllSolid and not corner4_3.StartSolid then
			new_center.x = new_center.x + (diameter * (1 - corner4_3.Fraction))
		end
	end
	
	corner1 = new_center + Vector(radius, radius)
	corner4 = new_center + Vector(radius, -radius)
	corner4_1 = trace_line{
		start = corner4,
		endpos = corner1,
		mask = CONTENTS_SOLID
	}

	if corner4_1.Hit and (not corner4_1.AllSolid or not corner4_1.StartSolid) then
		new_center.y = new_center.y - (diameter * (1 - corner4_1.Fraction))
	end

	if corner4_1.StartSolid then
		local corner1_4 = trace_line{
			start = corner1,
			endpos = corner4,
			mask = CONTENTS_SOLID
		}

		if corner1_4.Hit and not corner1_4.AllSolid and not corner1_4.StartSolid then
			new_center.y = new_center.y + (diameter * (1 - corner1_4.Fraction))
		end
	end
	
	trace_up = trace_line{
		start = new_center,
		endpos = new_center + Vector(0, 0, height),
		mask = CONTENTS_SOLID
	}

	if trace_up.Hit then
		new_center.z = new_center.z - ((height + 2) * (1 - trace_up.Fraction))
	end

	trace_down = trace_line{
		start = new_center,
		endpos = new_center - Vector(0, 0, radius),
		mask = CONTENTS_SOLID
	}

	if trace_down.Hit then
		new_center.z = trace_down.HitPos.z
	end

	return new_center
end


function MINIGAME.CreateZone(zone, lobby_id, zone_type)
	local ent

	if zone_type == "start" then
		zone.pos = MINIGAME.CorrectTrace(zone.pos, 18, 71)
	end

	ent = ents.Create("emm_trigger")
	ent.type = zone_type
	ent.id = 9999
	ent.lobby = lobby_id
	ent.width = zone.width
	ent.depth = zone.depth
	ent.height = zone.height
	ent.angle = zone.angle
	ent.pos = zone.pos
	ent:Spawn()

	if zone_type == "start" or zone_type == "end" then
		if IsValid(MinigameService.lobbies[lobby_id].zones[zone_type]) then
			MinigameService.lobbies[lobby_id].zones[zone_type]:Finish()
		end
		
		MinigameService.lobbies[lobby_id].zones[zone_type] = ent
	else
		if not MinigameService.lobbies[lobby_id].zones[zone_type] then
			MinigameService.lobbies[lobby_id].zones[zone_type] = {}
		end

		table.insert(MinigameService.lobbies[lobby_id].zones[zone_type], ent)
		ent:SetID(#MinigameService.lobbies[lobby_id].zones[zone_type])
	end
end

function MINIGAME.NetCreate()
	local zone = net.ReadTable()
	local lobby_id = net.ReadInt(8)
	local zone_type = net.ReadString()
		
	MINIGAME.CreateZone(zone, lobby_id, zone_type)
end
net.Receive("Race_CreateEnt", MINIGAME.NetCreate)

function MINIGAME.NetRemove()
	local zone_type = net.ReadString()
	local zone_id = net.ReadInt(8)
	local lobby_id = net.ReadInt(8)
		
	MINIGAME.RemoveZone(zone_type, zone_id, lobby_id)
end
net.Receive("Race_RemoveEnt", MINIGAME.NetRemove)

function MINIGAME.OnEntityCreated(ent)
	if ent.type ~= "start" then
		ent:SetTrigger(true)
		ent:SetCollision()
	else
		ent:SetTrigger(false)
		ent:PhysicsInitSphere(32, "default")
		ent:SetSolid(SOLID_VPHYSICS)
		ent:EnableCustomCollisions(true)
	end
end
hook.Add("Emm_Trigger_Init", "MINIGAME.OnEntityCreated", MINIGAME.OnEntityCreated)