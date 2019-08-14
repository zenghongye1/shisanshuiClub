local base = require("logic/mahjong_sys/components/mode_1/comp_mjPlayer")
local comp_mjSelfPlayer = class("comp_mjSelfPlayer", base)


function comp_mjSelfPlayer:ctor()
	self.curClickMJItem = nil
    self.curReqOutItem = nil --当前请求出牌的牌
    self.curDragItem = nil
    self.curScrollItem = nil  -- 手指滑动时 当前选中item

    self.canOutCard = false

    self.filterCards = {}

    -- 手指滑动时 当前选中item
    self.curScrollItem = nil
	base.ctor(self)
	self:RegisterEvents()
end

function comp_mjSelfPlayer:RegisterEvents()
	InputManager.AddLock()
    Notifier.regist(cmdName.MSG_MOUSE_BTN_UP, slot(self.OnMouseUp, self))
    Notifier.regist(cmdName.MSG_MOUSE_BTN, slot(self.OnMouseBtn, self))
end

function comp_mjSelfPlayer:UnRegisterEvents()
    InputManager.ReleaseLock()
    self.shakeTimer:Uninitialize()
    Notifier.remove(cmdName.MSG_MOUSE_BTN_UP, slot(self.OnMouseUp, self))
    Notifier.remove(cmdName.MSG_MOUSE_BTN, slot(self.OnMouseBtn, self))
end


--[[--
 * @Description: 显示可听牌箭头  
 ]]
function comp_mjSelfPlayer:ShowTingInHand()
    for i = 1, #self.handCardList do
        if roomdata_center.CheckCardTing(self.handCardList[i].paiValue) and not self.handCardList[i].isDisable then
            self.handCardList[i]:SetTingIcon(true)
        end
    end
end

--[[--
 * @Description: 隐藏可听牌箭头  
 ]]
function comp_mjSelfPlayer:HideTingInHand()
      for i = 1, #self.handCardList do
        self.handCardList[i]:SetTingIcon(false)
    end
end

--[[--
 * @Description: 麻将点击事件  
 ]]
function comp_mjSelfPlayer:ClickCardEvent( mj )
    if mj == self.curClickMJItem then
        if self.canOutCard then
            local paiVal = mj.paiValue
            Trace("-----------ClickCardEvent paiVal"..paiVal)
            if self:CheckCanSendOut(paiVal) then
                self.curReqOutItem = mj
                mahjong_play_sys.OutCardReq(paiVal,roomdata_center.tingType,roomdata_center.kouCardList)
                if self.viewSeat == 1 then
                    self:AutoOutCard(paiVal)
                end
            end
        else
            ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_click"))
        end
    else
--        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_click"))
        -- if self.curClickMJItem~=nil then
        --     self.curClickMJItem:SetSelectState(false)
        -- end
        for i = 1, #self.handCardList do
            self.handCardList[i]:SetSelectState(false)
        end
        self.curClickMJItem = mj
        self.curClickMJItem:SetSelectState(true)
        mode_manager.GetCurrentMode():GetComponent("comp_playerMgr"):SetHighLight(self.curClickMJItem.paiValue)
    end
end


function comp_mjSelfPlayer:CancelClick()
    if self.curClickMJItem~=nil then
        if not self.curClickMJItem.isDrag then
            self.curClickMJItem:SetSelectState(false)
        end
        self.curClickMJItem = nil
    end
end

function comp_mjSelfPlayer:AutoOutCard(paiValue)
    mahjong_ui.cardShowView:Hide()
    self:HideTingInHand()
    self:SetCanOut(false)
    roomdata_center.selfOutCard = paiValue
    local compPlayerMgr = self.mode:GetComponent("comp_playerMgr")
    local compResMgr = self.mode:GetComponent("comp_resMgr")
    compPlayerMgr:HideHighLight()
    self:OutCard(paiValue, function(pos) compResMgr:SetOutCardEfObj(pos) end)
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_out"))
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(paiValue))
end


