local base = require("logic.framework.ui.uibase.ui_window")
local cuopai_ui = class("cuopai_ui",base)

function cuopai_ui:ctor()
	base.ctor(self)
	self.IsOpenCuoPaiUI = false
	self.cuoPaiAnimObj = nil
	self.currentScene = nil
	self.cardTranTbl = {}
end

function cuopai_ui:OnOpen( ... )
	self:OnClose()
	Notifier.regist("CUO_PAI", slot(self.cuopai,self))
	local tbl = {}
	tbl.isShowAnchor = true
	Notifier.dispatchCmd(cmd_niuniu.ONDRAGACTION,tbl)
	self.IsOpenCuoPaiUI = true

	
	if self.args ~= nil and #self.args > 1 then
		local cards = self.args[1]
		self:LoadAllCard(cards)
		self.currentScene = self.args[2]
	end
end

function cuopai_ui:cuopai(tbl)
	self.cuoPaiAnimObj = tbl
end

function cuopai_ui:OnInit()
	self.closeBtn = child(self.transform,"closebtn")
	if self.closeBtn ~= nil then
		addClickCallbackSelf(self.closeBtn.gameObject,self.OnCloseClick,self)
	end
	self.cardGrid = child(self.transform, "Anchor_Center/cardGrid")
	self.grid =  componentGet(self.cardGrid,"UIGrid")
	
end

function cuopai_ui:OnClose()
	Notifier.remove("CUO_PAI", slot(self.cuopai,self))
	self.IsOpenCuoPaiUI = false
	if table.nums(self.cardTranTbl) ~= 0 then
		for i, v in pairs(self.cardTranTbl) do
			if v ~= nil then
				v.gameObject.transform.parent = nil
				v.gameObject:SetActive(false)
				GameObject.Destroy(v.gameObject)
				
			end
		end
		self.grid:Reposition()
		self.cardTranTbl = {}
	end
end

function cuopai_ui:PlayOpenAmination()
end

function cuopai_ui:OnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	Trace("关闭搓牌界面")
	--这里记得改成小写
--	local anchor = GameObject.Find("CuoPaiAnchor")
	local anchor = GameObject.Find("cuopaianchor")
	if anchor ~= nil then
		anchor.gameObject:SetActive(false)
	end
	UI_Manager:Instance():CloseUiForms("cuopai_ui")
end

function cuopai_ui:Update()
	if self.cuoPaiAnimObj ~= nil then
		local stateInfo = self.cuoPaiAnimObj:GetCurrentAnimatorStateInfo(0)
		if stateInfo ~= nil then
			local normalizedTime = stateInfo.normalizedTime
			if normalizedTime >= 0.85 then
				self.currentScene.tableComponent:OpenLastCard()
				self:OnCloseClick()
			end
		end
	end
end

function cuopai_ui:OnSwipe(myself,direction,fingerSwipe)
	Trace("Direction:"..tostring(direction))
	
end

function cuopai_ui:OnDragRecognizer(deltaMove,normalizedTime)
--	Trace("CuoPai On Drag"..tostring(GetTblData(gesture)))
	local gesture = {}
	gesture.isShowAnchor = false
	gesture.DeltaMove = deltaMove
	gesture.normalizedTime = normalizedTime
	Notifier.dispatchCmd(cmd_niuniu.ONDRAGACTION,gesture)
end

function cuopai_ui:OnFingerUp(fingerUpEvent)
		
end

function cuopai_ui:LoadAllCard(cards)
	if self.cardGrid == nil then
		Trace("cardGrid == nil")
		return
	end
	for i, v in pairs(cards) do
		if i < #cards then
			local cardObj = poker2d_factory.GetPoker(v)
			cardObj.transform:SetParent(self.cardGrid,false)
			self.cardTranTbl[i] = cardObj
			componentGet(child(self.cardTranTbl[i].transform, "bg"),"UISprite").depth = i * 2 + 3
			componentGet(child(self.cardTranTbl[i].transform, "num"),"UISprite").depth = i * 2 + 5
			componentGet(child(self.cardTranTbl[i].transform, "color1"),"UISprite").depth = i * 2 + 5
			componentGet(child(self.cardTranTbl[i].transform, "color2"),"UISprite").depth = i * 2 + 5
		end
	end
	self.grid:Reposition()
end


return cuopai_ui
