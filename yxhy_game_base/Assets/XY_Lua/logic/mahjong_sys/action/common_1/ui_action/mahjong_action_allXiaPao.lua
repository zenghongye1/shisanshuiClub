local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_allXiaPao = class("mahjong_action_allXiaPao", base)

function mahjong_action_allXiaPao:Execute(tbl)
	local paoStr = (self.cfg.xiapaoChinese or "")
	mahjong_ui:HideXiaPao()
	mahjong_ui:HideAllPaoState()
	if tbl["_para"]["p4"]~=nil then
		mahjong_ui:SetXiaoPao(self.gvblFun("p4"),paoStr..tbl["_para"]["p4"])
	end
	if tbl["_para"]["p3"]~=nil then
		mahjong_ui:SetXiaoPao(self.gvblFun("p3"),paoStr..tbl["_para"]["p3"])
	end
	if tbl["_para"]["p2"]~=nil then
		mahjong_ui:SetXiaoPao(self.gvblFun("p2"),paoStr..tbl["_para"]["p2"])
	end
	if tbl["_para"]["p1"]~=nil then
		mahjong_ui:SetXiaoPao(self.gvblFun("p1"),paoStr..tbl["_para"]["p1"])
	end
end


return mahjong_action_allXiaPao