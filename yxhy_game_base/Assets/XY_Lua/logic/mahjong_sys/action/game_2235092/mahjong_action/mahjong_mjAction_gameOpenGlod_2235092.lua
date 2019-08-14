local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_mjAction_gameOpenGlod_2235092 = class("mahjong_mjAction_gameOpenGlod_2235092", base)

function mahjong_mjAction_gameOpenGlod_2235092:Execute(tbl)
    local showCard = tbl._para.nOpenCard
    local cardValue = tbl._para.nCard
    local isGold = tbl._para.bGold
    local dice = tbl._para.dice
    local stDice = tbl._para.stDice

    self.compTable:HideAllFlowerInTable(function ()
        if mahjong_anim_state_control.GetCurrentStateName() == MahjongGameAnimState.changeFlower then
            mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.openGold)
        end 
        comp_show_base.curState = self.config.game_state.opengold
        if isGold then
            roomdata_center.AddMj(showCard)
        end
        mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.openGold, function()
            self.compDice:Init()
            self.compDice:Play(dice[1], dice[2], function ()
                if isGold then
                    roomdata_center.SetSpecialCard(cardValue)
                end
                self:OpenGlodAction(dice[1]+dice[2],showCard,cardValue,isGold,stDice,function()
                    self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
                    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_OPEN_GOLD)
                end)
            end,true,2,0.8)
        end, true)
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("kaijin"))
    end)
end

function mahjong_mjAction_gameOpenGlod_2235092:OpenGlodAction(diceNum,showCard,cardValue,isJin,stDice,callback)
    local index = self.compTable:GetMutliNextIndex(self.compTable.lastIndex,diceNum * 2 - 1)

    local mj = self.compMjItemMgr.mjItemList[index]

    mj:SetMesh(showCard)

    if isJin then
        mj:SetState(MahjongItemState.other)
        self.compTable.mjJin[1] = mj
        self.compTable.mjJin[1].mjObj.name = "jin"

        roomdata_center.UpdateRoomCard(-1)
    end


    local ShowJin_c = coroutine.start(function() 

        local originPos = mj.transform.localPosition
        local originScale = mj.transform.localScale
        local originEuler = mj.localEulers
        local originParent = mj.transform.parent

        local originPos_exchangeJin

        local isMoveJin = false
        if isJin and math.fmod(index,2) == 1 then
            isMoveJin = true
        end

        local mj_exchangeJin = nil
        if isMoveJin then
            mj_exchangeJin = self.compMjItemMgr.mjItemList[index + 1]
            originPos_exchangeJin = mj_exchangeJin.transform.localPosition
            self.compTable.exChangeSpecialCard = mj_exchangeJin
        end
        self.compTable:MoveMjTo3DCenter(mj, 0.2)

        if isMoveJin and mj_exchangeJin then   
            local x,y,z = originPos:Get()
            mj_exchangeJin:DOLocalMove(x,y,z, 0)
        end
        coroutine.wait(0.25)
        self.compTable:MoveMjTo2DCenter(mj, 0)
        coroutine.wait(0.5)

        -- 是金 则返回原位置
        if isJin then
            mj:Set3DLayer()
            mj:SetParent(originParent)
            mj.transform.localScale = originScale
            --mj.transform.localEulerAngles = originEuler
            local x,y,z = originEuler:Get()
            mj:DOLocalRotate(x,y,z ,0)
            if isMoveJin and originPos_exchangeJin then
                local x,y,z = originPos_exchangeJin:Get()
                mj:DOLocalMove(x,y,z, 0)
            else
                local x,y,z = originPos:Get()
                mj:DOLocalMove(x,y,z, 0)
            end
            coroutine.wait(0.1)
            mj:Show(true, false)
            mahjong_ui:ShowSpecialCard(cardValue,1,self.cfg.specialCardSpriteName)

            coroutine.wait(0.21)
        else
            mj:Set3DLayer()
            mj:SetParent(originParent)
            mj.transform.localScale = originScale
             local x,y,z = originEuler:Get()
            mj:DOLocalRotate(x,y,z ,0)
            x,y,z = originPos:Get()
            mj:DOLocalMove(x,y,z, 0)
            coroutine.wait(0.1)
            mj:Show(false, false)

            coroutine.wait(0.21)
        end

        if callback ~= nil then
            callback()
        end
    end)
    table.insert(self.compTable.ShowJin_c_List, ShowJin_c)
    
end

function mahjong_mjAction_gameOpenGlod_2235092:OnSync(jin,pos,bGoldIsBai,showCard)
     if jin and pos and showCard then
        roomdata_center.SetSpecialCard(jin)
        self:ReSetShowJin(showCard, pos)
        roomdata_center.AddMj(showCard)
        mahjong_ui:ShowSpecialCard(jin,1,self.cfg.specialCardSpriteName)
    end
end

function mahjong_mjAction_gameOpenGlod_2235092:ReSetShowJin( cardValue,pos )
    local index
    if roomdata_center.leftCard > pos then
        index = self.compTable:GetMutliNextIndex(self.compTable.lastIndex,roomdata_center.leftCard - pos)
    else
        index = self.compTable.lastIndex
    end

    local mj = self.compMjItemMgr.mjItemList[index]
    roomdata_center.UpdateRoomCard(-1)

    -- 当金牌在下层则与上层的牌交换位置
    local originPos = mj.transform.localPosition
    local originPos_exchangeJin

    local isMoveJin = false
    local mj_exchangeJin = nil
    if math.fmod(index,2) == 1 then
        mj_exchangeJin = self.compMjItemMgr.mjItemList[index + 1]
        if mj_exchangeJin and mj_exchangeJin.curState == MahjongItemState.inWall then
            isMoveJin = true
        end
    end
    
    if isMoveJin and mj_exchangeJin then
        originPos_exchangeJin = mj_exchangeJin.transform.localPosition
        self.compTable.exChangeSpecialCard = mj_exchangeJin
    end

    if isMoveJin and mj_exchangeJin then
        local x,y,z = originPos:Get()
        mj_exchangeJin:DOLocalMove(x,y,z, 0)
        x,y,z = originPos_exchangeJin:Get()
        mj:DOLocalMove(x,y,z, 0)
    end

    mj:SetMesh(cardValue)
    mj:SetState(MahjongItemState.other)

    self.compTable.mjJin[1] = mj
    self.compTable.mjJin[1].mjObj.name = "jin"
    -- mj:HideAndReset()
    self.compTable.mjJin[1]:Show(true)
end

return mahjong_mjAction_gameOpenGlod_2235092