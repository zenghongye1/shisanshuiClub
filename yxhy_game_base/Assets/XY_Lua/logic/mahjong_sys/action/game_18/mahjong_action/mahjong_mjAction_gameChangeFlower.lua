local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_mjAction_gameChangeFlower = class("mahjong_mjAction_gameChangeFlower", base)

function mahjong_mjAction_gameChangeFlower:Execute(tbl)
    local paramTbl = tbl._para
    local playerIndex = paramTbl["nFlowerWho"]      --谁补花
    local flowerCards = paramTbl["stFlowerCards"]       --花牌
    local newCards = paramTbl["stNewCards"]     --替换的花牌
    self.bFenZhang = paramTbl["bFenZhang"]     --是否分张，false不分，true分
    local totalCards = paramTbl["nTotalFlowerCard"]     --花牌总数量
    local leftCardNum = paramTbl["nCardLeft"]   --剩余牌数

    local viewSeat = self.gvblnFun(playerIndex)

    local isDeal = false
    if comp_show_base.curState == self.config.game_state.deal or comp_show_base.curState == self.config.game_state.opengold then
        isDeal = true
    end

    if not isDeal then
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(self.cfg.changeFlowerSound))
    end

    mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.changeFlower, 
        function()
            roomdata_center.SetPlayerFlowersCards(viewSeat, flowerCards)
            if self.compTable ~= nil then
                self:ChangeFlowerAction(viewSeat, flowerCards, totalCards, newCards, function() 
                    roomdata_center.SetRoomLeftCard(tbl._para.nCardLeft)
                    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_CHANGE_FLOWER)
                end,isDeal)
            else
                Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_CHANGE_FLOWER)
            end
    end, true,true)

    if viewSeat ~= 1 then
        for i = 1, #flowerCards do
            roomdata_center.AddMj(flowerCards[i])
        end
    end
end

function mahjong_mjAction_gameChangeFlower:ChangeFlowerAction(viewSeat, flowerCards, totalCards, newCards, callback,isDeal)
    if self.cfg.flowerOnTable then
        self:ChangeFlowerOnTable(viewSeat, flowerCards, totalCards, newCards, callback,isDeal)
    else
        self:ChangeFlowerAndHide(viewSeat, flowerCards, totalCards, newCards, callback,isDeal)
    end
end


function mahjong_mjAction_gameChangeFlower:ChangeFlowerOnTable(viewSeat, flowerCards, totalCards, newCards, callback,isDeal)
    flowerCount = #flowerCards
    self.compPlayerMgr:GetPlayer(viewSeat):PutFlowerToTable(flowerCards,flowerCount, isDeal)
    co_mgr.start(function()
        if not self.bFenZhang then
            if not isDeal then
                coroutine.wait(0.5)
            end
            for i = 1, flowerCount do
                local value = MahjongTools.GetRandomCard()
                if viewSeat == 1 then
                    value = newCards[i]
                end

                if self.cfg.changeflowerSendLast then
                    self.compTable:SendCardFromLast(viewSeat, value,isDeal)
                else
                    self.compTable:SendCard(viewSeat, value,isDeal)
                end
            end

            if isDeal then
                self.compPlayerMgr:GetPlayer(viewSeat):SortHandCard(false)
            else
                -- 打牌阶段 补花不需要排序
                -- self.compPlayerMgr:GetPlayer(viewSeat):SortHandCard(true)
            end
        end
        if callback ~= nil then
            callback()
        end
    end)
end


function mahjong_mjAction_gameChangeFlower:ChangeFlowerAndHide(viewSeat, flowerCards, totalCards, newCards, callback,isDeal)
    flowerCount = #flowerCards
    local changeFlower_c = coroutine.start(function()
        self.compPlayerMgr:GetPlayer(viewSeat):RemoveChangeFlowers(flowerCards,flowerCount, isDeal)

        if not self.bFenZhang then
            if isDeal then
                coroutine.wait(0.3)
            else
                coroutine.wait(0.5)
            end
            for i = 1, flowerCount do
                local value = MahjongTools.GetRandomCard()
                if viewSeat == 1 then
                    value = newCards[i]
                end

                if self.cfg.changeflowerSendLast then
                    self.compTable:SendCardFromLast(viewSeat, value,isDeal)
                else
                    self.compTable:SendCard(viewSeat, value,isDeal)
                end
            end

            coroutine.wait(0.05)

            if isDeal then
                self.compPlayerMgr:GetPlayer(viewSeat):SortHandCard(false)
            else
                -- 打牌阶段 补花不需要排序
                -- self.compPlayerMgr:GetPlayer(viewSeat):SortHandCard(true)
            end
            coroutine.wait(0.05)
        end
        if callback ~= nil then
            callback()
        end
    end)
    table.insert(self.compTable.changeFlower_c_List, changeFlower_c)
end

function mahjong_mjAction_gameChangeFlower:OnSync(flowerCardsList)
    if self.cfg.flowerOnTable then
        self:SyncFlowerOnTable(flowerCardsList)
    else
        self:SyncFlowerHide(flowerCardsList)
    end
end

function mahjong_mjAction_gameChangeFlower:SyncFlowerHide(flowerCardsList)
    roomdata_center.playerFlowerCards = {}
    for i = 1, roomdata_center.MaxPlayer() do
        local viewSeat = self.gvblnFun(i)
        roomdata_center.SetPlayerFlowersCards(viewSeat, flowerCardsList[i])
        local cards
        cards = self:GetResetCards(flowerCardsList[i])
        for j = 1, #cards do
            cards[j]:HideAndReset()
        end
    end
end

function mahjong_mjAction_gameChangeFlower:SyncFlowerOnTable(flowerCardsList)
    roomdata_center.playerFlowerCards = {}
    for i = 1, roomdata_center.MaxPlayer() do
        local viewSeat = self.gvblnFun(i)
        roomdata_center.SetPlayerFlowersCards(viewSeat, flowerCardsList[i])
        local cards
        cards = self:GetResetCards(flowerCardsList[i])
        self.compPlayerMgr:GetPlayer(viewSeat):PutFlowerMjList(cards, false, true)
    end
end

function mahjong_mjAction_gameChangeFlower:GetResetCards(cardlist)
    local count = #cardlist
    local cards
    if self.cfg.changeflowerSendLast then
        cards = self.compTable:GetResetCardsFromLast(count)
    else
        cards = self.compTable:GetResetCards(count)
    end
    for i = 1, #cards do
        cards[i]:SetMesh(cardlist[i])
    end
    return cards
end



return mahjong_mjAction_gameChangeFlower