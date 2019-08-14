local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_xiapao = class("mahjong_action_xiapao", base)

function mahjong_action_xiapao:Execute(tbl)
	-- local viewSeat = self.gvblFun(tbl["_src"])
	local _para = tbl._para
	-- if viewSeat == 1 then
	-- 	mahjong_ui:HideXiaPao()
	-- end

	if _para then
		for p,value in pairs(_para) do
			local viewSeat = self.gvblFun(p)
			if viewSeat == 1 then
				mahjong_ui:HideXiaPao()
				self.compTable:StopShakeTime()
			end
			if value == 0 then
				mahjong_ui:UpdateXiaPaoState(viewSeat,4,self.cfg)
			else
				mahjong_ui:UpdateXiaPaoState(viewSeat,3,self.cfg)
			end
			
			mahjong_ui:SetXiaoPao( viewSeat,(self.cfg.xiapaoChinese or "")..value )
		end
	end
end

return mahjong_action_xiapao