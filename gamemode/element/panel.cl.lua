local ElementPanel = {}

function ElementPanel:Init()
	self.text = self:Add(vgui.Create "DLabel")
	self.text:SetMouseInputEnabled(false)
	self.text:SetText ""
end

function ElementPanel:SetAttribute(k, v)
	self.element:SetAttribute(k, v)
end

function ElementPanel:GetAttribute(k)
	return self.element:GetAttribute(k)
end

function ElementPanel:OnRemove()
	if not self.element.finishing then
		self.element:Finish()
	end
end

function ElementPanel:PerformLayout()
	self.element:Layout()
end

function ElementPanel:Think()
	self.element:Think()
end

function ElementPanel:Paint()
	if self:GetAlpha() > 0 then
		self.element:Paint()
	end
end

function ElementPanel:PaintOver()
	if self:GetAlpha() > 0 then
		self.element:PaintOver()
	end
end

function ElementPanel:CanBubble()
	return self.element.parent and self:GetAttribute "bubble_mouse"
end

function ElementPanel:IsCursorOutBoundsX()
	local out_bounds

	local x, _ = self:LocalCursorPos()
	local w = self:GetWide()

	if 0 > x or x > w then
		out_bounds = true
	else
		out_bounds = false
	end

	return out_bounds
end

function ElementPanel:IsCursorOutBoundsY()
	local out_bounds

	local _, y = self:LocalCursorPos()
	local h = self:GetTall()

	if 0 > y or y > h then
		out_bounds = true
	else
		out_bounds = false
	end

	return out_bounds
end

function ElementPanel:IsCursorOutBounds()
	return self:IsCursorOutBoundsX() or self:IsCursorOutBoundsY()
end

function ElementPanel:OnMousePressed(mouse)
	self.element:OnMousePressed(mouse)

	if self:CanBubble() then
		self.element.parent.panel:OnMousePressed(mouse)
	end
end

function ElementPanel:OnMouseReleased(mouse)
	self.element:OnMouseReleased(mouse)

	if self:CanBubble() then
		self.element.parent.panel:OnMouseReleased(mouse)
	end
end

function ElementPanel:OnMouseWheeled(scroll)
	self.element:OnMouseScrolled(scroll)
end

local hovered_panels = {}

timer.Create("Element.HoveredPanels", 1/30, 0, function ()
	for panel, _ in pairs(hovered_panels) do
		if IsValid(panel) and panel:IsCursorOutBounds() then
			panel:OnCursorExited()
		end
	end
end)

function ElementPanel:OnCursorEntered()
	self.element:OnMouseEntered()
	hovered_panels[self] = true

	if self:CanBubble() then
		self.element.parent.panel:OnCursorEntered()
	end
end

function ElementPanel:OnCursorExited()
	if not self:IsChildHovered() or self:IsCursorOutBounds() then
		self.element:OnMouseExited()
		hovered_panels[self] = nil
	end
end

vgui.Register("ElementPanel", ElementPanel, "EditablePanel")
