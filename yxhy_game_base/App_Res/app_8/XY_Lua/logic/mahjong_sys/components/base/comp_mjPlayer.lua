local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjPlayer = class('comp_mjPlayer', mode_comp_base)
local Notifier = Notifier
local cmdName = cmdName
local Physics = Physics
--[[--
 * @Description: 发牌墩下标对应手牌下标转换  
 ]]
local DunIndexToHandIndex = {
    [1] = 1, [2] = 4,  [3]  = 2, [4]  = 5,  [5]  = 3, [6]  = 6,  [7]  = 11,
    [8] = 7, [9] = 12, [10] = 8, [11] = 13, [12] = 9, [13] = 10, [14] = 14,
}

function comp_mjPlayer:ctor()
	self.comp_operatorcard_class = require "logic/mahjong_sys/components/base/comp_mjOperatorcard"

    self.playerObj = nil
    self.viewSeat = -1
    self.handCardPoint = nil
    self.operCardPoint = nil 
    self.outCardPoint = nil
    self.handCardList = {}
    self.outCardList = {}

    self.filterCards = {}

    -- 花牌节点
    self.huaPointRoot  = nil
    self.operCardList = {}
    self.canOutCard = false
    self.handCardCount = 0
    self.curClickMJItem = nil
    self.curReqOutItem = nil --当前请求出牌的牌
    self.curDragItem = nil

    -- 最后一张摸得手牌
    self.lastCardValue = 0


    self.ArrangeHandCard_c = nil
    self.SortHandCard_c = nil
    self.DoOutCard_c = nil
    self.ShowWin_C = nil

    self:CreateObj()
    self:RegisterEvents()
    self:Init2DCamera()
end

--[[--
 * @Description: 创建玩家组件对象  
 ]]
function comp_mjPlayer:CreateObj()
    local resPlayerObj = newNormalObjSync(mahjong_path_mgr.GetMjPath("mjplayer"), typeof(GameObject))	
    self.playerObj = newobject(resPlayerObj)
end

--[[--
 * @Description: 初始化节点  
 ]]
function comp_mjPlayer:InitPoint()
  	self.handCardPoint = child_ext(self.playerObj.transform, "HandCardPoint")
    self.operCardPoint = child_ext(self.playerObj.transform, "OperCardPoint")
    self.outCardPoint = child_ext(self.playerObj.transform, "OutCardPoint")
    self.huaPointRoot = child_ext(self.playerObj.transform, "huaPoint")
    self.handAndOperDis = 0

     if self.viewSeat == 1 then
        self.handCardPoint.localScale = Vector3.one
        -- LuaHelper.SetTransformLocalX(self.handCardPoint, -2.45)
        -- LuaHelper.SetTransformLocalY(self.handCardPoint, 0.75)
        self.handCardPoint.localPosition = Vector3(-2.45, 0.75, -3.65)
        local pos = self.operCardPoint.localPosition
        pos.z = -3.65
        pos.x = -3.9
        self.operCardPoint.localPosition = pos
    else
        LuaHelper.SetTransformLocalY(self.handCardPoint, 0.82)
    end

    self.handAndOperDis = self.handCardPoint.localPosition.x - self.operCardPoint.localPosition.x
end  


--[[--
 * @Description: 初始化  
 ]]
function comp_mjPlayer:Init()
    self:StopAllCoroutine()
    self:InitPoint()
    self.handCardList = {}
    self.outCardList = {}
    self.operCardList = {}
    self.canOutCard = false
    self.handCardCount = 0
end

function comp_mjPlayer:RegisterEvents()
    Notifier.regist(cmdName.MSG_MOUSE_BTN_UP, slot(self.OnMouseUp, self))
    Notifier.regist(cmdName.MSG_MOUSE_BTN_DOWN, slot(self.OnMouseBtnDown, self))
    Notifier.regist(cmdName.MSG_MOUSE_BTN, slot(self.OnMouseBtn, self))
end

function comp_mjPlayer:UnRegisterEvents()
    Notifier.remove(cmdName.MSG_MOUSE_BTN_UP, slot(self.OnMouseUp, self))
    Notifier.remove(cmdName.MSG_MOUSE_BTN_DOWN, slot(self.OnMouseBtnDown, self))
    Notifier.remove(cmdName.MSG_MOUSE_BTN, slot(self.OnMouseBtn, self))
end

function comp_mjPlayer:OnMouseUp(pos)
    if self.viewSeat ~= 1 then
        return
    end

    if self.curDragItem ~= nil and self.curDragItem.isDrag  then
        if pos.y > Screen.height/4 then
            self:DragCardEvent( self.curDragItem )
        end
        self.curDragItem.isDrag = false
        self.curDragItem = nil
        self:TidyHandCard()
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

end

function comp_mjPlayer:OnMouseBtnDown(pos)
    if self.viewSeat ~= 1 then
        return
    end
end


-- 处理拖拽事件
function comp_mjPlayer:OnMouseBtn(pos)
    if self.viewSeat ~= 1 then
        return
    end
    local mj = self:GetRaycastMjItem(pos)
    if mj ~= nil and not mj:CheckCanClick() then
        return
    end

    if mj ~= nil and (self.curDragItem == nil or self.curDragItem.isDrag == false) then
        self.curDragItem = mj
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
    end
end

