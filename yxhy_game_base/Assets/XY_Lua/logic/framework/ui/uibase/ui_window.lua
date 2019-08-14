UILayerEnum = 
{
	UILayerEnum_Bottom = -100,
	UILayerEnum_Normal = 100,  	--用于普通的UI类型
	UILayerEnum_Top = 1600,  	--针对于弹对话框,推送跑马灯用这个类型用这个类型
}

UiCloseType = {
	UiCloseType_CloseNothing = 0, --打开后不影响其他UI，用于二级界
	UiCloseType_CloseOther =1,	  --打开会关闭其他Normal层的UI,用于一级界面
	UiCloseType_Navigation = 2,	  --导航栏UI，会压入导航栏堆栈
}

UIDestroyType =
{
	None = 1,
	Immediately = 2,
	ChangeScene = 3,
}

local ui_window = class("ui_window")

function ui_window:ctor()
	self.m_UiRoot = nil
	self.args = nil
	self.gameObject = nil
	self.transform = nil
	self.UiFormName = nil
	self.IsOpened = false
	self.m_CloseType = UiCloseType.CloseType_Nothing
	self.m_OpenAnim = nil
	self.m_CloseAnim = nil
	self.m_OnBack = nil
	self.m_inited = false
	self.m_OnClose = nil
	self.m_UiLayer = UILayerEnum.UILayerEnum_Normal
	self.m_defaultLayer = {}
	self.m_animationTime = 0.4 -- 0.5 --默认播放动画的时长
	self.sortingOrder = 0		--UI 主panel的sortingOrder		
	self.m_subPanelCount = 0	--子panel的数量
	self.destroyType = UIDestroyType.None
end

function ui_window:Init()
	if self.m_inited == true then return end
	self.m_inited = true
--	self.m_UiLayer = UILayerEnum.UILayerEnum_Normal
	local path = ui_prefab_enum["ui_enum_"..self.UiFormName]
	self.gameObject = LoadNarmalUI(path)
	self.transform = self.gameObject.transform
	self.gameObject.transform.parent = self.m_UiRoot.gameObject.transform
	self:SaveDefaultDepth()
	self:SetUIBase()
	self:OnInit()
end

--初始化，相当于awake生命周期内只执行一次
function ui_window:OnInit()
end

function ui_window:Open(CloseType,OnCloseCb, ... )
	if ... ~= nil then
		self.args = { ... }
	end
	if CloseType ~= nil then
		self.m_CloseType = CloseType
	else
		self.m_CloseType = UiCloseType.CloseType_Nothing
	end
	self:Init()
	if OnCloseCb ~= nil then
		self.m_OnClose = OnCloseCb
	end
	self.gameObject:SetActive(true)
	self.IsOpened =true
	
	self:PlayOpenAmination()
	self:OnOpen( ... )
end

--每次打开界面都会调用一次
function ui_window:OnOpen(...)
end

function ui_window:Refresh()
end
--刷新界面
function ui_window:OnRefresh()
end

--保存子panel的默认深度
function ui_window:SaveDefaultDepth()
	self.m_defaultLayer = {}
	local childPanel = self.gameObject:GetComponentsInChildren(typeof(UIPanel),true)
	if childPanel ~= nil then
		for j = 0,childPanel.Length -1,1 do
			local obj = childPanel[j]
			if obj.name ~= self.gameObject.name then
				local data = {}
				data.name = obj.gameObject.name
				data.depth = obj.depth
				data.panel = obj
				if data.depth > 9 then
			--		logError("子 panel不能超过10，必须改掉！！UI:"..self.gameObject.name.." 子panel:"..obj.gameObject.name.." depth:"..tostring(obj.depth))
				end
			
				table.insert(self.m_defaultLayer,data)
			end
		end
	end
end

--重置子panel的默认深度
function ui_window:ReSetDefaultDepth()
	if self.m_defaultLayer ~= nil and #self.m_defaultLayer > 0 then
		for i,v in ipairs(self.m_defaultLayer) do
			v.panel.depth = v.depth
		end
	end
end

--刷新界面下子panel的深度
function ui_window:RefreshDepth()
	self:ReSetDefaultDepth()
	self:SaveDefaultDepth()
	if self.m_defaultLayer ~= nil and #self.m_defaultLayer > 0 then
		self.m_subPanelCount = table.nums(self.m_defaultLayer)
		local panel = componentGet(self.gameObject.transform,"UIPanel")
		local rootDepth = panel.depth
		for i,v in ipairs(self.m_defaultLayer) do
			v.panel.depth = v.panel.depth + rootDepth
			v.panel.sortingOrder = v.panel.depth
		end
	end
	self:OnRefreshDepth()
end

function ui_window:OnRefreshDepth()
end

