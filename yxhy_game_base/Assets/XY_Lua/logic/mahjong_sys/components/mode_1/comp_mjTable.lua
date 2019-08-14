local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjTable = class("comp_mjTable", mode_comp_base)
local mahjong_path_mgr = mahjong_path_mgr

function comp_mjTable:ctor()
	self.name = "comp_mjTable"
	self.config = nil

    self.compMjItemMgr = nil -- 麻将子管理组件
    self.compPlayerMgr = nil -- 玩家管理组件
    self.tableObj = nil -- 桌子对象
    self.tableModelObj = nil -- 桌子模型对象

    -- self.mjSelectObj = nil -- 麻将选择效果对象
    self.mjDirObj = nil -- 牌桌东南西北对象

    self.timeLeft_trans = {} --倒计时十位列表
    self.timeRight_trans = {} --倒计时个位列表

    self.threeDCenterRoot = nil
    self.twoDCeneterRoot = nil

    self.mjWallPoints = {}

    self.mjWallRootTrList = {}

    --- coroutines    @todo  统一管理
    self.Wall_C_List = {}
    self.InitShowLai_c = nil


    ---- 计时相关 ----
    self.time_timer = nil --倒计时 计时器
    self.time_isAlarm = false
    self.time_alarmTime = 0
    self.time_count = 0 --倒计时 次数
    self.time_callback = nil -- 回调

    self.mj = nil
    self.mjJin = {}
    self.isNeedUpdateGlod = false
    self.exChangeSpecialCard = nil -- 和特殊牌交换位置的牌

    self.direction = require "logic/mahjong_sys/components/comp_mjDirection":create()


        -- corotine
    self.SendAllHandCard_c_List = {}
    self.changeFlower_c_List = {}
    self.HideAllFlowerInTable_c = nil
    self.ShowJin_c_List = {}
    self.DoHideHuaCardsToPoint_C_List = {}
end


function comp_mjTable:Initialize()
	mode_comp_base.Initialize(self)
    self.compMjItemMgr = self.mode:GetComponent("comp_mjItemMgr")
    self.compPlayerMgr = self.mode:GetComponent("comp_playerMgr")
    self.compScene = self.mode:GetComponent("comp_mjScene")
    self.config = self.mode.config
    self.cfg = self.mode.cfg

    self:InitTable()
    self:GetWallPoints() 
    self:SetTableFont()
    self:ResetWallRootPos()
    self:ChangeDeskCloth()
end

--[[--
 * @Description: 初始化牌桌对象  
 ]]
function comp_mjTable:InitTable()
	local resTableObj = newNormalObjSync(mahjong_path_mgr.GetMjPath("mjtable"), typeof(GameObject))	
	self.tableObj = newobject(resTableObj)
    self.transform = self.tableObj.transform

    self.tableModelObj = child(self.transform, "majiangzhuo").gameObject

    -- local mjSelect = newNormalObjSync(mahjong_path_mgr.GetMjPath("mj_select"), typeof(GameObject))
    -- self.mjSelectObj = newobject(mjSelect)

    self.mjDirObj = child(self.transform, "direction")
    self.direction:Init(self.mjDirObj)

    self.threeDCenterRoot = child(self.transform, "3DCenterPoint")
    self.twoDCenterRoot = child(self.transform, "2DCenterPoint")

    local timeleft = child(self.transform, "time/left")
    local timeright = child(self.transform, "time/right")
    for i=0,9 do
        local numl = child(timeleft,tostring(i))
        table.insert(self.timeLeft_trans,numl)
        local numr = child(timeright,tostring(i))
        table.insert(self.timeRight_trans,numr)
    end

    self.table_name_sprite = child(self.tableObj.transform, "name")

    local roomNumTr = child(self.tableObj.transform, "roomNum")
    self.roomNumComp = require("logic/mahjong_sys/components/base/comp_mjRoomNum"):create(roomNumTr)
end

function comp_mjTable:SetRoomNum(num)
    self.roomNumComp:SetRoomNum(num)
end

function comp_mjTable:SetDirection(direction)
    self.direction:SetDirection(direction)
