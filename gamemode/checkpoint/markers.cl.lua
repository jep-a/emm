CheckpointService.markers = {}


-- # Beams

CheckpointMarkerFadeBeam = CheckpointMarkerFadeBeam or Class.New()

function CheckpointMarkerFadeBeam:Init(props)
	local opacity = props and props.opacity or 255
	local direction = props and props.direction or Vector(0, 0, 1)
	local length = props and props.length or 24

	self.direction = direction
	self.length = length
	self.opacity = AnimatableValue.New()
	self.opacity:AnimateTo(opacity, 0.2)
end

function CheckpointMarkerFadeBeam:Finish(instant)
	if instant then
		self.opacity:Finish()
		self:DisconnectFromHooks()
	else
		self.opacity:AnimateTo(0, {
			duration = 0.2,
			remove = true,
			callback = function ()
				self:Finish(true)
			end
		})
	end
end

function CheckpointMarkerFadeBeam:Render()
	local length = self.length * self.parent.size_multiplier.current
	local color = HSVToColor(ColorToHSV(MinigameService.prototypes["Race"].ZONES[CheckpointService.type]), 0.4, 0.9)

	render.SetColorMaterialIgnoreZ()
	render.StartBeam(3)
	render.AddBeam(self.parent.position, 2, 1, ColorAlpha(color, self.opacity.current))
	render.AddBeam(self.parent.position + (self.direction * (length - (length/4))), 2, 1, ColorAlpha(color, self.opacity.current))
	render.AddBeam(self.parent.position + (self.direction * length), 2, 1, ColorAlpha(color, 0))
	render.EndBeam()
end
Class.AddHook(CheckpointMarkerFadeBeam, "PostDrawTranslucentRenderables", "Render")

CheckpointMarkerTwoPointBeam = CheckpointMarkerTwoPointBeam or Class.New()

function CheckpointMarkerTwoPointBeam:Init(props)
	local opacity = props and props.opacity or 255
	local start_position = props and props.start_position or LocalPlayer():GetEyeTrace().HitPos
	local end_position = props and props.end_position or start_position

	self.start_position = start_position
	self.end_position = end_position
	self.opacity = AnimatableValue.New()
	self.opacity:AnimateTo(opacity, 0.2)
end

function CheckpointMarkerTwoPointBeam:Finish(instant)
	CheckpointMarkerFadeBeam.Finish(self, instant)
end

function CheckpointMarkerTwoPointBeam:Render()
	local color = ColorAlpha(HSVToColor(ColorToHSV(MinigameService.prototypes["Race"].ZONES[CheckpointService.type]), 0.4, 0.9), self.opacity.current)
	
	render.SetColorMaterialIgnoreZ()

	render.StartBeam(3)
	render.AddBeam(self.start_position, 2, 1, color)
	render.AddBeam(self.end_position, 2, 1, color)
	render.EndBeam()

	render.DrawSphere(self.start_position, 1, 8, 8, color)
	render.DrawSphere(self.end_position, 1, 8, 8, color)
end
Class.AddHook(CheckpointMarkerTwoPointBeam, "PostDrawTranslucentRenderables", "Render")


-- # Markers

CheckpointHorizontalPlaneMarker = CheckpointHorizontalPlaneMarker or Class.New()

function CheckpointHorizontalPlaneMarker:Init(position)
	self.position = position
	self.beams = {}

	self.size_multiplier = AnimatableValue.New(0.5)
	self.opacity = AnimatableValue.New()

	for i = 1, 4 do
		local direction = Vector(1, 0, 0)
		direction:Rotate(Angle(0, i * 90, 0))

		self:CreateFadeBeam({
			opacity = 50,
			direction = direction
		})
	end

	self:CreateFadeBeam()

	self.size_multiplier:AnimateTo(1, 0.5, CubicBezier(0.5, -1, 0, 1))
	self.opacity:AnimateTo(255, 0.2)
end

function CheckpointHorizontalPlaneMarker:Finish(instant)
	if instant then
		self.size_multiplier:Finish()
		self.opacity:Finish()
		self:DisconnectFromHooks()

		for _, beam in pairs(self.beams) do
			beam:Finish(true)
		end
	else
		self.opacity:AnimateTo(0, {
			duration = 0.1,
			remove = true,
			callback = function ()
				self:Finish(true)
			end
		})

		for _, beam in pairs(self.beams) do
			beam:Finish()
		end
		
	end
end

function CheckpointHorizontalPlaneMarker:CreateFadeBeam(props)
	local beam = CheckpointMarkerFadeBeam.New(props)
	beam.parent = self

	self.beams[#self.beams + 1] = beam

	return beam
end

function CheckpointHorizontalPlaneMarker:Render()
	render.SetColorMaterialIgnoreZ()
	render.DrawSphere(self.position, 1, 8, 8, ColorAlpha(HSVToColor(ColorToHSV(MinigameService.prototypes["Race"].ZONES[CheckpointService.type]), 0.4, 0.9), self.opacity.current))
end
Class.AddHook(CheckpointHorizontalPlaneMarker, "PostDrawTranslucentRenderables", "Render")


-- # Rendering

function CheckpointService.ClearMarkers()
	for _, marker in pairs(CheckpointHorizontalPlaneMarker.static.instances) do
		marker:Finish()
	end

	for _, beam in pairs(CheckpointMarkerTwoPointBeam.static.instances) do
		beam:Finish()
	end
end