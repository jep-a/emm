Timer = Timer or Class.New()

function Timer:Init(delay, props_or_func)
	local props
	local callback
	local cur_time = CurTime()

	if istable(props_or_func) then
		props = props_or_func
	elseif isfunction(props_or_func) then
		callback = props_or_func
	else
		props = {}
	end

	self.counting = true
	self.start_time = cur_time
	self.end_time = cur_time + delay
	self.timeleft = delay
	self.callback = callback
end

function Timer:Pause()
	self.counting = false
end

function Timer:Resume()
	self.counting = true
end

function Timer:Count()
	local cur_time = CurTime()

	if self.counting then
		if cur_time > self.end_time then
			if self.callback then
				self.callback(self)
			end

			self:Finish()
		else
			self.timeleft = self.end_time - cur_time
		end
	else
		self.end_time = cur_time + self.timeleft
	end
end

function Timer:Think()
	self:Count()
end
Class.AddHook(Timer, "Think")

function Timer:Finish()
	self.callback = nil
	self:DisconnectFromHooks()
end
