local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameJiType = class("mahjong_action_gameJiType", base)

local JiEffectTypeMap = 
{
	[1] = 20038,
	[2] = 20039,
	[3] = 20040,
	[4] = 20041,
	[5] = 20042,
	[6] = 20043,
}

function mahjong_action_gameJiType:Execute(tbl)
	local nJiType = tbl._para.nJiType
	local nJiCard = tbl._para.nJiCard

	if nJiType == 5 or nJiType == 6 then
		mahjong_ui:ShowEffectAndCard(JiEffectTypeMap[nJiType],nJiCard,function ()
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_JITYPE)
		end)
	else
		mahjong_ui:ShowEffectAndCard(JiEffectTypeMap[nJiType],nil,function ()
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_JITYPE)
		end)
	end

end

return mahjong_action_gameJiType