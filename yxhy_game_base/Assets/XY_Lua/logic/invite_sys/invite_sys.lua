--require "logic/invite_sys/inviteConfig"

invite_sys = {}
local this = invite_sys
local clubInviteType = 
{
	JoinClub = 1,	--分享进入俱乐部
	JoinRoom = 2,	--俱乐部分享房间
}
-- 房间邀请

function this.inviteFriend(platform,_roomID, _gameName, _gameRule)
	--logError(_gameRule)
	local roomID = _roomID
	local gameName = _gameName
	local gameRule = _gameRule
	local shareStr = string.format(global_define.gameShareTitle, gameName,roomID)
	local shareType = 0
	local contentType = 5 
	local title = shareStr
	local filePath = ""
	local url = string.format(global_define.appConfig.MWInviteURL,roomID,data_center.GetLoginUserInfo().uid, 123)
	local description = gameRule
	Trace("inviteFriend------- url " .. url.." description:"..tostring(description))
	
	shareHelper.doShare(platform,shareType,contentType,title,filePath,url,description)
end


function this.inviteToClub(clubinfo,shareType,callback)
	if clubinfo == nil then
		return
	end
	local playerName = data_center.GetLoginUserInfo().nickname or ""
	playerName = string.urlencode(playerName)
	if tostring(Application.platform) == "IPhonePlayer" and data_center.GetPlatform() == LoginType.QQLOGIN then
		playerName = ""		--特殊处理bug
		Trace("playerName-------"..tostring(playerName))
	end
	local uid = data_center.GetLoginUserInfo().uid
	local positionStr = ""
	if clubinfo.position and clubinfo.position ~= 0 then
		positionStr = ClubUtil.GetLocationNameById(clubinfo.position)
	end
	local title = string.format(LanguageMgr.GetWord(9003,positionStr,clubinfo.cname))
	local gameName1 = GameUtil.GetGameName(clubinfo["gids"][1])
	local gameName2 = ""
	if clubinfo["gids"][2] then
		gameName2 = "、"..GameUtil.GetGameName(clubinfo["gids"][2])
	end
	local content = string.format(LanguageMgr.GetWord(9004,gameName1,gameName2))
	local shareType = shareType or 0
	local contentType = 5
	local filePath = ""
	local type = clubInviteType.JoinClub
	local autoEnter = 0
	if model_manager:GetModel("ClubModel"):IsClubCreater(clubinfo.cid) then
		autoEnter = 1
	end
	local stime = os.time()
	local paramStr = "id=%s&uid=%s&cid=%s&type=%s&autoEnter=%s&playerName=%s&stime=%s"
	local url = global_define.appConfig.MWBaseInviteURL .. string.format(paramStr, "", uid, clubinfo.cid, type, autoEnter, playerName, stime)
	Trace("inviteToClub------- url"..tostring(url))
	shareHelper.doShare(nil, shareType, contentType, title, filePath, url, content,callback)
end	

function this.inviteToRoom(_roomID, _gameName, _gameRule, cid)
	if cid == nil then
		return
	end
	local roomID = _roomID
	local gameName = _gameName
	local gameRule = _gameRule
	local shareStr = string.format(global_define.gameShareTitle, gameName,roomID)
	local shareType = 0
	local contentType = 5 
	local title = shareStr
	local filePath = ""
	local autoEnter = 0
	if model_manager:GetModel("ClubModel"):IsClubCreater(cid) then
		autoEnter = 1
		Trace("playerName-------"..tostring(playerName))
	end
	local playerName = data_center.GetLoginUserInfo().nickname or ""
	playerName = string.urlencode(playerName)
	if tostring(Application.platform) == "IPhonePlayer" and data_center.GetPlatform() == LoginType.QQLOGIN then
		playerName = ""		--特殊处理bug
	end
	local stime = os.time()
	local paramStr = "id=%s&uid=%s&cid=%s&type=%s&autoEnter=%s&playerName=%s&stime=%s"
	local url = global_define.appConfig.MWBaseInviteURL .. 
		string.format(paramStr,roomID,data_center.GetLoginUserInfo().uid, cid, clubInviteType.JoinRoom,autoEnter, playerName, stime)
	local description = gameRule
	Trace("inviteToRoom------- url " .. url.." description:"..tostring(description))
	
	shareHelper.doShare(nil,shareType,contentType,title,filePath,url,description)
end

