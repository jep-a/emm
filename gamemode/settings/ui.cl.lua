SettingsUIService = SettingsUIService or {}

function SettingsUIService.Init()
	SettingsUIService.container = SettingsUIService.CreateContainer()
	SettingsUIService.main_category = SettingsUIService.container:AddInner(SettingsUIService.CreateCategory())

	for _, k in pairs(SettingsService.ordered_convars) do
		local convar = SettingsService.convars[k]

		SettingsUIService.main_category:Add(InputBar.New(convar.help, convar.type, SettingsService.Get(k), {
			on_change = function (input, v)
				SettingsService.Set(k, v)
				SettingsUIService.container.panel:MoveToFront()
			end
		}))
	end
end
hook.Add("InitUI", "SettingsUIService.Init", SettingsUIService.Init)

function SettingsUIService.Reload()
	SettingsUIService.container:Finish()
	SettingsUIService.Init()
end
hook.Add("OnReloaded", "SettingsUIService.Reload", SettingsUIService.Reload)

function SettingsUIService.Open()
	RememberCursorPosition()
	RestoreCursorPosition()

	if SettingsUIService.focused then
		SettingsUIService.UnFocus()
	end

	SettingsUIService.open = true

	gui.EnableScreenClicker(true)
	SettingsUIService.container.panel:SetMouseInputEnabled(true)
	SettingsUIService.container.panel:MoveToFront()
	SettingsUIService.container:AnimateAttribute("alpha", 255)
	hook.Run "OnSettingsUIOpen"
end

function SettingsUIService.Close()
	RememberCursorPosition()

	if not SettingsUIService.focused then
		SettingsUIService.open = false

		gui.EnableScreenClicker(false)
		SettingsUIService.container.panel:SetMouseInputEnabled(false)
		SettingsUIService.container.panel:MoveToBack()
		SettingsUIService.container:AnimateAttribute("alpha", 0)
		hook.Run "OnSettingsUIClose"
	end
end

function GM:OnContextMenuOpen()
	SettingsUIService.Open()

	return true
end

function GM:OnContextMenuClose()
	SettingsUIService.Close()

	return true
end

function SettingsUIService.Focus()
	SettingsUIService.focused = true
	SettingsUIService.container.panel:MakePopup()
end

function SettingsUIService.UnFocus()
	SettingsUIService.focused = false
	SettingsUIService.container.panel:SetKeyboardInputEnabled(false)
end

function SettingsUIService.FocusTextEntry(element)
	if element:HasParent(SettingsUIService.container) then
		SettingsUIService.Focus()
	end
end
hook.Add("TextEntryFocus", "SettingsUIService.FocusTextEntry", SettingsUIService.FocusTextEntry)

function SettingsUIService.UnFocusTextEntry(element)
	if SettingsUIService.focused then
		SettingsUIService.UnFocus()
	end
end
hook.Add("TextEntryUnFocus", "SettingsUIService.UnFocusTextEntry", SettingsUIService.UnFocusTextEntry)