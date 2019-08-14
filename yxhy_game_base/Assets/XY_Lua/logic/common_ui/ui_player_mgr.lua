--[[--
 * @Description: UI 角色的模型管理
 * @Author:      shine
 * @FileName:    ui_player_mgr.lua
 * @DateTime:    2015-11-07 11:28:02
 ]]

require "logic/common_ui/ui_player"

ui_player_mgr = ui_base.New()
ui_player_mgr.__index = ui_player_mgr

local uiPlayerMgr = nil 

--[[--
 * @Description: 构造函数  
 ]]
function ui_player_mgr.New()
	local self = {}
	setmetatable(self, ui_player_mgr)

	self.actorFactory = nil
	self.ui_players = {}
	self.characterPanel = nil

	return self
end

--//////////////////////各个成员函数 //////////////////////////
function ui_player_mgr:Initialize()
	if uiPlayerMgr == nil then
		uiPlayerMgr = ui_player_mgr.New()
		uiPlayerMgr.actorFactory = GameKernel.GetActorFactory()
	end
	return uiPlayerMgr
end

function ui_player_mgr:Uninitialize()
	self:RemoveAllPlayerInfo()
	self.actorFactory = nil
	self.ui_players = {}
	self.characterPanel = nil
end


function ui_player_mgr:GetPlayerByActorID(preKey, actorID)
	local strID = preKey..toUint64String(actorID)
	for i,v in pairs(self.ui_players) do
		if i == strID then
			return v
		end
	end
	return nil
end

--[[--
 * @Description: 设置ui角色可旋转  
 ]]
function ui_player_mgr:SetPlayerCanRotateToggle(preKey, actorID, toggle)
	local strID = preKey..toUint64String(actorID)
	local uiPlayer = self:GetPlayerByActorID(preKey, actorID)
	if uiPlayer ~= nil then
		uiPlayer:SetPlayerCanRotateToggle(toggle)
	end
end

--[[--
 * @Description: 设置ui角色可旋转  
 ]]
function ui_player_mgr:SetPlayerDragArea(preKey, actorID, radius)
	local strID = preKey..toUint64String(actorID)
	local uiPlayer = self:GetPlayerByActorID(preKey, actorID)
	if uiPlayer ~= nil then
		uiPlayer:SetPlayerDragArea(radius)
	end
end

--[[--
 * @Description: 设置角色的胶囊体大小 并放置到脚底 
 ]]
function ui_player_mgr:SetPlayerCapsule(preKey, actorID, hight)
	local strID = toUint64String(actorID)
	local uiPlayer = self:GetPlayerByActorID(preKey, actorID)
	if uiPlayer ~= nil then
		uiPlayer:SetPlayerCapsule(hight)
	end
end

--[[--
 * @Description: 设置角色灯光效果开关  
 ]]
function ui_player_mgr:SetPlayerLight(preKey, actorID, state)
	local strID = toUint64String(actorID)
	local uiPlayer = self:GetPlayerByActorID(preKey, actorID)
	if uiPlayer ~= nil then
		uiPlayer:SetActorLightToggle(state)
	end	
end

--[[--
 * @Description: 移除所有角色信息  
 ]]
function ui_player_mgr:RemoveAllPlayerInfo()
	for i,v in pairs(self.ui_players) do
		if self.ui_players[i] ~= nil then
			self.ui_players[i]:Uninitialize()
			self.ui_players[i] = nil
		end
	end
end

--[[--
 * @Description: 移除角色信息  
 ]]
function ui_player_mgr:RemovePlayerInfo(preKey, actorID)
	if (actorID == nil) then
		return
	end
	local strID = preKey..toUint64String(actorID)
	
	if self.ui_players[strID] ~= nil then
		self.ui_players[strID]:Uninitialize()
		self.ui_players[strID] = nil
	end
end

function ui_player_mgr:RemovePlayerInfoByPreKey(preKey)
	for i,v in pairs(self.ui_players) do
		if v ~= nil then
			if string.find(i, preKey) then
				v:Uninitialize()
				self.ui_players[i] = nil			
			end
		end
	end
end

--[[--
 * @Description: 设置ui角色状态
 ]]
function ui_player_mgr:SetPlayerState(actorID)

end

--[[--
 * @Description: 设置ui角色信息  
 ]]
function ui_player_mgr:SetPlayerInfo(preKey, actorID, configID, pos, direct, scale, heroData, nodeObj)
	local strID = preKey..toUint64String(actorID) 
	if self.ui_players[strID] == nil then
		self.ui_players[strID] = self:CreatePlayer(actorID, self.actorFactory, configID, heroData, pos, direct, scale, nodeObj)
	end
	return self.ui_players[strID]
end

function ui_player_mgr.CreateCallback(actorObj)
	--异步加载的回调
	local luaScriptCls = logicLuaObjMgr.getLuaObjByGameObj(actorObj)
	if (luaScriptCls == nil) then
		warning("ui_player_mgr.CreateCallback().  luaScriptCls == nil")
		return
	end

	local actorObjData = actorObj:GetComponent(typeof(NS_Actor.ActorObjectData))
	local modelObj = actorObjData.modelRootGo
	--modelObj.transform.localPosition = Vector3.zero
	modelObj.transform.localScale = Vector3.one
	modelObj.transform.localRotation = Vector3.zero

	luaScriptCls.curPlayer:RefreshExterior(false, false)
	luaScriptCls:RecursiveSetLayerVal(luaScriptCls.curPlayer.transForm, LayerMask.NameToLayer("UI"))
