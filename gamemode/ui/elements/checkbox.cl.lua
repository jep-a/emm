Checkbox = Class.New(Element)

local checkbox_material = Material("emm2/ui/check.png", "noclamp smooth")

function Checkbox:Init(bool)
	Checkbox.super.Init(self, {
		width = INPUT_HEIGHT,
		height = INPUT_HEIGHT,
		background_color = COLOR_GRAY,
		border = LINE_THICKNESS/2,
		border_color = COLOR_WHITE,
		border_alpha = 0,
		cursor = "hand",
		bubble_mouse = false,

		hover = {
			border_alpha = 255
		},

		press = {
			background_color = COLOR_GRAY_DARK,
			border_color = COLOR_BACKGROUND
		},

		check = Element.New {
			layout = false,
			origin_position = true,
			origin_justification_x = JUSTIFY_CENTER,
			origin_justification_y = JUSTIFY_CENTER,
			position_justification_x = JUSTIFY_CENTER,
			position_justification_y = JUSTIFY_CENTER,
			width = BUTTON_ICON_SIZE,
			height = BUTTON_ICON_SIZE,
			crop_top = 0.075,
			inherit_color = false,
			color = bool and COLOR_WHITE or COLOR_GRAY_LIGHT,
			material = checkbox_material,
		},
	})

	self.value = bool
end

function Checkbox:OnMousePressed(mouse)
	Checkbox.super.OnMousePressed(self, mouse)

	self.value = not self.value
	self.check:AnimateAttribute("color", self.value and COLOR_WHITE or COLOR_GRAY_LIGHT)
end
