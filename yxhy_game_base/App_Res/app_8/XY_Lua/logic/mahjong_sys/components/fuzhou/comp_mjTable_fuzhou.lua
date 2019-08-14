local comp_table = require("logic/mahjong_sys/components/base/comp_mjTable")
local comp_mjTable_fuzhou = class("comp_mjTable_fuzhou", comp_table)

function comp_mjTable_fuzhou:ctor()
	comp_table.ctor(self)

	self.mj = nil

	-- corotine
	self.SendAllHandCard_c_List = {}
	self.changeFlower_c_List = {}
	self.HideAllFlowerInTable_c = nil
	self.ShowJin_c_List = {}
	self.DoHideHuaCardsToPoint_C_List = {}
end

function comp_mjTable_fuzhou:SendAllHandCard(dun,viewSeat,cards,cb)
    self.SendAllHandCard_c = coroutine.start(function ()            
        self.sendIndex = dun * 2 + (viewSeat-1) * self.config.MahjongDunCount * 2--发牌位置
        self.lastIndex = self.sendIndex + 2
        local cardsIndex = 1
        local zhunagOffset =  roomdata_center.zhuang_viewSeat - 1
        local waitTime = 0.1
        local mjList = {}
        local playerNum = roomdata_center.MaxPlayer()
        --5圈牌
        for i = 1,5,1 do
            --4人
            for j = 1,playerNum,1 do
                local num = 4
                -- 庄 多摸一张
                if (i == 5) then
                    if (1 == j) then
                        num = 1
                    else
                        num = 0
                    end
                end

                local playerVSeat = j + zhunagOffset
                if playerVSeat > playerNum then
                    playerVSeat = playerVSeat -playerNum
                end

                --牌数
                for k = 1,num,1 do
                    if (self.sendIndex <= 0) then
                        self.sendIndex = self.config.MahjongTotalCount
                    end

                    local mj = self:GetMJItem(self.sendIndex)                       
                    --logError(self.sendIndex)

                    waitTime = 1
                    self.sendIndex = self.sendIndex - 1 

                    local paiValue = MahjongTools.GetRandomCard()
                    if playerVSeat == 1 and cards ~= nil then
                        paiValue = cards[cardsIndex]
                        cardsIndex = cardsIndex + 1
                    end

                    if mj ~= nil then
                        mj:SetMesh(paiValue)
                        table.insert(mjList, mj)
                    end
                end

                
                self.compPlayerMgr:GetPlayer(playerVSeat):AddDun(mjList)  

                mjList = {}

                    
              
            end

            -- if i < 5 or (i == 5 and j == 1) then
            coroutine.wait(0.5)
            -- end
        end
        if cb ~= nil then
            cb()
        end
    end)
    table.insert(self.SendAllHandCard_c_List, self.SendAllHandCard_c)
end

-- 从后向前获取最后一个索引  
-- 不会修改lastindex  获取完成后需要自己设置lastindex
function comp_mjTable_fuzhou:GetNextLastIndex(currentLastIndex, totalCount)
    local totalCount = self.config.MahjongTotalCount
    currentLastIndex = currentLastIndex - 1
    if math.fmod(currentLastIndex,2) == 0 then
        currentLastIndex = currentLastIndex + 4
        if currentLastIndex > totalCount then
            currentLastIndex = currentLastIndex - totalCount
            if math.fmod(currentLastIndex,2) ~= 0 then
                currentLastIndex = currentLastIndex + 1
            end
        end
    end
    return currentLastIndex
end

-- 从牌堆尾部获取一张牌
function comp_mjTable_fuzhou:SendCardFromLast(viewseat, paiValue,isDeal)
    if self.lastIndex > self.config.MahjongTotalCount then
        self.lastIndex = self.lastIndex - self.config.MahjongTotalCount
    end
    if roomdata_center.leftCard == 0 then
        return
    end
    mj = self:GetMJItem(self.lastIndex)
    -- 
    if mj.paiValue ~= nil or mj.mjObj.activeSelf == false then
        self.lastIndex = self:GetNextLastIndex(self.lastIndex)
        mj = self:GetMJItem(self.lastIndex, true)
    end

    -- self.lastIndex = self.lastIndex - 1
    -- if math.fmod(self.lastIndex,2) == 0 then
    --     self.lastIndex = self.lastIndex + 4
    -- end
    self.lastIndex = self:GetNextLastIndex(self.lastIndex)

    self:UpdateJinPosition()

    mj:SetMesh(paiValue)
    self.compPlayerMgr:GetPlayer(viewseat):AddHandCard(mj,isDeal)
end

 --从牌尾拿牌
