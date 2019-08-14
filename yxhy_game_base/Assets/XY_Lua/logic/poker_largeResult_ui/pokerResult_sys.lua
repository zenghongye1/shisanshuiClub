--[[
	[@self.userTranList]
	slef:居首
	other：分数降序排列
--]]

local pokerResult_sys = class("pokerResult_sys")

function pokerResult_sys:ctor()
	self.fangzhuId = 0
	self.roomdata = {}
end

------对比分数表
function pokerResult_sys:ShowHighest(uid,ScorestuidList,callback)	-----IS=0 ：本机用户
	for i=1,#ScorestuidList do
		if uid == tonumber(ScorestuidList[i]) then
			if callback ~= nil then
				callback()
			end
		end
	end
end

----------获取最高分的uid表------------
function pokerResult_sys:FindHighestByuid(ScoreUid)
	local Temp = 0
	local higestUid = 0
	local ScoreUidList = {}
	for k,v in pairs(ScoreUid) do
		if v > Temp then
			Temp = v
			higestUid = k
		end	
	end
	table.insert(ScoreUidList,higestUid)
	for k,v in pairs(ScoreUid) do
		if k ~= higestUid and v == Temp and v > 0 then
			table.insert(ScoreUidList,k)
		end	
	end
	return ScoreUidList
end

---------获取最低分的uid表-------------
function pokerResult_sys:FindLowestByuid(ScoreUid)
	local Temp = 0
	local lowestUid = 0
	local ScoreUidList = {}
	for k,v in pairs(ScoreUid) do
		if v < Temp then
			Temp = v
			lowestUid = k
		end	
	end
	table.insert(ScoreUidList,lowestUid)
	for k,v in pairs(ScoreUid) do
		if k ~= lowestUid and v == Temp and v < 0 then
			table.insert(ScoreUidList,k)
		end	
	end
	return ScoreUidList
end

function pokerResult_sys:GetRoomNum()
	local str = "房号:  "..self.roomdata["rno"]
	local round = self.roomdata["cur_playNum"].."/"..self.roomdata["play_num"].."局"

	str = str.." ("..round..")"
	return str
end

function pokerResult_sys:GetGameName()
	return GameUtil.GetGameName(self.roomdata["gid"])
end

function pokerResult_sys:GetTime()
	return tostring(os.date("%Y-%m-%d  %H:%M:%S",os.time()))
end

function pokerResult_sys:SetRoomData()
	self.roomdata["rno"] = roomdata_center["roomnumber"]
	self.roomdata["cur_playNum"] = roomdata_center["nCurrJu"]
	self.roomdata["play_num"] = roomdata_center["nJuNum"]
	self.roomdata["gid"] = roomdata_center["gid"]
end

return pokerResult_sys