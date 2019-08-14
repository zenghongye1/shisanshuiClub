ClubUtil = {}
local GameUtil = GameUtil

ClubUtil.AgentGameSelectCount = 5
ClubUtil.NormalGameSelectCount = 5

ClubUtil.iconIdToNameMap = 
{
	[1] = "icon_27",
	[2] = "icon_28",
	[3] = "icon_29",
}

ClubUtil.locationTab = nil
ClubUtil.provinceIdList = {}
ClubUtil.locationProvinceToCityMap = {}

ClubUtil.SupportProvinceList = {350000}

-- type -> gidslist
ClubUtil.gameTypeMap = {}
-- gid -> typelist
ClubUtil.gidToGameTypeMap = nil

function ClubUtil.InitGameType()
	ClubUtil.gidToGameTypeMap = {}
	local configs = model_manager:GetModel("GameModel"):GetTypeList()
	for key, v in pairs(configs) do
		v.key = key
		for i = 1, #v.gids do
			if ClubUtil.gidToGameTypeMap[v.gids[i]] == nil then
				ClubUtil.gidToGameTypeMap[v.gids[i]] = {}
				ClubUtil.gidToGameTypeMap[v.gids[i]][1] = key
			else
				table.insert(ClubUtil.gidToGameTypeMap[v.gids[i]], key)
			end
		end
	end
end

-- 根据gid列表获取 标签页信息列表
function ClubUtil.GetGameTypeListAndTypeToGidMapByGidList(gids, sort)
	if gids == nil or #gids == 0 then
		return {}
	end
	-- gametype -> list
	local typeMap = {}
	local typeList = {}
	for i = 1, #gids do
		local list = ClubUtil.GetGameTypeListByGid(gids[i])
		if list ~= nil then
			for j = 1, #list do
				if not typeMap[list[j]] then
					local cfg = model_manager:GetModel("GameModel"):GetTypeList()[list[j]] -- config_mgr.getConfig("cfg_gametype", list[j])
					table.insert(typeList, cfg)
					typeMap[list[j]] = {}
					typeMap[list[j]][1] = gids[i]
				else
					table.insert(typeMap[list[j]], gids[i])
				end
			end
		end
	end

	if sort then
		table.sort(typeList, ClubUtil.SortGameType)
	end

	return typeList,typeMap
end


function ClubUtil.GetAllGameType(sort)
	local list = config_mgr.getConfigs()
	---  这会把配置表给排序  如果有问题，需要深拷贝再排序
	if sort then
		table.sort(list,  ClubUtil.SortGameType)
	end
	return list
end


function ClubUtil.SortGameType(left, right)
	if left == right then
		return false
	end
	if left == nil then
		return false
	end
	if right == nil then
		return false
	end
	if right.order == nil or left.order == nil then
		return false
	end
	return left.order <= right.order
end


-- 获取某个gid的标签
function ClubUtil.GetGameTypeListByGid(gid)
	if ClubUtil.gidToGameTypeMap == nil then
		ClubUtil.InitGameType()
	end
	if ClubUtil.gidToGameTypeMap[gid] ~= nil then
		return ClubUtil.gidToGameTypeMap[gid]
	else
		return {}
	end
end


function ClubUtil.GetOpenClubGids(clubGids)
	local legal_gids = {}
	local open_gids = model_manager:GetModel("GameModel"):GetOpenGidList()
	for _,gid in ipairs(clubGids or {}) do
		if IsTblIncludeValue(gid,open_gids) then
			table.insert(legal_gids,gid)
		end
	end
	return legal_gids
end


function ClubUtil.GetClubIconName(id)
	if id == nil or ClubUtil.iconIdToNameMap[id] == nil then
		return "icon_27"
	else
		return ClubUtil.iconIdToNameMap[id]
	end
end

function ClubUtil.GetClubMemberCapacity()
	return 50
end

