HALF_ALPHA = 255/2
QUARTER_ALPHA = 255/4
ANIMATION_DURATION = 0.2

LINE_THICKNESS = 2
MARGIN = 4

CAMUI_SMOOTH_MULTIPLIER = 16

INDICATOR_WORLD_SIZE = 18
INDICATOR_ICON_SIZE = 32
INDICATOR_PERIPHERAL_SIZE = 40
INDICATOR_COASTER_SIZE = 150

COLUMN_WIDTH = 256

BAR_WIDTH = 256
BAR_HEIGHT = 64

BUTTON_ICON_SIZE = 32
LARGE_BUTTON_ICON_SIZE = 64

CHECKBOX_SIZE = 24

INPUT_HEIGHT = 128 + (MARGIN * 4)

SettingsService.New("cam_ui_smooth_multiplier", {
	type = "number",
	default = 1,
	min = 0,
	max = 100,
	help = "3D UI smoothing multiplier",
})

surface.CreateFont("TextBar", {
	font = "Roboto",
	size = 24,
	weight = 900
})

surface.CreateFont("TextBarSecondary", {
	font = "Roboto Mono",
	size = 24
})

surface.CreateFont("Header", {
	font = "Roboto",
	size = 26
})

surface.CreateFont("ButtonBar", {
	font = "Roboto Mono",
	size = 22,
	italic = true
})

surface.CreateFont("Info", {
	font = "Roboto",
	size = 22
})

surface.CreateFont("NumberInfo", {
	font = "Roboto Mono",
	size = 18,
	weight = 900
})

surface.CreateFont("Label", {
	font = "Roboto Mono",
	size = 16,
	italic = true
})

surface.CreateFont("InputLabel", {
	font = "Roboto",
	size = 16
})

surface.CreateFont("InputText", {
	font = "Roboto",
	size = 16
})