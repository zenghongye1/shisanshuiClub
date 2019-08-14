--[[--
 * @Description: 杠库
 * @Author:      shine
 * @FileName:    lib_gang_score.lua
 * @DateTime:    2017-11-27 14:59:27
 ]]

local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local lib_gang_score = class("lib_gang_score", base)
local lib_common = require "logic/mahjong_sys/action/common_3/lib/lib_common"


local viewSeat = nil
local lib_common_c = nil

function lib_gang_score:GetGangScore_old(isHadGangFen, rewards, banker, i, base, beishu, pao_type)
	viewSeat = self.gvblnFun(i)
	lib_common_c = lib_common:create(self.mode)
	local gangScore = {}
 	if isHadGangFen then
 		local mingGangScoreTbl = self:GetMingGangScore(rewards, banker, i, base, beishu, pao_type)
 		for i,v in ipairs(mingGangScoreTbl) do
 			table.insert(gangScore, v)
 		end
 		local anGangScoreTbl = self:GetAnGangScore(rewards, banker, i, base, beishu, pao_type)
 		for i,v in ipairs(anGangScoreTbl) do
 			table.insert(gangScore, v)
 		end 
 		local beMingGangScoreTbl = self:GetBeMingGangScore(rewards, banker, i, base, beishu, pao_type)
 		for i,v in ipairs(beMingGangScoreTbl) do
 			table.insert(gangScore, v)
 		end 
 		local beAnGangScoreTbl = self:GetBeAnGangScore(rewards, banker, i, base, beishu, pao_type)
 		for i,v in ipairs(beAnGangScoreTbl) do
 			table.insert(gangScore, v)
 		end 				 		 
 	end		
 	return gangScore
end

function lib_gang_score:GetMingGangScore(rewards, banker, i, base, beishu, pao_type)
	local gangScoreTbl = {}
	if beishu == nil then
		beishu = 1
	end	

	local maxPlayer = roomdata_center.MaxPlayer()
	if rewards[i].revealed_gang_count > 0 then
		-- 遍历吃碰杠combineTile 查找明杠
		for a = 1, #rewards[i].combineTile do
			-- 明杠
			if rewards[i].combineTile[a].ucFlag == 18 or rewards[i].combineTile[a].ucFlag == 20 then
				local item_minggang= {}
	 			item_minggang.des = "明杠"
	 			local player = rewards[i].combineTile[a].value   --点杠者
	 			local viewSeat2 = self.gvblnFun(player)		
				base = lib_common_c:GetDealerBase(banker, i, player)	
	 			if rewards[player].xiapao and lib_common_c:GetSupportGangPao() then		 				
	 				item_minggang.money = (base + 1 + lib_common_c:GetPaoCount(rewards, i, player, pao_type)) * beishu
	 			else
	 				item_minggang.money = (base + 1) * beishu
	 			end
	 			item_minggang.p = MahjongTools.GetPosDes(viewSeat, viewSeat2)
	 			table.insert(gangScoreTbl, item_minggang)
			end
		end
	end	
	return gangScoreTbl
end

function lib_gang_score:GetAnGangScore(rewards, banker, i, base, beishu, pao_type)
	local gangScoreTbl = {}
	if beishu == nil then
		beishu = 1
	end	

	local maxPlayer = roomdata_center.MaxPlayer()
	if rewards[i].conceled_gang_count > 0 then
		-- 暗杠个数--- b		
		local flag = true 
		for b = 1, rewards[i].conceled_gang_count do
			local an_money = 0
			local item_angang = {}
			item_angang.des = "暗杠"
			for s=1, maxPlayer do
				if i ~= s then
					base = lib_common_c:GetDealerBase(banker, i, s)				
					if rewards[i].xiapao and lib_common_c:GetSupportGangPao() then
						an_money = an_money + (base + 1 + lib_common_c:GetPaoCount(rewards, i, s, pao_type))
					else
						an_money = an_money + (base + 1)
					end
				end
			end
			item_angang.money = an_money * beishu
			item_angang.p = "三家"
			table.insert(gangScoreTbl, item_angang)
		end
	end	
	return gangScoreTbl
end

