local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_mjAction_gameCi = class("mahjong_mjAction_gameCi", base)

function mahjong_mjAction_gameCi:Execute(tbl)
    Trace(GetTblData(tbl)) 
    
    roomdata_center.SetSpecialCard(tbl["_para"]["cards"][1])
    local cardValue = tbl._para.cards[1]
    local dun = math.ceil(tbl._para.sits[1]/2)
    local specialCard = roomdata_center.GetSpecialCard()
    if specialCard ~= nil and #specialCard > 0 then
        self.compTable:ShowCi(dun, cardValue, specialCard[1], true, function()
            mahjong_ui:ShowSpecialCard(specialCard[1],1,self.cfg.specialCardSpriteName)
            self.compPlayerMgr.selfPlayer:ShowSpecialInHand()
            self.compPlayerMgr:AllSortHandCard() 
            Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_CI)
        end)
    end
end



return mahjong_mjAction_gameCi

    