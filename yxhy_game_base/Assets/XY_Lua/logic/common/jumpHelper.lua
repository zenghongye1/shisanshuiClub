jumpHelper = {}

local UiNameDefine = {
	[1] = "activity_ui",			--活动界面,可直接打开
	[2] = "openroom_ui",			--开房界面,需判断已加入俱乐部
	[3] = "shop_ui",				--商城界面
	[4] = "share_ui",				--分享界面
	[5] = "mail_ui",				--邮箱界面
	[6] = "record_ui",				--战绩界面
	[7] = "join_ui_new",		--创建加入俱乐部界面
	[8] = "feedback_ui",			--反馈界面
	[9] = "personInfo_ui",			--个人信息界面,需要传入uid
	[10]= "setting_ui",				--设置界面
	[11]= "help_ui",				--玩法界面,需要传入对应玩法gid
	[12]= "certification_ui",		--认证界面
	[13]= "joinRoom_ui",			--加入房间界面
}

---跳UI界面,UiIndex:跳转界面索引;extra:打开界面的额外参数(后台未支持)
function jumpHelper.JumpToUI(UiIndex,extra)
	if UiIndex == 2 then
		if not model_manager:GetModel("ClubModel"):HasClub() then
			UI_Manager:Instance():FastTip("请先加入俱乐部")
			return
		end
		UI_Manager:Instance():ShowUiForms(UiNameDefine[UiIndex])
	elseif UiIndex == 9 then
		local uid = extra or data_center.GetLoginUserInfo().uid
		UI_Manager:Instance():ShowUiForms(UiNameDefine[UiIndex],nil,nil,uid)
	elseif UiIndex == 11 then
		local gid = extra or ENUM_GAME_TYPE.TYPE_SHISHANSHUI
		UI_Manager:Instance():ShowUiForms(UiNameDefine[UiIndex],nil,nil,gid)
	else
		UI_Manager:Instance():ShowUiForms(UiNameDefine[UiIndex])
	end
end

---跳转全屏网页,strUrl:http完整网址,isPortrait:是否竖屏
function jumpHelper.JumpToUrl(strUrl,isPortrait)
	if strUrl and string.len(strUrl or "") >0 then
		local webpage = SingleFullWeb.Instance:InitWebPage(strUrl, 0,Screen.height, 0,Screen.width,isPortrait)
			webpage.receive = function(webView,message)		---页面委托
				if message.path == "agentshare" and message.rawMessage then
					local strTbl = string.split(message.rawMessage,"url=")
					if strTbl and string.len(strTbl[2] or "") > 0 then
						DownloadCachesMgr.Instance:LoadImage(strTbl[2],function(code,texture,localPicUrl)	--分享图片
							if localPicUrl then
								local title = "流水分享"
								local url = ""
								local description = ""
								shareHelper.doShare(nil,0,2,title,localPicUrl,url,description)
							end
						end)
					end
				elseif message.path == "closelaya" then
					if webpage and webpage.Hide then
						webpage:Hide()
					end
				end
			end
		if webpage then
			webpage:Show()
		end
	end
end