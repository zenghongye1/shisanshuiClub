--[[--
 * @Description: 胡牌库
 * @Author:      shine
 * @FileName:    lib_hupai_score.lua
 * @DateTime:    2017-11-27 14:22:01
 ]]

local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local lib_hupai_score = class("lib_hupai_score", base)
local lib_common = require "logic/mahjong_sys/action/common_2/lib/lib_common"

local lib_common_c = nil
local win_type_des = 
{
	["gunwin"] = "点炮胡",
	["selfdraw"] = "自摸胡",
	["qidui"] = "七对胡",
	["gangflower"] = "杠上花",
	["gangci"] = "杠次",
	["pici"] = "皮次",
}


function lib_hupai_score:GetHuangpaiScore(bGangAddNoWin,basescore)
    if basescore==nil then
        basescore=1
    end	
	local item_huang = nil	
	if bGangAddNoWin == 2 then		
		item_huang = {}			
 		item_huang.des = "庄家赔三家"
 		if lib_common_c == nil then
 			lib_common_c = lib_common:create(self.mode)
 		end
 		if lib_common_c:GetSupportDealerAdd() then
 			item_huang.money = -3 * 2*basescore
 		else
 			item_huang.money = -3 *basescore
 		end
 		item_huang.p = "" 			
	end
	return item_huang
end


function lib_hupai_score:GetHuPaiScore(rewards, banker, who_win, win_type, i)
	local item_hu = nil 
	if win_type ~= "gunwin" or (rewards[i].nJiePao and rewards[i].nJiePao == 1) or IsTblIncludeValue(i,who_win) then
		item_hu = {}		
		local win_type_str = ""
		if win_type == "gunwin" then
			win_type_str = "点炮"
		elseif win_type == "selfdraw" then
			win_type_str = "自摸"
		elseif win_type == "robgangwin" then
			win_type_str = "抢杠"
		else
			logError(win_type)
		end

		local hu_type_str = ""
		if rewards[i].win_info and rewards[i].win_info.nFanDetailInfo then
			local nFanDetailInfo = rewards[i].win_info.nFanDetailInfo
			for _,v in ipairs(nFanDetailInfo) do
				if v.byFanType ~= 0 then
					hu_type_str = hu_type_str.."、"..v.szFanName.."x"..v.byFanNumber
				end
			end
		end

		local hu_score_str = rewards[i].hu_score
		if hu_score_str then
			if hu_score_str > 0 then
				hu_score_str = "+"..hu_score_str
			end
		end
		if IsTblIncludeValue(i,who_win) then
			item_hu.des = "胡牌分"..hu_score_str.."("..win_type_str..hu_type_str..")"
		else
			item_hu.des = "胡牌分"..hu_score_str
		end
	end	
	return item_hu
end


function lib_hupai_score:GetHuPaiScore2(rewards, who_win, win_type, i,basescore)
  lib_common_c = lib_common:create(self.mode)
  local win_viewSeat = 0
   if who_win~=nil and who_win>0 and who_win<5 then
     win_viewSeat = self.gvblnFun(who_win)
   end
   local viewSeat = self.gvblnFun(i) 
  local item_hu = nil 
  if win_type ~= "gunwin" or (rewards[i].nJiePao and rewards[i].nJiePao == 1) or viewSeat == win_viewSeat then
    item_hu = {}    
    local hu_des = win_type_des[win_type]
    if rewards[i].nJiePao and rewards[i].nJiePao == 1 then
       item_hu.des = "被"..hu_des
    elseif win_type=="selfdraw" and viewSeat ~= win_viewSeat then 
       item_hu.des = "被"..hu_des
    else
       item_hu.des = hu_des
    end

    local maxPlayer = roomdata_center.MaxPlayer()
    local hu_money = 0
    if viewSeat == win_viewSeat then   -- 本家胡牌
        local seat, des = lib_common_c:GetWhichJiePao(rewards)    --获取哪家放炮  
        if (win_type == "gunwin" or win_type == "gangflower") and seat ~= nil then                
           item_hu.p = des     
        else 
           if roomdata_center.maxplayernum==4 then
               item_hu.p =  "三家"
           elseif roomdata_center.maxplayernum==3 then
               item_hu.p =  "两家" 
           elseif roomdata_center.maxplayernum==2 then
               item_hu.p =  "对家" 
           end           
        end      
    else   -- 其他家胡牌    
         local otherviewSeat = self.gvblnFun(who_win)         
         local player = self.compPlayerMgr:GetPlayer(otherviewSeat)
         local selfPlayer = self.compPlayerMgr:GetPlayer(viewSeat)           
         item_hu.p = MahjongTools.GetPosDes(selfPlayer.index, player.index)    
    end 
    item_hu.money = rewards[i].hu_score*basescore  
  end  
  return item_hu
end
return lib_hupai_score