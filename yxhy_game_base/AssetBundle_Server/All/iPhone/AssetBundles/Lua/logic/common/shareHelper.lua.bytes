shareHelper = {}

--[[--
 * @Description: 
 * platform		1 微信，2 QQ，
 * shareType	0 微信/QQ好友，1朋友圈/空间，2微信收藏
 * contentType	1文本，2图片，3声音，4视频，5网页
 * title		"福建人自己的棋牌游戏"
 * filePath		""
 * url			
 * description 	"有闲你就来！福建本地的麻将游戏，最真实的在线十三水！就在有闲棋牌！"
 ]]

function shareHelper.doShare(platform,shareType,contentType,title,filePath,url,description,callback)
	Trace("-----------shareHelper.doShare--------------")
	local platform = platform or data_center.GetPlatform()
	if platform == LoginType.WXLOGIN then
		YX_APIManage.Instance:CheckWXInstall(function (msg)
			local msgNum = tonumber(msg) or 0;
			if msgNum == 1 then
				YX_APIManage.Instance:WeiXinShare(shareType,contentType,title,filePath,url,description,function (msg)
					Trace("onWeiXinShareCallBack------"..GetTblData(msg))
					shareHelper.ShareDoneReq(msg,callback)
				end)
			else
				UI_Manager:Instance():FastTip("微信未安装")
			end
		end)
	elseif platform == LoginType.QQLOGIN then
		YX_APIManage.Instance:CheckQQInstall(function (msg)
			Trace("CheckQQInstall-----" .. msg)
			local msgNum = tonumber(msg) or 0;
			if msgNum == 1 then
				if contentType == 5 then
					filePath = global_define.appConfig.qzoneShareIcon
				end
				YX_APIManage.Instance:QQShare(shareType,contentType,title,filePath,url,description,function (msg)
					Trace("onQQShareCallBack------"..GetTblData(msg))
					shareHelper.ShareDoneReq(msg,callback)
				end)
			else
				UI_Manager:Instance():FastTip("QQ未安装")
			end
		end)
	elseif 	platform == LoginType.YOUKE then		--游客开启微信分享
		YX_APIManage.Instance:WeiXinShare(shareType,contentType,title,filePath,url,description,function (msg)
			Trace("onWeiXinShareCallBack------"..GetTblData(msg))
			shareHelper.ShareDoneReq(msg,callback)
		end)
	end
end

function shareHelper.shareSucceed(callback,...)
	local msg = string.gsub(..., "\\/", "/")
	local retStr = ParseJsonStr(msg)
	local isSucceed = false
	if tonumber(retStr["errCode"]) == 0 then
		isSucceed = true
	elseif data_center.GetCurPlatform() == "IPhonePlayer" and tonumber(retStr["result"]) == 0 then
		isSucceed = true
	end
	if isSucceed and callback then
		callback(...)
	end
end

function shareHelper.ShareDoneReq(msg,callback)
	shareHelper.shareSucceed(function (msg)
		http_request_interface.ShareDone(function (msg)
			-- body
		end)
		if callback then
			callback()
		end
	end,msg)
end