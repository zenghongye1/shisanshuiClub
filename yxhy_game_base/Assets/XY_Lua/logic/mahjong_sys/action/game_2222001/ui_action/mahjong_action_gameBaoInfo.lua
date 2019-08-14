local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameBaoInfo = class("mahjong_action_gameBaoInfo", base)

function mahjong_action_gameBaoInfo:Execute(tbl)
	local dun = tbl._para.dun
	local sits = tbl._para.sits
	local changbaotimes = tbl._para.changbaotimes -- 为0时表示是定宝，>0表示换宝
	local card = tbl._para.card
	local bFirstTing = tbl._para.bFirstTing

	if card == nil then
		card = 0
	end
	local effectId = 20037
	if changbaotimes == 0 then
		effectId = 20036
	end
	if bFirstTing~=nil and bFirstTing==false then
		effectId = nil
	end
	if roomdata_center.isReconnecting then
		mahjong_ui:ShowSpecialCard(card,1,self.cfg.specialCardSpriteName)
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_BAOINFO)
		return
	end
	mahjong_ui:ShowEffectAndCard(effectId,card,function ()
				mahjong_ui:ShowSpecialCard(card,1,self.cfg.specialCardSpriteName)
				Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_BAOINFO)
			end)

end

return mahjong_action_gameBaoInfo