function comp_mjPlayer:GetLimitScreenPos()
    local item = self.handCardList[1]
    if item == nil then
        return nil
    end
    local limitLocalPos = item.transform.localPosition
    limitLocalPos.z = limitLocalPos.z + mahjongConst.MahjongOffset_z/3 + mahjongConst.MahjongOffset_z/2
    local worldPos = item.transform:TransformPoint(limitLocalPos)
    local screenPos = self.camera2D:WorldToScreenPoint(worldPos)
    return screenPos
end

function comp_mjPlayer:Init2DCamera()
    if self.camera2D == nil then
        self.camera2D =  mode_manager.GetCurrentMode():GetComponent("comp_mjScene").twoDCamera
    end
    return self.camera2D
end

function comp_mjPlayer:GetRaycastMjItem(pos)
    local ray = self.camera2D:ScreenPointToRay(pos)
    if ray == nil then
        return
    end
    local isCast, rayhit = Physics.Raycast(ray, nil, 100, 256)
    if isCast then
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
-- --[[--
--  * @Description: 用于结束取消点击  
--  ]]
-- function comp_mjPlayer:RemoveClickEvent()
--     for i,v in ipairs(self.handCardList) do
--         v.eventPai = nil
--         -- v:Set2DLayer()
--     end
-- end


function comp_mjPlayer:IsRoundSendCard( handCardCount )
    local normalCount = {}
    local maxCount = self.mode.config.MahjongHandCount + 1
    while maxCount > 0 do
        table.insert(normalCount,maxCount)
        maxCount = maxCount - 3
    end
    for i,v in ipairs(normalCount) do
        if handCardCount == v then 
            return true
        end
    end
    return false
end

--[[--
 * @Description: 摸牌  
 ]]
function comp_mjPlayer:AddHandCard(mj,isDeal)
    self.handCardCount = self.handCardCount + 1

    self.lastCardValue = mj.paiValue
    mj:SetHandState(self.viewSeat == 1)

    mj.transform:SetParent( self.handCardPoint, false)
    local x = #self.handCardList * mahjongConst.MahjongOffset_x + self:GetOperTotalWidth()
    --Trace("self.handCardCount------"..self.handCardCount)
    if isDeal == false and self:IsRoundSendCard(self.handCardCount) then
        --Trace("self:IsRoundSendCard(self.handCardCount)------"..tostring(self:IsRoundSendCard(self.handCardCount)))
        x = x +mahjongConst.MahjongOffset_x/2
    end
    mj:DOLocalMove(Vector3(x, 0, 0), 0,false)
    mj:DOLocalRotate(Vector3.zero, 0,DG.Tweening.RotateMode.Fast)
                
    if self.viewSeat == 1 then

        mj.onClickCallback = slot(self.ClickCardEvent, self)
        -- mj.eventPai = function( mj )
        --     self:ClickCardEvent( mj )
        -- end

        mj.dragEvent = function( mj )
            self:DragCardEvent( mj )
        end            
        roomdata_center.AddMj(mj.paiValue)
    else
        mj:ShowShadow()   
    end

    table.insert(self.handCardList,mj)
end

--[[--
 * @Description: 拿墩的形式摸牌  
 ]]
function comp_mjPlayer:AddDun( mj )
    self.handCardCount = self.handCardCount + 1

    mj:SetParent(self.handCardPoint, false)
    local x = 0
    local z = 0
    if DunIndexToHandIndex[self.handCardCount]>0 and DunIndexToHandIndex[self.handCardCount]<4 then
        x = (DunIndexToHandIndex[self.handCardCount]+2) * mahjongConst.MahjongOffset_x
        z = mahjongConst.MahjongOffset_y
    elseif DunIndexToHandIndex[self.handCardCount]>=11 and DunIndexToHandIndex[self.handCardCount]<=14 then
        x = (DunIndexToHandIndex[self.handCardCount]-5) * mahjongConst.MahjongOffset_x
        z = mahjongConst.MahjongOffset_y
    else
        x = (DunIndexToHandIndex[self.handCardCount]-1) * mahjongConst.MahjongOffset_x
    end

    mj:DOLocalMove(Vector3(x, 0, z), 0.05,false)
    mj:DOLocalRotate(Vector3(-90,0,0), 0.05,DG.Tweening.RotateMode.Fast)

    if self.viewSeat == 1 then
        -- mj.eventPai = function( mj )
        --     self:ClickCardEvent( mj )
        -- end
        mj.onClickCallback = slot(self.ClickCardEvent, self)
    end
    mj:SetHandState(self.viewSeat == 1)
    self.handCardList[DunIndexToHandIndex[self.handCardCount]] = mj

    --table.insert(self.handCardList,mj)

end

--[[--
 * @Description: 起牌动画  
 ]]
