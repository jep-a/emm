TextInput = TextInput or Class.New(Element)

local TextInputPanel = {}

function TextInputPanel:Paint(w, h)
	local color = self.element:GetAttribute "text_color" or self.element:GetAttribute "color"

	self:DrawTextEntryText(color, COLOR_GRAY_LIGHTER, color)
end

function TextInputPanel:OnCursorEntered()
	self.element.panel:OnCursorEntered()
end

function TextInputPanel:OnCursorExited()
	self.element.panel:OnCursorExited()
end

function TextInputPanel:OnMousePressed(mouse)
	self.element.panel:OnMousePressed(mouse)
end

function TextInputPanel:OnLoseFocus()
	self.element:OnUnFocus()
end

vgui.Register("TextInputPanel", TextInputPanel, "DTextEntry")

function TextInput:Init(props)
	TextInput.super.Init(self, {
		fit_y = true,
		width = BAR_WIDTH,
		padding_left = MARGIN * 2,
		padding_y = MARGIN * 2,
		background_color = COLOR_GRAY,
		cursor = "beam",
		font = "Info",
		border = 2,
		border_alpha = 0,
		
		hover = {
			border_alpha = 255
		},

		text_line = Element.New {
			layout = false,
			overlay = true,
			origin_position = true,
			origin_justification_x = JUSTIFY_CENTER,
			origin_justification_y = JUSTIFY_END,
			position_justification_x = JUSTIFY_CENTER,
			position_justification_y = JUSTIFY_END,
			width_percent = 1,
			height = LINE_THICKNESS/2,
			fill_color = true,
			alpha = 0
		}
	})

	self.panel.text = self.panel:Add(vgui.Create "TextInputPanel")
	self.panel.text.element = self
	self.panel.text:SetFont(self:GetAttribute "font")
	self.panel.text:SetText(self:GetAttribute "text" or "")

	if props then
		self:SetAttributes(props)
		self.on_click = props.on_click
	end
end

function TextInput:OnMousePressed(mouse)
	TextInput.super.OnMousePressed(self, mouse)
	
	if self.on_click then
		self.on_click(self, mouse)
	end

	self:OnFocus(self)
end

function TextInput:OnFocus()
	self.panel.text:RequestFocus()
	hook.Run("TextEntryFocus", self)
	self.text_line:AnimateAttribute("alpha", 255)
end

function TextInput:OnUnFocus()
	hook.Run("TextEntryUnFocus", self)
	self.text_line:AnimateAttribute("alpha", 0)
end