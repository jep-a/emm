ButtonBar = ButtonBar or Class.New(Element)

function ButtonBar:Init(props)
	props = props or {}

	ButtonBar.super.Init(self, {
		layout_justification_y = JUSTIFY_CENTER,
		fit_y = true,
		width = BAR_WIDTH,
		padding_x = MARGIN * 8,
		padding_top = MARGIN * 4,
		padding_bottom = MARGIN * 5,
		child_margin = MARGIN * 8,
		background_color = props.background and COLOR_GRAY or props.background_color,
		inherit_color = false,
		border = LINE_THICKNESS/2,
		border_color = props.color,
		border_alpha = 0,
		cursor = "hand",
		bubble_mouse = false,

		hover = {
			color = props.color,
			border_alpha = 255
		},

		press = {
			background_color = COLOR_GRAY_DARK,
			color = COLOR_BACKGROUND,
			border_color = COLOR_BACKGROUND
		},

		props.material and Element.New {
			width = BUTTON_ICON_SIZE,
			height = BUTTON_ICON_SIZE,
			crop_y = 0.1,
			material = props.material
		},

		Element.New {
			fit = true,
			font = "ButtonBar",
			text_justification = 4,
			text = string.upper(props.text)
		},

		props.divider and Element.New {
			layout = false,
			origin_position = true,
			origin_justification_x = JUSTIFY_CENTER,
			origin_justification_y = JUSTIFY_END,
			position_justification_x = JUSTIFY_CENTER,
			position_justification_y = JUSTIFY_END,
			width_percent = 1,
			height = 1,
			inherit_color = false,
			fill_color = true,
			color = COLOR_BACKGROUND_LIGHT,

			alpha = function ()
				return self.last and 0 or 255
			end
		}
	})

	self.on_click = props.on_click
end

function ButtonBar:OnMousePressed(mouse)
	ButtonBar.super.OnMousePressed(self, mouse)
	self.on_click(self, mouse)
end