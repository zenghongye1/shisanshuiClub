local ObjectContainer = class("ObjectContainer")

function ObjectContainer:ctor(go)
	self.go = nil
	self.tr = nil
	self.isActive = false

	if go ~= nil then
		self:SetGo(go)
	end
end

function ObjectContainer:SetGo(go)
	self.go  = go
	self.tr = go.transform
	self.isActive = go.activeSelf
end

function ObjectContainer:SetTr(tr)
	self.tr = tr
	self.go = tr.gameObject
	self.isActive = go.activeSelf
end


function ObjectContainer:SetActive(value, force)
	if self.isActive == value and not force then
		return 
	end
	self.isActive = value
	self.go:SetActive(value)
end



return ObjectContainer