local comp_table = require("logic/mahjong_sys/components/base/comp_mjTable")
local comp_mjTable_fuzhou = class("comp_mjTable_fuzhou", comp_table)

function comp_mjTable_fuzhou:ctor()
	comp_table.ctor(self)

	self.mj = nil
    self.mjJin = {}
    self.isNeedUpdateGlod = false
    self.exChangeSpecialCard = nil -- 和特殊牌交换位置的牌


	-- corotine
	self.SendAllHandCard_c_List = {}
	self.changeFlower_c_List = {}
	self.HideAllFlowerInTable_c = nil
	self.ShowJin_c_List = {}
	self.DoHideHuaCardsToPoint_C_List = {}
end

function comp_mjTable_fuzhou:GetViewSeat(seat, playerNum)
    if seat > playerNum then
        seat = seat -playerNum
    end
    return seat
end

function comp_mjTable_fuzhou:GetFormatSendIndex(index)
    if (index <= 0) then
        index = self.config.MahjongTotalCount
    end
    return index
end

function comp_mjTable_fuzhou:SendAllHandCard(dun,viewSeat,cards,cb)
    --self.sendIndex = dun * 2 + (viewSeat-1) * self.config.MahjongDunCount * 2--发牌位置
    --@todo 做成配置
    self.sendIndex = MahjongFuncSetUtil.GetSendIndexNormal(dun, viewSeat, self.config)
    self.sendIndex = self:GetFormatSendIndex(self.sendIndex)
    self.lastIndex = self:GetMutliNextIndex(self.sendIndex,2)
    local handCardMap = self.config.gameDealSendHandCardMap
    self.SendAllHandCard_c = coroutine.start(function ()            
   
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
            coroutine.wait(0.5)
        end
        -- --5圈牌
        -- for i = 1,5,1 do
        --     --4人
        --     for j = 1,playerNum,1 do
        --         local num = 4
        --         -- 庄 多摸一张
        --         if (i == 5) then
        --             if (1 == j) then
        --                 num = 1
        --             else
        --                 num = 0
        --             end
        --         end

        --         local playerVSeat = j + zhunagOffset
        --         if playerVSeat > playerNum then
        --             playerVSeat = playerVSeat -playerNum
        --         end

        --         --牌数
        --         for k = 1,num,1 do
        --             if (self.sendIndex <= 0) then
        --                 self.sendIndex = self.config.MahjongTotalCount
        --             end

        --             local mj = self:GetMJItem()                       
        --             --logError(self.sendIndex)

        --             waitTime = 1
        --             -- self.sendIndex = self.sendIndex - 1 

        --             local paiValue = MahjongTools.GetRandomCard()
        --             if playerVSeat == 1 and cards ~= nil then
        --                 paiValue = cards[cardsIndex]
        --                 cardsIndex = cardsIndex + 1
        --             end

        --             if mj ~= nil then
        --                 mj:SetMesh(paiValue)
        --                 table.insert(mjList, mj)
        --             end
        --         end

                
        --         self.compPlayerMgr:GetPlayer(playerVSeat):AddDun(mjList)  

        --         mjList = {}

                    
              
        --     end

        --     -- if i < 5 or (i == 5 and j == 1) then
        --     coroutine.wait(0.5)
        --     -- end
        -- end
        if cb ~= nil then
            cb()
        end
    end)
    table.insert(self.SendAllHandCard_c_List, self.SendAllHandCard_c)
end

--[[--
 * @Description: 摸牌  
 ]]
function comp_mjTable_fuzhou:SendCard( viewSeat,paiValue ,isDeal)
    if roomdata_center.leftCard == 0 then
        return
    end
    -- if (self.sendIndex == 0) then
    --     self.sendIndex = self.config.MahjongTotalCount
    -- end

    --TODO 需要处理取到已经被摸走的牌

    local mj,flag = self:GetMJItem()
    -- if mj.paiValue ~= nil or mj.mjObj.activeSelf == false then
    --     self.sendIndex = self.sendIndex - 1
    --     mj = self:GetMJItem(self.sendIndex, true)
    -- end
    -- self.sendIndex = self.sendIndex -1
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
        self.mjJin[1]:DOLocalMove(originPos_exchangeJin,0)
    elseif self.isNeedUpdateGlod then
        self:UpdateJinPosition()
    end
end

-- 从牌堆尾部获取一张牌
function comp_mjTable_fuzhou:SendCardFromLast(viewseat, paiValue,isDeal)
    if roomdata_center.leftCard == 0 then
        return
    end
    local mj,flag = self:GetMJItem(true)

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
        self.mjJin[1]:DOLocalMove(originPos_exchangeJin,0)
    elseif self.isNeedUpdateGlod then
        self:UpdateJinPosition()
    end
end

-- 在最后一张牌移动之前调用  
function comp_mjTable_fuzhou:UpdateJinPosition()
    if self.mjJin[1] == nil then
        return
    end
    self:UpdateJinAsLastCard()
end

-- 在最后一张牌上
function comp_mjTable_fuzhou:UpdateJinAtLastIndex()
    local mj = self.compMjItemMgr.mjItemList[self.lastIndex]
    local pos = mj.transform.localPosition
    local eulers = mj.transform.localEulerAngles
    local parent = mj.transform.parent
    if self.mjJin[1].transform.parent ~= parent then
        self.mjJin[1].transform:SetParent(parent, false)
    end
    local x = 0
    local y = 0
    x = pos.x
    y = pos.y + mahjongConst.MahjongOffset_y
    self.mjJin[1]:DOLocalMove(Vector3(x, pos.y + mahjongConst.MahjongOffset_y, pos.z), 0)
end

function comp_mjTable_fuzhou:UpdateJinAsLastCard()
    if self.compMjItemMgr.mjItemList[self.lastIndex]~= self.mjJin[1] then
        if self.lastIndex % 2 == 1 then
            self:UpdateJinAtLastIndex()
            return
        else
            -- 直接落下
            self.mjJin[1]:DOLocalMove(Vector3(self.mjJin[1].transform.localPosition.x, 0, 0), 0)
        end
    end
    self.mjJin[1]:ShowShadow()
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
    -- pos = pos or Vector3.zero
    -- mj:Set2DLayer()
    -- mj:SetParent(self.twoDCenterRoot, false)
    -- mj:DOLocalMove(pos, time)
    -- if rotate ~= nil then
    --     mj:DOLocalRotate(rotate, time)
    -- else
    --     mj:DOLocalRotate(Vector3.zero, time)
    -- end
    pos = pos or Vector3.zero
    -- mj:Set2DLayer()
    -- mj:SetParent(self.twoDCenterRoot, false)
    -- mj:DOLocalMove(pos, time)
    -- if rotate ~= nil then
    --     mj:DOLocalRotate(rotate, time)
    -- else
    --     mj:DOLocalRotate(Vector3.zero, time)
    -- end
    mj:SetParent(nil, false)
    local camera = self.compScene.twoDCamera
    local centerPos = camera:ScreenToWorldPoint(Vector3(Screen.width/2,Screen.height*3/5, self.threeDCenterRoot.position.z - camera.transform.position.z))
    centerPos = centerPos + pos
    mj:DOLocalMove(centerPos, 0)
    rotate = rotate or Vector3(-90, 0 ,0)
    if rotate ~= nil then
        mj:DOLocalRotate(rotate, time)
    else
        mj:DOLocalRotate(Vector3.zero, time)
    end
    mj:Set2DLayer()

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
    self.mjJin = {}
    self.isNeedUpdateGlod = false
    self.exChangeSpecialCard = nil
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