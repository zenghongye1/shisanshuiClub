local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local lib_common = class("lib_common", base)


function lib_common:GetPaoCount(rewards, seat1, seat2, pao_type)
	local paoCount = 0
	if rewards[seat1].xiapao and rewards[seat2].xiapao and rewards[seat1].xiapao >= 0 and rewards[seat2].xiapao >= 0 then
		if pao_type == 1 then
			paoCount = tonumber(rewards[seat1].xiapao) + tonumber(rewards[seat2].xiapao)
		elseif pao_type == 2 then
			if tonumber(rewards[seat1].xiapao) > tonumber(rewards[seat2].xiapao) then
				paoCount = tonumber(rewards[seat1].xiapao)
			else
				paoCount = tonumber(rewards[seat2].xiapao)
			end
		end
	end
	return paoCount
end

function lib_common:GetGangAddNoWin(bGangAddNoWin)
	local ret = false
	if bGangAddNoWin == 2 or bGangAddNoWin == 0 then		
		ret = false			
	else
		ret = true
	end	
	return ret
end

function lib_common:GetSupportDealerAdd()
	return roomdata_center.gamesetting.bSupportDealerAdd
end

function lib_common:GetSupportGangPao()
	return roomdata_center.gamesetting.bSupportGangPao
end

function lib_common:GetSupportXiaPao()
	return roomdata_center.gamesetting.bSupportXiaPao
end

function lib_common:GetSupportByKey(key)
	return roomdata_center.gamesetting[key]
end

function lib_common:GetDealerBase(banker, i1, i2)
	local base = 0
	if self:GetSupportDealerAdd() and (banker == i1 or banker == i2) then
		base = 1
	end
	return base
end

function lib_common:GetWhichJiePao(rewards)
	local des = nil
	local chair = nil
	for i,v in ipairs(rewards) do
		if v.nJiePao == 1 then
			chair = v._chair
			break
		end
	end
	local viewSeat = nil 
	if chair ~= nil then
		Trace("chair--------------------------"..tostring(chair)) 
		viewSeat = self.gvblFun(chair) 
        local player = self.compPlayerMgr:GetPlayer(viewSeat) 
        local selfPlayer = self.compPlayerMgr:GetPlayer(1)  
        des = MahjongTools.GetPosDes(selfPlayer.index, player.index) 
	end
	return viewSeat, des
end

function lib_common:GetAddFanInfo(winInfo, preDes, lastDes)
  local fanTbl = {} 
  local beishu=0
  for i,v in ipairs(winInfo) do 
    local itemInfo = {}  
    if v.byFanNumber ~= -1 then 
      --itemInfo.num = preDes..tostring(tonumber(v.byFanNumber)*(tonumber(v.byCount)))..lastDes
      itemInfo.num = preDes..tostring(v.byFanNumber)..lastDes 
      beishu=beishu+(tonumber(v.byFanNumber))*(tonumber(v.byCount))
      itemInfo.des =v.szFanName 
      itemInfo.rnum=v.byFanNumber
      table.insert(fanTbl, itemInfo)
    end 
  end 
  return fanTbl,beishu
end

return lib_common