end


function comp_mjTable:SetCurLightDir(viewSeat)
    local index = player_seat_mgr.ViewSeatToIndex(viewSeat)
    self.direction:SetLightItem(index)
end


function comp_mjTable:GetViewSeat(seat, playerNum)
    if seat > playerNum then
        seat = seat -playerNum
    end
    return seat
end


function comp_mjTable:GetFormatSendIndex(index)
    if (index <= 0) then
        index = self.config.MahjongTotalCount
    end
    return index
end


function comp_mjTable:SendAllHandCard(dun,viewSeat,cards,cb)
    --@todo 做成配置
    self.sendIndex = MahjongFuncSetUtil.GetSendIndexNormal(dun, viewSeat, self.config)
    self.sendIndex = self:GetFormatSendIndex(self.sendIndex)
    self.lastIndex = self:GetMutliNextIndex(self.sendIndex,2)
    local handCardMap = GameDealSendHandCardMap[self.cfg.gameDealSendHandCardMap]
    local co = coroutine.start(function ()            
   
        local cardsIndex = 1
        local zhunagOffset =  roomdata_center.zhuang_viewSeat - 1
        local waitTime = 0.1
        local mjList = {}
        local playerNum = roomdata_center.MaxPlayer()

        local circleCount = #handCardMap

        local curMjIndex = self.sendIndex

        for i = 1, circleCount do -- 圈
            for j = 1, playerNum do  --人
                local playerViewSeat = self:GetViewSeat(j + zhunagOffset, playerNum)
                local cardCount = handCardMap[i][j]

                if cardCount ~= nil and cardCount > 0 then
                    for k = 1, cardCount do  -- 牌
                        local mj = self:GetMJItem()
                        local paiValue = MahjongTools.GetRandomCard()
                        if playerViewSeat == 1 and cards ~= nil then
                            paiValue = cards[cardsIndex]
                            cardsIndex = cardsIndex + 1
                        end
                        if mj ~= nil then
                            mj:SetMesh(paiValue)
                            table.insert(mjList, mj)
                        end
                    end
                    self.compPlayerMgr:GetPlayer(playerViewSeat):AddDun(mjList)  

                    mjList = {}
                end
            end
            coroutine.wait(0.4)
        end
        
        if cb ~= nil then
            cb()
        end
    end)
    table.insert(self.SendAllHandCard_c_List, co)
end



function comp_mjTable:SetTableFont()
    if self.table_name_sprite then
        local spriteName = self.cfg.tableFontSpriteName
        if spriteName and spriteName~="" then
            local sprite1 = newNormalObjSync(mahjong_path_mgr.commonMJPrefix.."/texture/"..spriteName, typeof(UnityEngine.Texture))
            local comp1 = componentGet(self.table_name_sprite,"SpriteRenderer")
            if not IsNil(sprite1) then
                comp1.sprite = UnityEngine.Sprite.Create(sprite1,UnityEngine.Rect.New(0,0,sprite1.width,sprite1.height),Vector2(0.5,0.5))
            end 
        end
    end
end

function comp_mjTable:GetWallPoints()
    local mjWall = self.tableObj.transform:Find("MJWall")
    for i=1,4,1 do
        self.mjWallPoints[i] = mjWall:Find("majiangzhuo_wall_0"..i .. "/" .. i):Find("WallPoint")
        self.mjWallPoints[i].localPosition = self.config.sceneCfg.wallPointPosList[i]
        self.mjWallPoints[i].localScale = self.config.sceneCfg.wallScale
    end

    for i =1, 4, 1 do
        self.mjWallRootTrList[i] = mjWall:Find("majiangzhuo_wall_0"..i)
    end
end

function comp_mjTable:ResetWallRootPos()
    for i = 1, 4 do
        self.mjWallRootTrList[i].localPosition = self.config.sceneCfg.wallRootPointPosList[i]
    end
end

    --[[--
 * @Description: 初始化麻将墙  
 ]]
function comp_mjTable:InitWall()
    self:ShowWallInternal(nil, 
    function(mj) 
        mj:HideAndReset()
        mj.paiValue = nil
    end
    )
    self:ResetWallRootPos()