--[[--
 * @Description: 麻将拖动事件  
 ]]
function comp_mjSelfPlayer:DragCardEvent(mj)
    if self.curClickMJItem~=nil and self.curClickMJItem~=mj then
        self.curClickMJItem:OnClickUp()
    end
    if self.canOutCard then
        local paiVal = mj.paiValue
        if self:CheckCanSendOut(paiVal) then
            self.curReqOutItem = mj
            mahjong_play_sys.OutCardReq(paiVal,roomdata_center.tingType,roomdata_center.kouCardList)
            if self.viewSeat == 1 then
                self.filterCards = nil
                self:RefreshHandCardDisable()
                self:AutoOutCard(paiVal)
            end
        end
    end
end

--[[--
 * @Description: 设置是否能出牌  
 ]]
function comp_mjSelfPlayer:SetCanOut( isCanCout, filterCards, isTingShow)
    if isTingShow and self.filterCards and filterCards then
        filterCards = self:CombineFilterCards(filterCards)
    end
    self.canOutCard = isCanCout
    self.filterCards = filterCards
    self:RefreshHandCardDisable(isTingShow)
end

--[[--
 * @Description: 叠加不能出的牌，即不清除上次不能出的牌
 ]]
function comp_mjSelfPlayer:CombineFilterCards(filterCards)
    local oldFilterCards = {}
    for _,v in ipairs(self.filterCards) do
        local isDiff = true
        for _,u in ipairs(filterCards) do
            if v == u then
                isDiff = false
                break
            end
        end
        if isDiff then
            table.insert(oldFilterCards,v)
        end
    end
    for _,v in ipairs(oldFilterCards) do
        table.insert(filterCards,v)
    end
    return filterCards
end

function comp_mjSelfPlayer:SetDisableCardShow(state)
    self.showDisableCards = state
end

