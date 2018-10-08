NotificationContainer = NotificationContainer or Class.New(Element)

function NotificationContainer:Init(children, duration, key)
	duration = duration or 3

	if duration == 0 then
		duration = nil
	end

	NotificationContainer.super.Init(self, {
		duration = duration,
		fit = true
	})

	if key then
		self.key = key

		local old_notif = NotificationService.stickies[key]

		if old_notif then
			old_notif:Finish()
		end
	
		NotificationService.stickies[key] = self
	end

	if Class.InstanceOf(children, Element) then 
		self:Add(children)
	else
		for _, child in pairs(children) do
			self:Add(child)
		end
	end

	self:Add(NotificationService.CreateFlash())
	self:AnimateStart()
end

function NotificationContainer:AnimateStart()
	self:SetAttributes {
		crop_bottom = 1,
		layout_crop_y = 1
	}

	self:AnimateAttribute("crop_bottom", 0, 1/60)
	self:AnimateAttribute("layout_crop_y", 0)
end

function NotificationContainer:AnimateFinish()
	self:AnimateAttribute("crop_bottom", 1, {
		duration = ANIMATION_DURATION * 10,

		callback = function ()
			if self.key then
				local curr_notif = NotificationService.stickies[key]

				if curr_notif == self then
					NotificationService.stickies[self.key] = nil
				end
			end

			NotificationContainer.super.Finish(self)
		end
	})

	self:AnimateAttribute("alpha", 0, ANIMATION_DURATION * 10)
end

function NotificationContainer:Finish()
	self:AnimateFinish()
end

AvatarNotification = AvatarNotification or Class.New(Element)

function AvatarNotification:Init(ply, text)
	AvatarNotification.super.Init(self, {
		width = BAR_WIDTH,
		fit_y = true
	})

	self:Add(TextBar.New(text, {
		width = BAR_WIDTH,
		fit_x = false,
		fit_y = true
	}))

	self:Add(AvatarBar.New(ply))
end

CountdownNotification = CountdownNotification or Class.New(Element)

function CountdownNotification:Init(end_time, text)
	CountdownNotification.super.Init(self, {
		width = BAR_WIDTH,
		fit_y = true
	})

	self.end_time = end_time

	if text and #text > 0 then
		self:Add(TextBar.New(text, {
			width = BAR_WIDTH,
			fit_x = false,
			fit_y = true
		}))
	end

	self.time = self:Add(TextBar.New(nil, {
		width = BAR_WIDTH,
		padding_y = MARGIN * 2,
		fit_x = false,
		fit_y = true,
		fill_color = true,
		font = "HUDMeterValue"
	}))

	if text then
		self.time:SetAttributes {
			background_color = COLOR_GRAY,
			fill_color = false,
			text_color = false
		}
	end
end

function CountdownNotification:Think()
	CountdownNotification.super.Think(self)

	local sec = math.ceil(math.max(self.end_time - CurTime(), 0))

	local text

	if sec >= 60 then
		text = string.Trim(string.FormattedTime(sec, "%2i:%02i"))
	elseif sec > 0 then
		text = sec
	else
		text = ""
	end

	self.time:SetText(text)

	if 5 > sec and sec ~= self.last_seconds then
		self.time:Add(NotificationService.CreateFlash())
	end

	self.last_seconds = sec
end
