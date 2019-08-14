--[[--
 * @Description: 定义全局数据结构
 * @Author:      shine
 * @FileName:    global_define.lua
 * @DateTime:    2017-05-16
 ]]

global_define = {} 
local this = global_define

this.appId = 8
this.chatTextIntervalTime = 5
this.userNameLen = 7
this.color = 
{
	["WHITE"] = "[FFFFFF]",
	["GREEN"] = "[32E646]",
	["BLUE"]  = "[32E6F0]",
	["PURPLE"] = "[BE32F0]",
	["ORANGE"] = "[F0A032]",
}

--游戏类型
ENUM_GAME_TYPE = 
{
	TYPE_FUZHOU_MJ = 18,            --福州麻将
	TYPE_SHISHANSHUI = 80011,          --十三水
}


local HTTPNETTYPE = 
{
	HTTP_INTERNET = 1,
	HTTP_LOCAL_FZMJ = 2,
	HTTP_LOCAL_SSS = 3,
	HTTP_DEVELOP = 4,
	HTTP_RELEASE = 5,
	HTTP_ABROAD = 6,
	HTTP_DEFAULT = 10,
}

--ws 服务器地址控制
local srvUrlType = NetWorkManage.Instance.ServerUrlTypeNum
if srvUrlType == HTTPNETTYPE.HTTP_INTERNET then 		--外网测试
	this.wsurl = "ws://fjmj.dstars.cc:8001/?uid=%s&token=%s"
	this.preWebUrl = "http://fjmj.dstars.cc"
elseif srvUrlType == HTTPNETTYPE.HTTP_LOCAL_FZMJ then 	--福州麻将内网
	this.wsurl = "ws://192.168.2.202:8001/?uid=%s&token=%s"
	this.preWebUrl = "http://fjmj.dstars.cc"
elseif srvUrlType == HTTPNETTYPE.HTTP_LOCAL_SSS then	--十三水内网
	this.wsurl = "ws://192.168.2.203:8001/?uid=%s&token=%s"
	this.preWebUrl = "http://fjmj.dstars.cc"
elseif srvUrlType == HTTPNETTYPE.HTTP_DEVELOP then 	--开发调试
	this.wsurl = "ws://192.168.2.13:8011/?uid=%s&token=%s"
	this.preWebUrl = "http://fjmj.dstars.cc"
elseif srvUrlType == HTTPNETTYPE.HTTP_RELEASE then 		--发布	
	this.wsurl = "ws://fjmj.dstars.cc:8001/?uid=%s&token=%s"
	this.preWebUrl = "http://fjmj.dstars.cc"
elseif srvUrlType == HTTPNETTYPE.HTTP_ABROAD then	
	this.wsurl = "fjmj2.dstars.cc:8001/?uid=%s&token=%s"
	this.preWebUrl = "http://fjmj2.dstars.cc"
else
	this.wsurl = "ws://intest.dstars.cc:8001/?uid=%s&token=%s"
	this.preWebUrl = "http://b.feiyubk.com"
end

--[[
--php 服务器地址控制
if srvUrlType == HTTPNETTYPE.HTTP_INTERNET then
	NetWorkManage.Instance.BaseUrl = "http://fjmj.dstars.cc/dstars/api/flashapi.php"
elseif srvUrlType == HTTPNETTYPE.HTTP_LOCAL_FZMJ then -- 
	NetWorkManage.Instance.BaseUrl = "http://192.168.2.5/dstars_4/api/flashapi.php"
elseif srvUrlType == HTTPNETTYPE.HTTP_LOCAL_SSS then  --十三水内网
	NetWorkManage.Instance.BaseUrl = "http://192.168.2.5/dstars_4/api/flashapi.php"
elseif srvUrlType == HTTPNETTYPE.HTTP_DEVELOP then
	NetWorkManage.Instance.BaseUrl = "http://test.dstars.cc/dstars_4/api/flashapi.php"
elseif srvUrlType == HTTPNETTYPE.HTTP_RELEASE then
	NetWorkManage.Instance.BaseUrl = "http://fjmj.dstars.cc/dstars/api/flashapi.php"
elseif srvUrlType == HTTPNETTYPE.HTTP_ABROAD then
	NetWorkManage.Instance.BaseUrl = "http://fjmj2.dstars.cc/dstars/api/flashapi.php"
else
	NetWorkManage.Instance.BaseUrl = "http://intest.dstars.cc/dstars_4/api/flashapi.php"
end--]]
--this.preWebUrl = "http://b.feiyubk.com"
this.sss_path = Application.persistentDataPath.."/games/gamerule/YouXia_ShiSangShui_Rule.json"   --福州麻将配置数据
this.fzmj_path = Application.persistentDataPath.."/games/gamerule/FuZhouMJ.json"                 --十三水配置数据