end

function ui_player_mgr:CreatePlayer(roleID, actorFactory, configID, playerData, bornPos, direct, scale, nodeObj)
	--local actorObj = actorFactory:CreateUIHero(configID, "Hero_"..toUint64String(roleID))
	local actorObj = actorFactory:CreateUIHeroAsync(configID, "Hero_"..toUint64String(roleID), "ui_player_mgr.CreateCallback")
	
	local luaScriptCls = nil
	if not IsNil(actorObj) then
		local logicBaseLua = actorObj.gameObject:GetComponent(typeof(LogicBaseLua))
	    if (logicBaseLua == nil) then
	        logicBaseLua = actorObj.gameObject:AddComponent(typeof(LogicBaseLua))
	    end
	    logicBaseLua.fullLuaFileName = "logic/common_ui/ui_player"
	    logicBaseLua:RefreshLuaSetting()

	    luaScriptCls = logicLuaObjMgr.getLuaObjByGameObj(actorObj)
	    --luaScriptCls = ui_player.New()
		if (luaScriptCls ~= nil) then
			luaScriptCls.curPlayer = Player.New()
			luaScriptCls.curPlayer:SetObjectToLua(myUint64ToLuaInt64(roleID), actorObj, configID, playerData)
		
			--调整位置
			local playerParent = nil 
			if nodeObj ~= nil then
				playerParent = nodeObj
			else
				playerParent = GameObject.Find("panel_character")
			end
			if (playerParent ~= nil) then
				local uiEffect = actorObj.gameObject:GetComponent(typeof(UIEffect))
			    if (uiEffect == nil) then
			        uiEffect = actorObj.gameObject:AddComponent(typeof(UIEffect))
			    end
			    
				luaScriptCls.curPlayer.transForm.parent = playerParent.transform
				luaScriptCls.curPlayer.transForm.localPosition = Vector3.zero
				
				--指定位置
				if bornPos ~= nil and (bornPos.x ~= 0 or bornPos.y ~= 0 or bornPos.z ~= 0) then
					luaScriptCls.curPlayer.transForm.localPosition = bornPos
				end

				--指定方向
				if direct ~= nil then
					luaScriptCls.curPlayer.transForm.localRotation = direct
				end

				if scale ~= nil then
					luaScriptCls.curPlayer.transForm.localScale = scale
				end

				local resourceMgr = GameKernel.GetResourceMgr()
				local obj = newNormalObjSync(data_center.GetAppConfDataTble().appPath.."/ui/common/actor_light", typeof(GameObject))
				luaScriptCls.actorLight = newobject(obj.transform).transform
				luaScriptCls.actorLight.parent = playerParent.transform	
				luaScriptCls.actorLight.transform.localPosition = Vector3.New(219, 15, -25)	
				luaScriptCls.actorLight.transform.localScale = Vector3.New(4.65, 4.65, 4.65)	
			end	

			luaScriptCls.skillCtrl = luaScriptCls.curPlayer:AddComponent(BaseComponentFactory.New_SkillCtrl())
			luaScriptCls.skillCtrl:Init(luaScriptCls.curPlayer)

			--换装组件
			luaScriptCls.avatorData = luaScriptCls.curPlayer:AddComponent(BaseComponentFactory.New_AvatarData())
			--刷新外观
			--luaScriptCls.curPlayer:RefreshExterior(false, false)
			luaScriptCls.spinWithMouse = luaScriptCls.curPlayer.gameObject:AddComponent(typeof(SpinWithMouse)) 
			luaScriptCls.spinWithMouse.target = luaScriptCls.curPlayer.transForm
			--luaScriptCls:RecursiveSetLayerVal(luaScriptCls.curPlayer.transForm, LayerMask.NameToLayer("UI"))
		end
	end
	return luaScriptCls
end

--[[--
 * @Description: 设置ui角色可以换装  
 ]]
function ui_player_mgr:RecursiveSetLayerVal(preKey, actorID, layerOut)
	local strID = preKey..toUint64String(actorID)
	if self.ui_players[strID] ~= nil then
		self.ui_players[strID]:RecursiveSetLayerVal(self.ui_players[strID].curPlayer.transForm, layerOut)
	end
end

--[[--
 * @Description: 设置ui角色可以换装  
 ]]
function ui_player_mgr:SetPlayerAvatar()
	-- body
end

--[[--
 * @Description: 刷新外观  
 ]]
function ui_player_mgr:RefreshExterior(preKey, actorID)
	local strID = preKey..toUint64String(actorID)
	if self.ui_players[strID] ~= nil then
		self.ui_players[strID]:RefreshExterior(false, false)
	end
end

function ui_player_mgr:TryOnExterior(preKey, actorID, tryOnType, outwardId)
	local strID = preKey..toUint64String(actorID)
	if self.ui_players[strID] ~= nil then
		self.ui_players[strID]:TryOnExterior(tryOnType, outwardId)
	end
end

function ui_player_mgr:GetOffExterior(preKey, actorID, tryOnType, outwardId)
	local strID = preKey..toUint64String(actorID)
	if self.ui_players[strID] ~= nil then
		self.ui_players[strID]:GetOffExterior(tryOnType, outwardId)
	end
end