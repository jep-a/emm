TimeInput = TimeInput or Class.New(Element)

local TimeInputPanel = {}

local max_time_digits = 6

local function ZeroString(len)
	len = len or max_time_digits

	local digits = ""

	for i = 1, len do
		digits = digits.."0"
	end

	return digits
end

function TimeInputPanel:Init()
	self:SetMouseInputEnabled(false)
	self:SetUpdateOnType(true)
	
	self.time = "0"
	self.old_caret_pos = max_time_digits
	self.last_caret_pos_change = CurTime()
	
	self:OffsetCaretPos()
end

function TimeInputPanel:AllowInput(string)
	local allowed

	local is_num = string.find(string, "%d")

	if is_num then
		allowed = true
	else
		allowed = false
	end

	return not allowed
end

function TimeInputPanel:FormatDigits(digits)
	local trimmed_digits = string.TrimLeft(digits, "0")
	local digits_len = #trimmed_digits

	local time

	if tonumber(digits) == 0 then
		time = ""
	elseif 2 >= digits_len then
		time = trimmed_digits
	else
		local start = digits_len - 1

		for i = start, 0, -2 do
			local pair = trimmed_digits[i]..trimmed_digits[i + 1]
			
			if i == start then
				time = pair
			else
				time = pair..":"..time
			end
		end
	end

	return time
end

function TimeInputPanel:OnValueChange(value)
	local text = value
	local value_len = #value
	local caret_pos = self:GetCaretPos()

	if value_len > max_time_digits then
		local trim = max_time_digits - (value_len + 1)

		if (max_time_digits + 1) > caret_pos then
			text = string.Left(value, trim)
		else
			text = string.Right(value, trim)
			caret_pos = caret_pos - 1
		end
	elseif max_time_digits > value_len then
		text = ZeroString(max_time_digits - value_len)..text
		caret_pos = caret_pos + 1
	end

	self:SetText(text)
	self:SetCaretPos(caret_pos)
	self:OffsetCaretPos()

	self.time = self:FormatDigits(text)
end

function TimeInputPanel:ClampCaretPos()
	local caret_pos = self:GetCaretPos()

	self.non_zero_i = string.find(self:GetText(), "[^0]")

	if self.non_zero_i then
		caret_pos = math.max(caret_pos, self.non_zero_i - 1)
	else
		caret_pos = max_time_digits
	end

	self:SetCaretPos(caret_pos)
end

function TimeInputPanel:GenerateNewCaretPos()
	local caret_pos = self:GetCaretPos()
	local non_zero_i = self.non_zero_i or (max_time_digits + 1)
	local trimmed_caret_pos = caret_pos - non_zero_i + 1

	self.caret_pos_after_colon = trimmed_caret_pos

	if #self:GetText() > 2 then
		local offset_base

		if ((non_zero_i - 1) % 2) == 0 then
			offset_base = trimmed_caret_pos
		else
			offset_base = trimmed_caret_pos + 1
		end

		self.caret_pos_after_colon = trimmed_caret_pos + math.max(math.Round(offset_base/2) - 1, 0)
	end
end

function TimeInputPanel:OffsetCaretPos()
	self:ClampCaretPos()
	self:GenerateNewCaretPos()
end

function TimeInputPanel:PreventLetters()
	local text = self:GetText()

	if string.find(text, "[^%d]") then
		self:SetText(ZeroString())
		self.time = "0"
	end
end

function TimeInputPanel:Think()
	self:PreventLetters()

	if self:HasFocus() then
		local caret_pos = self:GetCaretPos()

		if caret_pos ~= self.old_caret_pos then
			self:OffsetCaretPos()
			self.old_caret_pos = caret_pos
			self.last_caret_pos_change = CurTime()
		end
	end
end

function TimeInputPanel:Paint(w, h)
	local color = self.element:GetAttribute "text_color" or self.element:GetAttribute "color"

	surface.SetFont(self:GetFont())
	surface.SetTextColor(color)
	surface.SetTextPos(2, 0)
	surface.DrawText(self.time)

	local number_w, number_h = surface.GetTextSize "0"

	surface.SetDrawColor(color)

	if self:HasFocus() and math.Round((CurTime() - self.last_caret_pos_change) % 1) == 0 then
		surface.DrawRect((number_w * self.caret_pos_after_colon) + 2, 0, LINE_THICKNESS/2, h - MARGIN)
	end
end

function TimeInputPanel:OnCursorEntered()
	self.element.panel:OnCursorEntered()
end

function TimeInputPanel:OnCursorExited()
	self.element.panel:OnCursorExited()
end

function TimeInputPanel:OnMousePressed(mouse)
	self.element.panel:OnMousePressed(mouse)
end

function TimeInputPanel:OnLoseFocus()
	self.element:OnUnFocus()
end

vgui.Register("TimeInputPanel", TimeInputPanel, "DTextEntry")

function TimeInput:Init(props)
	TimeInput.super.Init(self, {
		fit_y = true,
		width = BAR_WIDTH,
		padding_left = MARGIN * 2,
		padding_y = MARGIN * 2,
		background_color = COLOR_GRAY,
		cursor = "beam",
		font = "NumberInfo",
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

	self.panel.text = self.panel:Add(vgui.Create "TimeInputPanel")
	self.panel.text.element = self
	self.panel.text:SetFont(self:GetAttribute "font")

	local text = self:GetAttribute "text"

	if not text then
		text = ZeroString()
	end

	self.panel.text:SetText(text)
	self.panel.text.time = self.panel.text:FormatDigits(text)

	if props then
		self:SetAttributes(props)
		self.on_click = props.on_click
	end
end

function TimeInput:OnMousePressed(mouse)
	TimeInput.super.OnMousePressed(self, mouse)
	
	if self.on_click then
		self.on_click(self, mouse)
	end

	self:OnFocus(self)
end

function TimeInput:OnFocus()
	self.panel.text:SetMouseInputEnabled(false)
	self.panel.text:RequestFocus()
	
	hook.Run("TextEntryFocus", self)
	
	self.text_line:AnimateAttribute("alpha", 255)
end

function TimeInput:OnUnFocus()
	hook.Run("TextEntryUnFocus", self)
	self.text_line:AnimateAttribute("alpha", 0)
end