NotificationService = NotificationService or {}


-- # Elements

function NotificationService.CreateFlash()
	local element = Element.New {
		duration = ANIMATION_DURATION * 2,
		overlay = true,
		layout = false,
		width_percent = 1,
		height_percent = 1,
		fill_color = true
	}

	element:AnimateAttribute("alpha", 0, {delay = ANIMATION_DURATION})

	return element
end

NotificationContainer = NotificationContainer or Class.New(Element)

function NotificationContainer:Init(children, duration)
	NotificationContainer.super.Init(self, {
		duration = duration or 3,
		fit = true
	})

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
	self:SetAttribute("crop_bottom", 1)
	self:AnimateAttribute("crop_bottom", 0)
end

function NotificationContainer:AnimateFinish()
	self:AnimateAttribute("alpha", 0, 1)

	self:AnimateAttribute("crop_bottom", 1, {
		duration = 1,
		delay = 1,
		callback = function ()
			NotificationContainer.super.Finish(self)
		end
	})
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
		padding_bottom = MARGIN * 2,
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


-- # Element

function NotificationService.PushSideText(text)
	HUDService.quadrant_c:Add(NotificationContainer.New(TextBar.New(text, {
		padding = 0,
		fill_color = false
	})))
end

function NotificationService.PushText(text)
	HUDService.quadrant_b:Add(NotificationContainer.New(TextBar.New(text)))
end

function NotificationService.PushAvatarText(ply, text)
	HUDService.quadrant_b:Add(NotificationContainer.New(AvatarNotification.New(ply, text)))
end

function NotificationService.PushCountdown(time, text)
	HUDService.quadrant_b:Add(NotificationContainer.New(CountdownNotification.New(time, text), time - CurTime()))
end

local function FinishNotificationContainer(element)
	if Class.InstanceOf(element, NotificationContainer) then
		element:Finish()
	end
end

function NotificationService.Clear(lobby, ply)
	if not lobby or IsLocalPlayer(ply) then
		for _, element in pairs(HUDService.quadrant_b.children) do
			FinishNotificationContainer(element)
		end

		for _, element in pairs(HUDService.quadrant_c.children) do
			FinishNotificationContainer(element)
		end
	end
end
hook.Add("LocalLobbyPlayerLeave", "NotificationService.Clear", NotificationService.Clear)