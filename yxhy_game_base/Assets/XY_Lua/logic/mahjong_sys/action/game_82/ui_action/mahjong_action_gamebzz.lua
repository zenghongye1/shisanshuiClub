local base = require "logic/mahjong_sys/action/common/mahjong_action_base"
local mahjong_action_gamebzz = class("mahjong_action_gamebzz", base)

function mahjong_action_gamebzz:Execute(tbl)
	Trace("bzz=-*******************************************************************-"..json.encode(tbl))
	local operPlayViewSeat	
	if tbl then
		local para = tbl._para
		local flag_bzz = para.nbzz
		local seat = para.nChair
		roomdata_center.nbzz = 0
		roomdata_center.hasBZZ = flag_bzz
	end
	
	-- local operPlayViewSeat = self.gvblnFun(seat)
	-- if operPlayViewSeat and operPlayViewSeat == 1 then	
	-- 	if flag_bzz == 4 then 
	-- 		animations_sys.PlayAnimationByScreenPosition(mahjong_ui.playerList[operPlayViewSeat].operPos,0,0,
	-- 			mahjong_path_mgr.GetEffPath("Effect_bian", mahjong_path_enum.mjCommon),
	-- 				"bian",100,100,false,function()mahjong_ui.ShowBZZ(operPlayViewSeat,true,"bian")  end)
	-- 	elseif flag_bzz == 2 then
	-- 		animations_sys.PlayAnimationByScreenPosition(mahjong_ui.playerList[operPlayViewSeat].operPos,0,0,
	-- 			mahjong_path_mgr.GetEffPath("Effect_zuan", mahjong_path_enum.mjCommon),
	-- 				"zuan",100,100,false,function()mahjong_ui.ShowBZZ(operPlayViewSeat,true,"zuan")  end)
	-- 	elseif flag_bzz == 1 then
	-- 		animations_sys.PlayAnimationByScreenPosition(mahjong_ui.playerList[operPlayViewSeat].operPos,0,0,
	-- 			mahjong_path_mgr.GetEffPath("Effect_za", mahjong_path_enum.mjCommon),
	-- 				"za",100,100,false,function()mahjong_ui.ShowBZZ(operPlayViewSeat,true,"za")  end)
	-- 	end
	-- end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_FLAG_BZZ)
end

return mahjong_action_gamebzz