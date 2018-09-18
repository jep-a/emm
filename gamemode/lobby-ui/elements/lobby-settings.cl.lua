LobbySettings = LobbySettings or Class.New(Element)

function LobbySettings:Init(lobby)
	LobbySettings.super.Init(self, {
		layout_direction = DIRECTION_COLUMN,
		fit = true,
		child_margin = MARGIN * 4,
		alpha = 0,
		LobbyUIService.CreateHeader("Settings", true)
	})

	self.lobby = lobby

	self.body = self:Add(Element.New {
		fit = true,
		child_margin = MARGIN * 4,
	})

	self:InitSettings()
	self:AnimateAttribute("alpha", 255)
end

function LobbySettings:AddCategory(label, color)
	return self.body:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width = COLUMN_WIDTH,
		background_color = color or COLOR_GRAY,
		LobbyUIService.CreateLabels {"label"}
	})
end

function LobbySettings:InitSettings()
	self:AddCategory "Game"

	for _, ply_class in pairs(self.lobby.prototype.player_classes) do
		self:AddCategory(ply_class.name, ply_class.color)
	end
	
	-- for _, setting in pairs(self.adjustable_settings) do
	-- 	if string.match(setting.key, "player_classes%.%*") then
	-- 		for _, ply_class_category in pairs(ply_class_categories) do
	-- 			table.Add(ply_class_category, setting.settings)
	-- 		end
	-- 	else
	-- 		table.insert(uncategorized_settings, setting)
	-- 	end
	-- end
end