function this.CheckClipBoardAndJoinRoom()
	YX_APIManage.Instance:getCopy(function (msg)
		--Trace("getCopy------"..GetTblData(msg))--GAME_LOG: {"text":"197376","result":0}
		local tab = nil 
		local msg = string.gsub(msg, "\\/", "/")
		if not pcall( function() tab = ParseJsonStr(msg) end) then
			return
		end
		local retStr = tab
		if retStr.text == nil then
			return
		end
		local roomN = string.match(tostring(retStr.text),"%d%d%d%d%d%d")
		if roomN == nil then
			return
		end	

		join_room_ctrl.GetRoomByRno(roomN, function(dataTbl)
			local title = LanguageMgr.GetWord(10230)
			local content, contentTbl = ShareStrUtil.GetRoomShareStr(dataTbl["roominfo"]["gid"],dataTbl["roominfo"],true)
			if contentTbl then
				local subTitle = LanguageMgr.GetWord(10049, GameUtil.GetGameName(dataTbl["roominfo"]["gid"]), string.gsub(contentTbl[1], "、", ""))
				contentTbl[1] = ""
				local contentStr = LanguageMgr.GetWord(10231)..table.concat(contentTbl)
				contentTbl = {title,subTitle,contentStr}
			end
			MessageBox.ShowYesNoBox(contentTbl,function()
				join_room_ctrl.JoinRoomByRno(dataTbl["roominfo"]["rno"])
			end)
		end, false, true , function(erno, estr)  
			-- 不是俱乐部成员特殊处理
			if erno == 1010007 then
				UIManager:FastTip(estr)
			end
		end)
	end)
end



function this.LoadMWParam()
	local s = YX_APIManage.Instance:read("temp.txt")
	if s == nil then
		return
	end
	local s = string.gsub(s,"\\/","/")
	--s = string.gsub(s,"\"","\\\"")
	local t = ParseJsonStr(s)
	
	--[[ 调试用
	t = {
		["cid"] = "15";
		["stime"] = "1519647135";
		["id"] = "355060";
		["type"] = "1";
		["autoEnter"] = "0";
		["uid"] = "4560168";
		["playerName"] = "胡汉三";
	}--]]

	--logError("LoadMWParam----------"..GetTblData(t))
	-- 房间号
	local roomId
	if t.id ~= nil then
		roomId = t.id
	elseif t.roomId ~= nil then
		roomId = t.roomId
	end

	local sType = t.type
	local cid =  t.cid
	local autoEnter = t.autoEnter or 0
	local shareUid = t.uid
	local playerName = t.playerName or ""
	playerName = string.urldecode(playerName)
	if tostring(Application.platform) == "IPhonePlayer" and data_center.GetPlatform() == LoginType.QQLOGIN then
		playerName = "您的好友"		--特殊处理bug
	end
	
	local stime = t.stime or 0
	if sType ~= nil then
		sType = tonumber(sType)
		cid = tonumber(cid or 0)
		autoEnter = tonumber(autoEnter)
	end

	-- 兼容旧版本 直接进房间
	if (sType ~= 1 and sType ~= 2) or cid == nil  or cid == "" then
		this.DirectJoinRoom(roomId)
	elseif sType == 1 then
		this.InviteToJoinClub(cid, shareUid, stime, autoEnter, playerName)
	else
		this.InviteToJoinRoom(cid, shareUid, stime, roomId, autoEnter, playerName)
	end

	YX_APIManage.Instance:deleteFile("temp.txt")
end


function this.InviteToJoinClub(cid, shareUid, stime, autoEnter, playerName)
	if not model_manager:GetModel("ClubModel"):IsClubMember(cid) then
		if autoEnter == 1 then		---直接申请通过流程
			this.JoinCreatorShareClub(cid,shareUid,stime,playerName)
		else						---等待申请通过流程
			this.JoinNonCreatorShareClub(cid,playerName)
		end
	else
		--UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10050))		---您已加入过该俱乐部,请勿重复加入
		local clubInfo = model_manager:GetModel("ClubModel").clubMap[cid]
		model_manager:GetModel("ClubModel"):SetCurrentClubInfo(clubInfo)
	end
end

function this.InviteToJoinRoom(cid, shareUid, stime, roomId, autoEnter, playerName)
	if not model_manager:GetModel("ClubModel"):IsClubMember(cid) then
		if autoEnter == 1 then
			this.JoinCreatorShareClub(cid,shareUid,stime,playerName,function()
				this.ShowJoinRoomInfo(roomId)
			end)
		else
			this.JoinNonCreatorShareClub(cid,playerName)
		end
	else
		local clubInfo = model_manager:GetModel("ClubModel").clubMap[cid]
		model_manager:GetModel("ClubModel"):SetCurrentClubInfo(clubInfo)
		this.ShowJoinRoomInfo(roomId)
	end
