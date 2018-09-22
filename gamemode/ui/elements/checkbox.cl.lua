Checkbox = Class.New(Element)

local checkbox_material = Material("emm2/ui/check.png", "noclamp smooth")

function Checkbox:Init(bool, props)
	Checkbox.super.Init(self, {
		width = CHECKBOX_SIZE,
		height = CHECKBOX_SIZE,
		background_color = COLOR_GRAY_DARK,
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
			inherit_color = false,
			color = bool and COLOR_WHITE or COLOR_GRAY,
			material = checkbox_material,
		},
	})

	self.value = bool

	if props then
		self:SetAttributes(props)
		self.on_change = props.on_change
	end
end

function Checkbox:OnValueChanged(v)
	self.value = v
	self.check:AnimateAttribute("color", v and COLOR_WHITE or COLOR_GRAY)

	if self.on_change then
		self.on_change(self, v)
	end
end

function Checkbox:OnMousePressed(mouse)
	Checkbox.super.OnMousePressed(self, mouse)
	self:OnValueChanged(not self.value)
end

function Checkbox:SetValue(v)
	if v ~= self.value then 
		self:OnValueChanged(v)
	end
end