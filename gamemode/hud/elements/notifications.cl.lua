NotificationContainer = NotificationContainer or Class.New(Element)

function NotificationContainer:Init(quadrant_or_props, props)
	local quadrant = isstring(quadrant_or_props) and quadrant_or_props
	local props = istable(quadrant_or_props) and quadrant_or_props or props

	NotificationContainer.super.Init(self, {
		layout_direction = DIRECTION_COLUMN,
		fit = true
	})

	local key = Property(props, "key", nil, true)
	local index = Property(props, "index", nil, true)
	local flash = Property(props, "flash", true, true)
	local animate = Property(props, "animate", true, true)
	Property(props, "duration", 3)

	if key then
		self.key = key

		local old_notif = NotificationService.stickies[key]

		if old_notif then
			old_notif:Finish()
		end

		NotificationService.stickies[key] = self
	end

	self:SetAttributes(props)

	if quadrant then
		if index then
			HUDService["quadrant_"..quadrant]:Add(index, self)
		else
			HUDService["quadrant_"..quadrant]:Add(self)
		end
	end

	if flash then
		self:Add(NotificationService.CreateFlash())
	end

	if animate then
		self:AnimateStart()
	end
end

function NotificationContainer:AnimateStart()
	self:SetAttributes {
		crop_bottom = 1,
		layout_crop_y = 1
	}

	self:AnimateAttribute("crop_bottom", 0, SAFE_FRAME)
	self:AnimateAttribute("layout_crop_y", 0)
end

function NotificationContainer:Finish()
	self:AnimateFinish {
		duration = ANIMATION_DURATION * 10,

		callback = function ()
			if self.key then
				local curr_notif = NotificationService.stickies[key]

				if curr_notif == self then
					NotificationService.stickies[self.key] = nil
				end
			end
		end,

		crop_bottom = 1,
		alpha = 0
	}
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
		fit = true
	})

	self.end_time = end_time

	if text and #text > 0 then
		self:Add(TextBar.New(text))
	end

	self.time = self:Add(TextBar.New(nil, {
		background_color = COLOR_GRAY,
		fill_color = false,
		text_color = false,
		font = "Countdown"
	}))

	if text and #text > 0 then
		self.time:SetAttributes {
			font = "TextBarSecondary"
		}
	else
		self.time:SetAttributes {
			padding_top = MARGIN * 1.5,
			padding_bottom = MARGIN * 2,
			padding_x = MARGIN * 4
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
