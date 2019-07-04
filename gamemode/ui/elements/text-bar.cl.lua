TextBar = TextBar or Class.New(Element)

function TextBar:Init(text, props)
	TextBar.super.Init(self, {
		fit = true,
		padding_x = 8,
		padding_y = 4,
		fill_color = true,
		font = "TextBar",
		text_justification = 5,
		text = text
	})

	if props then
		self:SetAttributes(props)
	end

	if self:GetAttribute "fill_color" then
		self:SetAttribute("text_color", COLOR_BACKGROUND)
	end
end