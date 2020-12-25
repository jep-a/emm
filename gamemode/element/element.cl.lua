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

	self.setting_hooks = {}

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

	if i and #self.children >= (i - 1) then
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

function Element:MarkForAnimatingFinish()
	self.animating_finish = true

	for _, child in pairs(self.children) do
		child:MarkForAnimatingFinish()
	end
end

function Element:AnimateFinish(props_or_duration, props)
	if not self.animating_finish then
		local duration

		if istable(props_or_duration) then
			props = props_or_duration
			duration = Property(props, "duration", ANIMATION_DURATION, true)
		else
			duration = props_or_duration
		end

		callback = Property(props, "callback", nil, true)
		attributes = props

		self:MarkForAnimatingFinish()

		for k, v in pairs(attributes) do
			if istable(v) then
				self:AnimateAttribute(k, v.value, v.props)
			else
				self:AnimateAttribute(k, v)
			end
		end

		self.finish_timer = Timer.New(duration, function ()
			if callback then
				callback()
			end

			Element.Finish(self)
		end)
	end
end

function Element:Finish()
	for k, _ in pairs(self.setting_hooks) do
		SettingsService.RemoveHook(k, Class.TableID(self))
	end

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
	local static_attr = self.static_attributes
	local duration = static_attr.duration

	if duration and CurTime() > (static_attr.start_time + duration) then
		static_attr.duration = nil
		self:Finish()
	end
end

function Element:Think()
	self:DetectEnd()

	local attr = self.attributes

	self.panel:SetAlpha(math.Round(attr.alpha.current))
	self.panel.text:SetTextColor(attr.text_color and attr.text_color.current or self:GetColor())
end

function Element:AddConvarAnimator(name, attr, ...)
	local anim_props = {...}

	self.setting_hooks[name] = true

	SettingsService.AddHook(name, Class.TableID(self), function (v)
		self:AnimateAttribute(attr, v, unpack(anim_props))
	end)
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

function Element:OnMouseScrolled(scroll)
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

function Element:HasParent(element)
	local has_parent
	local curr_element = self

	while curr_element.parent do
		if curr_element.parent == element then
			has_parent = true

			break
		else
			has_parent = false
		end

		curr_element = curr_element.parent
	end

	return has_parent
end