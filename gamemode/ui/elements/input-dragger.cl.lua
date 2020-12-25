InputDragger = InputDragger or Class.New(Element)

local scroll_step = 24
local option_padding = 10

local function OptionValue(option)
	local v

	if istable(option) and option.value then
		v = option.value
	else
		v = option
	end

	return v
end

function InputDragger:Init(input, props)
	local input_w = input:GetFinalWidth()
	local input_h = input:GetFinalHeight()
	local screen_x, screen_y = input.panel:LocalToScreen(input_w/2, input_h/2)

	InputDragger.super.Init(self, {
		origin_position = true,
		origin_x = screen_x,
		origin_y = screen_y,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_CENTER,
		fit_x = true,
		height = INPUT_HEIGHT,
		background_color = COLOR_GRAY,
		alpha = 0,
		border = 2,
		cursor = "hand"
	})

	self.start_time = CurTime()

	self.inner_container = self:Add(Element.New {
		layout = false,
		layout_direction = DIRECTION_COLUMN,
		fit = true,
		padding_x = MARGIN * 3.5,
		child_margin = MARGIN
	})

	self.selected_outline = self:Add(Element.New {
		overlay = false,
		layout = false,
		origin_position = true,
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_CENTER,
		width_percent = 1,
		height = input_h,
		border = 2
	})

	self.text_generate = props.text_generate
	self.upper_range_round = props.upper_range_round
	self.upper_range_step = props.upper_range_step
	self.options = props.options
	self.generated_options = {}

	self.offset = 0
	self.selected_option_index = 0

	self.scroll = AnimatableValue.New(option_padding + 1, {
		smooth = true,
		smooth_multiplier = 2
	})

	if self.options then
		self:InitOptions(props.default)
	end

	self:AnimateAttribute("alpha", 255)
end

function InputDragger:GenerateUpperRangeValue(i)
	return tonumber(OptionValue(self.options[1])) - ((i - 1) * self.upper_range_step)
end

function InputDragger:GenerateOptions(default_i, insert_i, insert_option)
	self.insert_i = insert_i
	self.insert_option = insert_option

	local start_i = insert_i or default_i

	self.offset = start_i

	for i = start_i - option_padding, start_i + option_padding do
		self:GenerateOption(i)
	end
end

function InputDragger:GenerateOption(i, option_i)
	local is_insert
	local v

	local insert_i = self.insert_i
	local i_in_range = i > 0

	if insert_i then
		local insert_i_in_range = insert_i > 0

		if i == insert_i then
			is_insert = true
			v = self.insert_option
		else
			is_insert = false

			local offset_i

			if i_in_range and insert_i_in_range and i > insert_i then
				offset_i = -1
			elseif not i_in_range and not insert_i_in_range and insert_i > i then
				offset_i = 1
			else
				offset_i = 0
			end

			if i_in_range then
				v = self.options[i + offset_i]
			else
				v = self:GenerateUpperRangeValue(i + offset_i)
			end
		end
	else
		is_insert = false

		if i_in_range then
			v = self.options[i]
		else
			v = self:GenerateUpperRangeValue(i)
		end
	end

	if v then
		self.generated_options[i] = OptionValue(v)

		local text

		if istable(v) and v.text then
			text = v.text
		elseif self.text_generate then
			text = self.text_generate(v)
		end

		local element_props = {
			fit = true,
			font = "Info",
			text = text
		}

		if option_i then
			self.inner_container:Add(option_i, Element.New(element_props))
		else
			self.inner_container:Add(Element.New(element_props))
		end
	end
end

function InputDragger:InitOptions(default)
	local default_v = OptionValue(default)
	local first_option = tonumber(OptionValue(self.options[1]))

	if default_v > first_option then
		local mod = math.Round(default_v % math.Truncate(default_v, self.upper_range_round), 2)

		if mod == 0 then
			self:GenerateOptions(-((default_v - first_option - self.upper_range_step)/self.upper_range_step))
		else
			self:GenerateOptions(nil, -((default_v - mod - first_option)/self.upper_range_step), default)
		end
	else
		for i, v in pairs(self.options) do
			if OptionValue(v) == default_v then
				self:GenerateOptions(i)

				break
			elseif default_v > OptionValue(v) then
				self:GenerateOptions(nil, i, default)

				break
			end
		end
	end
end

function InputDragger:Finish()
	self.scroll:Finish()

	self:AnimateFinish {
		alpha = 0
	}
end

function InputDragger:SetScrollPos()
	local _, y = self.panel:LocalCursorPos()

	local scroll

	if math.Round(CurTime() - self.start_time, 2) > (1/30) then
		scroll = option_padding + math.Round((y - (self:GetFinalHeight()/2))/scroll_step) + 1
	else
		scroll = option_padding + 1
	end

	self.scroll.current = math.Clamp(scroll, 1, #self.inner_container.children)
	self.selected_option_index = self.scroll.current + self.offset - (option_padding + 1)
end

function InputDragger:LayoutScroll()
	local h = self:GetFinalHeight()
	local child_margin = self.inner_container.attributes.child_margin.current
	local option_h = self.inner_container.children[1]:GetFinalHeight() + child_margin
	local inner_h = (option_h * ((option_padding * 2) + 1)) - child_margin

	self.inner_container:SetAttribute("y", (h/2) - ((option_h - child_margin)/2) - ((self.scroll.smooth - 1) * option_h))
end

function InputDragger:Think()
	InputDragger.super.Think(self)

	if #self.inner_container.children > 0 then
		self:SetScrollPos()
		self:LayoutScroll()
	end
end