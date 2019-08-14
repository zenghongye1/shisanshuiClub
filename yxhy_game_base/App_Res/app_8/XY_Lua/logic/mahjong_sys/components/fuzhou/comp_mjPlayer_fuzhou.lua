local comp_player = require("logic/mahjong_sys/components/base/comp_mjPlayer")
local comp_mjPlayer_fuzhou = class("comp_player", comp_player)


local DunIndexToLocalHandIndex = 
{
    [1] = 4,
    [2] = 2,
    [3] = 3,
    [4] = 1,
}

function comp_mjPlayer_fuzhou:ctor()
	comp_player.ctor(self)

	self.comp_operatorcard_class = require "logic/mahjong_sys/components/fuzhou/comp_mjOperatorcard_fuzhou"
	 -- 缓存在桌子中间花牌
    self.showHuaInTableCardList = {}

	self.compTable = nil

	self.ArrangeMjList_c_List = {}
	self.RemoveFlowers_c_List = {}
end


function comp_mjPlayer_fuzhou:GetTable()
    if self.compTable ~= nil then
        return self.compTable
    end
    self.compTable = mode_manager.GetCurrentMode():GetComponent("comp_mjTable")
    return self.compTable
end

function comp_mjPlayer_fuzhou:AddDun(mjs)
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
        x = self.handCardCount * mahjongConst.MahjongOffset_x 
        --别人的牌墩 默认放在中间
        if x < 7 * mahjongConst.MahjongOffset_x then
            x = 7 * mahjongConst.MahjongOffset_x
        end
    end


    
    local moveMjFunc = function(mj, xA,  yA, zA) 
        mj:SetParent(self.handCardPoint, false) 
        mj:DOLocalMove(Vector3(xA, yA, zA), 0, false)
        mj:DOLocalRotate(Vector3(-90,0,0), 0,DG.Tweening.RotateMode.Fast)
        if self.viewSeat == 1 then
            -- mj.eventPai = function( mj )
            --     self:ClickCardEvent( mj )
            -- end
            mj.onClickCallback = slot(self.ClickCardEvent, self)
        end
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
   
    self:ArrangeMjList(mjList)   
    -- self.handCardCount = self.handCardCount +  #mjList
    
end

function comp_mjPlayer_fuzhou:AddMjListToHand(mjList)
    for i = 1, #mjList do
        table.insert(self.handCardList, mjList[i])
        mjList[i]:SetHandState(self.viewSeat == 1)
    end
end

local arrangeTime = 0.1

 -- 将两墩展开，上层两张牌放到后面，并掀开
function comp_mjPlayer_fuzhou:ArrangeMjList(mjList, callback)
    --向后平移/向下
    local moveFunc = function(mj, down)
        local y = 0
        if self.viewSeat == 1 then
            y = -0.1
        end
        local pos = mj.transform.localPosition
        if not down then
            mj:DOLocalMove(Vector3(pos.x + mahjongConst.MahjongOffset_x * 2, y, pos.z), arrangeTime, false)
        else
            mj:DOLocalMove(Vector3(pos.x, y, 0), arrangeTime, false)
        end
    end



    local ArrangeMjList_c = coroutine.start(function()
                coroutine.wait(0.05)
                if #mjList == 4 then
                    --平移
                   
                    moveFunc(mjList[3])
                    moveFunc(mjList[4])

                    coroutine.wait(arrangeTime)
                    -- 下移
                    moveFunc(mjList[3], true)
                    moveFunc(mjList[4], true)
                end

                coroutine.wait(0.1)
                if #mjList == 4 then
                    LuaHelper.SetTransformLocalZ(mjList[1].transform, 0)
                    LuaHelper.SetTransformLocalZ(mjList[2].transform, 0)
                end
                -- 翻牌
                for i, v in ipairs(mjList) do
                    v:DOLocalRotate(Vector3.zero, arrangeTime, DG.Tweening.RotateMode.Fast)
                end

                coroutine.wait(arrangeTime)

                for i, v in ipairs(mjList) do   
                    if self.viewSeat == 1 then
                        -- mjList[i]:Set2DLayer()
                        -- mjList[i]:AddEventListener()
                        mjList[i].dragEvent = function(mj)
                            self:DragCardEvent(mj)
                        end
                    end
                end

                self:AddMjListToHand(mjList)

                -- 移动到牌的位置
                for i, v in ipairs(mjList) do 
                    mjList[i]:DOLocalMove(Vector3(mahjongConst.MahjongOffset_x * (self.handCardCount + i - 1), 0, 0), 0.2, false)
                end


                self.handCardCount = self.handCardCount + #mjList

                coroutine.wait(arrangeTime)
                if self.viewSeat == 1 then
                    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_deal_card", true))
                end

                

            end
            )    

    table.insert(self.ArrangeMjList_c_List, ArrangeMjList_c)
end


-- 通用玩家显示补花操作
-- 位置， 花牌，花牌数量, 替换牌，回调
function comp_mjPlayer_fuzhou:RemoveChangeFlowers( flowerCards, flowerCount, isDeal)
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
        coroutine.wait(0.2)
    else
        coroutine.wait(0.3)
        
        for i = 1, #mjList do 
            local pos = mjList[i].transform.localPosition
            pos.z = pos.z + mahjongConst.MahjongOffset_y
            mjList[i]:DOLocalMove(pos, 0.2)
        end
        coroutine.wait(0.2)
        self:GetTable():DoHideHuaCardsToPoint(mjList, self.viewSeat, 0.3, nil, self.viewSeat == 1)
    end
    -- self:SortHandCard(false)

    -- coroutine.wait(0.3)
    -- 隐藏
    -- self:GetTable():DoHideHuaCardsToPoint(mjList, self.viewSeat, hideTime)


    end)
    table.insert(self.RemoveFlowers_c_List,RemoveFlowers_c)
   return time + hideTime