function comp_mjTable_fuzhou:GetResetCardsFromLast(count)
    local list = {}
    for i = 1, count do 
        if self.lastIndex > self.config.MahjongTotalCount then
            self.lastIndex = self.lastIndex - self.config.MahjongTotalCount
        end
        mj = self:GetMJItem(self.lastIndex)

        -- self.lastIndex = self.lastIndex - 1
        -- if math.fmod(self.lastIndex,2) == 0 then
        --     self.lastIndex = self.lastIndex + 4
        -- end
        self.lastIndex = self:GetNextLastIndex(self.lastIndex)
        table.insert(list, mj)
    end
    return list
end

function comp_mjTable_fuzhou:ShowChangeFlowers(viewSeat, flowerCards, flowerCount, newCards, callback,isDeal)
    flowerCount = #flowerCards
    local changeFlower_c = coroutine.start(function()
    self.compPlayerMgr:GetPlayer(viewSeat):RemoveChangeFlowers(flowerCards,flowerCount, isDeal)
    if isDeal then
        coroutine.wait(0.5)
    else
        coroutine.wait(0.9)
    end
    for i = 1, flowerCount do
        local value = MahjongTools.GetRandomCard()
        if viewSeat == 1 then
            value = newCards[i]
        end

        self:SendCardFromLast(viewSeat, value,isDeal)
    end

    coroutine.wait(0.05)

    if isDeal then
        self.compPlayerMgr:GetPlayer(viewSeat):SortHandCard(false)
    else
        -- 打牌阶段 补花不需要排序
        -- self.compPlayerMgr:GetPlayer(viewSeat):SortHandCard(true)
    end
    coroutine.wait(0.05)
    if callback ~= nil then
        callback()
    end
    end)
    table.insert(self.changeFlower_c_List, changeFlower_c)
end

-- 在最后一张牌移动之前调用  
function comp_mjTable_fuzhou:UpdateJinPosition()
    -- 金牌显示在UI  不需要处理
    if true then
        return
    end
    if self.mjJin == nil then
        return
    end
    self:UpdateJinAtLastIndex()
    self.mjJin:ShowShadow()
end

-- 在最后一张牌上
function comp_mjTable_fuzhou:UpdateJinAtLastIndex()
    local mj = self.compMjItemMgr.mjItemList[self.lastIndex]
    local pos = mj.transform.localPosition
    local eulers = mj.transform.localEulerAngles
    local parent = mj.transform.parent
    if self.mjJin.transform.parent ~= parent then
        self.mjJin.transform:SetParent(parent, false)
    end
    local x = 0
    local y = 0
    x = pos.x
    y = pos.y + mahjongConst.MahjongOffset_y
    self.mjJin:DOLocalMove(Vector3(x, pos.y + mahjongConst.MahjongOffset_y, pos.z), 0)
    local eulerY = 180
    if self.lastIndex >= 1 and self.lastIndex <= 36 then
        eulerY = 0
    end
    self.mjJin:DOLocalRotate(Vector3(0, eulerY, 0), 0)
end

-- 在最后一墩上
function comp_mjTable_fuzhou:UpdateJinAtLastDun()
    local mj = self.compMjItemMgr.mjItemList[self.lastIndex]
    if mj == nil then
        logError("mj is nil", self.lastIndex)
    end
    if not Mathf.Approximately(mj.transform.localPosition.y ,mahjongConst.MahjongOffset_y) then
        local tmpIndex = self:GetNextLastIndex(self.lastIndex)
      
        -- 前移一墩
        mj = self.compMjItemMgr.mjItemList[self.lastIndex]
    end

    local pos = mj.transform.localPosition
    local parent = mj.transform.parent
    if self.mjJin.transform.parent ~= parent then
        self.mjJin:SetParent(parent, false)
    end
    local x = 0
    local y = 0
    x = pos.x
    y = pos.y + mahjongConst.MahjongOffset_y
    self.mjJin:DOLocalMove(Vector3(x, pos.y + mahjongConst.MahjongOffset_y, pos.z), 0)
    self.mjJin:DOLocalRotate(Vector3(0, 180, 0), 0)
end

function comp_mjTable_fuzhou:HideAllFlowerInTable(callback)
    self.HideAllFlowerInTable_c = coroutine.start(function()
        self.compPlayerMgr:HideHuaInTable()
        coroutine.wait(0.5)
        if nil ~= callback then
            callback()
        end
    end)

end

