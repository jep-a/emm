-- # Util

local DefaultEase = CubicBezier(0, 0.66, 0.33, 1)

local function FrameMultiplier()
	return RealFrameTime() * 10
end


-- # Class

AnimatableValue = AnimatableValue or Class.New()

function AnimatableValue.New(...)
	local instance = Class.Instance(AnimatableValue, ...)

	if instance.generate or instance.checking_changes or instance.smoothing then
		table.insert(AnimatableValue.static.instances, instance)
		instance.thinker = true
	end

	return instance
end

function AnimatableValue.NewFromSetting(name, ...)
	local anim_v = AnimatableValue.New(SettingsService.Get(name), ...)
	anim_v:SetConvarAnimator(name)

	return anim_v
end

function AnimatableValue:Init(value, props)
	if EMM.debug then
		self.debug_trace = debug.traceback()
	end

	value = Default(value, 0)
	props = props or {}

	self.animations = {}
	self.current = value
	self.generate = props.generate

	if props.smooth then
		self.smoothing = true
		self.smooth_multiplier = props.smooth_multiplier or 1
		self.smooth_delta_only = props.smooth_delta_only
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

		if isnumber(debounce) then
			self.debounce_time = debounce
		else
			self.debounce_time = 0.1
		end

		self.debounce = value
		self.last_change = value
		self.last_change_time = CurTime()
	end

	self.animate_callback = props.animate_callback
	self.smooth_callback = props.smooth_callback
end

function AnimatableValue:GetAnimationEndTime()
	local end_time = 0

	for _, anim in pairs(self.animations) do
		end_time = anim.end_time
	end

	return end_time
end

function AnimatableValue:AnimateTo(value, props_or_duration, ease, delay)
	local instances = AnimatableValue.static.instances

	if not self.thinker and not table.HasValue(instances, self) then
		table.insert(instances, self)
	end

	local duration
	local finish
	local callback
	local animate_callback
	local stack

	if istable(props_or_duration) then
		duration = props_or_duration.duration or 0.2
		ease = props_or_duration.ease or DefaultEase
		delay = props_or_duration.delay or 0
		finish = props_or_duration.finish
		callback = props_or_duration.callback
		animate_callback = props_or_duration.animate_callback
		stack = props_or_duration.stack
	else
		duration = props_or_duration or 0.2
		ease = ease or DefaultEase
		delay = delay or 0
	end

	local last_anim = self.animations[#self.animations]
	local cur_time = CurTime()

	local start_time

	if stack and last_anim then
		start_time = last_anim.end_time
	else
		start_time = cur_time
	end

	local anim = {
		start_value = self.current,
		end_value = value,
		start_time = start_time + delay,
		end_time = start_time + duration + delay,
		ease = ease,
		delay = delay,
		finish = finish,
		animate_callback = animate_callback,
		callback = callback
	}

	if stack then
		table.insert(self.animations, anim)
	else
		self.animations = {anim}
	end

	return self
end

function AnimatableValue:Finish()
	if self.setting_hook then
		SettingsService.RemoveHook(self.setting_hook, Class.TableID(self))
	end

	self.animations = {}
	self:DisconnectFromHooks()
end

function AnimatableValue:SetConvarAnimator(name, ...)
	local anim_props = {...}

	self.setting_hook = name

	SettingsService.AddHook(name, Class.TableID(self), function (v)
		self:AnimateTo(v, unpack(anim_props))
	end)
end

function AnimatableValue:Animate()
	local first_anim = self.animations[1]

	if first_anim then
		local time = math.TimeFraction(first_anim.start_time, first_anim.end_time, CurTime())
		local eased_time = first_anim.ease(time)
		local inverted_eased_time = 1 - eased_time

		local value

		if IsColor(self.current) then
			value = Color(
				(inverted_eased_time * first_anim.start_value.r) + (eased_time * first_anim.end_value.r),
				(inverted_eased_time * first_anim.start_value.g) + (eased_time * first_anim.end_value.g),
				(inverted_eased_time * first_anim.start_value.b) + (eased_time * first_anim.end_value.b),
				(inverted_eased_time * first_anim.start_value.a) + (eased_time * first_anim.end_value.a)
			)
		else
			value = (inverted_eased_time * first_anim.start_value) + (eased_time * first_anim.end_value)
		end

		self.current = value

		if self.smoothing then
			self.smooth = value
		end

		if self.animate_callback then
			self.animate_callback(self)
		end

		if time >= 1 then
			if not self.thinker then
				self:DisconnectFromHooks()
			end

			table.remove(self.animations, 1)

			if first_anim.animate_callback then
				first_anim.animate_callback(self)
			end	

			if first_anim.callback then
				first_anim.callback(self)
			end

			if first_anim.finish then
				self:Finish()
			end
		end
	end
end

local cur_time = 0

hook.Add("Think", "AnimatableValue.CurTime", function ()
	cur_time = CurTime()
end)

function AnimatableValue:DetectChanges()
	if cur_time > (self.last_change_time + self.debounce_time) and self.last_change ~= self.current then
		self.debounce = self.current

		if self.callback then
			self.callback(self)
		end

		self.last_change = self.current
		self.last_change_time = CurTime()
	end
end

local function Smooth(mult, curr, last)
	return (last + (curr * mult))/(mult + 1)
end

function AnimatableValue:Smooth()
	local ang = isangle(self.current)
	local color = IsColor(self.current)
	local mult = FrameMultiplier() * self.smooth_multiplier

	local curr = self.current
	local last = self.last or curr

	if ang then
		if (last.y < -90) and (curr.y > 90) then
			last.y = last.y + 360
		elseif (last.y > 90) and (curr.y < -90) then
			last.y = last.y - 360
		end
	end

	if self.smooth_delta_only then
		self.smooth = curr - last
	else
		self.smooth = last
	end

	if ang then
		self.new = Angle(Smooth(mult, curr.p, last.p), Smooth(mult, curr.y, last.y), Smooth(mult, curr.r, last.r))
	elseif color then
		self.new = Color(Smooth(mult, curr.r, last.r), Smooth(mult, curr.g, last.g), Smooth(mult, curr.b, last.b), Smooth(mult, curr.a, last.a))
	else
		self.new = Smooth(mult, curr, last)
	end

	if self.smooth_callback and last ~= self.new then
		self.smooth_callback(self)
	end

	self.last = self.new
end

function AnimatableValue:Freeze(duration)
	self.frozen = true
	self.freeze_time = CurTime()
	self.freeze_duration = duration or 0.2
	self.smoothing = false
end

function AnimatableValue:UnFreeze()
	self.frozen = false
	self.smoothing = true
end

function AnimatableValue:Think()
	if self.generate then
		self.current = self.generate(self.current)
	end

	self:Animate()

	if self.checking_changes then
		self:DetectChanges()
	end

	if self.smoothing then
		self:Smooth()
	end

	if self.frozen and CurTime() > (self.freeze_time + self.freeze_duration) then
		self:UnFreeze()
	end
end
Class.AddHook(AnimatableValue, "Think")
