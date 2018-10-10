InputBar = InputBar or Class.New(Element)

function InputBar.Type(type)
	local type = type or "boolean"

	type = type or "boolean"

	local input_element

	if type == "boolean" then
		input_element = Checkbox
	elseif type == "text" then
		input_element = TextInput
	elseif type == "number" then
		input_element = NumberInput
	elseif type == "time" then
		input_element = TimeInput
	elseif type == "list" then
		input_element = ListSelector
	end

	return input_element
end

function InputBar:Init(label, type, v, input_props)
	InputBar.super.Init(self, {
		layout_justification_x = JUSTIFY_END,
		layout_justification_y = JUSTIFY_CENTER,
		width_percent = 1,
		height = 52,
		padding_x = 32,
		padding_y = 14,
		font = "InputLabel",
		text_justification = 4,
		text = label,

		Element.New {
			layout = false,
			origin_position = true,
			origin_justification_x = JUSTIFY_CENTER,
			origin_justification_y = JUSTIFY_END,
			position_justification_x = JUSTIFY_CENTER,
			position_justification_y = JUSTIFY_END,
			width_percent = 1,
			height = 1,
			inherit_color = false,
			fill_color = true,
			color = COLOR_BACKGROUND_LIGHT,

			alpha = function ()
				return self.last and 0 or 255
			end
		}
	})

	self:AddState("hidden", {
		crop_bottom = 1,
		background_color = COLOR_BACKGROUND_LIGHT
	})

	if type or v or input_props then
		self.input = InputBar.Type(type).New(v, input_props)

		self:Add(Element.New {
			layout_justification_x = JUSTIFY_END,
			width_percent = 0.25,
			height_percent = 1,
			self.input
		})
	end
end

function InputBar:SetValue(v)
	self.input:SetValue(v)
end

function InputBar:GetValue()
	return self.input.value
end