function comp_mjPlayer:ArrangeHandCard(callback)
    self.ArrangeHandCard_c = coroutine.start(function ()
        for i=1,#self.handCardList do
            local mj = self.handCardList[i]
            local x = 0
            local z = 0
            if i >=1 and i<=3 then
                z = mahjongConst.MahjongOffset_y
            elseif i >=11 and i<=14 then
                z = mahjongConst.MahjongOffset_y
            end
            x = (i-1) * mahjongConst.MahjongOffset_x
            mj:DOLocalMove(Vector3(x, 0, z), 0.3,false)
        end
        coroutine.wait(0.3)

        for i=1,#self.handCardList do
            local mj = self.handCardList[i]
            local x = (i-1) * mahjongConst.MahjongOffset_x

            mj:DOLocalMove(Vector3(x, 0, 0), 0.1,false)

        end
        coroutine.wait(0.2)

        for i=1,#self.handCardList do
            local mj = self.handCardList[i]
            local x = (i-1) * mahjongConst.MahjongOffset_x

            mj:DOLocalMove(Vector3(x, 0.45, 0), 0.3,false):SetEase(DG.Tweening.Ease.InBack)

        end
        coroutine.wait(0.3)

        for i=1,#self.handCardList do
            local mj = self.handCardList[i]
            local x = (i-1) * mahjongConst.MahjongOffset_x

            mj:DOLocalMove(Vector3(x, 0, 0), 0.5,false):SetEase(DG.Tweening.Ease.OutQuart)
            mj:DOLocalRotate(Vector3.zero, 0.5,DG.Tweening.RotateMode.Fast):SetEase(DG.Tweening.Ease.OutQuart)

        end
        coroutine.wait(0.5)

        for i=1,#self.handCardList do
            if self.viewSeat == 1 then
                self.handCardList[i].dragEvent = function(mj)
                    self:DragCardEvent(mj)
                end
            else
                self.handCardList[i]:ShowShadow()
            end
        end

        if callback~=nil then
            callback()
        end

        --compPlayerMgr:GetPlayer(1):AddDragEvent()
    end)
end

-- --[[--
--  * @Description: 显示手牌中混牌  
--  ]]
-- function comp_mjPlayer:ShowLaiInHand()
--     for i=1,#self.handCardList do
--         self.handCardList[i]:UpdateSpecialCard()
--     end
-- end

function comp_mjPlayer:ShowSpecialInHand()
    for i=1,#self.handCardList do
        self.handCardList[i]:UpdateSpecialCard()
    end
end

--[[--
 * @Description: 癞子牌置前  
 ]]
function comp_mjPlayer:PutFrontSpecialCard( list )
    for i=1,#list do
        local mj = list[i]
        if mj.isSpecialCard == true then
            local index = i-1
            while index > 0 and not list[index].isSpecialCard do 
                local temp = list[index]
                list[index] = list[index+1]
                list[index+1] = temp
                index = index -1
            end
        end
    end
end


--[[--
 * @Description: 插入排序，只能用于排序麻将组件  
 ]]
function comp_mjPlayer.InsertSort( list )
    for i = 2,#list,1 do
        local insertItem = list[i]
        local insertIndex = i - 1
        while (insertIndex > 0 and insertItem.paiValue < list[insertIndex].paiValue)
        do
            list[insertIndex + 1] = list[insertIndex]
            insertIndex = insertIndex -1
        end
        list[insertIndex + 1] = insertItem
    end
end



--[[--
 * @Description: 排手牌  
 ]]
