function GenerateSurfaceCircle(x, y, radius, arc, ang, quality)
	local circle = {}

	local offset = (ang * (quality/360)) - 1
	local steps = quality/(360/arc)
	local rounded_steps = math.Round(steps)

	for i = 1, rounded_steps + 1 do
		local rad = math.rad((arc * (i + offset))/steps)

        circle[i] = {
			x = x + (math.cos(rad) * radius),
			y = y + (math.sin(rad) * radius)
		}
	end

	circle[rounded_steps + 2] = {
		x = x,
		y = y
	}

	return circle
end