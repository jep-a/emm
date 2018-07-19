SmoothValueService = SmoothValueService or {}
SmoothValueService.values = SmoothValueService.values or {}


-- # Util

local DefaultEase = CubicBezier(0, 0.5, 0.35, 1)

local function FrameMultiplier()
	return (1/FrameTime() - 20)/60
end


-- # Class

SmoothValue = {}
SmoothValue.__index = SmoothValue

function SmoothValueService.CreateSmoothValue(value, smooth, callback)
	value = value or 0
	local id = #SmoothValueService.values + 1

	local tab = {}
	tab.id = id
	tab.animations = {}
	setmetatable(tab, SmoothValue)

	tab.current = value

	if smooth then
		tab.smoothing = true
		tab.smooth = value
		tab.last = value
		tab.new = value
	end

	if callback then
		tab.checking_changes = true
		tab.callback = callback
		tab.last_change_time = CurTime()
	end

	SmoothValueService.values[id] = tab

	return tab
end

function SmoothValue:To(value, props_or_duration, ease, delay, remove, callback)
	local duration

	if istable(props_or_duration) then
		duration = props_or_duration.duration or 0.2
		ease = props_or_duration.ease or DefaultEase
		delay = props_or_duration.delay or 0
		remove = props_or_duration.remove
		callback = props_or_duration.callback
	else
		duration = props_or_duration or 0.2
		ease = ease or DefaultEase
		delay = delay or 0
	end

	local cur_time = CurTime()

	table.insert(self.animations, {
		start_value = self.current,
		end_value = value,
		start_time = cur_time + delay,
		end_time = cur_time + duration + delay,
		ease = ease,
		delay = delay,
		remove = remove,
		callback = callback
	})

	return self
end

function SmoothValue:Remove()
	self.animations = {}
	SmoothValueService.values[self.id] = nil
end

function SmoothValue:AnimationThink()
	local anim = self.animations[1]

	if anim then
		local t = math.TimeFraction(anim.start_time, anim.end_time, CurTime())
		local eased_t = anim.ease(t)
		local value = ((1 - eased_t) * anim.start_value) + (eased_t * anim.end_value)

		self.current = value

		if self.smoothing then
			self.smooth = value
		end

		if t >= 1 then
			table.remove(self.animations, 1)

			if anim.callback then
				anim.callback(anim)
			end

			if anim.remove then
				self:Remove()
			end
		end
	end
end

function SmoothValue:ChangesThink()
	if CurTime() > (self.last_change_time + 0.2) and not (self.change_last == self.current) then
		self.callback(self)
		self.change_last = self.current
		self.last_change_time = CurTime()
	end
end

function SmoothValue:SmoothThink()
	local ang = isangle(self.current)
	local mult = FrameMultiplier()

	if ang then
		if (self.last.y < -90) and (self.current.y > 90) then
			self.last.y = self.last.y + 360
		elseif (self.last.y > 90) and (self.current.y < -90) then
			self.last.y = self.last.y - 360
		end
	end

	self.smooth = self.last

	if ang then
		self.new = Angle((self.current.p * mult + self.last.p)/(mult + 1), (self.current.y * mult + self.last.y)/(mult + 1), 0)
	else
		self.new = ((self.current * mult) + self.last)/(mult + 1)
	end

	self.last = self.new
end

function SmoothValue:Think()
	self:AnimationThink()

	if self.checking_changes then
		self:ChangesThink()
	end

	if self.smoothing then
		self:SmoothThink()
	end
end


-- # Smoothing

function SmoothValueService.SmoothValues()
	for _, v in pairs(SmoothValueService.values) do
		v:Think()
	end
end
hook.Add("Think", "SmoothValueService.SmoothValues", SmoothValueService.SmoothValues)