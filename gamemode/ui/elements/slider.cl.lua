InputSlider = InputSlider or Class.New(Element)

local scroll_step = 24

local function OptionValue(option)
	local v

	if istable(option) and option.value then
		v = option.value
	else
		v = option
	end

	return v
end

function InputSlider:Init(input, props)
	local input_w = input:GetFinalWidth()
	local input_h = input:GetFinalHeight()
	local screen_x, screen_y = input.panel:LocalToScreen(input_w, input_h/2)

	InputSlider.super.Init(self, {
		origin_position = true,
		origin_x = screen_x,
		origin_y = screen_y,
		position_justification_x = JUSTIFY_END,
		position_justification_y = JUSTIFY_CENTER,
		fit_x = true,
		height = BAR_HEIGHT * 2,
		alpha = 0,
		border = 2,
		cursor = "hand"
	})

	self.inner_container = self:Add(Element.New {
		layout = false,
		layout_direction = DIRECTION_COLUMN,
		fit = true,
		padding_x = MARGIN * 3.5,
		padding_y = MARGIN * 3,
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

	local default = props.default
	local upper_range_round = props.upper_range_round
	local upper_range_step = props.upper_range_step
	local options = props.options

	self.text_generate = props.text_generate
	self.upper_range_round = upper_range_round
	self.upper_range_step = upper_range_step
	self.options = options

	if options then
		if default then
			local default_v = OptionValue(default)
			local first_option = tonumber(OptionValue(options[1]))

			if default_v > first_option then
				local mod = math.Round(default_v % math.Truncate(default_v, upper_range_round), 4)

				if mod == 0 then
					self:GenerateOptions(-((default_v - first_option)/upper_range_step))
				else
					self:GenerateOptions(nil, -((default_v - mod - first_option)/upper_range_step), default)
				end
			else
				for i, v in pairs(options) do
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
	end

	self.offset = 0
	self.scroll = AnimatableValue.New(5, {
		smooth = true,
		smooth_multiplier = 2,

		generate = function ()
			local option_count = #self.inner_container.children
			local _, y = self.panel:LocalCursorPos()
			local relative_y = y - (self:GetFinalHeight()/2)
			local scroll = math.floor(option_count/2) + math.Round(relative_y/scroll_step) + 1
		
			return scroll
		end
	})

	self:AnimateAttribute("alpha", 255)
end

function InputSlider:GenerateUpperRangeValue(i)
	return tonumber(OptionValue(self.options[1])) - ((i - 1) * self.upper_range_step)
end

function InputSlider:GenerateOptions(default_i, insert_i, insert_option)
	self.insert_i = insert_i
	self.insert_option = insert_option

	local start_i = insert_i or default_i

	for i = start_i - 4, start_i + 4 do
		self:GenerateOption(i)
	end
end

function InputSlider:GenerateOption(i)
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
		local text

		if istable(v) and v.text then
			text = v.text
		elseif self.text_generate then
			text = self.text_generate(v)
		end

		self.inner_container:Add(Element.New {
			fit = true,
			font = "Info",
			text = text
		})
	end
end

function InputSlider:AnimateFinish()
	self:AnimateAttribute("alpha", 0, {
		callback = function ()
			InputSlider.super.Finish(self)
		end
	})
end

function InputSlider:Finish()
	self.scroll:Finish()
	self:AnimateFinish()
end

function InputSlider:Think()
	InputSlider.super.Think(self)

	local h = self:GetFinalHeight()
	local inner_h = self.inner_container:GetFinalHeight()
	local child_margin = self.inner_container:GetAttribute "child_margin"
	local option_h = self.inner_container.children[1]:GetFinalHeight() + child_margin

	self.inner_container:SetAttribute("y", (h/2) - option_h + child_margin - ((self.offset + self.scroll.smooth - 1) * option_h))
end