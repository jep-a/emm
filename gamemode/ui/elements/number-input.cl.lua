NumberInput = NumberInput or Class.New(Element)

local NumberInputPanel = {}

function NumberInputPanel:Init()
	self:SetUpdateOnType(true)
end

function NumberInputPanel:Paint(w, h)
	local attr = self.element.attributes
	local color = attr.text_color and attr.text_color.current or self.element:GetColor()

	self:DrawTextEntryText(color, COLOR_GRAY_LIGHTER, color)
end

function NumberInputPanel:AllowInput(string)
	local allowed

	local is_num = string.find(string, "[%d%.-]")

	if is_num then
		allowed = true
	else
		allowed = false
	end

	return not allowed
end

function NumberInputPanel:OnValueChange(v)
	self.element:OnValueChanged(v)
end

function NumberInputPanel:OnCursorEntered()
	self.element.panel:OnCursorEntered()
end

function NumberInputPanel:OnCursorExited()
	self.element.panel:OnCursorExited()
end

function NumberInputPanel:OnMousePressed(mouse)
	self.element.panel:OnMousePressed(mouse)
end

function NumberInputPanel:OnLoseFocus()
	self.element:OnUnFocus()
end

vgui.Register("NumberInputPanel", NumberInputPanel, "DTextEntry")

local offset = 2

function NumberInput:Init(text, props)
	NumberInput.super.Init(self, {
		width_percent = 1,
		height_percent = 1,
		padding_left = 2,
		background_color = COLOR_GRAY_DARK,
		cursor = "beam",
		font = "NumberInfo",
		border = 2,
		border_alpha = 0,

		disabled = {
			background_color = COLOR_BLACK_CLEAR,
			border = 1,
			border_color = COLOR_GRAY_DARK,
			border_alpha = 255
		},

		hover = {
			border_alpha = 255
		},

		text_line = TextInput.CreateTextLine()
	})

	self.value = tostring(text)
	self.panel.text = self.panel:Add(vgui.Create "NumberInputPanel")
	TextInput.SetupPanel(self, text)

	if props then
		self:SetAttributes(props)
		self.read_only = props.read_only
		self.on_change = props.on_change
		self.on_click = props.on_click

		if props.read_only then
			self:Disable()
		end
	end
end

function NumberInput:Disable()
	TextInput.Disable(self)
end

function NumberInput:Enable()
	TextInput.Enable(self)
end

function NumberInput:OnValueChanged(v, no_callback)
	local validated_v = tonumber(v) and v or tostring(0)

	self.value = validated_v

	if not no_callback and self.on_change then
		self.on_change(self, validated_v)
	end
end

function NumberInput:SetValue(v, no_callback)
	self.panel.text:SetText(v)
	self.panel.text:OnValueChange(v, no_callback)
end

function NumberInput:OnMousePressed(mouse)
	NumberInput.super.OnMousePressed(self, mouse)

	if self.on_click then
		self.on_click(self, mouse)
	end

	self:OnFocus(self)
end

function NumberInput:OnMouseEntered()
	TextInput.OnMouseEntered(self)
end

function NumberInput:OnMouseExited()
	TextInput.OnMouseExited(self)
end

function NumberInput:OnFocus()
	self.panel.text:RequestFocus()
	hook.Run("TextEntryFocus", self)
	self.text_line:AnimateAttribute("alpha", 255)
end

function NumberInput:OnUnFocus()
	hook.Run("TextEntryUnFocus", self)
	self.text_line:AnimateAttribute("alpha", 0)
end