function comp_mjPlayer:SortHandCard(isNeedAnim)
    local operWidth = self:GetOperTotalWidth()
    if self.viewSeat ~=1 and isNeedAnim then
        local index = math.floor(#self.handCardList/2+1)
        local lastMJ = table.remove(self.handCardList)
        table.insert(self.handCardList,index,lastMJ)

        for i=1,#self.handCardList do
            local x = operWidth + (i-1) * mahjongConst.MahjongOffset_x
            local mj = self.handCardList[i]
            if mj == lastMJ then
                SortHandCard_c = coroutine.start(function ()
                    mj:DOLocalMove(mj.transform.localPosition + Vector3(0, 0,mahjongConst.MahjongOffset_z ), 0.1,false)
                    mj:DOLocalRotate(Vector3(0,20,0), 0.1,DG.Tweening.RotateMode.Fast)
                    coroutine.wait(0.1)

                    mj:DOLocalMove(Vector3(x, 0, mahjongConst.MahjongOffset_z), 0.3,false)
                    coroutine.wait(0.3)

                    mj:DOLocalRotate(Vector3.zero, 0.1,DG.Tweening.RotateMode.Fast)
                    coroutine.wait(0.05)

                    mj:DOLocalMove(Vector3(x, 0, 0), 0.1,false)
                    coroutine.wait(0.1)
                    mj:ShowShadow()
                    self:TidyHandCard()
                end)
            else
                if self:IsRoundSendCard(#self.handCardList) and i == #self.handCardList then 
                    x = x + mahjongConst.MahjongOffset_x/2 
                end
                -- mj:DOLocalMove(Vector3(x, 0, 0), 0.05,false):OnComplete(function()
                --     mj:ShowShadow()
                -- end)
                -- mj:DOLocalRotate(Vector3.zero, 0.05,DG.Tweening.RotateMode.Fast)
                mj.transform.localPosition = Vector3(x, 0, 0)
                mj.transform.localEulerAngles = Vector3.zero
                mj:ShowShadow()
            end
        end
    else
        local lastMJ = self.handCardList[#self.handCardList]
        self.InsertSort(self.handCardList)
        self:PutFrontSpecialCard(self.handCardList)
        local needInsertAnim = false
        if isNeedAnim == true and lastMJ ~= self.handCardList[#self.handCardList] then
            needInsertAnim = true
        end
        for i=1,#self.handCardList do
            local x = operWidth + (i-1) * mahjongConst.MahjongOffset_x
            local mj = self.handCardList[i]
            if mj == lastMJ and needInsertAnim then
                SortHandCard_c = coroutine.start(function ()
                    -- if self.viewSeat == 1 then
                    --     mj.eventPai = nil
                    -- end
                    mj.canClick =  false

                    mj:DOLocalMove(mj.transform.localPosition + Vector3(0, 0,mahjongConst.MahjongOffset_z ), 0.1,false)
                    mj:DOLocalRotate(Vector3(0,20,0), 0.1,DG.Tweening.RotateMode.Fast)
                    coroutine.wait(0.1)

                    mj:DOLocalMove(Vector3(x, 0, mahjongConst.MahjongOffset_z), 0.3,false)
                    coroutine.wait(0.3)

                    mj:DOLocalRotate(Vector3.zero, 0.1,DG.Tweening.RotateMode.Fast)
                    coroutine.wait(0.05)

                    mj:DOLocalMove(Vector3(x, 0, 0), 0.1,false)
                    coroutine.wait(0.1)

                    if self.viewSeat == 1 then
                        mj.canClick = true
                        -- mj.eventPai = function( mj )
                        --     self:ClickCardEvent( mj )
                        -- end
                    end
                    -- 携程中需要特殊处理
                    mj:ShowShadow()
                    self:TidyHandCard()
                end)
            else
                if self:IsRoundSendCard(#self.handCardList) and i == #self.handCardList then 
                    x = x + mahjongConst.MahjongOffset_x/2 
                end
                -- mj:DOLocalMove(Vector3(x, 0, 0), 0,false)
                -- mj:DOLocalRotate(Vector3.zero, 0,DG.Tweening.RotateMode.Fast)

                if self.viewSeat == 1 then
                    -- mj.eventPai = function( mj )
                    --     self:ClickCardEvent( mj )
                    -- end
                    mj.onClickCallback = slot(self.ClickCardEvent, self)
                end
                mj.transform.localPosition = Vector3(x, 0, 0)
                mj.transform.localEulerAngles = Vector3.zero
                mj:ShowShadow()
            end
        end
    end
end

function comp_mjPlayer:TidyHandCard()
    local operWidth = self:GetOperTotalWidth()
    for i=1,#self.handCardList do
        local x = operWidth + (i-1) * mahjongConst.MahjongOffset_x
        local mj = self.handCardList[i]

        mj:SetSelectState(false)

        if self:IsRoundSendCard(#self.handCardList) and i == #self.handCardList then 
            x = x + mahjongConst.MahjongOffset_x/2 
        end

        mj.transform.localPosition = Vector3(x, 0, 0)
        mj.transform.localEulerAngles = Vector3.zero
        mj:ShowShadow()
    end
end

--[[--
 * @Description: 获取操作牌  
 ]]
function comp_mjPlayer:GetOperTotalWidth(isForce3D)
    local sum = 0
    for i,v in ipairs(self.operCardList) do
        sum = sum + v:GetWidth() + mahjongConst.MahjongOperCardInterval
    end
    if self.viewSeat == 1 and not (isForce3D or false) then 
        -- 这个系数调整看感觉
        return sum /3*2
    else
        -- 1.16手牌放大倍数 0.79 手牌和操作牌距离 
        if isForce3D and self.viewSeat == 1 then
            return sum - self.handAndOperDis + mahjongConst.MahjongOperCardInterval*2
        else
            return sum / 1.16 - self.handAndOperDis + mahjongConst.MahjongOperCardInterval*2
        end
    end
end

--[[--
 * @Description: 排操作牌  
 ]]
function comp_mjPlayer:SortOper()
    local xOffset = 0
    for i=1,#self.operCardList do
        local oper = self.operCardList[i]
        oper.operObj.transform.localPosition = Vector3(xOffset, 0, 0)
        xOffset = xOffset + self.operCardList[i]:GetWidth() + mahjongConst.MahjongOperCardInterval
    end
end

--[[--
 * @Description: 设置是否能出牌  
 ]]
function comp_mjPlayer:SetCanOut( isCanCout, filterCards )
    self.canOutCard = isCanCout
    self.filterCards = filterCards
    --[[
    if self.canOutCard == false and self.curClickMJItem~=nil then
        for i,v in ipairs(self.handCardList) do
            if v == self.curClickMJItem then
                self.curClickMJItem:OnClickUp()
                self.curClickMJItem =nil
                break
            end
        end
    end]]
end

function comp_mjPlayer:CheckCanSendOut(paiValue)
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

--[[--
 * @Description: 初始化手牌拖动事件  
 ]]
function comp_mjPlayer:AddDragEvent()
    for i,v in ipairs(self.handCardList) do
        v.dragEvent = function( v )
            self:DragCardEvent( v )
        end
        v:AddEventListener() 
    end
end

--[[--
 * @Description: 麻将点击事件  
 ]]
function comp_mjPlayer:ClickCardEvent( mj )
    if mj == self.curClickMJItem then
        if self.canOutCard then
            local paiVal = mj.paiValue
            Trace("-----------ClickCardEvent paiVal"..paiVal)
            if self:CheckCanSendOut(paiVal) then
                self.curReqOutItem = mj
                mahjong_play_sys.OutCardReq(paiVal)
                if self.viewSeat == 1 then
                    self:AutoOutCard(paiVal)
                end
            end
        else
            ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_click", true))
        end
    else
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_click", true))
        if self.curClickMJItem~=nil then
            self.curClickMJItem:SetSelectState(false)
        end
        self.curClickMJItem = mj
        self.curClickMJItem:SetSelectState(true)
        mode_manager.GetCurrentMode():GetComponent("comp_playerMgr"):SetHighLight(self.curClickMJItem.paiValue)
    end
end


function comp_mjPlayer:CancelClick()
    if self.curClickMJItem~=nil then
        if not self.curClickMJItem.isDrag then
            self.curClickMJItem:SetSelectState(false)
        end
        self.curClickMJItem = nil
    end
end

--[[--
 * @Description: 麻将拖动事件  
 ]]
function comp_mjPlayer:DragCardEvent(mj)
    if self.curClickMJItem~=nil and self.curClickMJItem~=mj then
        self.curClickMJItem:OnClickUp()
    end
    if self.canOutCard then
        local paiVal = mj.paiValue
        if self:CheckCanSendOut(paiVal) then
            self.curReqOutItem = mj
            mahjong_play_sys.OutCardReq(paiVal)
            if self.viewSeat == 1 then
                self.filterCards = nil
                self:AutoOutCard(paiVal)
            end
        end
    end
end

function comp_mjPlayer:AutoOutCard(paiValue)
    self:SetCanOut(false)
    roomdata_center.selfOutCard = paiValue
    local compPlayerMgr = self.mode:GetComponent("comp_mjPlayerMgr")
    local compResMgr = self.mode:GetComponent("comp_resMgr")
    compPlayerMgr:HideHighLight()
    self:OutCard(paiValue, function(pos) compPlayerMgr:SetOutCardEfObj(pos) end)
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_out", true))
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(paiValue))
end


--[[--
 * @Description: 出牌  
 ]]
function comp_mjPlayer:OutCard(paiValue, callback)
    self.handCardCount = self.handCardCount - 1
    if self.viewSeat == 1 then
        local isOut = false
        for i = 1,#self.handCardList,1 do
            if self.handCardList[i].paiValue == paiValue and self.curReqOutItem == self.handCardList[i] then
                local item = self.handCardList[i]
                -- self.handCardList[i].eventPai = nil
                -- self.handCardList[i]:ClearEvent()
                table.remove(self.handCardList,i)
                self.curReqOutItem = nil
                self.curClickMJItem = nil
                self:DoOutCard(item, callback)
                isOut = true
                break
            end
        end
        
        if isOut then
            return
        end

        for i = 1,#self.handCardList,1 do
            if self.handCardList[i].paiValue == paiValue then
                local item = self.handCardList[i]
                -- self.handCardList[i].eventPai = nil
                -- self.handCardList[i]:ClearEvent()
                table.remove(self.handCardList,i)
                self:DoOutCard(item, callback)
                break
            end
        end
        
    else
        local index = #self.handCardList - 1
        local item = self.handCardList[index]
        table.remove(self.handCardList,index) 
        item:SetMesh(paiValue)
        self:DoOutCard(item, callback)
    end
end

--[[--
 * @Description: 出牌动作  
 ]]
function comp_mjPlayer:DoOutCard(item, callback)
    DoOutCard_c = coroutine.start(function ()
        --Trace("DoOutCard viewSeat"..self.viewSeat.." mjvalue "..item.paiValue)
        --Trace("DoOutCard viewSeat"..self.viewSeat.." mjname "..item.mjObj.name)
        local mj = item
        mj:SetParent(self.outCardPoint, false)

        mj:SetState(MahjongItemState.inDiscardCard)

        local endPos = self:GetOutCardPos()
        mj:DOLocalMove(endPos + Vector3(0.1, 0, -0.15), 0.3,false):SetEase(DG.Tweening.Ease.OutQuart)
        mj:DOLocalRotate(Vector3.zero, 0.3,DG.Tweening.RotateMode.Fast)
        table.insert(self.outCardList,mj)
        coroutine.wait(0.5)

        self:SortHandCard(true and roomdata_center.leftCard~=0)
        mj:DOLocalMove(endPos, 0.2,false):SetEase(DG.Tweening.Ease.InExpo):OnComplete(function ()
            if self.viewSeat ~= 1 then
                mj:ShowShadow()
            end
            if callback ~= nil then
                callback(mj.transform.position + Vector3.New(0, 0.102, 0))
            end
        end)
    end)
end

--[[--
 * @Description: 获取出牌位置  
 ]]
function comp_mjPlayer:GetOutCardPos(isNeedMoreSpace)
    local x, z
    local x_num = mahjongConst.OutCardNum_x
    if roomdata_center.MaxPlayer() == 2 then
        x_num = mahjongConst.OutCardNum_x + 5
    elseif roomdata_center.MaxPlayer() == 3 then
        x_num = mahjongConst.OutCardNum_x + 2
    end
    if isNeedMoreSpace and roomdata_center.MaxPlayer() == 2 then
            x_num = x_num + 4
            x = #self.outCardList % x_num - 4
        elseif isNeedMoreSpace and roomdata_center.MaxPlayer() == 3 then
            x_num = x_num + 3
            x = #self.outCardList % x_num
        else
            x = #self.outCardList % x_num
        end
        z = -math.floor(#self.outCardList / x_num)
        return Vector3(x * mahjongConst.MahjongOffset_x, 0, z * mahjongConst.MahjongOffset_z)
end

--[[--
 * @Description: 获取出牌和操作中指定牌值的牌  
 ]]
function comp_mjPlayer:GetSameValueItem(value)
    local t = {}
    --出牌
    for i=1,#self.outCardList do
        if self.outCardList[i].paiValue == value then
            table.insert(t,self.outCardList[i])
        end
    end
    --操作牌
    for i=1,#self.operCardList do
        local oper = self.operCardList[i]
        --Trace("#oper.itemList--------------------"..#oper.itemList)
        for j=1,#oper.itemList do
            if oper.itemList[j].paiValue == value then
                table.insert(t,oper.itemList[j])
            end
        end
    end
    return t
end

function comp_mjPlayer:GetAndRemoveLastHandCard()
    local mj = self.handCardList[#self.handCardList]
    table.remove(self.handCardList, #self.handCardList)
    return mj
end

--[[--
 * @Description: 获取最后出的牌  
 ]]
function comp_mjPlayer:GetLastOutCard(keep)
    if (#self.outCardList > 0) then
        local mj = self.outCardList[#self.outCardList]
        if not keep then
            table.remove(self.outCardList)
        end
        return mj
    else
        logError("!!!!GetLastOutCard error")
        return nil
    end
end

--[[--
* @Description: 获取补杠的牌，用于抢杠  
]]
function comp_mjPlayer:GetAddBarCard(cardValue)
    for i,v in ipairs(self.operCardList) do
        if v.operData.operType == MahjongOperAllEnum.AddBar and v.itemList[#v.itemList].paiValue == cardValue then
            local mj = table.remove(v.itemList,#v.itemList)
            return mj
        end
    end
return nil
end

--[[--
 * @Description: 执行操作牌  
 ]]
function comp_mjPlayer:OperateCard( operData,mj )
    --Trace("!!!!!!!!---------OperateCard----------operData.operType "..operData.operType)
    --Trace("!!!!!!!!---------OperateCard----------operData.operCard "..tostring(operData.operCard))
    if(operData.operType == MahjongOperAllEnum.TripletLeft or
       operData.operType == MahjongOperAllEnum.TripletCenter or
       operData.operType == MahjongOperAllEnum.TripletRight or
       operData.operType == MahjongOperAllEnum.BrightBarLeft or
       operData.operType == MahjongOperAllEnum.BrightBarCenter or
       operData.operType == MahjongOperAllEnum.BrightBarRight ) then
        self:CreateOperCard(operData,mj)
    end
    if operData.operType == MahjongOperAllEnum.DarkBar then
        self:CreateOperCard(operData)
    end
    if(operData.operType == MahjongOperAllEnum.AddBar or
        operData.operType == MahjongOperAllEnum.AddBarLeft or
        operData.operType == MahjongOperAllEnum.AddBarCenter or
        operData.operType == MahjongOperAllEnum.AddBarRight ) then
        self:AddOperCard(operData)
        self:SortOper()
    end
    if operData.operType == MahjongOperAllEnum.Collect then
        self:CreateOperCard(operData,mj)
    end
    self:SortHandCard(false)
end

--[[--
 * @Description: 创建一个操作组  
 ]]
function comp_mjPlayer:CreateOperCard( operData,mj )
    local xOffset = 0
    for i=1,#self.operCardList do
        xOffset = xOffset + self.operCardList[i]:GetWidth() + mahjongConst.MahjongOperCardInterval
    end
    local oper = self.comp_operatorcard_class.create()
    oper.viewSeat = self.viewSeat
    Trace("self.operCardPoint----------------------------------------"..tostring(self.operCardPoint.name))
    oper.operObj.transform.parent = self.operCardPoint
    oper.operObj.transform.localPosition = Vector3(xOffset, 0, 0)
    oper.operObj.transform.localRotation = Vector3.zero
    oper:Show(operData, self:GetOperCardList(operData, mj))
    table.insert(self.operCardList, oper)
end

function comp_mjPlayer:ShowWin(mj, cards, isgun)
    if mj ~= nil then
        mj:SetState(MahjongItemState.inDiscardCard)
        self.ShowWin_C = coroutine.start(function()   
            if isgun then   --先播特效，再挪到手牌
                mj:ShowWinEff()
                coroutine.wait(1)
                self:SetWinCardPos(mj)
            else
                self:SetWinCardPos(mj)
                mj:ShowWinEff()
                coroutine.wait(1)
            end
            self:ShowWinCards(cards)
        end)
    else
        self:ShowWinCards(cards)
    end
end

function comp_mjPlayer:ShowWinCards(cards, callback, time)
    if #self.handCardList ~= #cards then
        logError("手牌数量与胡牌数量不对应", #cards, #self.handCardList)
        return
    end
    for i = 1, #self.handCardList do

        self.handCardList[i]:SetMesh(cards[i])
        self.handCardList[i]:SetState(MahjongItemState.inDiscardCard)
        --mj:DOLocalRotate(V`ector3(90,0,0), 0.5)
    end
    self:SortHandCard(false)

    for i = 1, #self.handCardList do
        local z = -0.093
        if self.viewSeat == 1 then
            z = -0.057
        end
        self.handCardList[i].transform.localPosition = Vector3(self.handCardList[i].transform.localPosition.x,0,z)
        self.handCardList[i]:DOLocalRotate(Vector3(90,0,0), 0.2)
    end
    if #self.handCardList <= 2 and self.viewSeat == 1 then
            for i = 1, #self.handCardList do
                local x = self:GetOperTotalWidth(true) + (i - 1) * mahjongConst.MahjongOffset_x
                self.handCardList[i].transform.localPosition = Vector3(x, 0, -0.057)
            end
        end
    -- self:RemoveClickEvent()

    if callback ~= nil then
        coroutine.start(function()
            coroutine.wait(time)
            callback()
            end)
    end
end


function comp_mjPlayer:SetWinCardPos(mj)
    local x = (#self.handCardList + 1/2) * mahjongConst.MahjongOffset_x + self:GetOperTotalWidth()
    if #self.handCardList == 1 then
        x = (#self.handCardList + 1/2) * mahjongConst.MahjongOffset_x + self:GetOperTotalWidth(true)
    end
    local z = -0.093
    if self.viewSeat == 1 then
        z = -0.057
    end
    mj.transform:SetParent(self.handCardPoint, false) 
    mj.transform.localPosition = Vector3(x, 0, z)
    mj.transform.localEulerAngles = Vector3(90, 0, 0)
    mj:HideShadow()
end

--[[--
 * @Description: 获取具体操作的牌组对象列表  
 ]]
function comp_mjPlayer:GetOperCardList( operData,mj )
    local index = 1
    local list = {}

    local searchCard = operData.otherOperCard
    if operData.operType == MahjongOperAllEnum.DarkBar then
        table.insert(searchCard,operData.operCard)
    end

    for i=1,#searchCard do
        self.handCardCount = self.handCardCount - 1
        if self.viewSeat == 1 then
            Trace("self:GetOperCardList( operData,mj )")
            index = 1
            while(index<=#self.handCardList) do
                if(self.handCardList[index].paiValue == searchCard[i]) then
                    local mjItem = self.handCardList[index]
                    table.remove(self.handCardList,index)
                    table.insert(list,mjItem)
                    break
                end
                index = index + 1
            end
        else
            local index = math.random(1,#self.handCardList)
            local mjItem = self.handCardList[index]
            mjItem:SetMesh(searchCard[i])
            table.remove(self.handCardList,index)
            table.insert(list,mjItem)
        end
    end


    if mj~=nil then
        table.insert(list,mj)
        self.InsertSort(list)
    end
    return list
end

--[[--
 * @Description: 给操作组添加牌  
 ]]
function comp_mjPlayer:AddOperCard( operData )
    --Trace("!!!!!!!!---------AddOperCard----------operData.operCard "..operData.operCard.." operCardList[i].keyItem.paiValue "..operCardList[i].keyItem.paiValue)
    for i=1,#self.operCardList do
        if(self.operCardList[i].keyItem~=nil and operData.operCard == self.operCardList[i].keyItem.paiValue) then
            local mj = nil
            local index = 1
            self.handCardCount = self.handCardCount - 1
            if self.viewSeat == 1 then
                while(index<=#self.handCardList) do
                    if(self.handCardList[index].paiValue == operData.operCard) then
                        mj = self.handCardList[index]
                        -- mj.eventPai = nil
                        table.remove(self.handCardList,index)
                        break
                    end
                    index = index + 1
                end
            else
                local index = math.random(1,#self.handCardList)
                mj = self.handCardList[index]
                mj:SetMesh(operData.operCard)
                table.remove(self.handCardList,index)
            end
            self.operCardList[i]:AddShow(operData,mj,true)
        else
            --Trace("!!!!!!!!---------AddOperCard----------operData.operCard "..operData.operCard.." operCardList[i].keyItem.paiValue "..operCardList[i].keyItem.paiValue)
        end
    end
end

--[[--
 * @Description: 恢复出牌
 ]]
function comp_mjPlayer:ResetOutCard(cardItems,cardsValue)
    --Trace("------------ResetOutCard")
    for i=1,#cardItems do
        local mj = cardItems[i]
        mj:SetMesh(cardsValue[i])
        mj:SetParent(self.outCardPoint,false)
        local endPos = self:GetOutCardPos()
        mj.transform.localPosition = endPos
        mj.transform.localEulerAngles = Vector3.zero
        mj:SetState(MahjongItemState.inDiscardCard)
        roomdata_center.AddMj(mj.paiValue)
        mj:ShowShadow()
        table.insert(self.outCardList,mj)
    end
end

--[[--
 * @Description: 恢复操作牌  
 ]]
function comp_mjPlayer:ResetOperCard(GetResetCardsFunc,operData)
    for i=1,#operData do
        local data = operData[i]
        local ucFlag = data.ucFlag  -- 类型
        local card = data.card      -- 操作牌
        local operWho = data.value  -- 拿谁的牌

        --创建一个操作牌组
        local xOffset = 0
        for i=1,#self.operCardList do
            xOffset = xOffset + self.operCardList[i]:GetWidth() + mahjongConst.MahjongOperCardInterval
        end
        local oper = self.comp_operatorcard_class.create()
        oper.viewSeat = self.viewSeat
        oper.operObj.transform:SetParent(self.operCardPoint, false)
        oper.operObj.transform.localPosition = Vector3(xOffset, 0, 0)
        oper.operObj.transform.localEulerAngles = Vector3.zero

        --计算操作牌方向
        local operWhoViewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(operWho)
        local offset = operWhoViewSeat - self.viewSeat 

        if offset<1 then
            offset = offset +roomdata_center.MaxPlayer()      -- 3：左 2：中 1：右
        end

        --吃
        if ucFlag == 16 then        
            local operType = MahjongOperAllEnum.Collect
            local od = operatordata:New(operType,card,{card+1,card+2})
            local cards = GetResetCardsFunc(3)
            cards[1]:SetMesh(card)
            roomdata_center.AddMj(card)
            cards[2]:SetMesh(card+1)
            roomdata_center.AddMj(card + 1)
            cards[3]:SetMesh(card+2)
            roomdata_center.AddMj(card + 2)
            oper:ReShow(od, cards)
        --碰
        elseif ucFlag == 17 then    
            local operType
            if(offset == 3) then
                operType = MahjongOperAllEnum.TripletLeft
            end
            if(offset == 2) then
                operType = MahjongOperAllEnum.TripletCenter
            end
            if(offset == 1) then
                operType = MahjongOperAllEnum.TripletRight
            end
            local od = operatordata:New(operType,card,{card,card})
            local cards = GetResetCardsFunc(3)
            for i=1,#cards do
                cards[i]:SetMesh(card)
                roomdata_center.AddMj(card)
            end
            oper:ReShow(od, cards)
        --明杠
        elseif ucFlag == 18 then    
            if(offset == 3) then
                operType = MahjongOperAllEnum.BrightBarLeft
            end
            if(offset == 2) then
                operType = MahjongOperAllEnum.BrightBarCenter
            end
            if(offset == 1) then
                operType = MahjongOperAllEnum.BrightBarRight
            end
            local od = operatordata:New(operType,card,{card,card,card})
            local cards = GetResetCardsFunc(4)
            for i=1,#cards do
                cards[i]:SetMesh(card)
                roomdata_center.AddMj(card)
            end
            oper:ReShow(od, cards)
        --暗杠
        elseif ucFlag == 19 then    
            operType = MahjongOperAllEnum.DarkBar
            local od = operatordata:New(operType,card,{card,card,card})
            local cards = GetResetCardsFunc(4)
            for i=1,#cards do
                cards[i]:SetMesh(card)
                roomdata_center.AddMj(card)
            end
            oper:ReShow(od, cards)
        --碰杠
        elseif ucFlag == 20 then    
            operType = MahjongOperAllEnum.AddBar
            local od = operatordata:New(operType,card,{card,card,card})
            local cards = GetResetCardsFunc(4)
            for i=1,#cards do
                cards[i]:SetMesh(card)
                roomdata_center.AddMj(card)
            end
            oper:ReShow(od, cards)
        end

        table.insert(self.operCardList, oper)
    end
end

--[[--
 * @Description: 恢复手牌  
 ]]
function comp_mjPlayer:ResetHandCard(cardItems,cardsValue)
    if self.viewSeat == 1 then
        self.lastCardValue = cardsValue[#cardsValue]
    end

    if cardsValue~=nil then
        table.sort(cardsValue)
    end

    for i=1,#cardItems do
        local mj = cardItems[i]
        mj:SetHandState(self.viewSeat == 1)
        
        mj:SetParent(self.handCardPoint, false)
        local x = #self.handCardList * mahjongConst.MahjongOffset_x + self:GetOperTotalWidth()

        --if isStart== false then
        --    x = x +mahjongConst.MahjongOffset_x/2
        --end

        mj.transform.localPosition = Vector3(x, 0, 0)
        mj.transform.localEulerAngles = Vector3.zero            

        if self.viewSeat == 1 then
            mj:SetMesh(cardsValue[i])

            -- mj.eventPai = function( mj )
            --     self:ClickCardEvent( mj )
            -- end
            mj.onClickCallback = slot(self.ClickCardEvent, self)

            mj.dragEvent = function( mj )
                self:DragCardEvent( mj )
            end            
            roomdata_center.AddMj(mj.paiValue)    
        else
            mj:SetMesh(MahjongTools.GetRandomCard())
            mj:ShowShadow()
        end
        self.handCardCount = self.handCardCount + 1
        table.insert(self.handCardList,mj)
    end

    if self.viewSeat == 1 then
        self:SortHandCard(false)
    end

end

-- 返回操作牌数据 用于听牌检测
function comp_mjPlayer:GetOperDatas()
    local res = {}
    for i = 1, #self.operCardList do
        table.insert(res, self.operCardList[i]:GetServerOperData())
    end
    if #res == 0 then
        res = nil
    end
    return res
end

function comp_mjPlayer:GetLastCard()
    return self.lastCardValue
end

function comp_mjPlayer:GetOutCardNums()
    local tab = {}
    for i = 1, #self.outCardList do
        table.insert(tab, self.outCardList[i].paiValue)
    end
    return tab
end

function comp_mjPlayer:StopAllCoroutine()
end



function comp_mjPlayer:Uninitialize()
	mode_comp_base.Uninitialize(self)
    coroutine.stop(self.ArrangeHandCard_c)
    coroutine.stop(self.SortHandCard_c)
    coroutine.stop(self.DoOutCard_c)
    coroutine.stop(self.ShowWin_C)

    self:UnRegisterEvents()
end

return comp_mjPlayer