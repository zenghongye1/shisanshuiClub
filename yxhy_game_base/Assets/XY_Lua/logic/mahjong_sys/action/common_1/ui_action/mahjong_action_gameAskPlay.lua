local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameAskPlay = class("mahjong_action_gameAskPlay", base)



function mahjong_action_gameAskPlay:Execute(tbl)
	local viewSeat = self.gvblFun(tbl._src)
    mahjong_ui:ShowHeadEffect(viewSeat)

    if roomdata_center.zhuang_viewSeat == 1 and roomdata_center.beginSendCard == false then
    	mahjong_ui:ShowZhuanTips()
    	roomdata_center.beginSendCard = true
   	end
end

return mahjong_action_gameAskPlay