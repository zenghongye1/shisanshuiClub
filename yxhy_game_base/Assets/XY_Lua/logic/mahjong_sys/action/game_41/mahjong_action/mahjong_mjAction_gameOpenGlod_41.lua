local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_mjAction_gameOpenGlod_41 = class("mahjong_mjAction_gameOpenGlod_41", base)

function mahjong_mjAction_gameOpenGlod_41:Execute(tbl)
    Trace(GetTblData(tbl))
    local cardValue = tbl._para.nCard
    local isGold = tbl._para.bGold
    comp_show_base.curState = self.config.game_state.opengold

    local isSame = false
    if roomdata_center.CheckIsSpecialCard(cardValue) then
        isSame = true
    end

    if not isSame then
        roomdata_center.AddMj(cardValue)
    end

    self.compTable:HideAllFlowerInTable(function ()
        if mahjong_anim_state_control.GetCurrentStateName() == MahjongGameAnimState.changeFlower then
            mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.openGold)
        end
        mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.openGold, 
            function()
                if isGold then
                    roomdata_center.SetSpecialCard(cardValue)
                else
                    if not isSame then
                        roomdata_center.AddFlowerCardToZhuang(cardValue)
                    end
                end

                self:ShowJinAction(cardValue, isGold, true, function()
                    self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
                    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_OPEN_GOLD)
                end,isSame)
            end, true)
    end)
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("kaijin"))
end

function mahjong_mjAction_gameOpenGlod_41:ShowJinAction( cardValue, isJin,isAnim, callback,isSame )

    local mj = self.compTable:GetMJItem()
    if isSame then
       self.compTable.sendIndex = self.compTable.sendIndex + 1
        if self.compTable.sendIndex > self.config.MahjongTotalCount then
            self.compTable.sendIndex = self.compTable.sendIndex - self.config.MahjongTotalCount
        end
    end
    mahjong_ui:SetLeftCard( roomdata_center.leftCard )

    mj:SetMesh(cardValue)
    if not isSame then
        mj:SetState(MahjongItemState.other)
    end

    if isJin then
        mj.mjObj.name = "jin"
        table.insert(self.compTable.mjJin,mj)
    end

    --@todo  更新牌数量，self.lastIndex 
    if not isAnim then
        if isJin then

            mahjong_ui:ShowSpecialCard(cardValue,#self.compTable.mjJin,self.cfg.specialCardSpriteName)

            local mj_last = self.compMjItemMgr.mjItemList[self.compTable.lastIndex]
            local pos = mj_last.transform.localPosition
            local eulers = mj_last.transform.localEulerAngles
            local parent = mj_last.transform.parent

            mj:SetParent(parent)
            mj.transform.localEulerAngles = eulers
            local x = pos.x - mahjongConst.MahjongOffset_x*#self.compTable.mjJin
            mj:DOLocalMove(x, 0, pos.z, 0)
            mj:Show(true, false)
        else
            mj:HideAndReset()
        end
        return
    end
    local ShowJin_c = coroutine.start(function() 

        local mj_last = self.compMjItemMgr.mjItemList[self.compTable.lastIndex]
        local pos = mj_last.transform.localPosition
        local eulers = mj_last.transform.localEulerAngles
        local parent = mj_last.transform.parent

        local originPos = mj.transform.localPosition
        local originScale = mj.transform.localScale
        local originEuler = mj.transform.localEulerAngles
        local originParent = mj.transform.parent

        self.compTable:MoveMjTo3DCenter(mj, 0.2)
        coroutine.wait(0.25)
        self.compTable:MoveMjTo2DCenter(mj, 0)

        coroutine.wait(0.5)

        -- 是金 则返回原位置
        if isJin then
            mj:Set3DLayer()
            mj:SetParent(parent)
            mj.transform.localScale = originScale
            mj.transform.localEulerAngles = eulers
            local x = pos.x - mahjongConst.MahjongOffset_x*#self.compTable.mjJin
            mj:DOLocalMove(x, 0, pos.z, 0)
            coroutine.wait(0.1)
            mj:Show(true, false)
            mahjong_ui:ShowSpecialCard(mj.paiValue,#self.compTable.mjJin,self.cfg.specialCardSpriteName)

        else
            if isSame then
                mj:Set3DLayer()
                mj:SetParent(originParent)
                mj.transform.localScale = originScale
                mj.transform.localEulerAngles = originEuler
                local x,y,z = originPos:Get()
                mj:DOLocalMove(x,y,z, 0)
                mj:Show(false, false)
            else
                self.compTable:DoHideHuaCardsToPoint({mj}, roomdata_center.zhuang_viewSeat, 0.2, nil, true)
                coroutine.wait(0.21)
            end
        end

        if callback ~= nil then
            callback()
        end
    end)
    table.insert(self.compTable.ShowJin_c_List, ShowJin_c)
end

function mahjong_mjAction_gameOpenGlod_41:OnSync(jin,pos)
     if jin ~= nil then
        for _,v in ipairs(jin) do
            roomdata_center.SetSpecialCard(v)
            self:ShowJinAction(v, true)
            roomdata_center.AddMj(v)
        end
        self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
    end
end

return mahjong_mjAction_gameOpenGlod_41