function ui_window:Close()
	if self == nil or self.gameObject == nil then
		logError("this forms is already destory!")
	end
	if self.m_OnClose ~= nil then
		self.m_OnClose()
		self.m_OnClose = nil
	end
	self:PlayCloseAnimation()
	self:OnClose()
	self.gameObject:SetActive(false)
	self.IsOpened = false
end

--每次关闭都会被调用一次，跟OnOpen类似
function ui_window:OnClose()
end

function ui_window:SetUIBase()
	local uibase = componentGet(self.gameObject.transform,"UI_Base")
	if uibase ~= nil then
		local scriptName = ui_script_enum["ui_script_"..self.UiFormName]
		uibase.FullLuaFileName = scriptName
		if self.Update ~= nil then
			uibase.isUpdate = true
		else
			uibase.isUpdate = false
		end
		if self.LateUpdate ~= nil then
			uibase.isLaterUpdate = true
		else
			uibase.isLaterUpdate = false
		end
		if self.FixedUpdate ~= nil then
			uibase.isLaterUpdate = true
		else
			uibase.isLaterUpdate = false
		end
	end
end

function ui_window:PlayOpenAmination(animationAnchor)
	-- if animationAnchor ~= nil then
	-- 	local anchor = self.transform:FindChild(animationAnchor)
	-- 	if anchor ~= nil then
	-- 		anchor.transform.localScale = Vector3(0,0,0)
	-- 		anchor.transform:DOScale(Vector3.one,self.m_animationTime)
	-- 	end
	-- else
	-- 	self.transform.localScale = Vector3(0,0,0)
	-- 	self.transform:DOScale(Vector3.one,self.m_animationTime)
	-- end	

	-- local collider = self:GetGameObject("collider")
	-- if collider then
	-- 	local colliderSprite = collider.transform:GetComponent("UISprite")
	-- 	if colliderSprite then
	-- 		local tweenAlpha = collider.gameObject:AddComponent(typeof(TweenAlpha))
	-- 		if tweenAlpha then
	-- 			tweenAlpha.from = 0
	-- 			tweenAlpha.to = 0.8 --colliderSprite.color.a

	-- 			tweenAlpha.duration = 0.1
	-- 			tweenAlpha.enabled = true
	-- 			-- tweenAlpha:ResetToBeginning()
	-- 			tweenAlpha:AddOnFinished(EventDelegate.Callback(function()
	-- 				--todo
	-- 			end))
	-- 			--alpha
	-- 			colliderSprite.gameObject:SetActive(false)
	-- 			coroutine.start(function()
	-- 				coroutine.wait(self.m_animationTime *0.2)
	-- 				colliderSprite.gameObject:SetActive(true)
	-- 				tweenAlpha:ResetToBeginning()
	-- 			end)
	-- 		end
	-- 	end
	-- end

	local scaleBegin = Vector3(0.7,0.7,1)
	if animationAnchor ~= nil then
		local anchor = self.transform:FindChild(animationAnchor)
		if anchor ~= nil then
			anchor.transform.localScale = scaleBegin
			anchor.transform:DOScale(Vector3.one,self.m_animationTime):SetEase(DG.Tweening.Ease.OutBack, 0.3)
		end
	else
		self.transform.localScale = scaleBegin
		-- self.transform:DOScale(Vector3.one,self.m_animationTime):SetEase(DG.Tweening.Ease.OutBack, 3):OnComplete(function()
		-- self.transform:DOScale(Vector3(0.98,0.98,1), 0.25):SetEase(DG.Tweening.Ease.OutBack, 6):OnComplete(function()
		-- 		--特效完成
		-- 		self.transform:DOScale(Vector3.one, 0.1):SetEase(DG.Tweening.Ease.InOutBack, 5)
		-- 	end)
		coroutine.start(function()
			-- coroutine.wait(0.05)
			self.transform:DOScale(Vector3.one,self.m_animationTime):SetEase(DG.Tweening.Ease.OutBack)
				:OnComplete(function()
						--特效完成
				end)
		end)
	end
	
	coroutine.start(function()
		coroutine.wait(self.m_animationTime)
		self:PlayOpenAnimationFinishCallBack()
	end)
end

function ui_window:PlayOpenAnimationFinishCallBack()

end

function ui_window:PlayCloseAnimation()
end

function ui_window:GetComponent(path, type)
	return subComponentGet(self.transform, path, type)
end

function ui_window:GetGameObject(path)
	local tr = self.transform:Find(path)
	if tr ~= nil then
		return tr.gameObject
	end
	return nil
end

function ui_window:GetTransform(path)
	local tr = self.transform:Find(path)
	if tr ~= nil then
		return tr
	end
	return nil
end

return ui_window