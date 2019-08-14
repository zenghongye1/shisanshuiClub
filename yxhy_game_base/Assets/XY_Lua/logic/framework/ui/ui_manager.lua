-- create by xuemin.lin
require "common/extern"

ui_manager_instace = nil
local ui_manager = class("ui_manager")

function ui_manager:ctor()
	self.m_CacheAllUiForms = {}
	self.m_CurrentShowFormsList = {} --当前显示的UI列表
	self.m_NavigationStackUiForms = require("logic.framework.ui.stack"):create()
	self.m_UiRoot = UnityEngine.GameObject.Find("uiroot_xy/Camera")
	self.m_CurrentDepthForNormalLayer =  0
	self.m_CurrentDepthForBottomLayer = 0
	self.m_CurrentDepthForTopLayer = 0
	self.m_offsetDepth = 20
end

function ui_manager:Instance()
	if ui_manager_instace == nil then
		ui_manager_instace = require("logic.framework.ui.ui_manager"):create()
	end
	return ui_manager_instace
end

--[[
	**UiFormName : UI界面的名字
	**CloseType  ：打开界面的时候关闭其他界面，或者不关闭其他界面，类型参照UiCloseType
	**OnCloseCb  ：这个界面被关闭完成的回调
]]
function ui_manager:ShowUiForms(UiFormName,CloseType,OnCloseCb,...)
	local Ui = self:FindUiFormsInCache(UiFormName,self.m_CacheAllUiForms)
	if Ui == nil then
		Ui = self:LoadFormsToCache(UiFormName)
		table.insert(self.m_CurrentShowFormsList,Ui)
	else
		local currentShowUi = self:FindUiFormsInCache(Ui.UiFormName,self.m_CurrentShowFormsList)
		if currentShowUi == nil then
			table.insert(self.m_CurrentShowFormsList,Ui)
		end
	end
--	table.insert(self.m_CurrentShowFormsList,Ui)
	if Ui.m_UiLayer ==  UILayerEnum.UILayerEnum_Normal  then
		if CloseType == UiCloseType.UiCloseType_CloseNothing or CloseType == nil then
		elseif CloseType == UiCloseType.UiCloseType_CloseOther or CloseType == UiCloseType.UiCloseType_Navigation then
			if self.m_CurrentShowFormsList ~= nil then
				for i = #self.m_CurrentShowFormsList ,1,-1 do
					local v = self.m_CurrentShowFormsList[i]
					if v.IsOpened == true and v.m_UiLayer == UILayerEnum.UILayerEnum_Normal and v.UiFormName ~= Ui.UiFormName then
						if CloseType == UiCloseType.UiCloseType_CloseOther then
							self:CloseUiForms(v.UiFormName)
						elseif  CloseType == UiCloseType.UiCloseType_Navigation then
							v:Close()
						end
					end
				end
			end
			if CloseType == UiCloseType.UiCloseType_Navigation then
				self:NavigationPush(Ui)
			end
		end
	elseif Ui.m_UiLayer == UILayerEnum.UILayerEnum_Main then
	
		
	elseif Ui.m_UiLayer == UILayerEnum.UILayerEnum_Top then
		
	end
	Ui:Open(CloseType,OnCloseCb,...)
	self:UpdateUiFromsDepth()	
	return Ui
end

--[[
	**UiFormName :要关闭的 UI界面名字
]]
function ui_manager:CloseUiForms(UiFormName,IsDestory)
	local Ui,index = self:FindUiFormsInCache(UiFormName,self.m_CurrentShowFormsList)
	if Ui ~= nil then
		if Ui.m_UiLayer ==  UILayerEnum.UILayerEnum_Normal then
			if Ui.m_CloseType == UiCloseType.UiCloseType_CloseNoting or Ui.m_CloseType == nil then
			elseif Ui.m_CloseType == UiCloseType.UiCloseType_CloseOther then
				
			elseif Ui.m_CloseType == UiCloseType.UiCloseType_Navigation then
				self:NavigationPop()	
				table.remove(self.m_CurrentShowFormsList,index)
		--		Trace("============="..table.nums(self.m_CurrentShowFormsList))
				return
			end
		end
		if Ui.IsOpened == true then
		
			Ui:Close()
			--Notifier.dispatchCmd(GameEvent.OnCloseWindow, UiFormName)
		end
		table.remove(self.m_CurrentShowFormsList,index)

	end
	if IsDestory or (Ui ~= nil and Ui.destroyType == UIDestroyType.Immediately)  then
		local destoryUi,index = self:FindUiFormsInCache(UiFormName,self.m_CacheAllUiForms)
		if destoryUi ~= nil then
			GameObject.Destroy(destoryUi.gameObject)
			table.remove(self.m_CacheAllUiForms,index)
		end
		
	end
