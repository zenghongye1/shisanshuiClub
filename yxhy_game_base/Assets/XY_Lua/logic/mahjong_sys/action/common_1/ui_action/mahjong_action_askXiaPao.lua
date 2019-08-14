local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_askXiaPao = class("mahjong_action_askXiaPao", base)

function mahjong_action_askXiaPao:Execute(tbl)
	for i = 1, roomdata_center.MaxPlayer() do
		local viewSeat = self.gvblnFun(i)
		if viewSeat ~= 1 then
			-- 买马中
			mahjong_ui:UpdateXiaPaoState(viewSeat, 2,self.cfg)
		end
	end
	mahjong_ui:ShowXiaPao(tbl._para.optional,self.cfg)
end


return mahjong_action_askXiaPao