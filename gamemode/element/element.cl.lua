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

	self.static_attributes = {
		layout = true,
		self_adjacent_justification = JUSTIFY_INHERIT,
		layout_justification_x = JUSTIFY_START,
		layout_justification_y = JUSTIFY_START,
		layout_direction = DIRECTION_ROW,
		wrap = true,
		fit_x = false,
		fit_y = false,
		inherit_color = true,
		fill_color = false
	}

	self.attributes = {
		x = AnimatableValue.New(),
		y = AnimatableValue.New(),
		width = AnimatableValue.New(),
		height = AnimatableValue.New(),
		padding_left = AnimatableValue.New(),
		padding_top = AnimatableValue.New(),
		padding_right = AnimatableValue.New(),
		padding_bottom = AnimatableValue.New(),
		crop_left = AnimatableValue.New(),
		crop_top = AnimatableValue.New(),
		crop_right = AnimatableValue.New(),
		crop_bottom = AnimatableValue.New(),
		child_margin = AnimatableValue.New(),
		color = AnimatableValue.New(COLOR_WHITE),
		background_color = AnimatableValue.New(COLOR_BLACK_CLEAR),
		alpha = AnimatableValue.New(255)
	}

	self.optional_attributes = {
		duration = true,	
		width_percent = true,
		height_percent = true,
		angle = true,
		border = true
	}

	if props then
		self:SetAttributes(props)
	end
end

function Element:Add(element)
	element.parent = self

	self.panel:Add(element.panel)

	table.insert(self.children, element)

	if element:GetAttribute "layout" then
		table.insert(self.layout_children, element)
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
		table.RemoveByValue(self.parent.children, self)

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

function Element:Think()
	if #self.layout_children > 0 then
		self:StackChildren()
	else
		self:LayoutText()
	end

	self:GenerateSize()
	self:DetectEnd()
	
	self.panel:SetSize(self:GetFinalWidth(), self:GetFinalHeight())
	self.panel:SetPos(math.Round(self:GetAttribute "x"), math.Round(self:GetAttribute "y"))
	self.panel:SetAlpha(math.Round(self:GetAttribute "alpha"))
	self.panel.text:SetTextColor(self:GetAttribute "color")
end