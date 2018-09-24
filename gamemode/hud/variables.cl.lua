HUD_PADDING_X = 256
HUD_PADDING_Y = 16

HUD_LINE_THICKNESS = 4

HUD_METER_SIZE = 3/4
HUD_ICON_SIZE = 64

HUD_MIDDLE_DISTANCE = 10.75

HUD_SIDE_ANGLE = 10
HUD_SIDE_DISTANCE = 15

HUD_METER_VALUE_TEXT_SIZE = 36
HUD_METER_VALUE_TEXT_MARGIN = HUD_METER_VALUE_TEXT_SIZE/18
HUD_METER_VALUE_TEXT_SMALL_SIZE = 22

HUD_SPEED_METER_DIVIDER = 5000

CROSSHAIR_METER_VALUE_TEXT_SIZE = 16
CROSSHAIR_METER_VALUE_TEXT_SMALL_SIZE = 12

CROSSHAIR_CONTAINER_SIZE = 200

CROSSHAIR_METER_ARC_PADDING = CROSSHAIR_METER_VALUE_TEXT_SIZE + LINE_THICKNESS
CROSSHAIR_METER_ARC_LENGTH = 32
CROSSHAIR_METER_ARC_ANGLE = 90

CROSSHAIR_LINES_SIZE = 300
CROSSHAIR_LINES_GAP = 3
CROSSHAIR_LINE_THICKNESS = 3

SettingsService.New("emm_hud_line_thickness", {
	type = "number",
	default = 4,
	round = true,
	min = 1,
	max = 8,
	help = "HUD meter line thickness (pixels)"
})

SettingsService.New("emm_crosshair_size", {
	type = "number",
	default = 24,
	round = true,
	min = 10,
	max = 512,
	help = "Crosshair size (pixels)"
})

SettingsService.New("emm_crosshair_gap", {
	type = "number",
	default = 3,
	round = true,
	min = 0,
	max = 64,
	help = "Crosshair gap (pixels)"
})

SettingsService.New("emm_crosshair_meter_radius", {
	type = "number",
	default = 150,
	round = true,
	min = 32,
	max = 512,
	help = "Crosshair meter radius (pixels)"
})

SettingsService.New("emm_crosshair_meter_arc_length", {
	type = "number",
	default = 32,
	round = true,
	min = 8,
	max = 90,
	help = "Crosshair meter arc length (degrees)"
})

surface.CreateFont("HUDMeterValue", {
	font = "Roboto Mono",
	size = HUD_METER_VALUE_TEXT_SIZE,
	weight = 700
})

surface.CreateFont("HUDMeterValueSmall", {
	font = "Roboto Mono",
	size = HUD_METER_VALUE_TEXT_SMALL_SIZE,
	weight = 700
})

surface.CreateFont("CrosshairMeterValue", {
	font = "Roboto Mono",
	size = CROSSHAIR_METER_VALUE_TEXT_SIZE,
	weight = 700
})

surface.CreateFont("CrosshairMeterValueSmall", {
	font = "Roboto Mono",
	size = CROSSHAIR_METER_VALUE_TEXT_SMALL_SIZE
})
