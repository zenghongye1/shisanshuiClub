local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjPlayer = class('comp_mjPlayer', mode_comp_base)
local Notifier = Notifier
local cmdName = cmdName
local Physics = Physics

--[[--
 * @Description: 发牌墩下标对应手牌下标转换  
 ]]
local DunIndexToLocalHandIndex = 
{
    [1] = 4,
    [2] = 2,
    [3] = 3,
    [4] = 1,
}

function comp_mjPlayer:ctor()
    self.comp_operatorcard_class = require "logic/mahjong_sys/components/mode_2/comp_mjOperCard"

    self.index = 1
    self.playerObj = nil
    self.viewSeat = -1
    self.handCardPoint = nil
    self.operCardPoint = nil 
    self.SecHandCardPoint=nil
    self.outCardPoint = nil
    self.handCardList = {}
    self.outCardList = {}

    -- self.filterCards = {}

    -- 花牌节点
    self.huaPointRoot  = nil
    self.operCardList = {}
    self.handCardCount = 0

    -- 最后一张摸得手牌
    self.lastCardValue = 0


    --需要亮的牌
    self.ShowFourCardT={}  
    -- self.ArrangeHandCard_c = nil
    self.SortHandCard_c = nil
    self.DoOutCard_c = nil
    self.ShowWin_C = nil
    self.ShowReward_C = nil 
    self.ShowTing_C = nil

    -- 缓存在桌子中间花牌
    self.showHuaInTableCardList = {}

    self.compTable = nil

    self.ArrangeMjList_c_List = {}
    self.RemoveFlowers_c_List = {}

    self:CreateObj()
    self:Init2DCamera()
    --self:RegisterEvents()
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
    self.SecHandCardPoint=child_ext(self.playerObj.transform, "SecHandCardPoint")
    self.config = mode_manager:GetCurrentMode().config
    self.cfg = mode_manager:GetCurrentMode().cfg

    self.handCardPoint.localPosition = self.config.sceneCfg.handPointPosList[self.index]
    self.SecHandCardPoint.localPosition = self.config.sceneCfg.SecHandPoint[self.index]
    self.outCardPoint.localPosition = self.config.sceneCfg.outPointPosList[self.index]
    self.operCardPoint.localPosition = MahjongSceneCfg[self.cfg.sceneCfg].operPointPosList[self.index]
    if self.viewSeat == 1 then
        self.handCardPoint.localScale = Vector3(1.1,1.1,1.1)
        self.SecHandCardPoint.localScale = Vector3(1.1,1.1,1.1)
    else
        self.handCardPoint.localScale = Vector3(0.91,0.91,0.91)
        self.SecHandCardPoint.localScale = Vector3(0.91,0.91,0.91)
        self.operCardPoint.localScale = Vector3(0.91,0.91,0.91)
    end

        self.operCardPoint.localScale = Vector3(1.054, 1.054, 1.054)
    -- if self.index == 3 then
        self.operCardPoint.localScale = Vector3(1.1, 1.1, 1.1)
    -- end

    if self.cfg.flowerOnTable then
        self.huaPointRoot.localPosition = self.config.sceneCfg.tableHuaPointPosList[self.index]
    else
        self.huaPointRoot.localPosition = self.config.sceneCfg.hideHuaPointPos
    end

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
    -- self.canOutCard = false
    self.handCardCount = 0
    self.showHuaInTableCardList = {}
end


function comp_mjPlayer:GetTable()
    if self.compTable ~= nil then
        return self.compTable
    end
    self.compTable = mode_manager.GetCurrentMode():GetComponent("comp_mjTable")
    return self.compTable
end


function comp_mjPlayer:Init2DCamera()
    if self.camera2D == nil then
        self.camera2D =  mode_manager.GetCurrentMode():GetComponent("comp_mjScene").twoDCamera
    end
    return self.camera2D
end


