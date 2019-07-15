Checkbox = Class.New(Element)

local checkbox_material = Material("emm2/ui/check.png", "noclamp smooth")

function Checkbox:Init(bool, props)
	Checkbox.super.Init(self, {
		width = CHECKBOX_SIZE,
		height = CHECKBOX_SIZE,
		background_color = COLOR_GRAY_DARK,
		border = LINE_THICKNESS,
		border_alpha = 0,
		inherit_cursor = false,
		cursor = "hand",
		bubble_mouse = false,

		disabled = {
			background_color = COLOR_BLACK_CLEAR,
			border = 1,
			border_color = COLOR_GRAY_DARK,
			border_alpha = 255
		},

		hover = {
			border_alpha = 255
		},

		press = {
			border_alpha = 0
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
			alpha = bool and 255 or 0,
			material = checkbox_material
		},
	})

	self.value = bool
	
	if props then
		self:SetAttributes(props)
		self.read_only = props.read_only
		self.on_change = props.on_change

		if props.read_only then
			self:Disable()
		end
	end
end

function Checkbox:Disable()
	self.disabled = true
	self.panel:SetMouseInputEnabled(false)
	self:AnimateState "disabled"
end

function Checkbox:Enable()
	self.disabled = false
	self.panel:SetMouseInputEnabled(true)
	self:RevertState()
end

function Checkbox:OnValueChanged(v, no_callback)
	self.value = v
	self.check:AnimateAttribute("alpha", v and 255 or 0)

	if not no_callback and self.on_change then
		self.on_change(self, v)
	end
end

function Checkbox:OnMousePressed(mouse)
	Checkbox.super.OnMousePressed(self, mouse)
	self:OnValueChanged(not self.value)
end

function Checkbox:OnMouseEntered()
	if self.disabled then
		self.panel:SetMouseInputEnabled(false)
	else
		Checkbox.super.OnMouseEntered(self)
	end
end

function Checkbox:OnMouseExited()
	if not self.disabled then
		Checkbox.super.OnMouseExited(self)
	end
end

function Checkbox:SetValue(v, no_callback)
	if v ~= self.value then 
		self:OnValueChanged(v, no_callback)
	end
end