this.hallShareTitle = "最多福州人玩的十三水游戏"
this.hallShareQTitle = "最多福州人玩的十三水游戏"
this.hallShareFriendContent = "自由开房，轻松玩牌！我在游侠十三水等你来战！"
this.hallShareFriendQContent = "本地十三水游戏，98%福州人都喜欢玩的游侠十三水！"
this.hallShareSubUrl = "/gamewap/youxiaqipai/view/youxixiazai.html?uid=%s"

this.gameShareTitle = "开房玩%s速来,房号:%s"
this.gameShareContent = ""

local httpmzsm = this.preWebUrl.."/gamewap/youxiaqipai/view/yonghuxieyi.html"
local httpfwtk = this.preWebUrl.."/gamewap/youxiaqipai/view/fuwutiaokuan.html"
local httpyszc = this.preWebUrl.."/gamewap/youxiaqipai/view/yinsizhengce.html"
local httpactivity = this.preWebUrl.."/gamewap/youxiaqipai/view/huodonggonggao.html"
this.defineimg = "http://portrait3.sinaimg.cn/1674470754/blog/180"

function this.SetURL(mzsm,fwtk,yszc,activity,shareurl) 
    if mzsm~=nil and mzsm~="" then
        httpmzsm=mzsm
    end
    if fwtk~=nil and fwtk~="" then
        httpfwtk=fwtk
    end
    if yszc~=nil and yszc~="" then
        httpyszc=yszc
    end
    if activity~=nil and activity~="" then
        httpactivity=activity
    end
    if shareurl~=nil and shareurl~="" then
        hallShareSubUrl=shareurl
    end 
end

-----------------------外部获取接口-----------------------
function  this.GetUrlData()
   local t=http_request_interface.GetTable()
   local url= httpactivity.."?session_key="..t.session_key.."&siteid="..t.siteid.."&version="..t.version
   return url
end

function this.GetMzsmUrl()
   local t=http_request_interface.GetTable()
     if httpmzsm == "" then
      httpmzsm = "http://b.feiyubk.com/gamewap/youxiaqipai/view/yonghuxieyi.html"
   end
   local url= httpmzsm.."?session_key="..t.session_key.."&siteid="..t.siteid.."&version="..t.version
   return url
end

function this.GetFwtkUrl()
   local t=http_request_interface.GetTable()
   if httpfwtk == "" then
      httpfwtk = "http://b.feiyubk.com/gamewap/youxiaqipai/view/fuwutiaokuan.html"
   end
   local url= httpfwtk.."?session_key="..t.session_key.."&siteid="..t.siteid.."&version="..t.version
   return url
end

function this.GetYszcUrl()
   local t=http_request_interface.GetTable()
   if httpyszc == "" then
      httpyszc = "http://b.feiyubk.com/gamewap/youxiaqipai/view/yinsizhengce.html"
   end
   local url= httpyszc.."?session_key="..t.session_key.."&siteid="..t.siteid.."&version="..t.version
   return url
end

function this.GetShareUrl()
   --local t=http_request_interface.GetTable()
   --local url= global_define.hallShareSubUrl.."?session_key="..t.session_key.."&siteid="..t.siteid.."&version="..t.version
   local url = hallShareSubUrl.."?uid=%s"
   return url
end