end

function comp_mjTable:ShowWall(cb)
    local InitWall_c = coroutine.start(function ()     
        self:ShowWallInternal( 
            nil,
            function(mj) 
                if self.cfg.isShowWall then
                    mj:Show(false)
                end
                mj:SetState(MahjongItemState.inWall)
            end)
        if cb~=nil then
            cb()
        end
    end)
    table.insert(self.Wall_C_List, InitWall_c)
end


function comp_mjTable:ShowWallInternal(dunCallback, itemCallback)
    local index = 1
    local x,y,z
    local wallCounts = self.config.wallDunCountMap
    for i = 1, #wallCounts do   -- 四排
        local offsetX = -(mahjongConst.MahjongOffset_x * wallCounts[i] / 2 - mahjongConst.MahjongOffset_x / 2)
        for j = 1, wallCounts[i] do  -- 墩数
            for k = 1, 2 do     -- 每墩两个
                local item = self.compMjItemMgr.mjItemList[index]
                x = offsetX
                y = (k - 1) * mahjongConst.MahjongOffset_y 
                item:SetParent(self.mjWallPoints[i], false)
                if self.cfg.isShowWall then
                    item:DOLocalMove(x,y,0, 0)
                end
                index = index + 1
                if nil ~= itemCallback then
                    itemCallback(item)
                end
            end
            offsetX = offsetX + mahjongConst.MahjongOffset_x
        end
    end
end


function comp_mjTable:ShowLai(dun, cardValue, isAnim,callback)
    Trace("ShowLai !!!!!!!!!!!!! dun "..dun.." cardValue "..cardValue)
    local laiIndex = self.lastIndex+(dun-1)*2
    if(laiIndex>self.config.MahjongTotalCount) then
        laiIndex = laiIndex - self.config.MahjongTotalCount
    end

    local tempIndex = self.lastIndex
    local tempMJ = nil

    self.InitShowLai_c = coroutine.start(function ()  
        -- if not IsNil(self.mjSelectObj) and isAnim then                 
        --     for i=1, dun do                                               
        --         tempMJ = self.compMjItemMgr.mjItemList[tempIndex]  
        --         if tempMJ ~= nil then
        --             self.mjSelectObj.transform.position = tempMJ.transform.position
        --             if i==1 then
        --                 self.mjSelectObj.transform.rotation = tempMJ.transform.rotation
        --             end
        --             coroutine.wait(0.2) 
        --         end
        --         tempIndex = tempIndex + 2
        --         if tempIndex > self.config.MahjongTotalCount then
        --             tempIndex = tempIndex - self.config.MahjongTotalCount
        --         end
        --     end

        --     if not IsNil(self.mjSelectObj) then
        --         self.mjSelectObj.transform.position = Vector3.zero
        --     end

        -- end

        local mj = self.compMjItemMgr.mjItemList[laiIndex]
        mj:SetMesh(cardValue)
        mj:Show(true,isAnim)

        if callback~=nil then
            callback()
        end
    end)
    
end

--[[--
 * @Description: 摸牌  
 ]]
function comp_mjTable:SendCard( viewSeat,paiValue ,isDeal)
    if roomdata_center.leftCard == 0 then
        return
    end
    local mj,flag = self:GetMJItem(nil, nil, true)
    local isExchange = false
    local originPos_exchangeJin
    if mj ~= nil and self.exChangeSpecialCard == mj then
        isExchange = true
        originPos_exchangeJin = mj.transform.localPosition
    end
    mj:SetMesh(paiValue)
    self.compPlayerMgr:GetPlayer(viewSeat):AddHandCard(mj,isDeal)

    if flag then 
        self.isNeedUpdateGlod = true
    end

    if isExchange and originPos_exchangeJin then
        local x,y,z = originPos_exchangeJin:Get()
        self.mjJin[1]:DOLocalMove( x,y,z,0)
    elseif self.isNeedUpdateGlod then
        self:UpdateJinPosition()
    end
end