function comp_mjPlayer:CheckAdjustLastCard()
    if self:IsIllegalCount(#self.handCardList) then
        logError("reconnect", #self.handCardList)
        SocketManager:reconnect()
    end
    if self:IsRoundSendCard(#self.handCardList) then
        local mj = self.handCardList[#self.handCardList]
        if mj==nil then
            return
        end 
        local pos = mj.transform.localPosition
        pos.x = pos.x + mahjongConst.MahjongOffset_x/2
        mj:DOLocalMove(pos, 0)
    end
end

function comp_mjPlayer:IsIllegalCount( handCardCount )
    if roomdata_center.IsPlayerTing(self.viewSeat) then
        return false
    end
    local normalCount = {}
    local maxCount = self.cfg.MahjongHandCount + 1
    while maxCount > 0 do
        table.insert(normalCount,maxCount)
        maxCount = maxCount - 3
    end
    for i,v in ipairs(normalCount) do
        if handCardCount == (v + 1) then 
            return true
        end
    end
    return false
end


function comp_mjPlayer:IsRoundSendCard( handCardCount )
    local normalCount = {}
    local maxCount = self.cfg.MahjongHandCount + 1
    while maxCount > 0 do
        table.insert(normalCount,maxCount)
        maxCount = maxCount - 3
    end
    for i,v in ipairs(normalCount) do
        if handCardCount == v then 
            -- if roomdata_center.IsPlayerTing(self.viewSeat) and self.viewSeat~=1 then
            --     return false
            -- end
            return true
        end
    end
    -- if roomdata_center.IsPlayerTing(self.viewSeat) and self.viewSeat~=1 then
    --     return true
    -- end
    return false
end

--[[--
 * @Description: 摸牌  
 ]]
function comp_mjPlayer:AddHandCard(mj,isDeal)
    self.handCardCount = self.handCardCount + 1
    self.lastCardValue = mj.paiValue
    mj:SetHandState(self.viewSeat == 1)

    mj:SetParent( self.handCardPoint, false)
    
    table.insert(self.handCardList,mj)
    local x = self:GetHandPosX(#self.handCardList)

    mj:DOLocalMove(Vector3(x, 0, 0), 0,false)
    mj:DOLocalRotate(0,0,0, 0,DG.Tweening.RotateMode.Fast)

    if not isDeal then
        self:CheckAdjustLastCard()
    end
    
    self:OnMjAddHand(mj)
end

function comp_mjPlayer:OnMjAddHand(mj)
    mj:ShowShadow()  
end


function comp_mjPlayer:AddDun(mjs)
    if mjs == nil or #mjs == 0 then
        return
    end

    local listCount = #mjs
    local mjList = {}
    if listCount == 4 then
        for i, v in ipairs(mjs) do
            mjList[DunIndexToLocalHandIndex[i]] = mjs[i]
        end
    else
        mjList[1] = mjs[1]
    end


    local x
    local y = 0
    local z = 0

    if self.viewSeat == 1 then
    -- 组 最左边位置
        if listCount > 1 then
            x = 5.3
        else
            x = 6.4
        end
        y = -0.1
    else
        -- x = self.handCardCount * mahjongConst.MahjongOffset_x 
        -- --别人的牌墩 默认放在中间
        -- if x < 7 * mahjongConst.MahjongOffset_x then
        --     x = 7 * mahjongConst.MahjongOffset_x
        -- end
        x = 2.8
    end


    
    local moveMjFunc = function(mj, xA,  yA, zA)
        mj:SetParent(self.handCardPoint, false)
        mj:DOLocalMove(Vector3(xA, yA, zA), 0, false)
        mj:DOLocalRotate(-90,0,0, 0,DG.Tweening.RotateMode.Fast)
    end


    --庄家单张
    if listCount == 1 then
        moveMjFunc(mjList[1], x, y, z)
    else
        -- 将四张牌一起挪到指定位置
        moveMjFunc(mjList[3], x, y, 0.161)
        moveMjFunc(mjList[1], x, y, -0.049)
        x = x + mahjongConst.MahjongOffset_x
        moveMjFunc(mjList[4], x, y, 0.161)
        moveMjFunc(mjList[2], x, y, -0.049)
    end

    --ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_ontable"))
   
    self:ArrangeMjList(mjList)   
    -- self.handCardCount = self.handCardCount +  #mjList
    
end

function comp_mjPlayer:AddMjListToHand(mjList)
    for i = 1, #mjList do
        table.insert(self.handCardList, mjList[i])
        self:OnMjAddHand(mjList[i])
        mjList[i]:SetHandState(self.viewSeat == 1)
    end
end
function comp_mjPlayer:ShowFourCard(value,isenable)   
    if self.viewSeat == 1 then
       self.SecHandCardPoint.eulerAngles={x=-90,y=0,z=0} 
    end 
    if isenable==nil then 
       isenable=true
    end
    local t={}
    for i=1,#value do
        table.insert(t,value[i])
    end
    local whileindex=1  
    local issort=false 
     
	
    if #self.handCardList>0 then
        while #t>0 do  
            if self.viewSeat==1 then 
                local specialmj=nil
                for m=1,#self.handCardList do 
                    local mj=  self.handCardList[m]    
                    if mj.paiValue ==t[1] and mj.isSpecialCard==false then   
                       mj:SetParent(self.SecHandCardPoint,false) 
                       if mj.isSpecialCard==false then
                          issort=true
                       end  
                       mj.isSpecialCard=true
                       table.remove(t,1)   
                       mj:SetDisable(isenable)   
                       specialmj=mj
                       break
                    end 
                end 
                if specialmj==nil then
                    table.remove(t,1)
                end
                whileindex=whileindex+1 
                if #t>0 and whileindex>4 then
                    logError("有未找到的牌") 
                    break 
                end
            else  
                local count=#t
                for i=1,count do
                    local mj =self.handCardList[i]
                    mj:SetParent(self.SecHandCardPoint,false) 
                    mj:SetMesh(t[1])
                    mj.isSpecialCard=true
                    table.remove(t,1) 
                end 
            end 
        end  
    end  
    if self.viewSeat==1 then 
        self:Resetfourcardstate(isenable)
    end
    if issort then   
        if self.viewSeat==1 and self:IsRoundSendCard(#self.handCardList) then
            self:SortHandCard(false,nil,false,function() self:putlastcard(comp_show_base.cardLastDraw)end) 
        else 
            self:SortHandCard(false,nil,false) 
        end
    end 
end



function comp_mjPlayer:Resetfourcardstate(isenable) 
    for m=1,#self.handCardList do
        local mj=  self.handCardList[m] 
        if mj.isSpecialCard ==false then  
            if isenable==false then  
               mj:SetDisable(true) 
            else
               mj:SetDisable(false)  
            end
        else
            mj:SetDisable(isenable) 
        end 
    end
end
function comp_mjPlayer:SetFourCard(list) 
    if list~=nil then
        self.ShowFourCardT=list  
    end
end

 -- 将两墩展开，上层两张牌放到后面，并掀开
function comp_mjPlayer:ArrangeMjList(mjList, callback)
    local arrangeTime = 0.05 * self:AnimSpd()
    --向后平移/向下
    local moveFunc = function(mj, down)
        local y = 0
        if self.viewSeat == 1 then
            y = -0.1
        end
        local pos = mj.transform.localPosition
        if not down then
            mj:DOLocalMove(Vector3(pos.x + mahjongConst.MahjongOffset_x * 2, y, pos.z), arrangeTime * self:AnimSpd(), false)
        else
            mj:DOLocalMove(Vector3(pos.x, y, 0), arrangeTime * self:AnimSpd(), false)
        end
    end

    local ArrangeMjList_c = coroutine.start(function()
                coroutine.wait(arrangeTime * self:AnimSpd())
                if #mjList == 4 then
                    --平移
                   
                    moveFunc(mjList[3])
                    moveFunc(mjList[4])

                    coroutine.wait(arrangeTime * self:AnimSpd())
                    -- 下移
                    moveFunc(mjList[3], true)
                    moveFunc(mjList[4], true)
                end

                coroutine.wait(arrangeTime*2 * self:AnimSpd())
                if #mjList == 4 then
                    LuaHelper.SetTransformLocalZ(mjList[1].transform, 0)
                    LuaHelper.SetTransformLocalZ(mjList[2].transform, 0)
                end
                -- 翻牌
                for i, v in ipairs(mjList) do
                    v:DOLocalRotate(0,0,0, arrangeTime * self:AnimSpd(), DG.Tweening.RotateMode.Fast)
                end

                coroutine.wait(arrangeTime * self:AnimSpd())

                self:AddMjListToHand(mjList)

                -- 移动到牌的位置
                for i, v in ipairs(mjList) do 
                    mjList[i]:DOLocalMove(Vector3(self:GetHandPosX(self.handCardCount + i, self.cfg.MahjongHandCount), 0, 0), arrangeTime*2 * self:AnimSpd(), false)
                end

                self.handCardCount = self.handCardCount + #mjList

                coroutine.wait(arrangeTime * self:AnimSpd())
                if self.viewSeat == 1 then
                    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_deal_card"))
                end
            end)    
    
    table.insert(self.ArrangeMjList_c_List, ArrangeMjList_c)
end

-- 通用玩家显示补花操作
-- 位置， 花牌，花牌数量, 替换牌，回调
function comp_mjPlayer:RemoveChangeFlowers( flowerCards, flowerCount, isDeal)
    if flowerCount == 0 then
        return 0
    end

    self.handCardCount = self.handCardCount - flowerCount
    -- 飞到屏幕中心时间
    local moveToCenterTime = 0.2
    -- 隐藏时间
    local hideTime = 0

    local time = 0
    
    local RemoveFlowers_c = coroutine.start(function()

    local mjList = {}
    -- 飞到屏幕中间
    if self.viewSeat == 1 then
        mjList = self:GetSelfCardsByCardValueList(flowerCards, true, true)
        --self:DoSelfCardsMoveToCenter(mjList, moveToCenterTime)
    else
        mjList = self:GetOterCardsByCount(flowerCards, flowerCount, true)
        --self:DoOtherCardsMoveToCenter(mjList, moveToCenterTime)
    end
    
    -- 设置状态
    for i = 1, #mjList do
        mjList[i]:SetState(MahjongItemState.other)
    end

    if isDeal then
        self:DoMoveToHuaPoint(mjList, self.viewSeat == 1)
        coroutine.wait(0.1 * self:AnimSpd())
    else
        --coroutine.wait(0.3)
        
        for i = 1, #mjList do 
            local pos = mjList[i].transform.localPosition
            pos.z = pos.z + mahjongConst.MahjongOffset_y
            mjList[i]:DOLocalMove(pos, 0.2 * self:AnimSpd())
        end
        coroutine.wait(0.2 * self:AnimSpd())
        self:GetTable():DoHideHuaCardsToPoint(mjList, self.viewSeat, 0.1, nil, self.viewSeat == 1)
    end
    -- self:SortHandCard(false)

    -- coroutine.wait(0.3)
    -- 隐藏
    -- self:GetTable():DoHideHuaCardsToPoint(mjList, self.viewSeat, hideTime)


    end)
    table.insert(self.RemoveFlowers_c_List,RemoveFlowers_c)
   return time + hideTime
end

function comp_mjPlayer:DoMoveToHuaPoint(mjList,isSelf)
    local mj
    local moveTime = 0.2 * self:AnimSpd()
    local x, y
    for i = 1, #mjList do
        mj = mjList[i]
        mj:SetParent(self.huaPointRoot)
        if isSelf then
            mj:Set3DLayer()
        end
        x = (math.fmod(#self.showHuaInTableCardList, 12) + 3)* mahjongConst.MahjongOffset_x
        z = math.floor(#self.showHuaInTableCardList / 12) * mahjongConst.MahjongOffset_z
        mj:DOLocalMove(Vector3(x,0,z), moveTime)
        mj:ShowShadow()
        table.insert(self.showHuaInTableCardList, mj)
    end
end

function comp_mjPlayer:DoHideFlowerCards()
    if #self.showHuaInTableCardList == 0 or self.cfg.flowerOnTable then
        return
    end
    self:GetTable():DoHideHuaCardsToPoint(self.showHuaInTableCardList ,self.viewSeat, 0.2, function() self.showHuaInTableCardList = {} end)
end


function comp_mjPlayer:DoSelfCardsMoveToCenter(mjList, time)
    self:GetTable():MoveMjListTo2DCenter(mjList, time)
end

function comp_mjPlayer:DoOtherCardsMoveToCenter(mjList, time)
    self:GetTable():MoveMjListTo3DCenter(mjList, time)
    coroutine.wait(time+ 0.05)
    self:GetTable():MoveMjListTo2DCenter(mjList, 0)
end

-- 暂时先放player
function comp_mjPlayer:ShowSpecialInHand()
    for i=1,#self.handCardList do
        self.handCardList[i]:SetMesh(self.handCardList[i].paiValue)
    end
    self:SortHandCard(false, nil, true)
end

--[[--
 * @Description: 癞子牌置前  
 ]]
function comp_mjPlayer:PutFrontSpecialCard(list, notIncludeLast)
    local count = #list
    if notIncludeLast then
       count = count - 1 
    end
    for i=1,count do
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
function comp_mjPlayer.InsertSort( list , notIncludeLast)
    local count = #list
    if notIncludeLast then
        count = count - 1
    end
    for i = 2,count,1 do
        local insertItem = list[i]
        local insertIndex = i - 1
        if type(insertItem.sortPaiValue) ~= "number" then
            logError("mj排序错误，无效的sortPaiValue:",insertItem.sortPaiValue)
            return
        end
        if type(list[insertIndex].sortPaiValue) ~= "number" then
            logError("mj排序错误，无效的sortPaiValue:",list[insertIndex].sortPaiValue)
            return
        end
        while (insertIndex > 0 and insertItem.sortPaiValue < list[insertIndex].sortPaiValue)
        do
            list[insertIndex + 1] = list[insertIndex]
            insertIndex = insertIndex -1
        end
        list[insertIndex + 1] = insertItem
    end
end


function comp_mjPlayer:SortHandimmediately(notIncludeLast, callback)  
    self.InsertSort(self.handCardList,notIncludeLast and self:IsRoundSendCard(#self.handCardList))
    if not self.cfg.specialNotSort  then
        self:PutFrontSpecialCard(self.handCardList, notIncludeLast) 
    end  
    for i=1,#self.handCardList do
        local x = self:GetHandPosX(i)
        local mj = self.handCardList[i]
        mj:LocalMoveByKey("x", x, 0)
        mj:DOLocalRotate(nil, 0, 0, 0)

        self:OnSortMj(mj)
    end

    if callback ~= nil then
        callback()
    end
end

function comp_mjPlayer:OnSortMj(mj)
    mj:ShowShadow()
end

function comp_mjPlayer:putlastcard(value)   
   local item=nil 
   if value==nil then
     return
   end 
   for i=1, #self.handCardList do 
      if self.handCardList[i].paiValue==value and self.handCardList[i].isSpecialCard==false then
         item = self.handCardList[i]
         table.remove(self.handCardList,i) 
         break
      end
   end 
   if item~=nil then
      table.insert(self.handCardList,item)
   end   
   for i=1,#self.handCardList do
        local x = self:GetHandPosX(i) 
        local mj = self.handCardList[i]   
        mj:LocalMoveByKey("x", x, 0)
        mj:DOLocalRotate(nil, 0, 0, 0) 
        self:OnSortMj(mj)  
    end 
     
end

function comp_mjPlayer:DoSortLastHandCardAnim(mj, x)
    self.SortHandCard_c = coroutine.start(function ()
        mj:DOLocalMove(mj.transform.localPosition + Vector3(0, 0, mahjongConst.MahjongOffset_z ), 0.075 * self:AnimSpd(), false)
        mj:DOLocalRotate(0,20,0, 0.075 * self:AnimSpd(),DG.Tweening.RotateMode.Fast)
        coroutine.wait(0.075 * self:AnimSpd())

        mj:DOLocalMove(Vector3(x, 0, mahjongConst.MahjongOffset_z), 0.2 * self:AnimSpd(), false)
        coroutine.wait(0.2 * self:AnimSpd())

        mj:DOLocalRotate(nil, 0,0, 0.05 * self:AnimSpd(),DG.Tweening.RotateMode.Fast)
        coroutine.wait(0.05 * self:AnimSpd())

        mj:DOLocalMove(Vector3(x, 0, 0), 0.075 * self:AnimSpd(),false)
        coroutine.wait(0.1 * self:AnimSpd())
        mj:ShowShadow()
        self:OnSortMj(mj)
        self:TidyHandCard()
    end)
end


function comp_mjPlayer:SortHandWithAnim(notIncludeLast)
    local index = math.floor(#self.handCardList/2+1)
    if self.ShowFourCardT and #self.ShowFourCardT >= index and #self.handCardList > index then
        index = index + 1
    end
    local lastMJ = table.remove(self.handCardList)
    table.insert(self.handCardList,index,lastMJ)
    local needAdjuct = true
    for i=1,#self.handCardList do
        local x = self:GetHandPosX(i)
        local mj = self.handCardList[i]
        if mj == lastMJ then
            needAdjuct = false
            self:DoSortLastHandCardAnim(mj, x)
        else
            mj:DOLocalMove(Vector3(x, 0, 0))
            mj:DOLocalRotate(nil, 0,0, 0)
            mj:ShowShadow()
        end
    end
    return needAdjuct
end


function comp_mjPlayer:SortHandCard(isNeedAnim, dontCheck, notIncludeLast, callback)
    local needAdjuct = true
    if not isNeedAnim then
        self:SortHandimmediately(notIncludeLast, callback)  
    else
        needAdjuct = self:SortHandWithAnim()
    end
    if needAdjuct and not dontCheck then
        self:CheckAdjustLastCard()
    end
    self:AdjustHandPointPosX()
end


function comp_mjPlayer:TidyHandCard()
    local operWidth = self:GetOperTotalWidth()
    for i=1,#self.handCardList do
        local x = self:GetHandPosX(i)
        local mj = self.handCardList[i]

        mj:SetSelectState(false)

        mj:DOLocalMove(Vector3(x, 0, 0))
        mj:ShowShadow()
    end
    self:CheckAdjustLastCard()
end

function comp_mjPlayer:GetHandPosX(index, handCount)
    local handCount = handCount or #self.handCardList
    if self:IsRoundSendCard(handCount) then
        handCount = handCount - 1
    end
    local x  = 0

    local offsetX = handCount  / 2 * mahjongConst.MahjongOffset_x - mahjongConst.MahjongOffset_x/ 2
    x = (index-1) * mahjongConst.MahjongOffset_x - offsetX
    return x
end

--[[--
 * @Description: 获取操作牌  
 ]]
function comp_mjPlayer:GetOperTotalWidth(isForce3D)
    local sum = 0
    for i,v in ipairs(self.operCardList) do
        sum = sum + v:GetWidth() + mahjongConst.MahjongOperCardInterval
    end

    return sum
end

--[[--
 * @Description: 排操作牌  
 ]]
function comp_mjPlayer:SortOper()
    local xOffset = 0
    for i=1,#self.operCardList do
        local oper = self.operCardList[i]
        oper.operObj.transform.localPosition = Vector3(xOffset, 0, 0)
        if self.viewSeat ~= 1 then
            xOffset = xOffset - self.operCardList[i]:GetWidth() - mahjongConst.MahjongOperCardInterval
        else
            xOffset = xOffset + self.operCardList[i]:GetWidth() + mahjongConst.MahjongOperCardInterval
        end
    end
end


--[[--
 * @Description: 出牌  
 ]]
function comp_mjPlayer:OutCard(paiValue, callback,isShowGive)
    self.handCardCount = self.handCardCount - 1
    local item=nil
    if isShowGive==nil then
        isShowGive=false
    end   
    if isShowGive then 
        for i=1,#self.handCardList do
            if self.handCardList[i].paiValue==paiValue then
                item=self.handCardList[i]
                table.remove(self.handCardList,i)
                break
            end
        end 
        for i=1,#self.ShowFourCardT do
           if self.ShowFourCardT[i]==paiValue then 
                table.remove(self.ShowFourCardT,i) 
                break
            end
        end 
        if item~=nil then  
           self:DoOutCard(item, callback) 
        end
    else     
        local index = #self.handCardList - 1
    	if roomdata_center.IsPlayerTing(self.viewSeat) then
        	index = #self.handCardList
    	end
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
    self.DoOutCard_c = coroutine.start(function ()
        local mj = item;

        mj:SetState(MahjongItemState.inDiscardCard)
        mj:SetParent( self.outCardPoint, true)
        mj.transform.localScale = Vector3.one
        -- 牌上移 防止穿过牌墩
        LuaHelper.SetTransformLocalY(mj.transform, 0.4)

        local endPos = self:GetOutCardPos()
        mj:DOLocalMove(endPos, 0.1 * self:AnimSpd(),false):OnComplete(function ()
            if callback ~= nil then
                callback(mj.transform.position + Vector3.New(0, 0.102, 0))
            end
        end)
        mj:DOLocalRotate(0,0,0, 0,DG.Tweening.RotateMode.Fast);
        mj:ShowShadow()
        table.insert(self.outCardList,mj)
        coroutine.wait(0.1 * self:AnimSpd())

        if self.viewSeat~=1 and roomdata_center.IsPlayerTing(self.viewSeat) then
            self:SortHandCard(false)
        else
            if roomdata_center.isNeedOutCard == true then
                self:SortHandCard(false)
                roomdata_center.isNeedOutCard = false
            else
            self:SortHandCard(true and roomdata_center.leftCard~=0)
        end
        end
    end)
end

--[[--
 * @Description: 获取出牌位置  
 ]]
function comp_mjPlayer:GetOutCardPos()
    local x, z
    local x_num = self.config.outCardLineNumMap[roomdata_center.MaxPlayer()]
    local offset = 0
    if x_num > 10 then
        offset = x_num - 10
    end
  
    x = #self.outCardList % x_num - offset
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


function comp_mjPlayer:PutFlowerToTable(flowerCards, flowerCount, isDeal)
    if flowerCount == 0 then
        return 0
    end

    self.handCardCount = self.handCardCount - flowerCount
    if self.viewSeat == 1 then
        mjList = self:GetSelfCardsByCardValueList(flowerCards, true, true)
    else
        mjList = self:GetOterCardsByCount(flowerCards, flowerCount, true)
    end
    
    self:PutFlowerMjList(mjList, not isDeal, false)
    return 0
end

function comp_mjPlayer:PutFlowerMjList(mjList, needAnim, needClear)
    if needClear then
        self.showHuaInTableCardList = {}
    end
     co_mgr.start(function ()
    -- 设置状态
        local waitTime = 0
        for i = 1, #mjList do
            mjList[i]:SetState(MahjongItemState.other)
           
            if needAnim then
                mjList[i]:DOLocalMove(mjList[i].transform.localPosition + Vector3(0, 0,0.3), 0.5 * self:AnimSpd())
                coroutine.wait(0.5 * self:AnimSpd())
                waitTime = 0
            end
            mjList[i]:Set3DLayer()
            mjList[i]:SetParent(self.huaPointRoot)

            local x = math.floor(#self.showHuaInTableCardList / self.config.sceneCfg.huaLineCountList[self.index]) 
            * mjList[i]:GetWidth() + 0.5 * mjList[i]:GetWidth()
            local y = 0
            local z = -0.5 * mjList[i]:GetHeight() - (#self.showHuaInTableCardList % self.config.sceneCfg.huaLineCountList[self.index]) * mjList[i]:GetHeight()
            mjList[i]:DOLocalMove(Vector3(x,y,z), waitTime * self:AnimSpd())
            mjList[i]:DOLocalRotate(0,0,0, 0)
            if waitTime > 0 then
                coroutine.wait(waitTime * self:AnimSpd())
            end
            table.insert(self.showHuaInTableCardList, mjList[i])
        end
    end)
end



-- 获取自己手牌中指定列表
-- reverse : 是否反序查找 
-- remove : 是否要移除列表
function comp_mjPlayer:GetSelfCardsByCardValueList(cardValues, reverse, remove)
    local count = #cardValues
    if count == 0 then
        return nil
    end

    local beginInex = (reverse and #self.handCardList) or 1
    local step = (reverse and -1) or 1
    local endIndex = (reverse and 1) or #self.handCardList
    local targetList = {}
    for i = 1, #cardValues do
        for j = beginInex, endIndex, step do
            if cardValues[i] == self.handCardList[j].paiValue then
                table.insert(targetList, self.handCardList[j])
                if remove then
                    table.remove(self.handCardList, j)
                    beginInex = (reverse and #self.handCardList) or 1
                end
                break
            end
        end
    end
    if #targetList ~= #cardValues then
        logError('补花异常，数目不对应', #cardValues, #targetList)
    end

    return targetList
end


-- 默认倒着移除
function comp_mjPlayer:GetOterCardsByCount(flowerCards, count, remove)
    local targetList = {}
    for i = count, 1, -1 do
        local handCards = #self.handCardList
        table.insert(targetList, self.handCardList[handCards - i + 1])
        self.handCardList[handCards - i + 1]:SetMesh(flowerCards[i])
        if remove then
            table.remove(self.handCardList,handCards - i + 1)
        end
    end
    return targetList
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

function comp_mjPlayer:AdjustHandPointPosX()
    local item = nil
    if #self.handCardList == 0 then
        return
    end
    if self.index == 2 or self.index == 4 then
        return
    end
    if self.index == 3 then
        self:AdjustThirdHandPosX()
    else
        self:AdjustSelfHandPosX()
    end
end

function comp_mjPlayer:AdjustSelfHandPosX()
    local disCount = self:GetAdjustSelfHandPosXDisCount()
    if self:IsRoundSendCard(#self.handCardList) then
        handCount = #self.handCardList - 1
    else
        handCount = #self.handCardList
    end
    local pos = self.operCardPoint:InverseTransformPoint(self.handCardPoint.position)
    local dis = handCount  / 2 * mahjongConst.MahjongOffset_x - mahjongConst.MahjongOffset_x/ 2 + self:GetOperTotalWidth() + mahjongConst.MahjongOffset_x * disCount - pos.x  -- x是负的
    if dis > 0 then
        pos.x = (handCount  / 2 * mahjongConst.MahjongOffset_x - mahjongConst.MahjongOffset_x/ 2 + self:GetOperTotalWidth() + mahjongConst.MahjongOffset_x * disCount)
        local worldPos = self.operCardPoint:TransformPoint(pos)
        local handLocalPos = self.playerObj.transform:InverseTransformPoint(worldPos)
        self.handCardPoint.localPosition = handLocalPos
        self.SecHandCardPoint.localPosition = handLocalPos
    end
end

function comp_mjPlayer:GetAdjustSelfHandPosXDisCount()
    local operCount = #self.operCardList
    if operCount == 0 then
        operCount = 1
    end
    return MahjongSelfHandPosOffsetList[self.cfg.selfHandPosOffsetList].selfHandPosOffsetList[operCount]
end



function comp_mjPlayer:AdjustThirdHandPosX()
    local disCount = 3
    local handCount
    local operCount = #self.operCardList
    if operCount == 5 then
        disCount = 2
    end
    if self:IsRoundSendCard(#self.handCardList) then
        handCount = #self.handCardList - 1
    else
        handCount = #self.handCardList
    end
    local pos = self.operCardPoint:InverseTransformPoint(self.handCardPoint.position)

    local dis = handCount  / 2 * mahjongConst.MahjongOffset_x - mahjongConst.MahjongOffset_x/ 2 + self:GetOperTotalWidth() + mahjongConst.MahjongOffset_x * disCount + pos.x  -- x是负的

    if dis > 0 then
        pos.x = -(handCount  / 2 * mahjongConst.MahjongOffset_x - mahjongConst.MahjongOffset_x/ 2 + self:GetOperTotalWidth() + mahjongConst.MahjongOffset_x * disCount)
        local worldPos = self.operCardPoint:TransformPoint(pos)
        local handLocalPos = self.playerObj.transform:InverseTransformPoint(worldPos)
        self.handCardPoint.localPosition = handLocalPos
        self.SecHandCardPoint.localPosition = handLocalPos
    end
end


--[[--
 * @Description: 执行操作牌  
 ]]
function comp_mjPlayer:OperateCard( operData,mj )
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
    end
    if operData.operType == MahjongOperAllEnum.FengGang then--风杠
        self.CreateOperCard(operData)
    end

    if operData.operType == MahjongOperAllEnum.Collect or operData.operType == MahjongOperAllEnum.NBZZ then
        self:CreateOperCard(operData,mj)
    end
    if operData.operType == MahjongOperAllEnum.LiangXiEr then
        self:CreateOperCard(operData)
    end
    if operData.operType == MahjongOperAllEnum.TingJinKan then
        self:ShowTingJinKan(operData)
    end

    self:SortOper()
    self:SortHandCard(false)
end

--[[--
 * @Description: 创建一个操作组  
 ]]
function comp_mjPlayer:CreateOperCard( operData,mj )
    local oper = self.comp_operatorcard_class:create()
    oper.viewSeat = self.viewSeat
    Trace("self.operCardPoint----------------------------------------"..tostring(self.operCardPoint.name))
    oper.operObj.transform:SetParent( self.operCardPoint, false)
    oper.operObj.transform.localRotation = Vector3.zero
    local operCardList = self:GetOperCardList(operData, mj)
    if operCardList then
        oper:Show(operData,operCardList)
        table.insert(self.operCardList, oper)
    end
end

function comp_mjPlayer:ShowWin(mj, cards, isgun)
    if mj ~= nil then
        mj:SetState(MahjongItemState.inDiscardCard)
        if self.viewSeat == 1 then
             for i = 1, #self.handCardList do
                self.handCardList[i]:SetState(MahjongItemState.inDiscardCard)
            end
        end
        self.ShowWin_C = coroutine.start(function()   
            if isgun then   --先播特效，再挪到手牌
                mj:ShowWinEff()
                coroutine.wait(1)
                self:SetWinCardPos(mj)
            else
                self:SetWinCardPos(mj)
                mj:ShowWinEff(true)
                coroutine.wait(1)
            end
            self:ShowWinCards(cards)
        end)
    else
        self:ShowWinCards(cards)
    end
end

function comp_mjPlayer:ResetHandCardWithTing()
    if not roomdata_center.IsPlayerTing(self.viewSeat) then
        return
    end
    local cardsValue = {}
    local cardItems = {}
    for i,v in ipairs(self.handCardList) do
        table.insert(cardsValue,v.paiValue)
        table.insert(cardItems,v)
    end
    for i=1,#self.operCardList do
        if self.operCardList[i].operData.operType == MahjongOperAllEnum.TingJinKan then
            for i,v in ipairs(self.operCardList[i].itemList) do
                table.insert(cardsValue,v.paiValue)
                table.insert(cardItems,v)
            end
            table.remove(self.operCardList,i)
            break
        end
    end
    if #self.handCardList ~= #cardItems then
        self.handCardList = {}
        self:ResetHandCard(cardItems,cardsValue)
    end
end

function comp_mjPlayer:ShowTingCards(cards, callback, time,notRotateCardIndexs)
    self:ResetHandCardWithTing()
    if #self.handCardList ~= #cards then
        logError("手牌数量与胡牌数量不对应", #cards, #self.handCardList)
        return
    end
    
    for i = 1, table.getn(self.handCardList) do
        if not table.contains(notRotateCardIndexs or {},i) then
            self.handCardList[i]:SetMesh(cards[i])
            self.handCardList[i]:SetState(MahjongItemState.inDiscardCard)
        end 
    end     
    self:SortHandCard(false, true, true, function ()
        for i = 1, #self.handCardList do
            local z = -0.093
            if self.viewSeat == 1 then
                z = -0.057
            end
            if not table.contains(notRotateCardIndexs or {},i) then
                self.handCardList[i].transform.localPosition = Vector3(self.handCardList[i].transform.localPosition.x - 2 *self.handCardList[i]:GetWidth() , 0,z)
                self.handCardList[i]:DOLocalRotate(90,0,0, 0.2)
            end
        end            

        self:AdjustHandPointPosX()
        if callback ~= nil then
            self.ShowTing_C = coroutine.start(function()
                coroutine.wait(time)
                callback()
            end)
        end        
    end)    
end

function comp_mjPlayer:ShowWinCards(cards, callback, time)
    coroutine.stop(self.SortHandCard_c)
    self:ResetHandCardWithTing()

    if #self.handCardList ~= #cards then
        logError("手牌数量与胡牌数量不对应", #cards, #self.handCardList)
--        return
    end
    for i = 1, #self.handCardList do
        self.handCardList[i]:SetMesh(cards[i])
        self.handCardList[i]:SetState(MahjongItemState.inDiscardCard)
    end
    self:SortHandCard(false, true)

        for i = 1, #self.handCardList do
            local z = -0.093
            if self.viewSeat == 1 then
                z = -0.057
            end
            self.handCardList[i].transform.localPosition = Vector3(self.handCardList[i].transform.localPosition.x,0,z)
            self.handCardList[i]:DOLocalRotate(90,0,0, 0.2 * self:AnimSpd())
        end            

    self:AdjustHandPointPosX()
    if callback ~= nil then
        self.ShowReward_C = coroutine.start(function()
            coroutine.wait(time * self:AnimSpd())
            callback()
        end)
    end
end

function comp_mjPlayer:ShowResultCards(cards, callback, time)
    coroutine.start(function()
        coroutine.wait(1)
        self:ResetHandCardWithTing()
        for i = 1, #self.handCardList do
            self.handCardList[i]:SetMesh(cards[i])
            self.handCardList[i]:SetState(MahjongItemState.inDiscardCard)
        end       

        self:SortHandCard(false, true, nil, function ()
            for i = 1, #self.handCardList do
                local z = -0.093
                if self.viewSeat == 1 then
                    z = -0.057
                end
                self.handCardList[i].transform.localPosition = Vector3(self.handCardList[i].transform.localPosition.x,0,z)
                self.handCardList[i]:DOLocalRotate(90,0,0, 0.2)
            end            

            self:AdjustHandPointPosX()
            if callback ~= nil then
                coroutine.start(function()
                    coroutine.wait(time)
                    callback()
                end)
            end        
        end)
    end)
end

function comp_mjPlayer:ShownAnGangCards(combineTile)
    if combineTile ~= nil then        
        for i,v in ipairs(combineTile) do
            if v.ucFlag == 19 then                
                for i=1,#self.operCardList do            
                    local mj = nil
                    for j=1,#self.operCardList[i].itemList do                    
                        if v.card == self.operCardList[i].itemList[j].paiValue then                    
                            mj = self.operCardList[i].itemList[j+3]
                            break
                        end
                    end
                    if mj ~= nil then
                        mj:DOLocalRotate(0,0,0, 0.2 * self:AnimSpd())
                        mj:ShowShadow()
                    end
                end
            end    
        end 
    end
end

function comp_mjPlayer:SetWinCardPos(mj)
    local x = self:GetHandPosX(#self.handCardList)
    x = x + mahjongConst.MahjongOffset_x/2 * 3
    local z = -0.093
    if self.viewSeat == 1 then
        z = -0.057
        -- 自己手牌偏移少两个位置
    end
    mj:SetParent(self.handCardPoint, false) 
    mj:DOLocalMove(Vector3(x, 0, z))
    mj:DOLocalRotate(90, 0, 0, 0)
    mj:SetParent(nil, true)
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
            index = 1
            while(index<=#self.handCardList) do
                if(self.handCardList[index].paiValue == searchCard[i]) then
                    local mjItem = self.handCardList[index]
                    self:RemoveShowFourCard(searchCard[i])
                    table.remove(self.handCardList,index)
                    table.insert(list,mjItem)
                    break
                end
                index = index + 1
            end
        else 
        --[[
        商丘亮四打一
        ]]
            if roomdata_center.gamesetting.bShowGive==true then
                local mjItem=nil
                index = 1
                while(index<=#self.handCardList) do
                    if(self.handCardList[index].paiValue == searchCard[i]) then
                        mjItem = self.handCardList[index]
                        self:RemoveShowFourCard(searchCard[i])
                        table.remove(self.handCardList,index)
                        table.insert(list,mjItem)
                        break
                    end
                    index = index + 1
                end
                local specialIndex=1 
                for i=1,#self.handCardList do
                    if self.handCardList[i].isSpecialCard==false then
                        specialIndex=i
                    end
                end
                if mjItem==nil then
                    local index = math.random(specialIndex,#self.handCardList)
                    mjItem = self.handCardList[index]
                    mjItem:SetMesh(searchCard[i])
                    table.remove(self.handCardList,index)
                    table.insert(list,mjItem)
                end
            else 
                local index = math.random(1,#self.handCardList)
                local mjItem = self.handCardList[index]
                mjItem:SetMesh(searchCard[i])
                table.remove(self.handCardList,index)
                table.insert(list,mjItem)
            end
        end
    end
    -- 校验操作牌数是否正确
    if #searchCard~= #list then
        logError("操作牌创建 error")
        SocketManager:reconnect()
        return
    end

    if mj~=nil then
        table.insert(list,mj)
    end
    self.InsertSort(list)
    return list
end

function comp_mjPlayer:RemoveShowFourCard(card)
    if self.ShowFourCardT then
        for i=1,#self.ShowFourCardT do
            if card == self.ShowFourCardT[i] then
                table.remove(self.ShowFourCardT,i)
                break
            end
        end
    end
end

--[[--
 * @Description: 给操作组添加牌  
 ]]
function comp_mjPlayer:AddOperCard( operData )
    for i=1,#self.operCardList do
        if (self.operCardList[i].operData.operType == MahjongOperAllEnum.TripletLeft or
            self.operCardList[i].operData.operType == MahjongOperAllEnum.TripletCenter or
            self.operCardList[i].operData.operType == MahjongOperAllEnum.TripletRight) and
            operData.operCard == self.operCardList[i].operData.operCard and 
            operData.operCard == self.operCardList[i].operData.otherOperCard[1] then
            local mj = nil
            local index = 1
            self.handCardCount = self.handCardCount - 1
            if self.viewSeat == 1 then
                while(index<=#self.handCardList) do
                    if(self.handCardList[index].paiValue == operData.operCard) then
                        mj = self.handCardList[index]
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

function comp_mjPlayer:ShowTingJinKan( operData )
    local oper = self.comp_operatorcard_class.create()
    oper.viewSeat = self.viewSeat
    oper.operObj.transform:SetParent( self.operCardPoint, false)
    oper.operObj.transform.localRotation = Vector3.zero
    local operCardList = self:GetOperCardList(operData)
    if operCardList then
        oper:Show(operData,operCardList)
        table.insert(self.operCardList, oper)
    end
end

--[[--
 * @Description: 恢复出牌
 ]]
function comp_mjPlayer:ResetOutCard(cardItems,cardsValue)
    for i=1,#cardItems do
        local mj = cardItems[i]
        mj:SetMesh(cardsValue[i])
        mj:SetParent(self.outCardPoint,false)
        local endPos = self:GetOutCardPos()
        mj:DOLocalMove(endPos)
        mj:DOLocalRotate(0,0,0,0)
        mj:SetState(MahjongItemState.inDiscardCard)
        roomdata_center.AddMj(mj.paiValue)
        mj:ShowShadow()
        table.insert(self.outCardList,mj)
    end
end

function comp_mjPlayer:GetReplaceCard(card)
    if card == self.config.GetReplaceSpecialCardValue() and card ~= 0 then
        return roomdata_center.specialCard[1] or card
    elseif card == roomdata_center.specialCard[1] and self.config.GetReplaceSpecialCardValue() ~= 0 then
        return self.config.GetReplaceSpecialCardValue()
    else
        return card
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
        local special=data.special  -- 特殊牌
        local oper = self.comp_operatorcard_class.create()
        oper.viewSeat = self.viewSeat
        oper.operObj.transform:SetParent(self.operCardPoint, false)
        oper.operObj.transform.localEulerAngles = Vector3.zero

        --计算操作牌方向
        local operWhoViewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(operWho)
        local offset = operWhoViewSeat - self.viewSeat 

        if offset<1 then
            offset = offset +roomdata_center.MaxPlayer()      -- 3：左 2：中 1：右
        end
        offset = player_seat_mgr.ViewSeatOffsetToIndexOffset(offset)

        --吃
        if ucFlag == 16 then        
            local operType = MahjongOperAllEnum.Collect

            local cardValue1 = self:GetReplaceCard(card)
            local cardValue2 = self:GetReplaceCard(cardValue1 + 1)
            local cardValue3 = self:GetReplaceCard(cardValue1 + 2)


            local od = operatordata:New(operType,card,{cardValue2,cardValue3}, ucFlag, operWho)
            local cards = GetResetCardsFunc(3)
            cards[1]:SetMesh(card)
            roomdata_center.AddMj(card)
            cards[2]:SetMesh(cardValue2)
            roomdata_center.AddMj(cardValue2)
            cards[3]:SetMesh(cardValue3)
            roomdata_center.AddMj(cardValue3)
            -- operWho 是吃的第几张牌 从0开始
            cards[operWho + 1]:SetCollectHighLight(true)
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
            local od = operatordata:New(operType,card,{card,card},ucFlag, operWho)
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

            local cardT={}
            if special==1 then 
                cardT={31,32,33,34}
                for i=1,#cardT do
                    if cardT[i]==card then
                        table.remove(cardT,i)
                    end
                end
            else
                cardT={card,card,card}
            end
            local od = operatordata:New(operType,card,cardT, ucFlag, operWho)
            local cards = GetResetCardsFunc(3,1)
            if special==1 then 
                local index=31
                for i=1,#cards do
                    cards[i]:SetMesh(index)
                    roomdata_center.AddMj(index)
                    index=index+1
                end
            else
                for i=1,#cards do
                    cards[i]:SetMesh(card)
                    roomdata_center.AddMj(card)
                end
            end
            
            oper:ReShow(od, cards)
        --暗杠
        elseif ucFlag == 19 then    
            operType = MahjongOperAllEnum.DarkBar
            local cardT={}
            if special==1 then 
                cardT={31,32,33,34}
                for i=1,#cardT do
                    if cardT[i]==card then
                        table.remove(cardT,i)
                    end
                end
            else
                cardT={card,card,card}
            end
            local od = operatordata:New(operType,card,cardT, ucFlag, operWho)
            local cards = GetResetCardsFunc(3,1)
            if special==1 then 
                local index=31
                for i=1,#cards do
                    cards[i]:SetMesh(index)
                    roomdata_center.AddMj(index)
                    index=index+1
                end
            else 
                for i=1,#cards do
                    cards[i]:SetMesh(card)
                    roomdata_center.AddMj(card)
                end
            end
            oper:ReShow(od, cards)
        --碰杠
        elseif ucFlag == 20 then    
            local cardT={}
            if special==1 then 
                cardT={31,32,33,34}
                for i=1,#cardT do
                    if cardT[i]==card then
                        table.remove(cardT,i)
                    end
                end
            else
                cardT={card,card,card}
            end
            operType = MahjongOperAllEnum.AddBar
            local od = operatordata:New(operType,card,cardT, ucFlag, operWho)
            local cards = GetResetCardsFunc(3,1)
            if special==1 then 
                local index=31
                for i=1,#cards do
                    cards[i]:SetMesh(index)
                    roomdata_center.AddMj(index)
                    index=index+1
                end
            else 
                for i=1,#cards do
                    cards[i]:SetMesh(card)
                    roomdata_center.AddMj(card)
                end
            end
            oper:ReShow(od, cards)
        end

        table.insert(self.operCardList, oper)
    end

    self:SortOper()
end 
--[[--
 * @Description: 恢复手牌  
 ]]
function comp_mjPlayer:ResetHandCard(cardItems,cardsValue,lastCard)
    if self.viewSeat == 1 then
    	if lastCard then
	        self.lastCardValue = lastCard 
	        for i=1,#cardsValue do
	            if cardsValue[i]==lastCard then
	                table.remove(cardsValue,i)
	                break
	            end
	        end
	        table.insert(cardsValue,lastCard)
    	else
    		self.lastCardValue = cardsValue[#cardsValue]
    	end
    end 
    for i=1,#cardItems do
        local mj = cardItems[i]
        mj:SetHandState(self.viewSeat == 1)
        
        mj:SetParent(self.handCardPoint, false)
        local x = self:GetHandPosX(i, #cardItems)

        mj:DOLocalMove(Vector3(x, 0, 0))
        mj:DOLocalRotate(0,0,0,0)


        local value = nil 
        if cardsValue ~= nil then
            value = cardsValue[i]
        end
        self:OnResetHandCard(mj, value)
       
        self.handCardCount = self.handCardCount + 1
        table.insert(self.handCardList,mj)
    end

    self:SortHandCard(false, nil, true)
end

function comp_mjPlayer:OnResetHandCard( mj, value )
    mj:SetMesh(MahjongTools.GetRandomCard())
    mj:ShowShadow()
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
    coroutine.stop(self.SortHandCard_c)
    coroutine.stop(self.DoOutCard_c)
    coroutine.stop(self.ShowWin_C)
    coroutine.stop(self.ShowReward_C)
    coroutine.stop(self.ShowTing_C)

    for i = 1, #self.ArrangeMjList_c_List do
        coroutine.stop(self.ArrangeMjList_c_List[i])
    end
    self.ArrangeMjList_c_List = {}
    for i = 1, #self.RemoveFlowers_c_List do
        coroutine.stop(self.RemoveFlowers_c_List[i])
    end
    self.RemoveFlowers_c_List = {}
    self.showHuaInTableCardList = {}
end

function comp_mjPlayer:Uninitialize()
	mode_comp_base.Uninitialize(self)
   
    self:StopAllCoroutine()
    -- self:UnRegisterEvents()
end

return comp_mjPlayer