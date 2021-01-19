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
		return NotificationContainer.New("c", {
			key = key,
			notification = TextBar.New(text, {
				padding = 0,
				fill_color = false
			})
		})
	end
end

function NotificationService.PushText(text, key)
	if NotificationService.Visible() then
		return NotificationContainer.New("b", {
			key = key,
			notification = TextBar.New(text)
		})
	end
end

function NotificationService.PushAvatarText(ply, text, key)
	if NotificationService.Visible() then
		return NotificationContainer.New("b", {
			key = key,
			notification = AvatarNotification.New(ply, text)
		})
	end
end

function NotificationService.PushCountdown(time, text, key, i)
	if NotificationService.Visible() then
		return NotificationContainer.New("a", {
			key = key,
			index = i,
			notification = CountdownNotification.New(time, text),
			duration = time - CurTime()
		})
	end
end

function NotificationService.PushMeter(props, key, i)
	if NotificationService.Visible() then
		return NotificationContainer.New("b", {
			key = key,
			index = i,
			duration = 0,
			meter = HUDMeter.New(table.Merge({
				width_percent = 1,
				top_layout = true,
				padding_bottom = MARGIN * 4
			}, props)),
			fill_x = false,
			width_percent = HUD_METER_SIZE,
			layout_justification_x = JUSTIFY_CENTER,
			child_margin = MARGIN * 4
		})
	end
end

function NotificationService.PushMetaText(text, key, i)
	if NotificationService.Visible() then
		return NotificationContainer.New("a", {
			key = key,
			index = i,
			duration = 0,
			notification = TextBar.New(text)
		})
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
		for _, element in pairs(HUDService.quadrant_a.children) do
			FinishNotificationContainer(element)
		end

		for _, element in pairs(HUDService.quadrant_b.children) do
			FinishNotificationContainer(element)
		end

		for _, element in pairs(HUDService.quadrant_c.children) do
			FinishNotificationContainer(element)
		end
	end
end
hook.Add("LocalLobbyPlayerLeave", "NotificationService.Clear", NotificationService.Clear)