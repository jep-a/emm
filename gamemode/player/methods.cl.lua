local player_metatable = FindMetaTable("Player")

function player_metatable:GetSanitized()
	local sanitized_ply = {}
	sanitized_ply.id = self:EntIndex()
	sanitized_ply.steamID = self:SteamID64()
	sanitized_ply.name = self:Nick()
	return sanitized_ply
end
