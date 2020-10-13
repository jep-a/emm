Timer = Timer or Class.New()

local cur_time = 0

hook.Add("Think", "Timer.CurTime", function ()
	cur_time = CurTime()
end)

function Timer:Init(delay, props)
	props = props or {}

	self.counting = true
	self.start_time = cur_time
	self.end_time = cur_time + delay
	self.timeleft = delay
	self.callback = props.callback
end

function Timer:Count()
	if cur_time > self.end_time then
		if self.callback then
			self.callback(self)
		end

		self:Finish()
	elseif self.counting then
		self.timeleft = math.max(cur_time - self.end_time, 1)
	else
		self.end_time = cur_time + self.timeleft
	end
end

function Timer:Think()
	self:Count()
end
Class.AddHook(Timer, "Think")