-- 从牌堆尾部获取一张牌
function comp_mjTable:SendCardFromLast(viewseat, paiValue,isDeal)
    if roomdata_center.leftCard == 0 then
        return
    end
    local mj,flag = self:GetMJItem(true, nil, true)

    local isExchange = false
    local originPos_exchangeJin
    if mj ~= nil and self.exChangeSpecialCard == mj then
        isExchange = true
        originPos_exchangeJin = mj.transform.localPosition
    end
    
    mj:SetMesh(paiValue)
    self.compPlayerMgr:GetPlayer(viewseat):AddHandCard(mj,isDeal)

    if flag then 
        self.isNeedUpdateGlod = true
    end

    if isExchange and originPos_exchangeJin then
        local x,y,z = originPos_exchangeJin:Get()
        self.mjJin[1]:DOLocalMove(x,y,z,0)
    elseif self.isNeedUpdateGlod then
        self:UpdateJinPosition()
    end
end

-- 在最后一张牌移动之前调用  
function comp_mjTable:UpdateJinPosition()
    if self.mjJin[1] == nil then
        return
    end
    self:UpdateJinAsLastCard()
end


-- 在最后一张牌上
function comp_mjTable:UpdateJinAtLastIndex()
    local mj = self.compMjItemMgr.mjItemList[self.lastIndex]
    local pos = mj.transform.localPosition
    local eulers = mj.localEulers
    local parent = mj.transform.parent
    if self.mjJin[1].transform.parent ~= parent then
        self.mjJin[1]:SetParent(parent, false)
    end
    local x = 0
    local y = 0
    x = pos.x
    y = pos.y + mahjongConst.MahjongOffset_y
    self.mjJin[1]:DOLocalMove(x, pos.y + mahjongConst.MahjongOffset_y, pos.z, 0)
end

function comp_mjTable:UpdateJinAsLastCard()
    if self.compMjItemMgr.mjItemList[self.lastIndex]~= self.mjJin[1] then
        if self.lastIndex % 2 == 1 then
            self:UpdateJinAtLastIndex()
            return
        else
            -- 直接落下
            self.mjJin[1]:DOLocalMove(self.mjJin[1].transform.localPosition.x, 0, 0, 0)
        end
    end
    self.mjJin[1]:ShowShadow()
end


function comp_mjTable:HideAllFlowerInTable(callback)
    self.HideAllFlowerInTable_c = coroutine.start(function()
        self.compPlayerMgr:HideHuaInTable()
        coroutine.wait(0.5)
        if nil ~= callback then
            callback()
        end
    end)

end

-- 牌移动到3d中心
function comp_mjTable:MoveMjTo3DCenter(mj, time, pos,rotate)
    pos = pos or Vector3.zero
    rotate = rotate or Vector3(-50, 0 ,0 )
    mj:SetParent(self.threeDCenterRoot, true)
    local x,y,z = pos:Get()
    mj:DOLocalMove(x,y,z, time)
    mj:DOLocalRotate(rotate.x, rotate.y, rotate.z, time)
end

-- 默认角度为0  表示正朝相机
function comp_mjTable:MoveMjTo2DCenter(mj, time, pos, rotate)
    pos = pos or Vector3.zero
    mj:SetParent(nil, false)
    local camera = self.compScene.twoDCamera
    local centerPos = camera:ScreenToWorldPoint(Vector3(Screen.width/2,Screen.height*3/5, self.threeDCenterRoot.position.z - camera.transform.position.z))
    centerPos = centerPos + pos
    local x,y,z = centerPos:Get()
    mj:DOLocalMove(x,y,z, 0)
    rotate = rotate or Vector3(-90, 0 ,0)
    if rotate ~= nil then
        mj:DOLocalRotate(rotate.x, rotate.y, rotate.z, time)
    else
        mj:DOLocalRotate(0,0,0, time)
    end
    mj:Set2DLayer()
end

function comp_mjTable:MoveMjListTo3DCenter(mjList, time, rotate)
    local count = #mjList
    local tmpPos = Vector3.zero
    for i = 1, count do
        tmpPos.x = -mahjongConst.MahjongOffset_x * (count - 1) / 2 + (i - 1) * mahjongConst.MahjongOffset_x
        self:MoveMjTo3DCenter(mjList[i], time, tmpPos, rotate)
    end
