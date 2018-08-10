NotificationService = NotificationService or {}

Notification = Notification or Class.New(Element)

function Notification:Init(text)
	self.super.Init(self, {
		duration = 3,
		fit = true,
		text = text,
		font = "Notification"
	})

	self:SetAttribute("crop_bottom", 1)
	self:AnimateAttribute("crop_bottom", 0)

	self.flash = self:Add(Element.New {
		layout = false,
		width_percent = 1,
		height_percent = 1,
		fill_color = true
	})

	self.flash:AnimateAttribute("alpha", 0, {delay = 0.2})
end

function Notification:Finish()
	self:AnimateAttribute("alpha", 0, 1)

	self:AnimateAttribute("crop_bottom", 1, {
		duration = 1,
		delay = 1,
		callback = function ()
			self.super.Finish(self)
		end
	})
end

function NotificationService.CreateText(text)
	HUDService.quadrant_c:Add(Notification.New(text))
end