end

function this.DirectJoinRoom(roomId)
	if roomId ~= nil and roomId ~= "" then
		UI_Manager:Instance():ShowUiForms("waiting_ui")
        join_room_ctrl.JoinRoomByRno(tonumber(rid))
	end
end

function this.JoinCreatorShareClub(cid,shareUid,stime,playerName,callback)
	model_manager:GetModel("ClubModel"):ReqJoinShareClub(cid,shareUid,stime,function(msgTab)
		--logError("ReqJoinShareClub----------"..GetTblData(msgTab))
		
		if msgTab.ret == 0 then
			if callback then
				callback()
			end
		elseif msgTab.ret == 101 then	---该链接不是俱乐部会长分享，申请后方可加入
			this.JoinNonCreatorShareClub(cid,playerName)	
		elseif msgTab.ret == 102 then	---您已加入过该俱乐部,请勿重复加入
			model_manager:GetModel("ClubModel"):SetCurrentClubInfo(msgTab["clubinfo"])
		elseif msgTab.ret == 104 then	---此俱乐部链接已过有效期，申请后方可加入
			this.JoinNonCreatorShareClub(cid,playerName)
		else
			UI_Manager:Instance():FastTip(msgTab.msg)
		end
	end)
end

function this.JoinNonCreatorShareClub(cid,playerName)
	model_manager:GetModel("ClubModel"):ReqGetJoinClubInfoByCid(cid,function(clubInfo)
		--logError("ReqGetJoinClubInfoByCid"..GetTblData(clubInfo))
	
		 if clubInfo == nil then
			return
		 end
		 UI_Manager:Instance():ShowUiForms("InviteNoticeUI",nil,nil,clubInfo,playerName)
	end)
end

function this.ShowJoinRoomInfo(rno)
	-- http_request_interface.getRoomByRno(rno,function(str)
	-- 	local s = string.gsub(str,"\\/","/")  
	-- 	local t = ParseJsonStr(s)
	-- 	--logError("ShowJoinRoomInfo-----"..GetTblData(t))
		
	-- 	if t.ret == 0 then
	-- 		local title = LanguageMgr.GetWord(10049, GameUtil.GetGameName(t["data"]["gid"]))
	-- 		local content, contentTbl = ShareStrUtil.GetRoomShareStr(t["data"]["gid"],t["data"],true)
	-- 		if contentTbl then
	-- 			local subTitle = string.format("付费方式: %s   ", string.gsub(contentTbl[1], "、", ""))
	-- 			contentTbl[1] = ""
	-- 			local contentStr = table.concat(contentTbl)
	-- 			contentTbl = {title,subTitle,contentStr}
	-- 		end
	-- 		MessageBox.ShowYesNoBox(contentTbl,function()
	-- 			join_room_ctrl.JoinRoomByRno(t["data"]["rno"])
	-- 		end)
	-- 	else
	-- 		UI_Manager:Instance():FastTip(t.msg)
	-- 	end
		
	-- end)
	join_room_ctrl.GetRoomByRno(rno, function(t) 
		-- local title = LanguageMgr.GetWord(10049, GameUtil.GetGameName(t["roominfo"]["gid"]))
		-- local content, contentTbl = ShareStrUtil.GetRoomShareStr(t["roominfo"]["gid"],t["roominfo"],true)
		-- if contentTbl then
		-- 	local subTitle = string.format("付费方式: %s   ", string.gsub(contentTbl[1], "、", ""))
		-- 	contentTbl[1] = ""
		-- 	local contentStr = table.concat(contentTbl)
		-- 	contentTbl = {title,subTitle,contentStr}
		-- end
		-- MessageBox.ShowYesNoBox(contentTbl,function()
		-- 	join_room_ctrl.JoinRoomByRno(t["roominfo"]["rno"])
		-- end)

		--TER0327-label
		local title = LanguageMgr.GetWord(10230)
		local content, contentTbl = ShareStrUtil.GetRoomShareStr(t["roominfo"]["gid"],t["roominfo"],true)
		if contentTbl then
			local subTitle = LanguageMgr.GetWord(10049, GameUtil.GetGameName(t["roominfo"]["gid"]), string.gsub(contentTbl[1], "、", ""))
			contentTbl[1] = ""
			local contentStr = LanguageMgr.GetWord(10231)..table.concat(contentTbl)
			contentTbl = {title,subTitle,contentStr}
		end
		MessageBox.ShowYesNoBox(contentTbl,function()
			join_room_ctrl.JoinRoomByRno(t["roominfo"]["rno"])
		end)

	end)
end