end

function comp_mjTable:MoveMjListTo2DCenter(mjList, time, rotate)
     local count = #mjList
    local tmpPos = Vector3.zero
    for i = 1, count do
        tmpPos.x = -mahjongConst.MahjongOffset_x * (count - 1) / 2 + (i - 1) * mahjongConst.MahjongOffset_x
        self:MoveMjTo2DCenter(mjList[i], time, tmpPos, rotate)
    end
end


-- 移动到玩家花牌位置
function comp_mjTable:DoHideHuaCardsToPoint(mjList, viewSeat, time, callback, is2d)
    local point = mahjong_ui:GetPlayerHuaPointPos(viewSeat)
    self:DoHideToPoint(mjList, point, time, callback, is2d)
end
-- 移动到指定坐标
function comp_mjTable:DoHideToPoint(mjList, pos, time, callback, is2d)
    if pos == nil then
        if callback ~= nil then
            callback()
        end
        return
    end
    local c = coroutine.start(function ()
    local point = pos
    -- point = Utils.NGUIPosTo2DCameraPos(point)
    if is2d then
        point = Utils.NGUIPosTo2DCameraPos(point)
    else
        point = Utils.NGUIPosTo3DCameraPos(point)
    end
    if point == nil then
        logError("找不到 viewSeat  " .. viewSeat)
    end
    for i = 1, #mjList do 
        -- mjList[i]:Set2DLayer()
        mjList[i]:DOMove(point, time, false)
        mjList[i]:DOScale(0, time)
    end

    if callback ~= nil then
        callback()
    end
    coroutine.wait(0.21)
    for i = 1, #mjList do
        mjList[i]:HideAndReset()
    end
    end)
    table.insert(self.DoHideHuaCardsToPoint_C_List, c)
end


function comp_mjTable:Clear()
    self.mjJin = {}
    self.isNeedUpdateGlod = false
    self.exChangeSpecialCard = nil
end

-- 从后向前获取最后一个索引  
-- 不会修改lastindex  获取完成后需要自己设置lastindex
function comp_mjTable:GetNextLastIndex(currentLastIndex, totalCount)
    return self:GetMutliNextIndex(currentLastIndex ,1,totalCount)
end

--[[--
 * @Description: 获取从后向前数第count个的索引   
 ]]
function comp_mjTable:GetMutliNextIndex(currentLastIndex,count, totalCount)
    local totalCount = totalCount or self.config.MahjongTotalCount
    if math.fmod(count,2) == 0 then
        currentLastIndex = currentLastIndex + count
    else
        if math.fmod(currentLastIndex,2) == 0 then
            currentLastIndex = currentLastIndex + count - 2
        else
            currentLastIndex = currentLastIndex + count + 2
        end
    end

    if currentLastIndex > totalCount then
        currentLastIndex = currentLastIndex - totalCount
    end

    return currentLastIndex
end


 --[[--
 * @Description: 取走一个牌子，无需关心下标和摸到特殊牌
 * sendLast：是否从牌尾拿
 * isTouchSpecialCard：是否摸到了特殊牌，默认不穿或者传false
 * return mj,isTouchSpecialCard：取走的牌子和是否摸到了特殊牌
 ]]
