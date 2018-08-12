NotificationService = NotificationService or {}


-- # Elements

function NotificationService.CreateFlash()
	local element = Element.New {
		layout = false,
		width_percent = 1,
		height_percent = 1,
		fill_color = true
	}

	element:AnimateAttribute("alpha", 0, {delay = 0.2})

	return element
end

Notification = Notification or Class.New(Element)

function Notification:Init(text)
	Notification.super.Init(self, {
		duration = 3,
		fit = true,
		text = text,
		font = "Notification"
	})

	self:Add(NotificationService.CreateFlash())
	self:StartAnimate()
end

function Notification:StartAnimate()
	self:SetAttribute("crop_bottom", 1)
	self:AnimateAttribute("crop_bottom", 0)
end

function Notification:FinishAnimate()
	self:AnimateAttribute("alpha", 0, 1)

	self:AnimateAttribute("crop_bottom", 1, {
		duration = 1,
		delay = 1,
		callback = function ()
			Notification.super.Finish(self)
		end
	})
end

function Notification:Finish()
	self:FinishAnimate()
end

AvatarNotification = AvatarNotification or Class.New(Element)

function AvatarNotification:Init(ply, text)
	AvatarNotification.super.Init(self, {
		duration = 3,
		fit = true,
	})

	self:Add(Element.New {
		width = BAR_WIDTH,
		fit_y = true,
		padding = MARGIN,
		fill_color = true,
		font = "Notification",
		text_justification = 5,
		text_color = COLOR_WHITE,
		text = text
	})

	self:Add(AvatarBar.New(ply))
	self:Add(NotificationService.CreateFlash())
	Notification.StartAnimate(self)
end

function AvatarNotification:Finish()
	Notification.FinishAnimate(self)
end


-- # Element

function NotificationService.PushText(text)
	HUDService.quadrant_c:Add(Notification.New(text))
end

function NotificationService.PushAvatarText(ply, text)
	HUDService.quadrant_b:Add(AvatarNotification.New(ply, text))
end