end

function comp_mjPlayer_fuzhou:DoMoveToHuaPoint(mjList,isSelf)
    local mj
    local moveTime = 0.2
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

function comp_mjPlayer_fuzhou:DoHideFlowerCards()
    if #self.showHuaInTableCardList == 0 then
        return
    end
    self:GetTable():DoHideHuaCardsToPoint(self.showHuaInTableCardList ,self.viewSeat, 0.2, function() self.showHuaInTableCardList = {} end)
end


function comp_mjPlayer_fuzhou:DoSelfCardsMoveToCenter(mjList, time)
    self:GetTable():MoveMjListTo2DCenter(mjList, time)
end

function comp_mjPlayer_fuzhou:DoOtherCardsMoveToCenter(mjList, time)
    self:GetTable():MoveMjListTo3DCenter(mjList, time)
    coroutine.wait(time+ 0.05)
    self:GetTable():MoveMjListTo2DCenter(mjList, 0)
end

-- 获取自己手牌中指定列表
-- reverse : 是否反序查找 
-- remove : 是否要移除列表
function comp_mjPlayer_fuzhou:GetSelfCardsByCardValueList(cardValues, reverse, remove)
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
function comp_mjPlayer_fuzhou:GetOterCardsByCount(flowerCards, count, remove)
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

-- function comp_mjPlayer_fuzhou:ShowLaiInHand()
--     for i=1,#self.handCardList do
--         self.handCardList[i]:UpdateSpecialCard()
--     end
-- end


-- function comp_mjPlayer_fuzhou:ShowJinInHand()
--      for i=1,#self.handCardList do
--         self.handCardList[i]:UpdateSpecialCard()
--     end
--     self:SortHandCard(false)
-- end


function comp_mjPlayer_fuzhou:ShowTingInHand()
    for i = 1, #self.handCardList do
        if roomdata_center.CheckCardTing(self.handCardList[i].paiValue) then
            self.handCardList[i]:SetTingIcon(true)
        end
    end
end

function comp_mjPlayer_fuzhou:HideTingInHand()
      for i = 1, #self.handCardList do
        self.handCardList[i]:SetTingIcon(false)
    end
end

function comp_mjPlayer_fuzhou:AutoOutCard(paiValue)
    mahjong_ui.cardShowView:Hide()
    self:HideTingInHand()
    self:SetCanOut(false)
    roomdata_center.selfOutCard = paiValue
    local compPlayerMgr = self.mode:GetComponent("comp_playerMgr")
    local compResMgr = self.mode:GetComponent("comp_resMgr")
    compPlayerMgr:HideHighLight()
    self:OutCard(paiValue, function(pos) compResMgr:SetOutCardEfObj(pos) end)
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_out", true))
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(paiValue))
end

--出牌动作
function comp_mjPlayer_fuzhou:DoOutCard(item, callback)
    self.DoOutCard_c = coroutine.start(function ()
        local mj = item;

        mj:SetState(MahjongItemState.inDiscardCard)
        mj:SetParent( self.outCardPoint, true)
        mj.transform.localScale = Vector3.one
        -- 牌上移 防止穿过牌墩
        LuaHelper.SetTransformLocalY(mj.transform, 0.4)

        local endPos = self:GetOutCardPos();
         mj:DOLocalMove(endPos, 0.2,false):OnComplete(function ()
            if callback ~= nil then
                callback(mj.transform.position + Vector3.New(0, 0.102, 0))
            end
        end)
        mj:DOLocalRotate(Vector3.zero, 0,DG.Tweening.RotateMode.Fast);
        table.insert(self.outCardList,mj)
        coroutine.wait(0.2)
        mj:ShowShadow()

        self:SortHandCard(true and roomdata_center.leftCard~=0)
       
    end)
end

--[[--
 * @Description: 给操作组添加牌  
 ]]
function comp_mjPlayer_fuzhou:AddOperCard( operData )
    --Trace("!!!!!!!!---------AddOperCard----------operData.operCard "..operData.operCard.." operCardList[i].keyItem.paiValue "..operCardList[i].keyItem.paiValue)
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

function comp_mjPlayer_fuzhou:Uninitialize()
	comp_player.Uninitialize(self)
    self:StopAllCoroutine()
end

function comp_mjPlayer_fuzhou:StopAllCoroutine()
    for i = 1, #self.ArrangeMjList_c_List do
        coroutine.stop(self.ArrangeMjList_c_List[i])
    end
    self.ArrangeMjList_c_List = {}
    --coroutine.stop(BuHuaInHand_c)
    --coroutine.stop(RemoveFlowers_c)
    for i = 1, #self.RemoveFlowers_c_List do
        coroutine.stop(self.RemoveFlowers_c_List[i])
    end
    self.RemoveFlowers_c_List = {}
    self.showHuaInTableCardList = {}
end


return comp_mjPlayer_fuzhou