CheckpointService.markers = {}


-- # Beams

CheckpointMarkerFadeBeam = CheckpointMarkerFadeBeam or Class.New()

function CheckpointMarkerFadeBeam:Init(props)
	local opacity = props and props.opacity or 255
	local direction = props and props.direction or Vector(0, 0, 1)
	local length = props and props.length or 128

	self.direction = direction or Vector(0, 0, 1)
	self.length = length or 128
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

	render.SetColorMaterialIgnoreZ()
	render.StartBeam(3)
	render.AddBeam(self.parent.position, 2, 1, ColorAlpha(COLOR_YELLOW, self.opacity.current))
	render.AddBeam(self.parent.position + (self.direction * (length - (length/4))), 2, 1, ColorAlpha(COLOR_YELLOW, self.opacity.current))
	render.AddBeam(self.parent.position + (self.direction * length), 2, 1, ColorAlpha(COLOR_YELLOW, 0))
	render.EndBeam()
end
Class.AddHook(CheckpointMarkerFadeBeam, "PostDrawTranslucentRenderables", "Render")


-- # Markers

CheckpointStartMarker = CheckpointStartMarker or Class.New()

function CheckpointStartMarker:Init(props)
	self.position = props.position
	self.beams = {}

	self.size_multiplier = AnimatableValue.New(0.5)
	self.opacity = AnimatableValue.New()
	self.length = AnimatableValue.New(128, {smooth = true})

	if props.angle then
		self.angle_beam = self:CreateFadeBeam({direction = -Angle(0, props.angle, 0):Forward()})
	else
		self.angle = AnimatableValue.New(0, {
			callback = function (value)
				if self.angle_beam then
					self.angle_beam:Finish()
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

	self:CreateFadeBeam()

	self.size_multiplier:AnimateTo(1, 0.5, CubicBezier(0.5, -1, 0, 1))
	self.opacity:AnimateTo(255, 0.2)
end

function CheckpointStartMarker:Finish(instant)
	if instant then
		self.size_multiplier:Finish()

		if self.angle then
			self.angle:Finish()
		end

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

function CheckpointStartMarker:CreateFadeBeam(props)
	local beam = CheckpointMarkerFadeBeam.New(props)
	beam.parent = self

	self.beams[#self.beams + 1] = beam

	return beam
end

function CheckpointStartMarker:Render()
	render.SetColorMaterialIgnoreZ()
	render.DrawSphere(self.position, 1, 8, 8, ColorAlpha(COLOR_YELLOW, self.opacity.current))

	if self.angle_beam then
		self.angle_beam.length = self.length.smooth
	end
end
Class.AddHook(CheckpointStartMarker, "PostDrawTranslucentRenderables", "Render")


-- # Rendering

function CheckpointService.ClearMarkers()
	for _, marker in pairs(CheckpointStartMarker.static.instances) do
		marker:Finish()
	end
end