function comp_mjSelfPlayer:RefreshHandCardDisable(isTingShow)
    local map = {}
    if self.filterCards ~= nil then
        for i = 1, # self.filterCards do
            map[self.filterCards[i]] = 1
        end
    end
    local hasCanSendCard = false
    for i = 1, #self.handCardList do
        if map[self.handCardList[i].paiValue] ~= nil then
            self.handCardList[i]:SetDisable(true)
            if self.handCardList[i] == self.curDragItem then
                self.curDragItem.isDrag = false
                self:TidyHandCard()
            end
        else
            hasCanSendCard = true
            self.handCardList[i]:SetDisable(false)
        end
    end
    if not hasCanSendCard and self.canOutCard and not isTingShow then -- 没有能出的牌，则最后一张必须能出
        self.handCardList[#self.handCardList]:SetDisable(false)
        RemoveAllValueFormTable(self.handCardList[#self.handCardList].paiValue,self.filterCards)
    end
end

function comp_mjSelfPlayer:SetAllHandCardDisable()
    for i = 1, #self.handCardList do
        self.handCardList[i]:SetDisable(true)
        if self.handCardList[i] == self.curDragItem then
            self.curDragItem.isDrag = false
            self:TidyHandCard()
        end
    end
end

function comp_mjSelfPlayer:CheckCanSendOut(paiValue)
    if self.filterCards == nil then
        return true
    end
    for i = 1, #self.filterCards do
        if self.filterCards[i] == paiValue then
            return false
        end
    end
    return true
end

function comp_mjSelfPlayer:SetKouInHand(turnCard)
    if turnCard and type(turnCard) == "table" then
        local index = 1
        for _,turnValue in ipairs(turnCard) do
            for i = index, #self.handCardList do
                if self.handCardList[i].paiValue == turnValue then
                    self.handCardList[i]:SetKouIcon(true)
                    index = i + 1
                    break
                end
            end
        end
    end
end

------------------------  重写 --------------------

function comp_mjSelfPlayer:Init()
	base.Init(self)
    self.curClickMJItem = nil
    self.curReqOutItem = nil --当前请求出牌的牌
    self.curDragItem = nil
    self.curScrollItem = nil  -- 手指滑动时 当前选中item
	self.canOutCard = false
	self.filterCards = {}
    self.shakeTimer = require("logic/mahjong_sys/components/base/comp_shakeTimer"):create()

end

function comp_mjSelfPlayer:OnMjAddHand(mj)
    mj.onClickCallback = slot(self.ClickCardEvent, self)
    mj.dragEvent = function( mj )
        self:DragCardEvent( mj )
    end            
    if mj.paiValue ~= nil then
        roomdata_center.AddMj(mj.paiValue)
    end
end

function comp_mjSelfPlayer:OnSortMj(mj)
    mj.canClick = true
    mj.onClickCallback = slot(self.ClickCardEvent, self)
end

function comp_mjSelfPlayer:SortHandWithAnim(notIncludeLast)
    local needAdjuct = true
    local lastMJ = self.handCardList[#self.handCardList]
    self.InsertSort(self.handCardList,notIncludeLast and self:IsRoundSendCard(#self.handCardList))
    if not self.cfg.specialNotSort then
        self:PutFrontSpecialCard(self.handCardList)
    end
    local needInsertAnim = false
    if lastMJ ~= self.handCardList[#self.handCardList] then
        needInsertAnim = true
    end
    for i=1,#self.handCardList do
        local x = self:GetHandPosX(i)
        local mj = self.handCardList[i]
        if mj == lastMJ and needInsertAnim then
            needAdjuct = false
            self:DoSortLastHandCardAnim(mj, x)
        else
            mj:DOLocalMove(x, 0, 0,0)
            mj:DOLocalRotate(nil, 0,0, 0)
            mj:ShowShadow()
        end
    end
    return needAdjuct
end


function comp_mjSelfPlayer:OutCard(paiValue, callback)
    self.handCardCount = self.handCardCount - 1
    local isOut = false
    local outIndex = -1
    for i = 1, #self.handCardList, 1  do
    	if self.handCardList[i].paiValue == paiValue then
    		outIndex = i
    		if self.curReqOutItem ~= nil and self.curReqOutItem == self.handCardList[i] then
    			break
    		end
    	end
    end

    local outMj = self.handCardList[outIndex]
    if outMj ~= nil then
    	table.remove(self.handCardList,outIndex)
    	self.curReqOutItem = nil
        self.curClickMJItem = nil
        self.curScrollItem = nil
        self:DoOutCard(outMj, callback)
    end
end

function comp_mjSelfPlayer:OnResetHandCard(mj, value)
    mj:SetMesh(value)

    mj.onClickCallback = slot(self.ClickCardEvent, self)

    mj.dragEvent = function( mj )
        self:DragCardEvent( mj )
    end            
    roomdata_center.AddMj(mj.paiValue)    
end




-------- 点击事件相关  -----------------------

function comp_mjSelfPlayer:OnMouseUp(pos)
    if self.curDragItem ~= nil and self.curDragItem.isDrag  then
        if pos.y > Screen.height/4 then
            self:DragCardEvent( self.curDragItem )
        end
        if self.curDragItem ~= nil then
            self.curDragItem.isDrag = false
            self.curDragItem = nil
        end
        self:TidyHandCard()
        -- 松手时清除当前选中item
        if self.curClickMJItem ~= nil then
            self.curClickMJItem:SetSelectState(false)
            self.curClickMJItem = nil
        end
        return
    end

    local mj = self:GetRaycastMjItem(pos)
    if mj ~= nil then
        mj:OnClick()
    else
        self:CancelClick()
        mode_manager.GetCurrentMode():GetComponent("comp_playerMgr"):HideHighLight()
    end
    if self.curDragItem ~= nil then
        self.curDragItem.isDrag = false
        self.curDragItem = nil
    end

    if self.curScrollItem ~= nil then
        --- 不需要修改选中状态
        self.curScrollItem = nil
    end

    for i = 1, #self.handCardList do
        self.handCardList[i].isDrag = false
    end

    if self.curClickMJItem == nil then
        for i = 1, #self.handCardList do
            self.handCardList[i]:SetSelectState(false)
        end
    end

end

-- 处理拖拽事件
function comp_mjSelfPlayer:OnMouseBtn(pos)
    local mj = self:GetRaycastMjItem(pos)
    if mj ~= nil and not mj:CheckCanClick() then
        return
    end

    if mj ~= nil and (self.curDragItem == nil or self.curDragItem.isDrag == false) then
        self.curDragItem = mj
        self:OnFingerScrollItem(mj)
    end

    if self.limitScreenPos == nil then
        self.limitScreenPos = self:GetLimitScreenPos()
    end
    if self.limitScreenPos == nil or self.curDragItem == nil then
        return
    end
    if pos.y > self.limitScreenPos.y or self.curDragItem.isDrag then
        -- z在桌子之前就行
        pos.z = 1
        local worldPos = self.camera2D:ScreenToWorldPoint(pos)
        self.curDragItem.isDrag = true
        self.curDragItem.transform.position = worldPos
        self.curDragItem.localPosition = self.curDragItem.transform.localPosition
        mode_manager.GetCurrentMode():GetComponent("comp_playerMgr"):SetHighLight(self.curDragItem.paiValue)
    end
end

function comp_mjSelfPlayer:OnFingerScrollItem(mj)
    if mj == self.curScrollItem then
        return
    end
    if not mj:CheckCanClick() then
        return
    end

    if self.curClickMJItem ~= nil and mj ~= self.curClickMJItem then
        self.curClickMJItem:SetSelectState(false)
        self.curClickMJItem = nil
    end
    if self.curScrollItem ~= nil and self.curScrollItem:CheckCanClick() then
        self.curScrollItem:SetSelectState(false)
    end
    self.curScrollItem = mj
    self.curScrollItem:SetSelectState(true)
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_click"))
end


function comp_mjSelfPlayer:GetLimitScreenPos()
    return Vector3(Screen.width, Screen.height / 5, 0)
end


function comp_mjSelfPlayer:GetRaycastMjItem(pos)
    if IsNil(self.camera2D) then
        return
    end
    local ray = self.camera2D:ScreenPointToRay(pos)
    if ray == nil then
        return
    end
    local rayHits = Physics.RaycastAll(ray, 100, 288)

    local rayhit
    if rayHits.Length > 0 then
        for i = 0, rayHits.Length - 1 do
            if rayHits[i].collider.gameObject.layer == 5 and  rayHits[i].collider.gameObject.name ~= "mask" then
                    return nil
            elseif rayHits[i].collider.gameObject.name ~= "mask" then
                rayhit = rayHits[i]
            end
        end
        if rayhit == nil then
            return
        end
        local tempObj = rayhit.collider.gameObject
        if tempObj.name == "mjobj" then
            if self.comp_mjItemMgr == nil then
                self.comp_mjItemMgr =  mode_manager.GetCurrentMode():GetComponent("comp_mjItemMgr")
            end
            local mjItem = self.comp_mjItemMgr.mjObjDict[tempObj.transform.parent.gameObject]
            if(mjItem~=nil) then
                return mjItem
            end
        end
    end

    return nil
end

function comp_mjSelfPlayer:StartShakeTimer(time,loopTime)
    self.shakeTimer:StartTimer(time,loopTime)
end

function comp_mjSelfPlayer:StopShakeTimer()
    self.shakeTimer:StopTimer()
end

function comp_mjSelfPlayer:Uninitialize()
	base.Uninitialize(self)
	self:UnRegisterEvents()
end


return comp_mjSelfPlayer