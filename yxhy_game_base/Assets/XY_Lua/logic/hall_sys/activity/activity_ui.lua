--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local base = require("logic.framework.ui.uibase.ui_window")
local activity_ui = class("activity_ui",base)

function activity_ui:ctor()
	base.ctor(self) 
	self.detail = {}
	self.isWebLoad = false
	self.isHallLoad = false
end

function activity_ui:OnInit()
	self:InitView()
	--注册事件
	Notifier.regist(cmdName.SHOW_PAGE_HALL, self.OnHallLoad, self)
end

function activity_ui:OnOpen(isPop)
	self:UpdateView()
	if self.webView then
		self.webView:Show()
	end

	if isPop then
		self.gameObject:SetActive(false)
		coroutine.start(function ()
			coroutine.wait(0.2)
			if self.IsOpened == true then
				self.gameObject:SetActive(true)
			end
		end)	
	end
end
function activity_ui:PlayOpenAmination()
end
-- function activity_ui:PlayOpenAnimationFinishCallBack()

-- 	if self.webView and self.IsOpened then
-- 		self.webView:Show()
-- 	end
-- end

function activity_ui:OnRefreshDepth()
  local Effect_zuixihuodong = child(self.gameObject.transform, "panel_activity/Panel_Top/Title/Effect_zuixihuodong")
  if Effect_zuixihuodong and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(Effect_zuixihuodong.gameObject, topLayerIndex)
  end
end

function activity_ui:OnClose()
	if self.webView then
		self.webView:Hide()
	end
end

function activity_ui:InitView()
    local btn_close = child(self.gameObject.transform,"panel_activity/Panel_Top/btn_close")
    if btn_close ~= nil then
        addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
    end 
	
	local btn_action = child(self.gameObject.transform,"panel_activity/Panel_Middle/detail/btnAction")
    if btn_action ~= nil then
        addClickCallbackSelf(btn_action.gameObject,self.ActionClick,self)
    end
	self.gridList = child(self.gameObject.transform,"panel_activity/Panel_Middle/btnGrid")
	self.detail.title = child(self.gameObject.transform,"panel_activity/Panel_Middle/detail/title")
	self.detail.tex = child(self.gameObject.transform,"panel_activity/Panel_Middle/detail/Texture")

	self:InitWebView()
end

function activity_ui:UpdateView()
	
end

function activity_ui:ActionClick()
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
	
end

function activity_ui:CloseWin()  
    ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("activity_ui")
end


function activity_ui:InitWebView()
	local url = global_define.GetUrlData()
	if not self.webView then
		local WebComponent = require "logic/common/WebComponent"
		self.webView = WebComponent:create(self:GetGameObject("panel_activity/Panel_Middle/WebComponent"), url)

		self.webView:AddReceiveFunction(function(webView, message)
			if message.path=="move" then
				self:CloseWin()
				if not model_manager:GetModel("ClubModel"):HasClub() then
					UI_Manager:Instance():FastTip("请先加入俱乐部")
					return
				end
				UI_Manager:Instance():ShowUiForms("openroom_ui")
			end
			if message.path=="yaoqing" then    
				self:CloseWin()
				UI_Manager:Instance():ShowUiForms("share_ui",UiCloseType.UiCloseType_CloseNothing,function() 
					Trace("Close share_ui")
				end)
			end
			
			if message.path == "wxhongbao" then
				self:GotoShare()
			end

			if message.path == "load" then				
				if self.isHallLoad then
					if hall_ui ~= nil then
						hall_ui:ShowActivity()
					else
						logError("hall_ui is nil ")
					end
				end
				self.isWebLoad = true
			end

			-- 打开全屏网页
			if message.path=="web" and message.rawMessage then
				local strTbl = string.split(message.rawMessage, "param1=")
				-- "https://www.baidu.com"
				if strTbl and string.len(strTbl[2] or "") >0 then
					local webpage= SingleFullWeb.Instance:InitWebPage(strTbl[2], -1,-1, -1,-1, false)
					if webpage then
						webpage:Show()
					end
				end
			end
		end) 
	end
end
 
function activity_ui:GotoShare()
    ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click") 

    local sharePlatform = data_center.GetPlatform()
	local shareType = 1--0微信/QQ好友，1朋友圈/空间，2微信收藏
    local contentType = 2 --1文本，2图片，3声音，4视频，5网页
    local title = global_define.appConfig.hallShareQTitle
    local localPicUrl = ""
    local url = string.format(global_define.GetShareUrl(),data_center.GetLoginUserInfo().uid)
    local description = global_define.appConfig.hallShareFriendQContent
	
    local summary =  "QQ河南麻将"
    local iconUrl = "http://qqhnmj.zdgame.com/dstars/images/tmp/zm.png"
    local targetUrl = "http://qqhenmj.qq.com/m/"
    --local localPicTip = "localPicTip"
    --local editTextTip = "editTextTip"
    local shareContent = 0 

    http_request_interface.GetShareConfig(nil,function(str)
        Trace(str)
        local s = string.gsub(str, "\\/", "/")
        local t = ParseJsonStr(s)
        if t.ret==0 then
            if tonumber(t.sharecfg[1].sharetype)==5 then
                title=t.sharecfg[1].h5cfg.h5_title
                targetUrl=t.sharecfg[1].h5cfg.h5_url
                summary=t.sharecfg[1].h5cfg.h5_subtitle
                iconUrl=t.sharecfg[1].icon
                contentType = t.sharecfg[1].sharetype
                shareContent=0
                shareHelper.doShare(sharePlatform,shareType,contentType,title,localPicUrl,url,description)
            elseif tonumber(t.sharecfg[1].sharetype)==2 then
            	iconUrl=t.sharecfg[1].icon
            	contentType = t.sharecfg[1].sharetype
                shareContent=1 
                DownloadCachesMgr.Instance:LoadImage(iconUrl,function( code,texture,url )  
                    localPicUrl=url
                    if localPicUrl~=nil then
	                    Trace(localPicUrl)
	                    targetUrl=""
	                    summary=""
	                    title=""
	                    shareHelper.doShare(sharePlatform,shareType,contentType,title,localPicUrl,url,description)
                    end
                end)
            end
        end
    end)
      
end


function activity_ui:OnHallLoad()
	if self.isWebLoad then
		if hall_ui ~= nil then
			hall_ui:ShowActivity()
		else
			logError("hall_ui is nil ")
		end		
	end

	self.isHallLoad = true
end

return activity_ui