local reserved_states = {
	"hover",
	"press"
}

function Element:InitStates()
	self.states = {}
	self.current_state = "original"
	self.reserved_states = {}

	for _, k in pairs(reserved_states) do
		self.reserved_states[k] = true
	end
end

function Element:SaveOriginalState()
	self.states.original = {}

	for k, v in pairs(self.attributes) do
		self.states.original[k] = v.current
	end
end

function Element:AddState(key, props)
	self.states[key] = props
end

function Element:SetState(key, ...)
	if self.current_state == "original" and not self.states.original then
		self:SaveOriginalState()
	end

	self.current_state = key
	self:SetAttributes(self.states[key])
end

function Element:AnimateState(key, ...)
	local original_state = self.current_state == "original"

	if original_state and not self.states.original then
		self:SaveOriginalState()
	end

	local modified_attr = {}

	if not original_state then
		for k, _ in pairs(self.states[self.current_state]) do
			if not self.states[key][k] then
				modified_attr[k] = true
			end
		end
	end

	self.current_state = key

	for k, _ in pairs(modified_attr) do
		self:AnimateAttribute(k, self.states.original[k], ...)
	end

	for k, v in pairs(self.states[key]) do
		self:AnimateAttribute(k, v, ...)
	end
end

function Element:RevertState(...)
	if self.states.original then
		for k, v in pairs(self.states[self.current_state]) do
			local original_v = self.states.original[k]

			if v ~= original_v then
				self:AnimateAttribute(k, original_v, ...)
			end
		end

		self.current_state = "original"
	end
end