local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local baseClass = class("mahjong_action_totalreward", base)
local bigSettlement_ui_data = require "logic/mahjong_sys/data/mahjong_data_class/bigSettlement_ui_data"

--[[--
 * @Description: 特殊牌型加倍叠加番，同时计算自摸点炮和特殊牌型次数  
 ]]
function baseClass:Execute(tbl)
	local para = tbl._para
	self.totallInfo = {}
	if para ~= nil then
		self.totallInfo = para.totallInfo or {}
	end

	local user_list = room_usersdata_center.GetUsersDataList()

	local highScore,lowScore = self:GetHighScore()

	local totalrewardData = bigSettlement_ui_data:create()
	totalrewardData.gameName = self:GetGameName()
	totalrewardData.endTime = self:GetGameTime()
	totalrewardData.roomNum = self:GetRoomNum()

	local players = {}
	local sortPlayerList = {}
	for i,userInfo in pairs(user_list) do
		local pStr = "p"..i
		local totalrewardData_one = {}
		-- 用户数据
		totalrewardData_one.userData = {}
		totalrewardData_one.userData["name"] = userInfo.name
		totalrewardData_one.userData["uid"] = userInfo.uid
		totalrewardData_one.userData["headurl"] = userInfo.headurl
		totalrewardData_one.userData["imagetype"] = userInfo.imagetype
		-- 获取总分
		totalrewardData_one.all_score = (self.totallInfo[pStr] and self.totallInfo[pStr].score) or 0
		-- 大赢家
		totalrewardData_one.isWin = highScore == totalrewardData_one.all_score and highScore~=0
		-- 大输家
		totalrewardData_one.isRich = lowScore == totalrewardData_one.all_score and lowScore~=0
		-- 详细信息
		totalrewardData_one.tList = self:GetMainInfo(i)
		-- 房主
		totalrewardData_one.isRoomOwner = roomdata_center.ownerId == userInfo.uid
		if userInfo.viewSeat == 1 then
			table.insert(sortPlayerList,totalrewardData_one)
		else
			table.insert(players,totalrewardData_one)
		end
	end

	-- 排序
	for i=2,#players do
		local insertItem = players[i]
        local insertIndex = i - 1
        while (insertIndex > 0 and insertItem.all_score > players[insertIndex].all_score)
        do
            players[insertIndex + 1] = players[insertIndex]
            insertIndex = insertIndex -1
        end
        players[insertIndex + 1] = insertItem
	end

	for i=1,#players do
		table.insert(sortPlayerList,players[i])
	end

	totalrewardData.players = sortPlayerList
	roomdata_center.totalRewardData = totalrewardData
end

--[[--
 * @Description: item = {name = "自摸",num = "X次"}
 *
 * ---麻将总信息
	"totallInfo":{
		"p1":{
		   "score":80,	--累计积分
		   "winnum":2,	--累计胜局
		   "angang":2,	--累计暗杠次数
		   "minggang":3,--累计明杠次数
		   "selfdraw":0,--累计自摸次数
		   "gun":1,		--累计点炮次数
		   "huangju":2,	--累计荒局次数
		   "winfo":{--累计特殊牌型次数 格式："t牌型id" = 2
				"t2":3,
				....
		   }
		},
		...
	}
 ]]
function baseClass:GetMainInfo(index)
	local tList = {}
	for playerIndexStr,info in pairs(self.totallInfo) do
		local p_index = tonumber(string.sub(playerIndexStr,2))
		if p_index == index then
			-- 自摸、点炮
			if self.cfg.bigSettlementNeedShowWinType then
				table.insert(tList,{name = "点炮",num = (info.gun.."次")})
				table.insert(tList,{name = "自摸",num = (info.selfdraw.."次")})
			end
			-- 牌型
			for fanTypeStr,num in pairs(info.winfo) do
				local fanType = tonumber(string.sub(fanTypeStr,2))
				if fanType > 0 then
					for i=1,1 do
						if self.cfg.bigSettlementNeedIgnore then
							if IsTblIncludeValue(fanType, self.cfg.ignoreEffect or {}) then
								break
							end
						end
						local item = self:GetFanInfoItem(fanType,num)
						if item then
							table.insert(tList,item)
						end
					end
				end
			end
			-- 杠数
			if self.cfg.bigSettlementNeedShowGang then
				table.insert(tList,{name = "暗杠",num = (info.angang.."次")})
				table.insert(tList,{name = "明杠",num = (info.minggang.."次")})
			end
		end
	end
	return tList
end

function baseClass:GetFanInfoItem(fanType,num)
	local artConfig = config_mgr.getConfigs("cfg_artconfig")
	local hutypeConfig = config_mgr.getConfig(self.cfg.huTypeTable,fanType)
	if hutypeConfig then
		local artId = hutypeConfig.artId
		local artIdByGameId = hutypeConfig.artIdByGameId
		if artIdByGameId then
			local newArtId = artIdByGameId[self.mode.game_id]
			if newArtId then
				artId = newArtId
			end
		end
		if artId then
			local item = {}
            local artData = artConfig[artId]
            if artData and artData.chineseName then
				item.name = artData.chineseName..":"
				item.num = num.."次"
				return item
			else
				logError("未找到对应cfg_artconfig",artId)
			end
		else
			logError("无法获取artId,"..self.cfg.huTypeTable.." byFanType:"..fanType)
		end
	else
		logError("hutypeConfig,"..self.cfg.huTypeTable.." byFanType:"..fanType)
	end
end

function baseClass:GetRoomNum()
	local str = "房号:"..roomdata_center.roomnumber
	local round = roomdata_center.nJuNum.."局"
	if roomdata_center.bSupportKe then
		round = "打课"
	end
	str = str.."（"..round.."）"
	return str
end

function baseClass:GetGameTime()
	return os.date("%Y-%m-%d  %H:%M:%S",os.time())
end

function baseClass:GetGameName()
	return GameUtil.GetGameName(roomdata_center.gid)
end

function baseClass:GetHighScore()
	local highScore = 0
	local lowScore = 0
	for i,info in pairs(self.totallInfo) do
		local s = info.score
		if highScore < s then
			highScore = s
		end
		if lowScore > s then
			lowScore = s
		end
	end
	return highScore,lowScore
end

return baseClass