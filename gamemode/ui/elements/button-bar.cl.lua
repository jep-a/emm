ButtonBar = ButtonBar or Class.New(Element)

function ButtonBar:Init(props)
	props = props or {}

	ButtonBar.super.Init(self, {
		layout_justification_y = JUSTIFY_CENTER,
		width = BAR_WIDTH,
		height = BAR_HEIGHT,
		padding_x = 32,
		child_margin = 32,
		background_color = props.background and COLOR_GRAY or props.background_color,
		inherit_color = false,
		fill_color = props.fill_color,
		color = props.fill_color and props.color,
		border = LINE_THICKNESS,
		border_color = props.fill_color and COLOR_BACKGROUND or props.color,
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
			material = props.material,
			inherit_color = props.fill_color and false,
			color = props.fill_color and COLOR_BACKGROUND
		},

		Element.New {
			fit = true,
			font = "ButtonBar",
			text_justification = 4,
			text = string.upper(props.text),
			text_color = props.fill_color and COLOR_BACKGROUND
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

	if self:GetAttribute "fill_color" then
		self:SetAttribute("text_color", COLOR_BACKGROUND)
	end
end

function ButtonBar:OnMousePressed(mouse)
	ButtonBar.super.OnMousePressed(self, mouse)
	self.on_click(self, mouse)
end