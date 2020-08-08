UIService = UIService or {}
UIService.menus = UIService.menus or {}

function UIService.Register(name, service, props)
	table.Merge(service, props)

	UIService.menus[name] = {}
	UIService.menus[name].service = service
	UIService.menus[name].properties = props

	local function MenuHook()
		local GM = GM or GAMEMODE

		if props.toggle_hook then
			hook.Add(props.toggle_hook, name, function ()
				if service.active then
					service.Close()
				else
					service.Open()
				end
			end)
		end

		if props.open_hook then
			GM[props.open_hook] = function ()
				UIService.Open(name)

				return true
			end
		end

		if props.close_hook then
			GM[props.close_hook] = function ()
				UIService.Close(name)

				return true
			end
		end
	end

	hook.Add("Initialize", "UIService.Add"..name.."MenuHooks", MenuHook)
	hook.Add("OnReloaded", "UIService.Reload"..name.."MenuHooks", MenuHook)
end

function UIService.Open(name)
	RememberCursorPosition()
	RestoreCursorPosition()

	local menu = UIService.menus[name]

	if menu.focused then
		UIService.UnFocus(menu)
	end

	if menu.active then

	else
		menu.active = true
		menu.service.Init()

		local container = menu.service.container

		container.panel:SetMouseInputEnabled(true)
		container.panel:MoveToFront()
		container:AnimateAttribute("alpha", 255)

		gui.EnableScreenClicker(true)
	end
end

function UIService.Close(name)
	RememberCursorPosition()

	local menu = UIService.menus[name]

	if not menu.focused then
		menu.active = false

		local container = menu.service.container

		container.panel:SetMouseInputEnabled(false)
		container.panel:MoveToBack()

		container:AnimateAttribute("alpha", 0, {callback = function ()
			container:Finish()
		end})

		gui.EnableScreenClicker(false)
	end
end

function UIService.Active(name)
	return UIService.menus[name].active
end

function UIService.Focus(menu)
	menu.focused = true
	menu.service.container.panel:MakePopup()
end

function UIService.UnFocus(menu)
	menu.focused = false
	menu.service.container.panel:SetKeyboardInputEnabled(false)
end

function UIService.FocusTextEntry(element)
	for _, menu in pairs(UIService.menus) do
		if element:HasParent(menu.service.container) then
			UIService.Focus(menu)

			break
		end
	end
end
hook.Add("TextEntryFocus", "UIService.FocusTextEntry", UIService.FocusTextEntry)

function UIService.UnFocusTextEntry(element)
	for _, menu in pairs(UIService.menus) do
		if element:HasParent(menu.service.container) then
			UIService.UnFocus(menu)

			break
		end
	end
end
hook.Add("TextEntryUnFocus", "UIService.UnFocusTextEntry", UIService.UnFocusTextEntry)