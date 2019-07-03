-- # Util

util.AddNetworkString "UpdateStamina"

function StaminaService.SendStamina(ply, target, stamina_type)
	net.Start "UpdateStamina"
	net.WriteEntity(target)
	net.WriteString(stamina_type)
	net.WriteTable(target.stamina[stamina_type])
	net.Send(ply)
end