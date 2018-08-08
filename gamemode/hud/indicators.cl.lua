IndicatorService = IndicatorService or {}


-- # Elements

function IndicatorService.CreateContainer()
	local element = Element.New {
		width_percent = 1,
		height_percent = 1
	}

	element.panel:SetPaintedManually(true)

	return element
end

Indicator = Indicator or Class.New(Element)

local indicator_material = Material("emm2/shapes/arrow.png", "noclamp smooth")

function Indicator:Init(ent_or_vec)
	self.animatable_color = AnimatableValue.New(COLOR_WHITE, {
		smooth = true,
		generate = function ()
			local color

			if IsValid(self.entity) then
				color = self.entity.color
			else
				color = COLOR_WHITE
			end

			return color
		end
	})

	self.super.Init(self, {
		layout = false,
		width_percent = 1,
		height_percent = 1,
		inherit_color = false,

		color = function ()
			return self.animatable_color.smooth
		end
	})

	self.off_screen = AnimatableValue.New(false, {
		generate = function ()
			local scr_w = ScrW()
			local scr_h = ScrH()
			local x = self.world:GetAttribute "x"
			local y = self.world:GetAttribute "y"
		
			return 0 > x or x > scr_w or 0 > y or y > scr_h
		end,

		callback = function (anim_v)
			if anim_v.current then
				self.world:AnimateAttribute("alpha", 0)
				self.peripheral:AnimateAttribute("alpha", 255)
			else
				self.world:AnimateAttribute("alpha", 255)
				self.peripheral:AnimateAttribute("alpha", 0)
			end
		end
	})

	if isentity(ent_or_vec) then
		self.entity = ent_or_vec
	elseif isvector(ent_or_vec) then
		self.position = ent_or_vec
	end

	self.world = self:Add(Element.New {
		layout = false,
		width = 32,
		height = 32,
		material = indicator_material,
		alpha = 0
	})

	self.peripheral = self:Add(Element.New {
		layout = false,
		width = 40,
		height = 40,
		material = indicator_material,
		alpha = 0
	})
end

function Indicator:Think()
	self.super.Think(self)

	local scr_w = ScrW()
	local scr_h = ScrH()
	local periph_radius = (scr_h/2) - 128
	local x = self.world:GetAttribute "x"
	local y = self.world:GetAttribute "y"

	if 0 > x or x > scr_w or 0 > y or y > scr_h then
		local ang = math.atan2(y - (scr_h/2), x - (scr_w/2)) * (180/math.pi)
		local rad_ang = math.rad(ang)
		local periph_x = (math.cos(rad_ang) * periph_radius) + (scr_w/2)
		local periph_y = (math.sin(rad_ang) * periph_radius) + (scr_h/2)

		self.peripheral:SetAttribute("x", periph_x - (self.peripheral:GetAttribute "width"/2))
		self.peripheral:SetAttribute("y", periph_y - (self.peripheral:GetAttribute "width"/2))
		self.peripheral:SetAttribute("angle", -ang + 90)
	end
end

function Indicator:Finish()
	self.super.Finish(self)
	self.animatable_color:Finish()
end


-- # Init

function IndicatorService.CalculatePositions(lobby, ply)
	local indicators = IndicatorService.container.children

	for i = 1, #indicators do
		local indicator = indicators[i]

		local pos
	
		if IsValid(indicator.entity) then
			pos = indicator.entity:WorldSpaceCenter()
		elseif indicator.position then
			pos = indicator.position
		end
	
		local eye_pos = LocalPlayer():EyePos()
	
		cam.Start3D()
	
		local dist = eye_pos:Distance(pos)
		local screen_pos = (pos + Vector(0, 0, Lerp(dist/600, 40, 45))):ToScreen()
		local size = Lerp(dist/800, 64, 20)
		local x, y = screen_pos.x - (size/2), screen_pos.y - 6 - (size/2)
	
		cam.End3D()
	
		indicator.world:SetAttribute("x", x)
		indicator.world:SetAttribute("y", y)
		indicator.world:SetAttribute("size", size)
	end
end
hook.Add("Think", "IndicatorService.CalculatePositions", IndicatorService.CalculatePositions)

function IndicatorService.Add(lobby, ply)
	if ply == LocalPlayer() then
		for _, _ply in pairs(lobby.players) do
			if ply ~= _ply then
				_ply.indicator = Indicator.New(_ply)
				IndicatorService.container:Add(_ply.indicator)
			end
		end
	else
		ply.indicator = Indicator.New(ply)
		IndicatorService.container:Add(ply.indicator)
	end
end
hook.Add("LocalLobbyAddPlayer", "IndicatorService.Add", IndicatorService.Add)
hook.Add("LocalLobbyPlayerSpawn", "IndicatorService.Add", function (lobby, ply)
	if ply ~= LocalPlayer() then
		IndicatorService.Add(lobby, ply)
	end
end)

hook.Add("LocalLobbyPlayerDeath", "IndicatorService.Remove", function (lobby, ply)
	if ply ~= LocalPlayer() then
		ply.indicator:Finish()
	end
end)

function IndicatorService.Clear(lobby, ply)
	if ply == LocalPlayer() then
		IndicatorService.container:Clear()
	else
		ply.indicator:Finish()
	end
end
hook.Add("LocalLobbyRemovePlayer", "IndicatorService.Clear", IndicatorService.Clear)

function IndicatorService.ReloadIndicators()
	local ply = LocalPlayer()

	if ply.lobby then
		IndicatorService.Add(ply.lobby, ply)
	end
end


-- # Init

function IndicatorService.Init()
	IndicatorService.container = IndicatorService.CreateContainer()
end
hook.Add("InitUI", "IndicatorService.Init", IndicatorService.Init)

function IndicatorService.Reload()
	IndicatorService.container:Finish()
	IndicatorService.Init()
	IndicatorService.ReloadIndicators()
end
hook.Add("OnReloaded", "IndicatorService.Reload", IndicatorService.Reload)

function IndicatorService.Show()
	IndicatorService.container:AnimateAttribute("alpha", 255)
end
hook.Add("LocalPlayerSpawn", "IndicatorService.Show", IndicatorService.Show)

function IndicatorService.Hide()
	IndicatorService.container:AnimateAttribute("alpha", 0)
end
hook.Add("LocalPlayerDeath", "IndicatorService.Hide", IndicatorService.Hide)

function IndicatorService.Render()
	IndicatorService.container.panel:PaintManual()
end
hook.Add("DrawIndicators", "IndicatorService.Render", IndicatorService.Render)
