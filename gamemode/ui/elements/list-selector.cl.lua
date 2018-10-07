ListSelector = ListSelector or Class.New(Element)

local hamburger_material = Material("emm2/ui/hamburger.png", "noclamp smooth")

function ListSelector:Init(v, props)
	ListSelector.super.Init(self, {
		width = CHECKBOX_SIZE,
		height = CHECKBOX_SIZE,
		background_color = COLOR_GRAY_DARK,
		border = LINE_THICKNESS,
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
			material = hamburger_material,
		},
	})

	self.value = v
	self.original_value = v
	self.options = props.options

	self.original_values = {}
	self.changed_values = {}

	self.inputs = {}

	for _, k in pairs(props.options) do
		self.original_values[k] = v[k]
	end

	if props then
		self:SetAttributes(props)
		self.on_change = props.on_change
	end
end

function ListSelector:Finish()
	if self.list then
		self:FinishList()
	end

	if ListSelector.focused == self then
		ListSelector.focused = nil
	end

	ListSelector.super.Finish(self)
end

function ListSelector:CreateList()
	local input_w = self:GetFinalWidth()
	local input_h = self:GetFinalHeight()
	local screen_x, screen_y = self.panel:LocalToScreen(input_w/2, input_h/2)

	self.list = Element.New {
		clamp_to_screen = true,
		origin_position = true,
		origin_x = screen_x,
		origin_y = screen_y,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_CENTER,
		fit_y = true,
		width = COLUMN_WIDTH,
		padding_y = MARGIN * 2,
		background_color = COLOR_GRAY,
		alpha = 0,
		border = 2
	}

	self.list.panel:MakePopup()
	self.list.panel:SetKeyboardInputEnabled(false)

	ListSelector.focused = self

	for _, list_option in pairs(self.options) do
		self.inputs[list_option] = self.list:Add(InputBar.New(list_option, nil, self.value[list_option], {
			on_change = function (input, v)
				self:OnListValueChanged(list_option, v)
			end
		}))
	end

	self.list:AnimateAttribute("alpha", 255)
end

function ListSelector:FinishList()
	local old_list = self.list

	if old_list then
		old_list:AnimateAttribute("alpha", 0, {
			callback = function ()
				old_list:Finish()
			end
		})
		
		self.list = nil
	end
end

function ListSelector:OnListValueChanged(k, v)
	-- MinigameSettingsService.SortChange(self.original_values, self.changed_values, k, v)

	-- if table.Count(self.changed_values) > 0 then
		-- local new_v = {}

		-- for k, _ in pairs(self.changed_values) do
		-- 	local input_v = self.inputs[k]:GetValue()

		-- 	if input_v or self.original_values[k] ~= nil then
		-- 		new_v[k] = input_v
		-- 	end
		-- end

		self:OnValueChanged(k, v)
	-- else
	-- 	self:OnValueChanged(k, self.original_value)
	-- end
end

function ListSelector.MousePressed(panel)
	if ListSelector.focused and ListSelector.focused.list and ListSelector.focused.list.panel:IsCursorOutBounds() then
		ListSelector.focused:FinishList()
		ListSelector.focused = nil
	end
end
hook.Add("VGUIMousePressed", "ListSelector.MousePressed", ListSelector.MousePressed)

function ListSelector:OnValueChanged(k, v)
	if k then
		self.value[k] = v
	else
		self.value = v
	end

	if self.on_change then
		self.on_change(self, k, v)
	end
end

function ListSelector:OnMousePressed(mouse)
	ListSelector.super.OnMousePressed(self, mouse)

	if not self.list then
		self:CreateList()
	end
end

function ListSelector:SetValue(k, v)
	if v ~= self.inputs[k]:GetValue() then
		self:OnValueChanged(k, v)
	end
end
