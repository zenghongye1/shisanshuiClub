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

---------------------------设置数据start-------------------------
function this.SetLoginUserInfo(infoData)
    userInfoTbl = infoData
	userInfo = userInfoTbl["user"]
end

function this.InitVersionInfo()
	curVerCommInfo.versionNum = FileUtils.GetGameVerNo("ver_app_8.txt").VersionNum
	Trace("curVerCommInfo----------"..curVerCommInfo.versionNum)
end

function this.SetClientConfData(data)
	clientConfData = data
end
---------------------------设置数据end--------------------------


---------------------------外部接口start--------------------------
--获取登录信息
function this.GetLoginUserInfo()
	return userInfo
end

function this.GetUserInfoTbl()
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
---------------------------外部接口end--------------------------