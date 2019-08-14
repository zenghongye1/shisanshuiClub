local base = require "logic.mahjong_sys.action.game_25/mahjong_action/mahjong_mjAction_gameOpenGlod_25"
local mahjong_mjAction_gameOpenGlod_45 = class("mahjong_mjAction_gameOpenGlod_45", base)

function mahjong_mjAction_gameOpenGlod_45:Execute(tbl)
    Trace(GetTblData(tbl))

    local cardValue = tbl._para.nCard
    local isGold = tbl._para.bGold
    local dice = tbl._para.dice
    local stDice = tbl._para.stDice

    self.compTable:HideAllFlowerInTable(function ()
        if mahjong_anim_state_control.GetCurrentStateName() == MahjongGameAnimState.start then
            mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.openGold)
        end 
        comp_show_base.curState = self.config.game_state.opengold
        if isGold then
            roomdata_center.AddMj(cardValue)
        end
        mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.openGold, function()
                if isGold then
                    roomdata_center.SetSpecialCard(self.config.GetSpecialCardValue(cardValue))
                end
                self:OpenGlodAction(dice[1]+dice[2],cardValue,isGold,stDice,function()
                    self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
                    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_OPEN_GOLD)
                end)
        end, true)
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("kaijin"))
    end)
end

function mahjong_mjAction_gameOpenGlod_45:OnSync(jin,pos)
     if jin ~= nil and pos then
        self:ReSetShowJin(jin, pos)
        roomdata_center.AddMj(jin)
    end
end

return mahjong_mjAction_gameOpenGlod_45