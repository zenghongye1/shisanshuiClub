local GameModel = class("GameModel")

local gameListPath = Application.persistentDataPath.."/games"
local gameListName = "gamelist"
local updateUrl = "http://fjmjup.zdgame.com/MJUpdate/"

local LoginModel

function GameModel:Init()
	LoginModel = model_manager:GetModel("LoginModel")

	self.gamelist = {}
	self.grouplist = {}
	self.gidList = nil -- 游戏列表数组
	self.openGidList = nil -- 已开放游戏列表数组
	self.gidMap = nil -- 游戏信息字典
	self.typeList = nil -- 按类型分类的二维数组
	self.jsonNameList = {}

	Notifier.regist(HttpCmdName.GetCardGameList, self.OnResCardGameList, self)
end

function GameModel:Clear()
	Notifier.remove(HttpCmdName.GetCardGameList, self.OnResCardGameList, self)
end

------------------------ 外部方法 ----------------------------------------

--[[--
 * @Description: 返回所有游戏gid列表  
 ]]
function GameModel:GetGidList()
	if self.gidList == nil then
		self.gidList = self:UpdateGidList()
	end
	return self.gidList
end

--[[--
 * @Description: 返回开放游戏gid列表  
 ]]
function GameModel:GetOpenGidList()
	if self.openGidList == nil then
		self.openGidList = self:UpdateGidList(true)
	end
	return self.openGidList
end

--[[--
 * @Description: 返回根据类型分类的二维数组  
 ]]
function GameModel:GetTypeList()
	if self.typeList == nil then
		self.typeList = self.grouplist
	end
	return self.typeList
end

--[[--
 * @Description: 返回游戏名称
 ]]
function GameModel:GetGameName(gid)
	local info = self:GetGidMap()[gid]
	local gamename = ""
	if info then
	    gamename = info.name
	end
    return gamename
end

--[[--
 * @Description: 返回json文件名，带后缀
 ]]
function GameModel:GetJsonName(gid)
	if self.jsonNameList[gid] then
		return self.jsonNameList[gid]
	end
	local info = self:GetGidMap()[gid]
	local jsonname = ""
	if info and info["grule"] then
		local jsonurl=string.split(info["grule"],"/")
	    jsonname =jsonurl[table.getCount(jsonurl)]
	    self.jsonNameList[gid] = jsonname
	end
    return jsonname
end

------------------------ 外部方法 ----------------------------------------

function GameModel:ReqGetCardGameList(isForce,callback)
	local param = {}
	param.checksum = self:GetCheckSum(isForce)
	param.siteid = http_request_interface.GetTable().siteid
	param.clientver = data_center.GetVerCommInfo().versionNum
	param.devicetype = tonumber(data_center.GetLoginUserInfo().deviceid)
	param.appid = global_define.appConfig.appId
	param.uid = data_center.GetLoginUserInfo().uid

	HttpProxy.SendGlobalRequest("/gamelist.json", HttpCmdName.GetCardGameList, param, callback)
end

function GameModel:GetCheckSum(isForce)
	if isForce then
		return nil
	end
	local data = GameModel:GetlocalFileData()
	if data and data.checksum then
		return data.checksum
	end
end

function GameModel:OnResCardGameList(param)
	if param then
		self:SaveGrouplist(param)
		if param.gamelist then
			self:SaveGameList(param)
		else
			self:LoadGameList()
		end
	end
end

function GameModel:SaveGrouplist(param)
	if param.grouplist then
		self.grouplist = param.grouplist
	end
end

function GameModel:SaveGameList(param)
	if param.gamelist then
		self.gamelist = param.gamelist
		self:CheckJsonLegal()
		local context = CombinJsonStr(param)
		NetWorkManage.Instance:CreateFile(gameListPath,gameListName,context)
	end
end

function GameModel:LoadGameList()
	local filePath = gameListPath.."/"..gameListName
	local isSucceed = false
	local data = GameModel:GetlocalFileData()
	if data and data.gamelist then
		self.gamelist = data.gamelist
		self:CheckJsonLegal()
		isSucceed = true
	end

	if not isSucceed then
		self:ReqGetCardGameList(true)
	end
end

function GameModel:GetlocalFileData()
	if self.localData then
		return self.localData
	end
	local filePath = gameListPath.."/"..gameListName
	if FileReader.IsFileExists(filePath) then
		local context = FileReader.ReadFile(filePath)
		if context then
			local data = ParseJsonStr(context)
			if data then
				self.localData = data
				return data
			end
		end
	end
end

function GameModel:GetlocalGameData(gid)
	local localData = self:GetlocalFileData()
	if localData then
		for i,v in ipairs(localData.gamelist or {}) do
			if v.gid == gid then
				return v
			end
		end
	end
end

function GameModel:UpdateGidList(isCheckOpen)
	local list = {}
	for i,v in ipairs(self.gamelist) do
		if GameUtil.CheckHasGame(v.gid) then
			if isCheckOpen then
				if self:GetGameStatus(v.gid) then
					table.insert(list,v.gid)
				end
			else
				table.insert(list,v.gid)
			end
		end
	end
	return list
end

function GameModel:UpdateGidMap()
	local list = {}
	for i,v in ipairs(self.gamelist) do
		if GameUtil.CheckHasGame(v.gid) then
			list[v.gid] = v
		end
	end
	return list
end

function GameModel:CheckJsonLegal()
  for _,v in ipairs(self.gamelist) do
    local flag,url,grule_md5 = self:NeedDownloadJson(v)
    if flag and url then
      NetWorkManage.Instance:HttpDownTextAsset(url, function(code, msg)
            PlayerPrefs.DeleteKey(global_define.CreateRoomPlayerPrefs..v.gid)
            PlayerPrefs.DeleteKey(global_define.ClubCreateRoomPlayerPrefs..v.gid)
          end, global_define.appConfig.jsonurl)   
    end
  end
end

--[[--
 * @Description: 返回所有游戏{gid=info}字典  
 ]]
function GameModel:GetGidMap()
	if self.gidMap == nil then
		self.gidMap = self:UpdateGidMap()
	end
	return self.gidMap
end

--[[--
 * @Description: 返回gid是否对外开放
 ]]
function GameModel:GetGameStatus(gid)
	local status = true
	local info = self:GetGidMap()[gid]
	if info then
		if info.status ~= nil and info.status == 1 then
			status = false
		end
	else
		status = false
	end
	return status
end

function GameModel:NeedDownloadJson(game)
	local jsonname = self:GetJsonName(game.gid)
	local realUrl = self:GetDownloadUrl(game)
	local grule_md5 = game["grule_md5"]

	if grule_md5 == nil then
		return true,realUrl
	end

	local localGame = self:GetlocalGameData(game.gid)
	if localGame == nil then
		return true,realUrl
	end

	if grule_md5 ~= localGame.grule_md5 then
		return true,realUrl
	end

	if not FileReader.IsFileExists(global_define.appConfig.jsonurl.."/"..jsonname) then
		return true,realUrl
	end

	return false
end

function GameModel:GetDownloadUrl(game)
	local downloadUrl = LoginModel.mjupdateurl..(game["grule"] or "")
	-- local downloadUrl = updateUrl..data["grule"]
	return downloadUrl
end

return GameModel