require "logic/shisangshui_sys/card_data_manage"


large_result =ui_base.New()
local this =large_result


local fangzhuId = nil
local SeatStrByuid = {}
local ScorestUid = {}

function this.Show()	
	place_card.Hide()
	small_result.Hide()
	common_card.Hide()
		
	if this.gameObject == nil then
		--require "logic/shisangshui_sys/large_result/large_result"
		this.gameObject = newNormalUI("game_80011/ui/large_result")
	else
		this.gameObject:SetActive(true)
	end
	
	roomdata_center.isStart = false
end

--[[--
 * @Description: 逻辑入口  
 ]]
function this.Start()
	this.registerevent()

	Trace("总结算")
	if room_data.GetRid() == nil then
		Trace("---room_data.rid == nil-----")
    else
		---根据房id查找房间信息 {"rid":房号}
		http_request_interface.getRoomByRid(room_data.GetRid(), 1, this.OnGetRoomReturnDate) 
	end	
	this:RegistUSRelation()
end

--[[--
 * @Description: 销毁  
 ]]
function this.OnDestroy()
	this.gameObject = nil
	this:UnRegistUSRelation() 
end
	

function this.Hide()
	if this.gameObject == nil then
		return
	else
		GameObject.Destroy(this.gameObject)
	end
end

--注册事件
function this.registerevent()
	local endbtn = child(this.transform, "Panel/endbtn")
	if endbtn ~= nil then
		UIEventListener.Get(endbtn.gameObject).onClick = this.EndBtnClick
	end
    local btn_share=child(this.transform,"Panel/sharebtn")
    if btn_share ~= nil then
		UIEventListener.Get(btn_share.gameObject).onClick = this.ShareClick
	end
end

function this.LoadAllResult(result)
	--fangzhuId = card_data_manage.roomMasterUid
	fangzhuId =  room_data.GetSssRoomDataInfo().owner_uid  --房主的uid
	local highestNum ={}  ----记录最高分index
	local tbSort = {}
	local ScoreUid = {}	  ----最高分——uid表
	local selfId = data_center.GetLoginUserInfo().uid
	for k,v in pairs(result) do
		if v ~= nil then	
			--local Seat = player_seat_mgr.GetLogicSeatByStr(k)
			ScoreUid[tostring(v.uid)] = v.all_score	
				-------非主机的其他用户----------
			if selfId ~= v.uid then	
				Trace("总结算判断是否本机"..selfId.."???"..v.uid)
				SeatStrByuid[tostring(v.uid)] = tostring(k)   ------uid获取Str座位	
				table.insert(tbSort,v)
				--------主机用户放在首位---------
			else
				local trans = child(this.transform, "Panel/user")
				trans.gameObject:SetActive(true)
				-----------------总结算用户信息-----------------------
				local obj1 = child(this.transform,"Panel/user/IDlbl")
				local IDLbl = componentGet(obj1, "UILabel")
				local obj2 = child(this.transform,"Panel/user/namelbl")
				local NameLbl = componentGet(obj2, "UILabel")
			
				-----------------总结算获胜情况-----------------------		
				local winLbl = componentGet(child(this.transform,"Panel/user/winState/count1"), "UILabel")
				local shotLbl = componentGet(child(this.transform,"Panel/user/winState/count2"), "UILabel")
				local allshotLbl = componentGet(child(this.transform,"Panel/user/winState/count3"), "UILabel")
				local specialLbl = componentGet(child(this.transform,"Panel/user/winState/count4"), "UILabel")
				local tex_photo= componentGet(child(this.transform, "Panel/user/picFrame"), "UITexture")
				
				--hall_data.getuserimage(tex_photo,2,room_usersdata_center.GetTempUserByLogicSeat(Seat).headurl)
				Trace("name:"..v.nickname.."img.url:"..v["img"].url)
				hall_data.getuserimage(tex_photo,v["img"].type,v["img"].url)
				--[[if (v["img"].type == 2) then
					small_result.GetHeadPic(tex_photo,v["img"].url)
				else
					small_result.GetHeadPic(tex_photo,headurl)	----本地头像暂写死
				end--]]
				Trace("----------------------大结算头像-------------------")
				
				IDLbl.text = "ID:"..v.uid
				NameLbl.text = v.nickname
				local score = v["score"]
				for i = 1, #score do
					if score[i]["nWinNums"] ~= nil then
						winLbl.text = score[i]["nWinNums"] .."次"
					end
					if score[i]["nShootNums"] ~= nil then
						shotLbl.text = score[i]["nShootNums"] .."次"
					end
					if score[i]["nAllShootNums"] ~= nil then
						allshotLbl.text = score[i]["nAllShootNums"] .."次"
					end
					if score[i]["nSpecialNums"] ~= nil then
						specialLbl.text = score[i]["nSpecialNums"] .."次"
					end
				end
				local reduceScoreLbl = componentGet(child(this.transform, "Panel/user/winState/negScore"), "UILabel")
				local addScoreLbl = componentGet(child(this.transform, "Panel/user/winState/posScore"), "UILabel")
				
				local totalScores = v.all_score	
				if totalScores <= 0 then
					reduceScoreLbl.text = tostring(totalScores)
					reduceScoreLbl.gameObject:SetActive(true)
					addScoreLbl.gameObject:SetActive(false)
				else
					addScoreLbl.text = "+"..totalScores
					reduceScoreLbl.gameObject:SetActive(false)
					addScoreLbl.gameObject:SetActive(true)
				end
				------------判断本机用户是否房主-----------------------
				local fangzhu=componentGet(child(this.transform, "Panel/user/fangzhu"), "UISprite")
				if selfId == fangzhuId then	
					fangzhu.gameObject:SetActive(true)
				else
					fangzhu.gameObject:SetActive(false)
				end
			end
		else
			Trace("result" ..i.. "= nil")
		end		
	end
	ScorestUid = this.FindHighestByuid(ScoreUid) 		----获取最高分的uid
	-------------本机用户显示最高分特技-------------
	this.ShowHighest(selfId,ScorestUid,0)
	this.ShowOthersResult(tbSort)
