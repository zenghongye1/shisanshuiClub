--[[--
 * @Description: 传说中的数据中心(这里只存放一些通用数据)
 * @Author:      shine
 * @FileName:    data_center.lua
 * @DateTime:    2017-05-16 14:16:14
 ]]

data_center = {}
local this = data_center

local curVerCommInfo = 
{
	versionNum = nil,
}

local clientConfData = nil
 

--登录信息
local userInfo = 
{
	nickname = nil,
	uid = nil,
	diamond = nil,
	coin = nil,
	ingot = nil,
	score = nil,
	cvalue = nil,
	vip = nil,
	safecoin = nil,
	bankrupt = nil,
	phone = nil,
	email = nil,
	ttype = nil,
	sitemid = nil,
	pwd = nil,
	session_key = nil,
}

local userInfoTbl = nil

local appConfDataTbl = nil

local curPlatform = nil

local curGameID = nil

local curResId = nil

local isFirstUpdateInfo = false		----用于切换账号首次刷新大厅数据

this.jcGameUrl = ""					--小游戏的url地址

---------------------------设置数据start-------------------------
function this.SetAppConfData()
	print("---------------------------设置数据start------------------------")
	local appConfData = FileUtils.GetAppConfData("config/app_config.txt")
	appConfDataTbl = ParseJsonStr(appConfData)
end

function this.SetCurPlatform()
	curPlatform = tostring(Application.platform)
end

function this.SetLoginUserInfo(infoData)
    userInfoTbl = infoData
	userInfo = userInfoTbl["user"]

	--将uid本地缓存
	if PlayerPrefs.HasKey("USER_UID") and PlayerPrefs.GetString("USER_UID")~= nil and PlayerPrefs.GetString("USER_UID") == tostring(userInfo.uid) then
		return
	end
	PlayerPrefs.SetString("USER_UID", userInfo.uid)
end

function this.SetPhoneNum(num)
	userInfo.phone = num
end

function this.SetUserInfo(infoData)
	userInfo = infoData
	-- 兼容登录和php
	userInfo.imageurl = infoData.imgurl
	userInfo.imagetype = infoData.imgtype
		--将uid本地缓存
	if PlayerPrefs.HasKey("USER_UID") and PlayerPrefs.GetString("USER_UID")~= nil and PlayerPrefs.GetString("USER_UID") == tostring(userInfo.uid) then
		return
	end
	PlayerPrefs.SetString("USER_UID", userInfo.uid)
end

function this.InitVersionInfo()
	if appConfDataTbl ~= nil then		
		local verCommFileName = appConfDataTbl.verFileNameLst[1]
		local verInfoTbl = FileUtils.GetGameVerNo(verCommFileName)
		if verInfoTbl ~= nil then
			curVerCommInfo.versionNum = FileUtils.GetGameVerNo(verCommFileName).VersionNum
			Trace("curVerCommInfo----------"..curVerCommInfo.versionNum)
		else
			Trace(verCommFileName.." is not exist...")
			curVerCommInfo.versionNum = "1.0.0"   --设置一个默认值
		end
	else
		Fatal("appConfData is nil...")
	end
end

function this.GetSiteId()
	local siteid = 1
	   -- 福州 --- siteid android 1 ios 1001 pc 3001
    if this.GetCurPlatform() ==  "WindowsEditor"   then
        siteid = 1
    elseif this.GetCurPlatform() == "Android" then
        siteid = 1
    elseif this.GetCurPlatform() == "IPhonePlayer" then
        siteid = 1001
    end
    return siteid
end


function this.GetDeviceType()
	local deviceType = 1
	   -- 福州 --- siteid android 1 ios 1001 pc 3001
    if this.GetCurPlatform() ==  "WindowsEditor"   then
        deviceType = 3
    elseif this.GetCurPlatform() == "Android" then
        deviceType = 1
    elseif this.GetCurPlatform() == "IPhonePlayer" then
        deviceType = 2
    end
    return deviceType
end


function this.SetClientConfData(data)
	clientConfData = data
end

function this.SetCurGameID(gid)
	curGameID = gid
	curResId = GameUtil.GetResId(gid)
end

----设置isFirstUpdateInfo状态
function this.SetIsUpdateState(state)
	isFirstUpdateInfo = state
end
---------------------------设置数据end--------------------------


---------------------------外部接口start--------------------------
function this.CheckRoomCard(num)
	if userInfo.card == nil or userInfo.card < num then
		MessageBox.ShowYesNoBox("钻石不足，是否前往商城购买？", function ()
        	UI_Manager:Instance():ShowUiForms("shop_ui")
        	MessageBox.HideBox()
    	end, function() MessageBox.HideBox() end, nil, false)
		return false
	end
	return true
end


--[[--
 * @Description: 获取打包配置  
 ]]
function this.GetAppConfDataTble()
	return appConfDataTbl
end

function this.GetCurPlatform()
	return curPlatform
end

--获取登录信息
function this.GetLoginUserInfo()
	return userInfo
end

function this.GetUserInfoTbl()
	--logError("!!!!!" )
    return userInfoTbl
end

--[[--
 * @Description: 获取版本通用信息  
 ]]
function this.GetVerCommInfo()
	return curVerCommInfo
end

--[[--
 * @Description: 获取客户端配置数据  
 ]]
function this.GetClientConfData()
	return clientConfData
end

function this.GetResRootPath()	
	return "game_"..tostring(curResId)
end

function this.GetAppPath()
	return this.GetAppConfDataTble().appPath
end

function this.GetResMJCommPath()
	return this.GetAppConfDataTble().appPath .. "/mj_common"
end

function this.GetResPokerCommPath()
	return this.GetAppConfDataTble().appPath.."/poker_common"
end

function this.GetPlatform()
	if PlayerPrefs.HasKey("LoginType") then
        return PlayerPrefs.GetInt("LoginType")
    else
        return LoginType.YOUKE
    end
end

----获取isFirstUpdateInfo状态用来首次更新大厅信息
function this.GetIsUpdateState()
	return isFirstUpdateInfo
end
---------------------------外部接口end--------------------------