function ClubUtil.GetGameContent(gids, sp, count)
	if gids == nil then
		return ""
	end
	gids = ClubUtil.GetOpenClubGids(gids)
	sp = sp or "、"
	local strTab = {}
	for i = 1, #gids do
		if global_define.CheckHasName(gids[i]) then
		strTab[#strTab + 1] = GameUtil.GetGameName(gids[i])
		end
	end
	local content = table.concat(strTab, sp)
	return ClubUtil.FormatGameStr(content, count)
end


function ClubUtil.CopyClubInfo(dest, source)
	if source == nil then
		return
	end
	for k, v in pairs(source) do
		dest[k] = source[k] 
	end
end


function ClubUtil.InitLocations()
	local path = data_center.GetAppConfDataTble().appPath.."/config/txt/location/location"
	local locationTxtAsset = newNormalObjSync(path, typeof(UnityEngine.TextAsset))
	if locationTxtAsset == nil then
		logError("加载不到location.txt")
		return
	end
	ClubUtil.locationTab = ParseJsonStr(locationTxtAsset.text)
	ClubUtil.InitLocationMap()
end

function ClubUtil.GetProvinceCitys(id)
	id = tostring(id - id % 10000)
	if ClubUtil.locationProvinceToCityMap[id] == nil then
		return {}
	end
	return ClubUtil.locationProvinceToCityMap[id]
end


function ClubUtil.GetProvinceId(cityId)
	local provinceid = tostring(cityId - cityId % 10000)
	return provinceid
end

function ClubUtil.InitLocationMap()
	ClubUtil.locationProvinceToCityMap = {}
	ClubUtil.provinceIdList = {}
	for provinceid, province in pairs(ClubUtil.locationTab) do
		if ClubUtil.locationProvinceToCityMap[provinceid] == nil then
			ClubUtil.locationProvinceToCityMap[provinceid] = {}
		end
		table.insert(ClubUtil.provinceIdList, {provinceid, province.name})
		if province.city ~= nil then
			for id, city in pairs(province.city) do
				table.insert(ClubUtil.locationProvinceToCityMap[provinceid], {id, city.name})
			end
			Utils.sort(ClubUtil.locationProvinceToCityMap[provinceid], function(a,b) return a[1] > b[1] end)
		else
			table.insert(ClubUtil.locationProvinceToCityMap[provinceid], {provinceid, province.name})
		end
	end

	Utils.sort(ClubUtil.provinceIdList, function(a,b) return a[1] > b[1] end)
end

function ClubUtil.SearchClubSortFunc(clubA, clubB)
	if clubA == nil or clubB == nil then
		return false
	end
	if model_manager:GetModel("ClubModel"):IsClubMember(clubA.cid) then
		return false
	end
	if model_manager:GetModel("ClubModel"):IsClubMember(clubB.cid) then
		return true
	end
	return false
end


function ClubUtil.RoomListSortFunc(clubA, clubB)
	if clubA == nil or clubB == nil then
		return false
	end
	if clubA.uid == clubB.uid  then
		return false
	end
	if clubA.uid == model_manager:GetModel("ClubModel").selfPlayerId then
		return true
	elseif clubB.uid == model_manager:GetModel("ClubModel").selfPlayerId then
		return false
	end
	return false
end

function ClubUtil.FormatGameStr(content, maxCount)
	if maxCount == nil then
		return content
	end
	if Utils.utf8len(content) <= maxCount then
		return content
	end
	local str = Utils.utf8sub(content, 1, maxCount - 1)
	return str .. "..."
end


function ClubUtil.OpenCreateClub()
	UI_Manager:Instance():ShowUiForms("ClubCreateUI")
end


function ClubUtil.CloseCreateClub()
	UI_Manager:Instance():CloseUiForms("ClubCreateUI")
end

function ClubUtil.GetLocationNameById(id, defaultStr)

	defaultStr = defaultStr or "中国"
	if id == nil then
		return defaultStr
	end
	id = tostring(id)
	local info

	if id % 10000 == 0 then
		info = ClubUtil.locationTab["100000"].city[id] or ClubUtil.locationTab["990000"].city[id]
	else
		local province = tostring(id  - id % 10000)
		if ClubUtil.locationTab[province] ~= nil then
			if id % 100 == 0 then
				info = ClubUtil.locationTab[province].city[id]
			else
				local city = ClubUtil.locationTab[province].city[tostring(id - id * 100)]
				if city ~= nil and city.area ~= nil then
					info = city.area[id]
				end
			end
		end
	end

	-- -- city
	-- if id % 100 == 0 then
	-- 	info = ClubUtil.locationTab.city[id]
	-- else
	-- 	local cityId = id - id % 100 
	-- 	local city = ClubUtil.locationTab.city[tostring(cityId)]
	-- 	if city ~= nil then
	-- 		info = city.area[id]
	-- 	end
	-- end
	if info == nil then
		return  defaultStr
	else
		return info.name
	end
end

