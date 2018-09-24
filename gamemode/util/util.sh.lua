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