end
					
--------------------非主机用户结算信息----------------------			
function this.ShowOthersResult(result)
	table.sort(result,function (a,b) return a.all_score > b.all_score end)	
	for k, v in ipairs(result) do
		--local Index = SeatStrByuid[tostring(v.uid)]
		--local i = player_seat_mgr.GetLogicSeatByStr(Index)	
		if v ~= nil then	
			Trace("总结算数据单条"..tostring(k))			
			local trans = child(this.transform, "Panel/userGrid/user"..k)
			trans.gameObject:SetActive(true)
							-----------------总结算用户信息-----------------------
			local obj1 = child(this.transform,"Panel/userGrid/user"..k.."/IDlbl")
			local IDLbl = componentGet(obj1, "UILabel")
			local obj2 = child(this.transform,"Panel/userGrid/user"..k.."/namelbl")
			local NameLbl = componentGet(obj2, "UILabel")
			
							-----------------总结算获胜情况-----------------------		
			local winLbl = componentGet(child(this.transform,"Panel/userGrid/user"..k.."/winState/count1"), "UILabel")
			local shotLbl = componentGet(child(this.transform,"Panel/userGrid/user"..k.."/winState/count2"), "UILabel")
			local allshotLbl = componentGet(child(this.transform,"Panel/userGrid/user"..k.."/winState/count3"), "UILabel")
			local specialLbl = componentGet(child(this.transform,"Panel/userGrid/user"..k.."/winState/count4"), "UILabel")
			local tex_photo= componentGet(child(this.transform, "Panel/userGrid/user"..k.."/picFrame"), "UITexture")
            Trace("---------------------------------------------------------------------------")    
            Trace("name:"..v.nickname.."img.url:"..v["img"].url)
            --Trace(i.."tex_photo.name")
            --hall_data.getuserimage(tex_photo,2,room_usersdata_center.GetTempUserByLogicSeat(i).headurl)
			hall_data.getuserimage(tex_photo,v["img"].type,v["img"].url)
			--[[if (v["img"].type == 2) then
					small_result.GetHeadPic(tex_photo,v["img"].url)
				else
					small_result.GetHeadPic(tex_photo,headurl)	----本地头像暂写死
				end--]]
			Trace("----------------------大结算头像-------------------")
			
			IDLbl.text = "ID:"..v.uid
			NameLbl.text = v.nickname
			local score = v["score"]
			for i = 1, #score do
				if score[i]["nWinNums"] ~= nil then
					winLbl.text = score[i]["nWinNums"] .."次"
				end
				if score[i]["nShootNums"] ~= nil then
					shotLbl.text = score[i]["nShootNums"] .."次"
				end
				if score[i]["nAllShootNums"] ~= nil then
					allshotLbl.text = score[i]["nAllShootNums"] .."次"
				end
				if score[i]["nSpecialNums"] ~= nil then
					specialLbl.text = score[i]["nSpecialNums"] .."次"
				end
			end
			local reduceScoreLbl = componentGet(child(this.transform, "Panel/userGrid/user"..k.."/winState/negScore"), "UILabel")
			local addScoreLbl = componentGet(child(this.transform, "Panel/userGrid/user"..k.."/winState/posScore"), "UILabel")
			
			local totalScores = v.all_score	
			if totalScores <= 0 then
				reduceScoreLbl.text = tostring(totalScores)
				reduceScoreLbl.gameObject:SetActive(true)
				addScoreLbl.gameObject:SetActive(false)
			else
				addScoreLbl.text ="+"..totalScores
				reduceScoreLbl.gameObject:SetActive(false)
				addScoreLbl.gameObject:SetActive(true)
			end
			-------------非本机用户显示房主标志-------------
			local fangzhu = componentGet(child(this.transform, "Panel/userGrid/user"..k.."/fangzhu"), "UISprite")
			if v.uid == fangzhuId then		
				fangzhu.gameObject:SetActive(true)
			else
				fangzhu.gameObject:SetActive(false)
			end
			-------------非本机用户显示最高分特技-------------
			this.ShowHighest(v.uid,ScorestUid,k)
		end
	end
	-------------居中控制-------------
	local userNum = #result
	local selfPos = child(this.transform, "Panel/user")
	local other1Pos = child(this.transform, "Panel/userGrid")
	local grid = componentGet(child(this.transform,"Panel/userGrid"), "UIGrid")
	grid.enabled = true
	if userNum == 1 then
		selfPos.transform.localPosition =  Vector3(-110,-6,0)				
	elseif userNum == 2 then
		selfPos.transform.localPosition =  Vector3(-213,-6,0)
		other1Pos.transform.localPosition =  Vector3(102,-6,0)
	elseif userNum == 3 then
		selfPos.transform.localPosition =  Vector3(-314,-6,0)		
	elseif userNum == 4 then
		selfPos.transform.localPosition =  Vector3(-422,-6,0)
	else
		return
	end
