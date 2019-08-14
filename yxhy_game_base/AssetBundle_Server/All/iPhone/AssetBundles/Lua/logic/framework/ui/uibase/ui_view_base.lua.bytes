local ui_view_base = class("ui_view_base")
local subComponentGet = subComponentGet
function ui_view_base:ctor(go)
	self.gameObject = nil
	self.transform = nil
	self.isActive = false
	self:SetGo(go)
end

function ui_view_base:SetGo(go)
	if go == nil then
		return
	end
	self.gameObject = go
	self.transform = go.transform
	self.isActive = go.activeSelf
	self:InitView()
end

function ui_view_base:InitView()
end

function ui_view_base:SetActive(value)
	if self.isActive == value then
		return
	end
	self.isActive = value
	self.gameObject:SetActive(value)
	if self.isActive then
		self:OnShow()
	else
		self:OnHide()
	end
end


function ui_view_base:OnShow()
end

function ui_view_base:OnHide()
end

function ui_view_base:IsValid()
	return not IsNil(self.gameObject)
end

function ui_view_base:GetComponent(path, type)
	return subComponentGet(self.transform, path, type)
end

function ui_view_base:GetGameObject(path)
	local tr = self.transform:Find(path)
	if tr ~= nil then
		return tr.gameObject
	end
	return nil
end

return ui_view_base