function comp_mjTable_fuzhou:ShowJin(cardValue, isJin,isAnim, callback)

    local mj = self:GetMJItem(self.lastIndex)
    mj:SetMesh(cardValue)
    mj:SetState(MahjongItemState.other)

    if isJin then
        self.mjJin = mj
        -- mj:SetSpecialCard(true)
    end

    self.lastIndex = self:GetNextLastIndex(self.lastIndex)

    -- self.lastIndex = self.lastIndex - 1
    -- if math.fmod(self.lastIndex,2) == 0 then
    --     self.lastIndex = self.lastIndex + 4
    -- end

    --@todo  更新牌数量，self.lastIndex 
    if not isAnim then
        if isJin then
            mahjong_ui.ShowSpecialCard(cardValue)
            mj:HideAndReset()
            -- self:UpdateJinPosition()
        else
            mj:HideAndReset()
        end
        return
    end
    local ShowJin_c = coroutine.start(function() 

    self:MoveMjTo3DCenter(mj, 0.2)
    coroutine.wait(0.25)
    self:MoveMjTo2DCenter(mj, 0)

    coroutine.wait(0.5)

    -- 是金 则返回原位置
    if isJin then
        local pos = mahjong_ui.GetSpeciaCardPos()
        self:DoHideToPoint({mj}, pos, 0.4, 
            function() mahjong_ui.ShowSpecialCard(mj.paiValue) end, true)
        -- self:UpdateJinPosition()
        
    else
        self:DoHideHuaCardsToPoint({mj}, roomdata_center.zhuang_viewSeat, 0.2, nil, true)
        -- roomdata_center.AddFlowerCardToZhuang(cardValue)
        coroutine.wait(0.21)
    end
    if callback ~= nil then
        callback()
    end
    end)
    table.insert(self.ShowJin_c_List, ShowJin_c)
end


-- 牌移动到3d中心
function comp_mjTable_fuzhou:MoveMjTo3DCenter(mj, time, pos,rotate)
    pos = pos or Vector3.zero
    rotate = rotate or Vector3(-50, 0 ,0 )
    mj:SetParent(self.threeDCenterRoot, true)
    mj:DOLocalMove(pos, time)
    mj:DOLocalRotate(rotate, time)
end

-- 默认角度为0  表示正朝相机
function comp_mjTable_fuzhou:MoveMjTo2DCenter(mj, time, pos, rotate)
    pos = pos or Vector3.zero
    mj:Set2DLayer()
    mj:SetParent(self.twoDCenterRoot, false)
    mj:DOLocalMove(pos, time)
    if rotate ~= nil then
        mj:DOLocalRotate(rotate, time)
    else
        mj:DOLocalRotate(Vector3.zero, time)
    end
end


function comp_mjTable_fuzhou:MoveMjListTo3DCenter(mjList, time, rotate)
    local count = #mjList
    local tmpPos = Vector3.zero
    for i = 1, count do
        tmpPos.x = -mahjongConst.MahjongOffset_x * (count - 1) / 2 + (i - 1) * mahjongConst.MahjongOffset_x
        self:MoveMjTo3DCenter(mjList[i], time, tmpPos, rotate)
    end
end

function comp_mjTable_fuzhou:MoveMjListTo2DCenter(mjList, time, rotate)
     local count = #mjList
    local tmpPos = Vector3.zero
    for i = 1, count do
        tmpPos.x = -mahjongConst.MahjongOffset_x * (count - 1) / 2 + (i - 1) * mahjongConst.MahjongOffset_x
        self:MoveMjTo2DCenter(mjList[i], time, tmpPos, rotate)
    end
end

 -- 移动到玩家花牌位置
function comp_mjTable_fuzhou:DoHideHuaCardsToPoint(mjList, viewSeat, time, callback, is2d)
    local point = mahjong_ui.GetPlayerHuaPointPos(viewSeat)
    self:DoHideToPoint(mjList, point, time, callback, is2d)
end
-- 移动到指定坐标
function comp_mjTable_fuzhou:DoHideToPoint(mjList, pos, time, callback, is2d)
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
        mjList[i]:DOScale(0.2, time)
    end

    if callback ~= nil then
        callback()
    end
    coroutine.wait(0.2)
    for i = 1, #mjList do
        mjList[i]:HideAndReset()
    end
    end)
    table.insert(self.DoHideHuaCardsToPoint_C_List, c)
end

function comp_mjTable_fuzhou:Clear()
    self.mjJin = nil
end

function comp_mjTable_fuzhou:StopAllCoroutine()
    comp_table.StopAllCoroutine(self)
    -- coroutine.stop(ShowJin_c)
    -- coroutine.stop(changeFlower_c)
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

function comp_mjTable_fuzhou:Uninitialize()
    comp_table.Uninitialize(self)
    self:StopAllCoroutine()
end


return comp_mjTable_fuzhou