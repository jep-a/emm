local ElementPanel = {}

function ElementPanel:Init()
	self.text = self:Add(vgui.Create "DLabel")
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
	self.element:Paint()
end

vgui.Register("ElementPanel", ElementPanel, "EditablePanel")