function comp_mjTable:GetMJItem(sendLast,isTouchSpecialCard, notUpdateRoomCard)
    local sendLast = sendLast or false
    local isTouchSpecialCard = isTouchSpecialCard or false

    if roomdata_center.leftCard <= 0 then
        return nil,isTouchSpecialCard
    end

    local isSame = false
    if self.lastIndex == self.sendIndex then
        isSame = true
    end
    local mj
    if sendLast then
        mj = self.compMjItemMgr.mjItemList[self.lastIndex]
        self.lastIndex = self:GetNextLastIndex(self.lastIndex)
        if isSame then
            self.sendIndex = self.sendIndex - 1
        end
    else
        mj = self.compMjItemMgr.mjItemList[self.sendIndex]
        self.sendIndex = self.sendIndex - 1
        if isSame then
            self.lastIndex = self:GetNextLastIndex(self.lastIndex)
        end
    end
    if isSame and self.lastIndex > self.sendIndex then
        if not notUpdateRoomCard then
            roomdata_center.UpdateRoomCard(-1)
        end
        return mj,isTouchSpecialCard
    end
    if self.sendIndex <= 0 then
        self.sendIndex = self.sendIndex + self.config.MahjongTotalCount
    end
    if mj == nil then
        logError(roomdata_center.leftCard,self.config.MahjongTotalCount,self.sendIndex,self.lastIndex)
    end
    if mj and mj.curState == MahjongItemState.inWall then
        if not notUpdateRoomCard then
            roomdata_center.UpdateRoomCard(-1)
        end
        return mj,isTouchSpecialCard
    else
        return self:GetMJItem(sendLast,true, notUpdateRoomCard)
    end

end

--[[--
 * @Description: 恢复完整牌墙  
 ]]
function comp_mjTable:ReShowWall()
    self:ShowWallInternal(nil,
        function (mj) 
            if self.cfg.isShowWall then
                mj:Show(false)
                mj:ShowShadow()
            end
            mj:SetState(MahjongItemState.inWall)
        end)
end

--[[--
 * @Description: 恢复牌墙  
 ]]
function comp_mjTable:ResetWall(dun,viewSeat)
    local index = 1
    local wallCounts = self.config.wallDunCountMap
    for i = 1, #wallCounts do   -- 四排
        for j = 1, wallCounts[i] do  -- 墩数
            for k = 1, 2 do     -- 每墩两个
                local item = self.compMjItemMgr.mjItemList[index]
                if self.cfg.isShowWall then
                    item:Show(false)
                    item:ShowShadow()
                end
                item:SetState(MahjongItemState.inWall)
                index = index + 1
            end
        end
    end

    self.sendIndex = dun * 2 + (viewSeat-1) * wallCounts[viewSeat] * 2 --发牌位置
    self.lastIndex = self:GetMutliNextIndex(self.sendIndex, 2)
end

 --[[--
 * @Description: 得到一组牌子，重连用  
 ]]
function comp_mjTable:GetResetCards( count ,lastCount)
    local list = {}
    for i=1,count do
        local mj = self:GetMJItem()
        table.insert(list,mj)
    end
    if lastCount and lastCount > 0 then
        local lastList = self:GetResetCardsFromLast(lastCount)
        for i,v in ipairs(lastList) do
            table.insert(list,v)
        end
    end
    return list
end

 --从牌尾拿牌
function comp_mjTable:GetResetCardsFromLast(count)
    local list = {}
    for i = 1, count do 
        local mj = self:GetMJItem(true)
        table.insert(list, mj)
    end
    return list
end

--[[--
 * @Description: 设置定时器  
 ]]
function comp_mjTable:SetTime(time,isAlarm,alarmTime,shakeTimeTbl,fun,funLeftTime)
    if self.time_timer~=nil then
        self.time_timer:Stop()
        self.time_timer = nil
    end
    self.time_count = math.floor(time)

    self.time_isAlarm = isAlarm or false
    self.time_alarmTime = alarmTime or 0
    self.shakeTimeTbl = shakeTimeTbl or {}

    if fun~=nil then
        self.time_count = self.time_count - (funLeftTime or 0)
        self.time_callback = fun
    end

    self.time_timer = Timer.New(slot(self.UpdateTime, self), 1, self.time_count+1)
    self.time_timer:Start()  
end

  --[[--
 * @Description: 更新时间  
 ]]