function lib_gang_score:GetBeMingGangScore(rewards, banker, i, base, beishu, pao_type)
	local gangScoreTbl = {}	
	if beishu == nil then
		beishu = 1
	end

	local maxPlayer = roomdata_center.MaxPlayer()
	for j=1, maxPlayer do
		-- 遍历其余三家的明杠
		if i~=j then
			local viewSeat2 = self.gvblnFun(j)
			if rewards[j].revealed_gang_count>0 then
				-- 遍历吃碰杠combineTile 查找明杠
				for k=1,#rewards[j].combineTile do
					if rewards[j].combineTile[k].ucFlag == 18 or rewards[j].combineTile[k].ucFlag == 20 then
 						if i == rewards[j].combineTile[k].value then
 							local item_beiminggang = {}
							item_beiminggang.des = "被明杠"	
							base = lib_common_c:GetDealerBase(banker, i, j)					
							if rewards[i].xiapao and lib_common_c:GetSupportGangPao() then
								item_beiminggang.money = - (base + 1 + lib_common_c:GetPaoCount(rewards, i, j, pao_type)) * beishu
							else								
								item_beiminggang.money = -(base + 1) * beishu
							end
							item_beiminggang.p = MahjongTools.GetPosDes(viewSeat, viewSeat2)
							table.insert(gangScoreTbl, item_beiminggang)
				 		end
					end
				end
	 		end
		end
	end
	return gangScoreTbl
end


function lib_gang_score:GetBeAnGangScore(rewards, banker, i, base, beishu, pao_type)
	local gangScoreTbl = {}	
	if beishu == nil then
		beishu = 1
	end

	local maxPlayer = roomdata_center.MaxPlayer()
	for c=1, maxPlayer do
		-- 遍历其余三家的暗杠
		if i ~= c then
			local viewSeat2 = self.gvblnFun(c)
			if rewards[c].conceled_gang_count > 0 then
	 			-- 此家的暗杠次数
				for k=1,#rewards[c].combineTile do
					if rewards[c].combineTile[k].ucFlag == 19 then
						local item_beiangang = {}
						item_beiangang.des = "被暗杠"
						base = lib_common_c:GetDealerBase(banker, i, c)							
						if rewards[i].xiapao and lib_common_c:GetSupportGangPao() then
							item_beiangang.money = - (base + 1 + lib_common_c:GetPaoCount(rewards, i, c, pao_type)) * beishu
						else							
							item_beiangang.money = -(base + 1) * beishu
						end
			 		
						item_beiangang.p = MahjongTools.GetPosDes(viewSeat, viewSeat2)
						table.insert(gangScoreTbl, item_beiangang)
					end
				end
	 		end
		end
	end
	return gangScoreTbl
end
 
function lib_gang_score:GetGangScore2(isHadGangFen, rewards, i,basescore)
  local gangScore = {}
   if isHadGangFen then
     local maxPlayer = roomdata_center.MaxPlayer()
     for j=1,maxPlayer do
      for k,v in ipairs(rewards[j].ganginfo) do
        local item_gang= {} 
         if v.ucFlag == 18 or v.ucFlag == 20 then
           if v.Target == i then
             item_gang.des = "被明杠"                        
           else
             item_gang.des = "明杠"
           end           
         elseif v.ucFlag == 19 then
           if v.Target == i then
             item_gang.des = "暗杠"                        
           else
             item_gang.des = "被暗杠"
           end           
         end
         item_gang.money = v.stScore[i]*basescore 
         if item_gang.money~=0 then
               table.insert(gangScore, item_gang)
             end         
          end       
       end               
   end    
   return gangScore
end

function lib_gang_score:GetGangScore(isHadGangFen, rewards, banker, i, base, beishu, pao_type)
	local gangScore = {}
	local reward = rewards[i]
	local revealed_gang_score = reward.revealed_gang_score
	local conceled_gang_score = reward.conceled_gang_score
	if revealed_gang_score and tonumber(revealed_gang_score)~=0 then
		if tonumber(revealed_gang_score) > 0 then
			revealed_gang_score = "+"..revealed_gang_score
		end
		local item = {}
		item.des = "明杠分"
		item.num = revealed_gang_score
		table.insert(gangScore,item)
	end
	if conceled_gang_score and tonumber(conceled_gang_score)~=0 then
		if tonumber(conceled_gang_score) > 0 then
			conceled_gang_score = "+"..conceled_gang_score
		end
		local item = {}
		item.des = "暗杠分"
		item.num = conceled_gang_score
		table.insert(gangScore,item)
	end
	return gangScore
end
return lib_gang_score