end

---------http回调处理--------
function this.OnGetRoomReturnDate(str)
	local s=string.gsub(str, "\\/", "/")
	Trace("-------this.OnGetRoomReturnDate-------"..tostring(s))
    local t=ParseJsonStr(s)
    if tonumber(t.ret)~=0 then
        return
    end
	
	local reward = t["data"].accountc.rewards
	if reward == nil then
		Trace("reward == nil")
	else
		Trace("总结算"..GetTblData(reward))
		this.LoadAllResult(reward)
	end
end

function this.EndBtnClick(obj)
	ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/anjianxuanze")  ---按键声音
	this.Hide()
	shisangshui_play_sys.LeaveReq()
end

function this.ShareClick(obj)
	ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/anjianxuanze")  ---按键声音
    Trace("share")
    YX_APIManage.Instance:GetCenterPicture("screenshot.png")
    YX_APIManage.Instance.onfinishtx = function(tx) 
        local shareType = 0--0微信好友，1朋友圈，2微信收藏
        local contentType = 2 --1文本，2图片，3声音，4视频，5网页
        local title = "我在测试"  
        local filePath = YX_APIManage.Instance:onGetStoragePath().."screenshot.png"
        local url = "http://connect.qq.com/"
        local description = "test"
        YX_APIManage.Instance:WeiXinShare(shareType,contentType,title,filePath,url,description)
    end
end

------最高分加特技------
function this.ShowHighest(uid,ScorestuidList,IS)	-----IS=0 ：本机用户
	local winCrown
	local winFrame
	for i=1,#ScorestuidList do
		if uid == tonumber(ScorestuidList[i]) then
			if IS == 0 then
				winCrown=componentGet(child(this.transform, "Panel/user/crown"), "UISprite")
				winFrame=componentGet(child(this.transform, "Panel/user/frame"), "UISprite")
				winCrown.gameObject:SetActive(false)
				winFrame.gameObject:SetActive(false)
			else
				winCrown=componentGet(child(this.transform, "Panel/userGrid/user"..IS.."/crown"), "UISprite")
				winFrame=componentGet(child(this.transform, "Panel/userGrid/user"..IS.."/frame"), "UISprite")
				winCrown.gameObject:SetActive(false)
				winFrame.gameObject:SetActive(false)
			end
			winCrown.gameObject:SetActive(true)
			winFrame.gameObject:SetActive(true)
		end
	end
end

----------获取最高分的uid表------------
function this.FindHighestByuid(ScoreUid)
	local Temp = 0
	local higestUid = 0
	local ScorestuidList = {}
	for k,v in pairs(ScoreUid) do
		if v > Temp then
			Temp = v
			higestUid = k
		end	
	end
	table.insert(ScorestuidList,higestUid)
	for k,v in pairs(ScoreUid) do
		if k ~= higestUid and v == Temp and v > 0 then
			table.insert(ScorestuidList,k)
		end	
	end
	return ScorestuidList
end