end

--
function ui_manager:FastTip(text, time, pos, encoding, outlineColorValue)
	local fastTip = self:ShowUiForms("fast_tip",UiCloseType.UiCloseType_CloseNothing)
	fastTip:Show(text, time, pos, encoding, outlineColorValue)
	return fastTip
	
end

--[[
	根据UI窗口的名字查找是否这个UI存在缓存中
  ]]
function ui_manager:FindUiFormsInCache(UiFormName,UiList)
	for i,v in pairs(UiList) do
		if v.UiFormName == UiFormName then
			return v,i
		end
	end
	return nil
end

function ui_manager:GetUiFormsInShowList(UiFormName)
	for i,v in pairs(self.m_CurrentShowFormsList) do
		if v.UiFormName == UiFormName then
		--	logError("v.UiFormName:"..tostring(v.UiFormName).." other:"..UiFormName)
			return v
		end
	end
	return nil
end

--[[
	更新Panel的深度,为panel的深度排序。isopen为ture表示当前打开，false表示隐藏
]]
function ui_manager:UpdateUiFromsDepth()
	self.m_CurrentDepthForNormalLayer =0
	self.m_CurrentDepthForBottomLayer = 0
	self.m_CurrentDepthForTopLayer = 0
	if table.nums(self.m_CurrentShowFormsList) > 0 then
	for i,Ui in ipairs(self.m_CurrentShowFormsList) do
		local panel = componentGet(Ui.gameObject.transform,"UIPanel")
		if Ui.m_UiLayer ==  UILayerEnum.UILayerEnum_Normal then
				self.m_CurrentDepthForNormalLayer = self.m_CurrentDepthForNormalLayer + self.m_offsetDepth	
				panel.depth = tonumber(Ui.m_UiLayer) + self.m_CurrentDepthForNormalLayer
			
			elseif Ui.m_UiLayer == UILayerEnum.UILayerEnum_Bottom then
				self.m_CurrentDepthForBottomLayer = self.m_CurrentDepthForBottomLayer + self.m_offsetDepth	
				panel.depth = tonumber(Ui.m_UiLayer) + self.m_CurrentDepthForBottomLayer
			elseif Ui.m_UiLayer == UILayerEnum.UILayerEnum_Top then
				
				self.m_CurrentDepthForTopLayer = self.m_CurrentDepthForTopLayer + self.m_offsetDepth	
				panel.depth = tonumber(Ui.m_UiLayer) + self.m_CurrentDepthForTopLayer
			--	logError("UILayerEnum_Top:"..tostring(panel.depth))
			end
			panel.sortingOrder = panel.depth
			Ui.sortingOrder = panel.depth
			Ui:RefreshDepth()
		end
	end
end

--[[
	用于导航界面。Push是打开一个新UI
]]
function ui_manager:NavigationPush(Ui)	
	self.m_NavigationStackUiForms:Push(Ui) 
end

--[[
	用于导航界面。Pop是回退到上一级UI
]]
function ui_manager:NavigationPop()
	local Ui = self.m_NavigationStackUiForms:Pop()
	if Ui ~= nil then
		if Ui.IsOpened == true then
			Ui:Close()
		end
		Ui = self.m_NavigationStackUiForms:Top()
		if Ui~= nil and Ui.IsOpened == false then
			
			Ui:Open(Ui.m_CloseType)
			self:UpdateUiFromsDepth()
		end
		return Ui
	end
end


