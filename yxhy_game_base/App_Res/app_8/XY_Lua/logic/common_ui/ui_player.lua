--[[--
 * @Description: 创建角色模型展示
 * @Author:      shine
 * @FileName:    ui_player.lua
 * @DateTime:    2015-11-06 18:05:53
 ]]


ui_player = ui_base.New()
ui_player.__index = ui_player

--[[--
 * @Description: 构造函数  
 ]]
function ui_player.New()
	local self = {}
	setmetatable(self, ui_player)

	self.curPlayer = nil
	self.skillCtrl = nil
	self.avatorData = nil
	self.spinWithMouse = nil
	self.moc = nil
	self.widget = nil
	self.actorLight = nil

	return self
end

--//////////////////////各个成员函数 //////////////////////////

function ui_player:Initialize()
end

function ui_player:Uninitialize()
	if self.curPlayer~=nil then
		self.curPlayer:ClearData()
	end

	if not IsNil(self.actorLight) then
		destroy(self.actorLight.gameObject)
	end
	destroy(self.curPlayer.gameObject)
	self.curPlayer = nil 
end

--[[--
 * @Description: 递归设置UI角色层  
 ]]
function ui_player:RecursiveSetLayerVal(node, layer)
    if (node == nil) then
        return
    end

    for i=1,node.childCount do
        local child = node:GetChild(i-1)
        if (child ~= nil) then
            child.gameObject.layer = layer
            self:RecursiveSetLayerVal(child, layer)
        end
    end
end

--[[--
 * @Description: 设置角色的拖动区域  
 ]]
function ui_player:SetPlayerDragArea(radius)
	local charController = componentGet(self.curPlayer.transForm, "CharacterController")
	if charController.radius ~= nil then
		 charController.radius = radius
	end
end

--[[--
 * @Description: 设置角色的胶囊体大小 并放置到脚底 
 ]]
function ui_player:SetPlayerCapsule(height)
	local charController = componentGet(self.curPlayer.transForm, "CharacterController")
	if charController.radius ~= nil then
		 charController.height = height
		 charController.center = Vector3.New(0,height/2,0)
	end
end

function ui_player:SetPlayerCanRotateToggle(state)
	if state ~= nil then
		if state then
			self.widget = self.curPlayer.gameObject:AddComponent(typeof(UIWidget))
		else

		end
	end
end

function ui_player:SetActorLightToggle(state)
	if state ~= nil then
		if not IsNil(self.actorLight) then
			self.actorLight.gameObject:SetActive(state)
		end
	end	
end

function ui_player:RefreshExterior()
	if (self.curPlayer ~= nil) then
		self.curPlayer:RefreshExterior(false, false)
	end
end

function ui_player:TryOnExterior(tryOnType, outwardId)
	if (self.curPlayer ~= nil) then
		self.curPlayer:TryOnExterior(tryOnType, outwardId)
	end
end

function ui_player:GetOffExterior(tryOnType, outwardId)
	if (self.curPlayer ~= nil) then
		self.curPlayer:GetOffExterior(tryOnType, outwardId)
	end
end