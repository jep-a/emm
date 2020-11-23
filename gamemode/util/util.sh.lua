function Nily(v)
	return v == "nil" or v == nil
end

function Falsy(v)
	return (
		v == "" or
		v == 0 or
		v == false or
		Nily(v)
	)
end

function Default(...)
	local final_v

	for _, v in pairs({...}) do
		if v ~= "nil" then
			final_v = v

			break
		end
	end

	return final_v
end

function Property(table, key, default, collect)
	if table then
		local v = not Nily(table[key]) and table[key] or default

		if collect then
			table[key] = nil
		elseif Nily(table[key]) then
			table[key] = v
		end

		return v
	else
		return default
	end
end

function RemapClamp(n, in_min, in_max, out_min, out_max)
	return math.Remap(math.Clamp(n, in_min, in_max), in_min, in_max, out_min, out_max)
end

function Snap(n, snap)
	local mod = n % snap

	return n - mod + (math.Round(mod/snap) * snap)
end

function SequentialTableHasValue(tab, val)
	for i = 1, #tab do
		if val == tab[i] then
			return true
		end
	end

	return false
end

function Plural(string, quantity)
	return string..((quantity ~= 1) and "s" or "")
end

function NiceTime(seconds)
	local text

	if seconds == nil then
		text = "a few seconds"
	elseif seconds < 60 then
		local floored = math.floor(seconds)

		text = floored..Plural(" second", floored)
	elseif seconds < (60 * 60) then
		local floored = math.floor(seconds/60)

		text = floored..Plural(" minute", floored)
	else
		local floored = math.floor(seconds/(60 * 60))

		text = floored..Plural(" hour", floored)
	end

	return text
end

function IsColor(color)
	return istable(color) and color.r and color.g and color.b
end

function IsPlayer(ply)
	return isentity(ply) and IsValid(ply) and ply:IsPlayer()
end

function GetObservingPlayer(ply)
	if SERVER then
		if IsValid(ply) and IsValid(ply:GetObserverTarget()) then
			return ply:GetObserverTarget()
		end

		return ply
	else
		local local_ply = LocalPlayer()

		if IsValid(local_ply) then
			if IsValid(local_ply:GetObserverTarget()) then
				return local_ply:GetObserverTarget()
			end
		end

		return local_ply
	end
end