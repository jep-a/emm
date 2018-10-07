ScrollContainer = ScrollContainer or Class.New(Element)

function ScrollContainer:Init(props, inner_container_props)
	ScrollContainer.super.Init(self, props)

	self.inner_container = self:Add(Element.New(inner_container_props))

	self.scroll = AnimatableValue.New(0, {
		smooth = true,
		smooth_multiplier = 2,

		smooth_callback = function (anim_v)
			self.inner_container.attributes.offset_y.current = anim_v.smooth
			self.inner_container:SetPanelBounds()
		end
	})
end

function ScrollContainer:AddInner(...)
	return self.inner_container:Add(...)
end

function ScrollContainer:OnMouseScrolled(scroll)
	local curr_scroll = self.scroll.current
	local new_scroll = curr_scroll + (scroll * 50)
	local min = math.min(-(self.inner_container:GetFinalHeight() - self:GetFinalHeight()), 0)

	-- if 0 > min and 0 > new_scroll or new_scroll > min then
		self.scroll.current = math.Clamp(new_scroll, min, 0)
	-- end
end

function ScrollContainer:Finish()
	self.scroll:Finish()
	ScrollContainer.super.Finish(self)
end
