NotificationService = NotificationService or {}
NotificationService.stickies = NotificationService.stickies or {}

function NotificationService.CreateFlash(duration)
	local element = Element.New {
		duration = duration or (ANIMATION_DURATION * 2),
		overlay = true,
		layout = false,
		width_percent = 1,
		height_percent = 1,
		fill_color = true
	}

	element:AnimateAttribute("alpha", 0)

	return element
end

function NotificationService.Visible()
	return SettingsService.Get "show_hud" and SettingsService.Get "show_notifications"
end

function NotificationService.PushSideText(text)
	if NotificationService.Visible() then
		return HUDService.quadrant_c:Add(NotificationContainer.New(TextBar.New(text, {
			padding = 0,
			fill_color = false
		})))
	end
end

function NotificationService.PushText(text)
	if NotificationService.Visible() then
		return HUDService.quadrant_b:Add(NotificationContainer.New(TextBar.New(text)))
	end
end

function NotificationService.PushAvatarText(ply, text)
	if NotificationService.Visible() then
		return HUDService.quadrant_b:Add(NotificationContainer.New(AvatarNotification.New(ply, text)))
	end
end

function NotificationService.PushCountdown(time, text, key)
	if NotificationService.Visible() then
		return HUDService.quadrant_b:Add(NotificationContainer.New(CountdownNotification.New(time, text), time - CurTime(), key))
	end
end

function NotificationService.PushMetaText(text, key, i)
	if NotificationService.Visible() then
		local notification = NotificationContainer.New(TextBar.New(text), 0, key)

		if i then
			HUDService.quadrant_a:Add(i, notification)
		else
			HUDService.quadrant_a:Add(notification)
		end

		return notification
	end
end

local function FinishNotificationContainer(element)
	if Class.InstanceOf(element, NotificationContainer) then
		element:Finish()
	end
end

function NotificationService.FinishSticky(k)
	if NotificationService.stickies[k] then
		NotificationService.stickies[k]:Finish()
	end
end

function NotificationService.Clear(lobby, ply)
	if NotificationService.Visible() and not lobby or IsLocalPlayer(ply) then
		for _, element in pairs(HUDService.quadrant_b.children) do
			FinishNotificationContainer(element)
		end

		for _, element in pairs(HUDService.quadrant_c.children) do
			FinishNotificationContainer(element)
		end
	end
end
hook.Add("LocalLobbyPlayerLeave", "NotificationService.Clear", NotificationService.Clear)