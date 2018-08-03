-- # Util

local DefaultEase = CubicBezier(0, 0.5, 0.35, 1)

local function FrameMultiplier()
	return FrameTime() * 10
end

local function IsColor(color)
	return istable(color) and color.r and color.g and color.b
end


-- # Class

AnimatableValue = AnimatableValue or Class.New()

function AnimatableValue:Init(value, props)
	value = value or 0
	props = props or {}

	self.animations = {}
	self.current = value

	if props.smooth then
		self.smoothing = true
		self.smooth_multiplier = props.smooth_multiplier or 1
		self.smooth = value
		self.last = value
		self.new = value
	end

	local debounce = props.debounce

	if props.callback then
		debounce = debounce or 0.1
	end

	if debounce then
		self.checking_changes = true
		self.callback = props.callback
		self.debounce_time = debounce
		self.debounce = value
		self.last_change = value
		self.last_change_time = CurTime()
	end
end

function AnimatableValue:GetAnimationEndTime()
	local end_time = 0

	for _, anim in pairs(self.animations) do
		end_time = anim.end_time
	end

	return end_time
end

function AnimatableValue:AnimateTo(value, props_or_duration, ease, delay, finish, callback)
	local duration

	if istable(props_or_duration) then
		duration = props_or_duration.duration or 0.2
		ease = props_or_duration.ease or DefaultEase
		delay = props_or_duration.delay or 0
		finish = props_or_duration.finish
		callback = props_or_duration.callback
	else
		duration = props_or_duration or 0.2
		ease = ease or DefaultEase
		delay = delay or 0
	end

	local last_anim = self.animations[#self.animations]
	local cur_time = CurTime()

	local start_time

	if last_anim then
		start_time = last_anim.end_time
	else
		start_time = cur_time
	end

	table.insert(self.animations, {
		start_value = self.current,
		end_value = value,
		start_time = start_time + delay,
		end_time = start_time + duration + delay,
		ease = ease,
		delay = delay,
		finish = finish,
		callback = callback
	})

	return self
end

function AnimatableValue:Finish()
	self.animations = {}
	self:DisconnectFromHooks()
end

function AnimatableValue:Animate()
	local first_anim = self.animations[1]

	if first_anim then
		local time = math.TimeFraction(first_anim.start_time, first_anim.end_time, CurTime())
		local eased_time = first_anim.ease(time)
		local value = ((1 - eased_time) * first_anim.start_value) + (eased_time * first_anim.end_value)

		self.current = value

		if self.smoothing then
			self.smooth = value
		end

		if time >= 1 then
			table.remove(self.animations, 1)

			if first_anim.callback then
				first_anim.callback(first_anim)
			end

			if first_anim.finish then
				self:Finish()
			end
		end
	end
end

function AnimatableValue:DetectChanges()
	if CurTime() > (self.last_change_time + self.debounce_time) and self.last_change ~= self.current then
		self.debounce = self.current

		if self.callback then
			self.callback(self)
		end

		self.last_change = self.current
		self.last_change_time = CurTime()
	end
end

function AnimatableValue:Smooth()
	local ang = isangle(self.current)
	local color = IsColor(self.current)
	local mult = FrameMultiplier() * self.smooth_multiplier

	if ang then
		if (self.last.y < -90) and (self.current.y > 90) then
			self.last.y = self.last.y + 360
		elseif (self.last.y > 90) and (self.current.y < -90) then
			self.last.y = self.last.y - 360
		end
	end

	self.smooth = self.last

	if ang then
		self.new = Angle(((self.current.p * mult) + self.last.p)/(mult + 1), ((self.current.y * mult) + self.last.y)/(mult + 1), 0)
	elseif color then
		self.new = Color(((self.current.r * mult) + self.last.r)/(mult + 1), ((self.current.g * mult) + self.last.g)/(mult + 1), ((self.current.b * mult) + self.last.b)/(mult + 1), ((self.current.a * mult) + self.last.a)/(mult + 1))
	else
		self.new = ((self.current * mult) + self.last)/(mult + 1)
	end

	self.last = self.new
end

function AnimatableValue:Think()
	self:Animate()

	if self.checking_changes then
		self:DetectChanges()
	end

	if self.smoothing then
		self:Smooth()
	end
end
Class.AddHook(AnimatableValue, "Think")
