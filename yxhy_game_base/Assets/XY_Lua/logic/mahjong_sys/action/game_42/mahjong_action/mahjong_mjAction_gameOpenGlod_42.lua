local base = require "logic.mahjong_sys.action.game_18/mahjong_action/mahjong_mjAction_gameOpenGlod_18"
local mahjong_mjAction_gameOpenGlod_42 = class("mahjong_mjAction_gameOpenGlod_42", base)

function mahjong_mjAction_gameOpenGlod_42:Execute(tbl)
    Trace(GetTblData(tbl))
    local cardValue = tbl._para.nCard
    local isGold = tbl._para.bGold
    local bGoldIsBai = tbl._para.bGoldIsBai
    comp_show_base.curState = self.config.game_state.opengold

    if not bGoldIsBai then
        roomdata_center.AddMj(cardValue)
        self.compTable:HideAllFlowerInTable(function ()
            if mahjong_anim_state_control.GetCurrentStateName() == MahjongGameAnimState.changeFlower then
            mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.openGold)
        end
            mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.openGold, 
                function()
                    if isGold then
                        roomdata_center.SetSpecialCard(cardValue)
                        -- mahjong_ui:SetAllScoreVisible(true)
                    else
                        roomdata_center.AddFlowerCardToZhuang(cardValue)
                    end

                    self:ShowJinAction(cardValue, isGold, true, function()
                        self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
                        Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_OPEN_GOLD)
                    end)
                end, true)
        end)
    else
        roomdata_center.SetSpecialCard(cardValue)
        mahjong_ui:ShowSpecialCard(cardValue,1,self.cfg.specialCardSpriteName)
        self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
        Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_OPEN_GOLD)
    end

    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("kaijin"))
end

function mahjong_mjAction_gameOpenGlod_42:OnSync(jin,pos,isDontShowOnDesk)
     if jin ~= nil then
        roomdata_center.SetSpecialCard(jin)
        if not isDontShowOnDesk then
            self:ShowJinAction(jin, true)
            roomdata_center.AddMj(jin)
        else
            mahjong_ui:ShowSpecialCard(jin,1,self.cfg.specialCardSpriteName)
        end
        self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
    end
end

return mahjong_mjAction_gameOpenGlod_42