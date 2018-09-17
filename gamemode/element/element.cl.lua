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

function Element:Add(i_or_element, element)
	local i

	if isnumber(i_or_element) then
		i = i_or_element
	else
		element = i_or_element
	end

	element.parent = self
	element.last = true

	self.panel:Add(element.panel)

	local layout = element:GetAttribute "layout"

	if i then
		table.insert(self.children, i, element)

		if layout then
			table.insert(self.layout_children, i, element)
		end
	else
		i = table.insert(self.children, element)

		if layout then
			table.insert(self.layout_children, element)
		end
	end

	if i > 1 then
		self.children[i - 1].last = nil
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
	if self.dragging then
		self:StopDragging()
	end

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

	if self:GetAttribute "origin_position" then
		self:PositionFromOrigin()
	end

	if #self.layout_children > 0 then
		self:StackChildren()
	else
		if self:GetAttribute "font" then
			self:LayoutText()
		elseif #self.children > 0 then
			self:Fit()
		end
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

function Element:OnMouseReleased(mouse)
	-- 
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

local drag_distance = 8

local holding_element
local holding_mouse
local holding_x
local holding_y
local dragging

hook.Add("Think", "Element.DragThink", function ()
	if holding_element then
		local mouse_down = input.IsMouseDown(holding_mouse)

		if mouse_down and not holding_element.dragging then
			local curr_x, curr_y = input.GetCursorPos()

			if math.abs(curr_x - holding_x) > drag_distance or math.abs(curr_y - holding_y) > drag_distance then
				holding_element:StartDragging()
			end
		end
	
		if holding_element.dragging then
			holding_element:DragThink()
			
			if not mouse_down then
				holding_element:StopDragging()
			end
		end
	end
end)

hook.Add("VGUIMousePressed", "Element.StartDragging", function (panel, mouse)
	if panel.element then
		holding_element = panel.element
		holding_mouse = mouse
		holding_x, holding_y = input.GetCursorPos()
	end
end)

function Element:StartDragging()
	self.dragging = true
end

function Element:StopDragging()
	if self == holding_element then
		holding_element = nil
	end

	self.dragging = false
end

function Element:DragThink()
	--
end
