local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_playerChat = class("mahjong_action_playerChat", base)



function mahjong_action_playerChat:Execute(tbl)
	Trace(GetTblData(tbl))
	local viewSeat = self.gvblFun(tbl._src)
	local contentType = tbl["_para"]["contenttype"]
	local content = tbl["_para"]["content"]
	local givewho = self.gvblFun(tbl["_para"]["givewho"])

	if roomdata_center.isStart == true then		
	else		
	end
	
	model_manager:GetModel("ChatModel"):DealChat(viewSeat,contentType,content,givewho)
end

return mahjong_action_playerChat