require "logic/poker_sys/utils/PokerShareSpecialDeal"	----牌类特殊字段处理
ShareStrUtil = {}
local gameIdToFuncMap = {}
local createRoomToFuncMap = {}
local costtypeStr = {
	[0] = "房主支付、",
	[1] = "AA支付、",
	[2] = "大赢家支付、",
	[3] = "会长支付、",
}
--[[--
 * @Description: 牌局内  
 ]]
function ShareStrUtil.GetShareStr(gameId,needHide, dontAdd)
	local gameId = gameId or player_data.GetGameId()
	local gameName = GameUtil.GetGameName(gameId)
	local func = ShareStrUtil.GetGameShareStr--gameIdToFuncMap[gameId]


	local ruleStr = ""
	if func ~= nil then
		ruleStr = func(gameId,roomdata_center.gamesetting,needHide, dontAdd)
	end
	return gameName, ruleStr
end

--[[--
 * @Description: 牌局外  
 ]]
function ShareStrUtil.GetRoomShareStr(gameId,data,dontAdd,needHide)
	local gameId = gameId or player_data.GetGameId()
	local func = ShareStrUtil.GetRoomShareStrInternal--createRoomToFuncMap[gameId]

	if func == nil then
		logError("找不到gameId", gameId)
		return ""
	end
	if data.costtype then
		data.cfg["costtype"] = data.costtype
	end
	return func(gameId,data.cfg,dontAdd,needHide)
end

function ShareStrUtil.IsKeyNotConnect(connect,keys,gameData)
	local connect_cfg = config_mgr.getConfig("cfg_rule",connect)
	if connect_cfg then
		for i = 1, #keys do
			if keys[i] == connect and gameData[connect] == false then
				return true
			end
		end
	end
	return false
end

function ShareStrUtil.GetGameShareStr(gameId,gameData,needHide, dontAdd)
	local gameId = gameId or player_data.GetGameId()
	local strTab = {}
	ShareStrUtil.AddGamePlayerAndJU(strTab, gameData)	
	local keys = GameUtil.GetShareKeys(gameId)
	if keys ~= nil and #keys > 0 then
		for i = 1, #keys do
			if not ShareStrUtil.CheckKeyIsNeedHide(gameId,keys[i],needHide) then
				local value = nil
				local cfg = config_mgr.getConfig("cfg_rule",keys[i])
				if cfg ~= nil then
					local connect = cfg.connect
					if not (connect and ShareStrUtil.IsKeyNotConnect(connect,keys,gameData)) then
						local res = gameData[keys[i]]
						if type(res) == "boolean" then
							if res==true then
								value=ShareStrUtil.ShareValueByGid(gameId,cfg)[1]
							else
								value=ShareStrUtil.ShareValueByGid(gameId,cfg)[0]
							end
						elseif type(res) == "number" then
							value=ShareStrUtil.ShareValueByGid(gameId,cfg)[res]
						elseif type(res) == "table" then
							value = PokerShareSpecialDeal.ProduceValue(gameId,keys[i],res) or ""	--牛牛三公两个字段表需要特殊处理
						else
							logError(type(res))
						end
						-- if gameData[keys[i]] == true then 
						-- 	value = cfg.selectValue
						-- elseif gameData[keys[i]] == false then
						-- 	value = cfg.delselectValue
						-- end
						if value ~= nil then
							table.insert(strTab,"、"..value)
						end
					end
				end
			end
		end
	end
	if not dontAdd then
		table.insert(strTab, GameUtil.GetShareContent(gameId))
	end
	return table.concat(strTab)
end

function ShareStrUtil.GetRoomShareStrInternal(gameId,roomShareData,dontAdd,needHide)
	local strTab = {}
	local gameId = gameId or player_data.GetGameId()
	ShareStrUtil.AddRoomPlayerAndJU(strTab,roomShareData)
	local keys = GameUtil.GetShareKeys(gameId)
	if keys ~= nil and #keys > 0 then
		for i = 1, #keys do
			if not ShareStrUtil.CheckKeyIsNeedHide(gameId,keys[i],needHide) then
				local cfg = config_mgr.getConfig("cfg_rule",keys[i])
				if cfg ~= nil then
					local value = ShareStrUtil.GetKeyValue(gameId, keys[i], roomShareData, cfg)
					if value ~= nil then
						table.insert(strTab,"、"..value)
					end
				end
			end
		end
	end
	if not dontAdd then
		table.insert(strTab, GameUtil.GetShareContent(gameId))
	end
	return table.concat(strTab), strTab
end


function ShareStrUtil.GetKeyValue(gid, key, roomShareData, cfg)
	local value = nil

	--key = cfg.RoomRuleKey or key	
	local num = roomShareData[key]
	------牛牛三公两个字段需要特殊处理
	if ENUM_GAME_TYPE.TYPE_NIUNIU == gid  or ENUM_GAME_TYPE.TYPE_SANGONG == gid then
		local shareStr = PokerShareSpecialDeal.ProduceValue(gid,key,roomShareData[key])
		if shareStr then
			return shareStr
		else
			key = cfg.RoomRuleKey
			shareStr = PokerShareSpecialDeal.ProduceValue(gid,key,roomShareData[key])
			if shareStr then
				return shareStr
			end
		end
	end
	
	if num then
		local str = ShareStrUtil.ShareValueByGid(gid,cfg)[num]
		if str and str~="" then
			value = str
		end
	end

	if value == nil then
		key = cfg.RoomRuleKey
		num = roomShareData[key]
		if num then
			local str = ShareStrUtil.ShareValueByGid(gid,cfg)[num]
			if str and str~="" then
				value = str
			end
		end
	end

	return value
end


function ShareStrUtil.AddGamePlayerAndJU(strTab, cfg)
	if cfg.costtype then
		table.insert(strTab, costtypeStr[cfg.costtype])
	end
	local curPlayerNum = room_usersdata_center.GetRoomPlayerCount()
	table.insert(strTab, "当前人数"..curPlayerNum.."/"..roomdata_center.maxplayernum.."、")
	if cfg.bSupportKe then
		table.insert(strTab, "打课")
	else
		table.insert(strTab, roomdata_center.nJuNum .. "局")
	end	
end


function ShareStrUtil.AddRoomPlayerAndJU(strTab,cfg)
	if cfg.costtype then
		table.insert(strTab, costtypeStr[cfg.costtype])
	end
	table.insert(strTab, cfg.pnum .. "人、")
	if cfg.bsupportke ==1 then
		table.insert(strTab, "打课")
	else
		table.insert(strTab, cfg.rounds .. "局")
	end		 
end

function ShareStrUtil.CheckKeyIsNeedHide(gameId,key,needHide)
	if not needHide then
		return
	end
	local hideKeys = GameUtil.GetHideRuleKeys(gameId)
	if hideKeys then
		for _,v in ipairs(hideKeys) do
			if v == key then
				return true
			end
		end
	end
	return false
end

function ShareStrUtil.ShareValueByGid(gid,cfg)
	local str
	if gid and cfg.shareValueByGid and cfg.shareValueByGid[gid] then
		str = cfg.shareValueByGid[gid]
	else
		str = cfg.shareValue
	end
	return str
end