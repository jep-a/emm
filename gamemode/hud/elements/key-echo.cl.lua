-- # Key Echo

KeyEcho = KeyEcho or Class.New(Element)

function KeyEcho:Init(props)
	props = props or {}

	KeyEcho.super.Init(self, {
		layout = false,
		origin_position = true,
		width_percent = 0.325,
		height_percent = 0.325,
		background_color = COLOR_BACKGROUND,
		font = "KeyEcho",
		text_justification = 5,

		inner_text = props.arrow and Element.New {
			layout = false,
			width_percent = 1,
			height_percent = 1,
			y = -6,
			font = "KeyEcho",
			text_justification = 5,
			text = props.arrow
		}
	})

	if props then
		if props.key then
			self.key = props.key
		end

		props.arrow = nil
		props.key = nil

		self:SetAttributes(props)
	end
end

function KeyEcho:Think()
	KeyEcho.super.Think(self)

	local key_down = HUDService.KeyDown(self.key)
	local text_color = HUDService.KeyDown(self.key) and COLOR_BACKGROUND or false

	self:SetAttribute("fill_color", key_down)
	self:SetAttribute("text_color", text_color)

	if self.inner_text then
		self.inner_text:SetAttribute("text_color", text_color)
	end
end

KeyEchos = KeyEchos or Class.New(Element)

function KeyEchos:Init()
	KeyEchos.super.Init(self, {
		layout_justification_x = JUSTIFY_CENTER,
		layout_justification_y = JUSTIFY_START,
		layout_direction = DIRECTION_COLUMN,
		wrap = true,
		fit = false,
		width = 180,
		height = 180,
		child_margin = MARGIN * 2,
	})
end