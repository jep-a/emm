HUD_LINE_THICKNESS = 2

HUD_METER_SIZE = 3/4
HUD_ICON_SIZE = 64

HUD_MIDDLE_DISTANCE = 0

HUD_SIDE_ANGLE = 35
HUD_SIDE_DISTANCE = 0

HUD_SPEED_METER_DIVIDER = 5000

CROSSHAIR_METER_ARC_ANGLE = 90
CROSSHAIR_LINE_THICKNESS = 3

local function ReloadHUD()
	HUDService.Reload()
	IndicatorService.Reload(true)
end

SettingsService.New("show_hud", {
	default = true,
	help = "Show HUD",
	callback = ReloadHUD
})

SettingsService.New("show_hud_meters", {
	default = true,
	help = "Show HUD meters",
	callback = ReloadHUD
})

SettingsService.New("show_crosshair", {
	default = true,
	help = "Show crosshair",
	callback = ReloadHUD
})

SettingsService.New("show_crosshair_meters", {
	help = "Show crosshair meters",
	callback = ReloadHUD
})

SettingsService.New("show_nametags", {
	default = true,
	help = "Show nametags"
})

SettingsService.New("show_indicators", {
	default = true,
	help = "Show indicators",

	callback = function ()
		IndicatorService.Reload(true)
	end
})

SettingsService.New("show_outlines", {
	default = true,
	help = "Show indicator outlines"
})

SettingsService.New("show_keys", {
	default = false,
	help = "Show key echoes",
	callback = ReloadHUD
})

SettingsService.New("show_notifications", {
	default = true,
	help = "Show notifications",
	callback = ReloadHUD
})

SettingsService.New("hud_padding_x", {
	type = "number",
	default = 16,
	round = true,
	snap = 8,
	min = 0,
	max = 256,
	help = "HUD horizontal padding (pixels)"
})

SettingsService.New("hud_padding_y", {
	type = "number",
	default = 16,
	round = true,
	snap = 8,
	min = 0,
	max = 256,
	help = "HUD vertical padding (pixels)"
})

SettingsService.New("hud_angle", {
	type = "number",
	default = 5,
	min = 0,
	max = 35,
	help = "HUD side angles (degrees)",
	callback = ReloadHUD
})

SettingsService.New("crosshair_size", {
	type = "number",
	default = 24,
	round = true,
	min = 10,
	max = 512,
	help = "Crosshair size (pixels)"
})

SettingsService.New("crosshair_gap", {
	type = "number",
	default = 3,
	round = true,
	min = 0,
	max = 64,
	help = "Crosshair gap (pixels)"
})

SettingsService.New("crosshair_meter_radius", {
	type = "number",
	default = 40,
	round = true,
	min = 32,
	max = 512,
	help = "Crosshair meter radius (pixels)"
})

SettingsService.New("crosshair_meter_arc_length", {
	type = "number",
	default = 40,
	round = true,
	min = 0,
	max = 90,
	help = "Crosshair meter arc length (degrees)"
})

surface.CreateFont("Countdown", {
	font = "Roboto Mono",
	size = 36
})

surface.CreateFont("HUDMeterValue", {
	font = "Roboto Mono",
	size = 34
})

surface.CreateFont("HUDMeterValueSmall", {
	font = "Roboto Mono",
	size = 24
})

surface.CreateFont("CrosshairMeterValue", {
	font = "Roboto Mono",
	size = 16
})

surface.CreateFont("CrosshairMeterValueSmall", {
	font = "Roboto Mono",
	size = 12
})

surface.CreateFont("KeyEcho", {
	font = "Roboto",
	size = 42
})

surface.CreateFont("KeyEchoSmall", {
	font = "Roboto Mono",
	size = 14,
	weight = 900
})

surface.CreateFont("Nametag", {
	font = "Roboto Mono Bold Italic",
	size = 16
})
