CheckpointService.markers = {}


-- # Beams

CheckpointMarkerFadeBeam = {}
CheckpointMarkerFadeBeam.__index = CheckpointMarkerFadeBeam

function CheckpointMarkerFadeBeam:Init(props)
	local opacity = props and props.opacity or 255
	local direction = props and props.direction or Vector(0, 0, 1)
	local length = props and props.length or 128

	self.direction = direction or Vector(0, 0, 1)
	self.length = length or 128
	self.opacity = AnimatableValueService.CreateAnimatableValue()
	self.opacity:AnimateTo(opacity, 0.2)
end

function CheckpointMarkerFadeBeam:Remove(instant)
	if instant then
		self.opacity:Remove()
		self.parent.beams[self.id] = nil
	else
		self.opacity:AnimateTo(0, {
			duration = 0.2,
			remove = true,
			callback = function ()
				self:Remove(true)
			end
		})
	end
end

function CheckpointMarkerFadeBeam:Render()
	local length = self.length * self.parent.size_multiplier.current

	render.SetColorMaterialIgnoreZ()
	render.StartBeam(3)
	render.AddBeam(self.parent.position, 2, 1, ColorAlpha(COLOR_YELLOW, self.opacity.current))
	render.AddBeam(self.parent.position + (self.direction * (length - (length/4))), 2, 1, ColorAlpha(COLOR_YELLOW, self.opacity.current))
	render.AddBeam(self.parent.position + (self.direction * length), 2, 1, ColorAlpha(COLOR_YELLOW, 0))
	render.EndBeam()
end


-- # Markers

CheckpointStartMarker = {}
CheckpointStartMarker.__index = CheckpointStartMarker

function CheckpointService.CreateStartMarker(props)
	local id = #CheckpointService.markers + 1

	local marker = {}
	marker.id = id
	setmetatable(marker, CheckpointStartMarker)

	marker:Init(props)

	CheckpointService.markers[id] = marker

	return marker
end

function CheckpointStartMarker:Init(props)
	self.position = props.position
	self.beams = {}

	self.size_multiplier = AnimatableValueService.CreateAnimatableValue(0.5)

	if props.angle then
		self:CreateFadeBeam({direction = -Angle(0, props.angle, 0):Forward()})
	else
		self.angle = AnimatableValueService.CreateAnimatableValue(0, {
			callback = function (value)
				if self.angle_beam then
					self.angle_beam:Remove()
				end

				self.angle_beam = self:CreateFadeBeam({direction = -Angle(0, value.current, 0):Forward()})
			end
		})

		for i = 1, 4 do
			local direction = Vector(1, 0, 0)
			direction:Rotate(Angle(0, i * 90, 0))
	
			self:CreateFadeBeam({
				opacity = 20,
				direction = direction
			})
		end
	end

	self.opacity = AnimatableValueService.CreateAnimatableValue()

	self:CreateFadeBeam()

	self.size_multiplier:AnimateTo(1, 0.5, CubicBezier(0.5, -1, 0, 1))
	self.opacity:AnimateTo(255, 0.2)
end

function CheckpointStartMarker:Remove(instant)
	if instant then
		self.size_multiplier:Remove()

		if self.angle then
			self.angle:Remove()
		end

		self.opacity:Remove()
		CheckpointService.markers[self.id] = nil

		for _, beam in pairs(self.beams) do
			beam:Remove(true)
		end
	else
		self.opacity:AnimateTo(0, {
			duration = 0.1,
			remove = true,
			callback = function () self:Remove(true) end
		})

		for _, beam in pairs(self.beams) do
			beam:Remove()
		end
	end
end

function CheckpointStartMarker:CreateFadeBeam(props)
	local id = #self.beams + 1

	local beam = {}
	beam.parent = self
	beam.id = id
	setmetatable(beam, CheckpointMarkerFadeBeam)

	beam:Init(props)

	self.beams[id] = beam

	return beam
end

function CheckpointStartMarker:Render()
	render.SetColorMaterialIgnoreZ()
	render.DrawSphere(self.position, 1, 8, 8, ColorAlpha(COLOR_YELLOW, self.opacity.current))

	for _, beam in pairs(self.beams) do
		beam:Render()
	end
end


-- # Rendering

function CheckpointService.ClearMarkers()
	for _, marker in pairs(CheckpointService.markers) do
		marker:Remove()
	end
end

function CheckpointService.RenderMarkers()
	for _, marker in pairs(CheckpointService.markers) do
		marker:Render()
	end
end
hook.Add("PostDrawTranslucentRenderables", "CheckpointService.RenderMarkers", CheckpointService.RenderMarkers)