function comp_mjTable:UpdateTime()
    if self.time_count <= 0 and self.time_callback~=nil then
        self.time_callback()
        self:StopTime(false)
    end

    if self.time_count >= 0 then
        if IsTblIncludeValue(math.ceil(self.time_count),self.shakeTimeTbl) then
            Notifier.dispatchCmd(cmdName.MSG_SHAKE,{}) 
        end
        if self.time_isAlarm and self.time_count < self.time_alarmTime then
            ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("timeup_alarm"))
        end

        local leftNum = math.floor(self.time_count/10)
        local rightNum = self.time_count-leftNum*10
        for i,v in ipairs(self.timeLeft_trans) do
            v.gameObject:SetActive(false)
        end
        for i,v in ipairs(self.timeRight_trans) do
            v.gameObject:SetActive(false)
        end
        if self.timeLeft_trans[leftNum+1] then
            self.timeLeft_trans[leftNum+1].gameObject:SetActive(true)
        end
        if self.timeRight_trans[rightNum+1] then
            self.timeRight_trans[rightNum+1].gameObject:SetActive(true)
        end
        self.time_count = self.time_count - 1
    end
end

function comp_mjTable:StopShakeTime()
    self.shakeTimeTbl = {}
end

 --[[--
 * @Description: 停止定时器  
 ]]
function comp_mjTable:StopTime(isHide)
    isHide = isHide or true
    if isHide then
        for i,v in ipairs(self.timeLeft_trans) do
            v.gameObject:SetActive(false)
        end
        for i,v in ipairs(self.timeRight_trans) do
            v.gameObject:SetActive(false)
        end
    end
    if self.time_timer~=nil then
        self.time_timer:Stop()
        self.time_timer = nil
    end
    self.time_count = 0
    self.time_isAlarm = false
    self.time_alarmTime = 0
    self.shakeTimeTbl = {}
    self.time_callback = nil
end

--[[--
 * @Description: 更换桌布  
 ]]
function comp_mjTable:ChangeDeskCloth()
    local clothNum = hall_data.GetPlayerPrefs("desk")
    if clothNum~= "1" and clothNum~= "2" and clothNum~= "3" then
        return
    end
    local matName = "zhuozi_0"..clothNum..""
    local mat = newNormalObjSync(mahjong_path_mgr.GetMaterialPath(matName), typeof(UnityEngine.Material))
    local meshRenderer = self.tableModelObj:GetComponent(typeof(UnityEngine.MeshRenderer))
    meshRenderer.sharedMaterial = mat
    for i = 1, 4  do
        local mr = self.mjWallRootTrList[i]:GetComponent(typeof(UnityEngine.MeshRenderer))
        mr.sharedMaterial = mat
    end

    if self.table_name_sprite then
        componentGet(self.table_name_sprite,"SpriteRenderer").color = mahjongConst.TableFontColor[tonumber(clothNum)] -- Color.green -- mahjongConst.TableFontColor[clothNum]
    end
    if self.roomNumComp then
        self.roomNumComp:SetColor(tonumber(clothNum))
    end
end

function comp_mjTable:StopAllCoroutine()
    coroutine.stop(self.InitShowLai_c)
    for i = 1, #self.Wall_C_List do
        coroutine.stop(self.Wall_C_List[i])
    end
    self.Wall_C_List = {}
    self.InitShowLai_c = nil

     coroutine.stop(self.HideAllFlowerInTable_c)
    for i = 1, #self.DoHideHuaCardsToPoint_C_List do
        coroutine.stop(self.DoHideHuaCardsToPoint_C_List[i])
    end
    self.DoHideHuaCardsToPoint_C_List = {}

    for i = 1, #self.changeFlower_c_List do
        coroutine.stop(self.changeFlower_c_List[i])
    end
    self.changeFlower_c_List = {}
     for i = 1, #self.ShowJin_c_List do
        coroutine.stop(self.ShowJin_c_List[i])
    end

    for i = 1, #self.SendAllHandCard_c_List do
        coroutine.stop(self.SendAllHandCard_c_List[i])
    end
    self.SendAllHandCard_c_List = {}

    self.ShowJin_c_List = {}
end

function comp_mjTable:Uninitialize()
	mode_comp_base.Uninitialize(self)
    self.roomNumComp:Uninitialize()
    self:StopAllCoroutine()
    self.compMjItemMgr = nil 
    self.compPlayerMgr = nil
    self:StopTime()
end

return comp_mjTable