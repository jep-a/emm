function CubicBezier(p1x, p1y, p2x, p2y)
	local function SolveEpsilon(duration)
		return 1/(200 * duration)
	end

	local cx = 3 * p1x
	local bx = 3 * (p2x - p1x) - cx
	local ax = 1 - cx - bx
	local cy = 3 * p1y
	local by = 3 * (p2y - p1y) - cy
	local ay = 1 - cy - by

	local function SampleCurveX(t)
		return ((((ax * t) + bx) * t) + cx) * t
	end

	local function SampleCurveY(t)
		return ((((ay * t) + by) * t) + cy) * t
	end

	local function SampleCurveDerivativeX(t)
		return (((3 * ax * t) + (2 * bx)) * t) + cx
	end

	local function SolveCurveX(x, epsilon)
		local t0
		local t1
		local t2
		local x2
		local d2
		local i

		for i = 1, 8 do
			t2 = x
			x2 = SampleCurveX(t2) - x

			if epsilon > math.abs(x2)  then
				return t2
			end

			d2 = SampleCurveDerivativeX(t2)

			if math.abs(d2) < 1e-6 then
				break
			end

			t2 = t2 - (x2/d2)
		end

		t0 = 0
		t1 = 1
		t2 = x

		if t2 < t0 then
			return t0
		end

		if (t2 > t1) then
			return t1
		end

		while t0 < t1 do
			x2 = SampleCurveX(t2)
	
			if epsilon > math.abs(x2 - x) then
				return t2
			end

			if x > x2 then
				t0 = t2
			else
				t1 = t2
			end

			t2 = ((t1 - t0)/2) + t0
		end

		return t2
	end

	local function Solve(x, epsilon)
		return SampleCurveY(SolveCurveX(x, epsilon))
	end

	return function(x, duration)
		duration = duration or 400
		return Solve(x, SolveEpsilon(duration))
	end
end