function ui_manager:OnBeforeChangeScene()
	for i = #self.m_CacheAllUiForms , 1, -1 do
		if not self.m_CacheAllUiForms[i].IsOpened 
			and self.m_CacheAllUiForms[i].destroyType == UIDestroyType.ChangeScene then
			GameObject.Destroy(self.m_CacheAllUiForms[i].gameObject)
			table.remove(self.m_CacheAllUiForms,i)
		end
	end
end

--[[
	加载UI，私有方法，外界不需要调用到
]]
function ui_manager:LoadFormsToCache(UiFormName)
	if ui_prefab_enum["ui_enum_"..UiFormName] == nil then
		return
	end
	return self:LoadUIForm(UiFormName)
end

function ui_manager:LoadUIForm(UiFormName)
	local luaFile = ui_script_enum["ui_script_"..UiFormName]
	local luaFileObj = require(luaFile):create()
	luaFileObj.UiFormName = UiFormName
	luaFileObj.m_UiRoot = self.m_UiRoot
	table.insert(self.m_CacheAllUiForms,luaFileObj)
	return luaFileObj
end

--这个方法可以不用，用OnInit代替
function ui_manager:Awake(UiFormsName)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.Awake ~= nil then
		Ui:Awake()
	end
end

function ui_manager:Start(UiFormsName)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.Start ~= nil then
		Ui:Start()
	end
end

function ui_manager:Update(UiFormsName)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CurrentShowFormsList)
	if Ui ~= nil and Ui.IsOpened == true and Ui.Update~= nil then
		Ui:Update()
	end
end

function ui_manager:OnEnable(UiFormsName)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnEnable ~= nil then
		Ui:OnEnable()
	end
end

function ui_manager:OnDisable(UiFormsName)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnDisable ~= nil then
		Ui:OnDisable()
	end
end

function ui_manager:OnTriggerEnter(UiFormsName,collider)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnTriggerEnter ~= nil then
		Ui:OnTriggerEnter(collider)
	end
end

function ui_manager:OnTriggerStay(UiFormsName,collider)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnTriggerStay ~= nil then
		Ui:OnTriggerStay(collider)
	end
end

function ui_manager:OnTriggerExit(UiFormsName,collider)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnTriggerExit ~= nil then
		Ui:OnTriggerExit(collider)
	end
end

function ui_manager:OnCollisionEnter(UiFormsName,collision)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnCollisionEnter ~= nil then
		Ui:OnCollisionEnter(collision)
	end
end

function ui_manager:OnCollisionStay(UiFormsName,collision)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnCollisionStay ~= nil then
		Ui:OnCollisionStay(collision)
	end
end

function ui_manager:OnCollisionExit(UiFormsName,collision)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnCollisionExit ~= nil then
		Ui:OnCollisionExit(collision)
	end
end

function ui_manager:OnFingerHover(UiFormsName,e)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CurrentShowFormsList)
	if Ui ~= nil and Ui.OnFingerHover ~= nil then
		Ui:OnFingerHover(e)
	end
end

function ui_manager:OnSwipe(UiFormsName,Direction,SelectObj)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CurrentShowFormsList)
	if Ui ~= nil and Ui.OnSwipe ~= nil then
		Ui:OnSwipe(Direction,SelectObj)
	end
end

function ui_manager:OnFingerUp(UiFormsName,fingerUp)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CurrentShowFormsList)
	if Ui ~= nil and Ui.OnFingerUp ~= nil then
		Ui:OnFingerUp(fingerUp)
	end
end

function ui_manager:OnFingerDown(UiFormsName,fingerDown)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnFingerDown ~= nil then
		Ui:OnFingerDown(fingerDown)
	end
end

function ui_manager:OnTap(UiFormsName,tap)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnTap ~= nil then
		Ui:OnTap(tap)
	end
end

function ui_manager:OnDragRecognizer(UiFormsName,DeltaMove,normalizedTime)
	local Ui = self:FindUiFormsInCache(UiFormsName,self.m_CacheAllUiForms)
	if Ui ~= nil and Ui.OnDragRecognizer ~= nil then
		Ui:OnDragRecognizer(DeltaMove,normalizedTime)
	end
end

return ui_manager