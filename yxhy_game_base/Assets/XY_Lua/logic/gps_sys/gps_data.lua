gps_data = {}
local this = gps_data

local playerGpsList = {} 
local playerIndexList = {}
local mahjongIndex = {
	[1] = 1,
	[2] = 3,
	[3] = 4,
	[4] = 6
}

function this.SetTotalPlayer(indexTbl)
	local tbl = {}
	if indexTbl and not isEmpty(indexTbl) then
		if GameUtil.CheckGameIdIsMahjong(player_data.GetGameId()) then
			for _,v in ipairs(indexTbl) do
				table.insert(tbl,mahjongIndex[v])
			end
		else
			tbl = indexTbl
		end
		playerIndexList = tbl
	end
end

function this.SetGpsData(imgUrl,imagetype,seatIndex,viewSeat,coordinate)	
	-----数据格式-----
	local player = {
		["imgUrl"] = imgUrl or "",
		["imageType"] = imagetype or 2,
		["seatIndex"] = seatIndex or 1,
		["viewSeat"] = viewSeat or -1,	--小于1表示该座位还没人enter
		["coordinate"] = {["latitude"] = coordinate["latitude"],["longitude"] = coordinate["longitude"]},
	}
	if GameUtil.CheckGameIdIsMahjong(player_data.GetGameId()) then
		player["seatIndex"]= mahjongIndex[seatIndex]	
	end
	playerGpsList[seatIndex] = {}
	playerGpsList[seatIndex] = player
end

function this.RemoveOne(seatIndex)
	playerGpsList[seatIndex] = {}
end

function this.ResetGpsData()
	playerGpsList = {}
	playerIndexList = {}
end

function this.GetGpsData()
	return playerGpsList
end

function this.GetPlayerIndexList()
	return playerIndexList
end
