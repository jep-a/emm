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

UIService.Register("Settings", SettingsUIService, {
	open_hook = "OnContextMenuOpen",
	close_hook = "OnContextMenuClose",
})