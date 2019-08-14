local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_buycode = class("mahjong_action_buycode", base)

function mahjong_action_buycode:Execute(tbl)
	local card = tbl._para.card
	local score = tbl._para.score

	mahjong_ui:ShowEffectAndCard(20025,card,function ()
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_BUYCODE)
	end)

end

return mahjong_action_buycode