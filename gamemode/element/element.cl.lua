JUSTIFY_INHERIT = 0
JUSTIFY_START = 1
JUSTIFY_CENTER = 2
JUSTIFY_END = 3

DIRECTION_ROW = 0
DIRECTION_COLUMN = 1

-- # Class

Element = Element or Class.New()

function Element:Init(props)
	self.children = {}
	self.layout_children = {}
	
	self.panel = vgui.Create "ElementPanel"
	self.panel.element = self
	
	self:InitStates()
	self:InitAttributes()
	
	if props then
		self:SetAttributes(props)
	end
end

function Element:Add(element)
	element.parent = self
	element.last = true

	self.panel:Add(element.panel)

	local i = table.insert(self.children, element)

	if i > 1 then
		self.children[i - 1].last = nil
	end

	if element:GetAttribute "layout" then
		table.insert(self.layout_children, element)
	end

	if element:GetAttribute "inherit_cursor" then
		local cursor = self:GetAttribute "cursor"

		if cursor then
			element:SetAttribute("cursor", cursor)
		end
	end

	return element
end

function Element:Clear()
	local finishing_children = {}

	for _, element in pairs(self.children) do
		table.insert(finishing_children, element)
	end

	for _, element in pairs(finishing_children) do
		element:Finish()
	end
end

function Element:Finish()
	if self.parent then
		local i = table.RemoveByValue(self.parent.children, self)

		if i > 1 and self.last then
			self.parent.children[i - 1].last = true
		end

		if self:GetAttribute "layout" then
			table.RemoveByValue(self.parent.layout_children, self)
		end

		self.parent = nil
	end

	for k, v in pairs(self.attributes) do
		v:Finish()
	end

	if IsValid(self.panel) then
		self.finishing = true
		self.panel:Remove()
	end
end

function Element:DetectEnd()
	local duration = self:GetAttribute "duration"

	if duration and CurTime() > (self:GetAttribute "start_time" + duration) then
		self:SetAttribute("duration", nil)
		self:Finish()
	end
end

function Element:Layout()
	self.laying_out = true

	if self.parent and self:GetAttribute "origin_position" then
		self:PositionFromOrigin()
	end

	if #self.layout_children > 0 then
		self:StackChildren()
	else
		self:LayoutText()
	end

	self:GenerateSize()

	self.panel:SetSize(self:GetFinalWidth(), self:GetFinalHeight())
	self.panel:SetPos(math.Round(self:GetAttribute "x"), math.Round(self:GetAttribute "y"))

	if self:GetAttribute "layout" and self.parent then
		self.parent.panel:InvalidateLayout(true)
	end

	self.laying_out = false
end

function Element:Think()
	self:DetectEnd()

	self.panel:SetAlpha(math.Round(self:GetAttribute "alpha"))
	self.panel.text:SetTextColor(self:GetAttribute "text_color" or self:GetAttribute "color")
end

function Element:OnMousePressed(mouse)
	if self.states.press then
		local old_state = self.current_state

		self:SetState "press"
		self:AnimateState(old_state, ANIMATION_DURATION * 4)
	end
end

function Element:OnMouseEntered()
	if self.states.hover then
		self:AnimateState "hover"
	end
end

function Element:OnMouseExited()
	if self.states.hover then
		self:RevertState()
	end
end