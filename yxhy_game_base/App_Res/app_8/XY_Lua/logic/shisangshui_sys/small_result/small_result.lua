require "logic/shisangshui_sys/card_define"
require "logic/shisangshui_sys/large_result/large_result"
require "logic/shisangshui_sys/special_card_show/special_card_show"
require "logic/shisangshui_sys/card_data_manage"


small_result = ui_base.New()
local this = small_result

--计时间Lbl
local timeLbl
--最大等待时间
local leftTime = 30

local cardGrid = {}
local isEnterTotalResult = false
local fangzhuId
local timer_Elapse = nil
local NameByuid ={} ------uid————Name表

function this.Show(tbl)	
	local result = tbl._para		
	Trace("显示小结算界面")
	special_card_show.Hide()	----隐藏特殊牌型
	--	fangzhuId = card_data_manage.roomMasterUid	------房主ID
	fangzhuId = room_data.GetSssRoomDataInfo().owner_uid --房主ID
	Trace("房主ID：".. fangzhuId)
	local stRewards = result["rewards"]
	if stRewards == nil then
		Trace("stRewards == nil")
	end
	if this.gameObject==nil then
		this.gameObject=newNormalUI("game_80011/ui/small_result")
	else
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end	
	room_data.GetSssRoomDataInfo().cur_playNum = result["curr_ju"] +  1
	Trace("+++++++++++++++++++++++++++当前局++++++++++++++++++++"..tostring(room_data.GetSssRoomDataInfo().cur_playNum))
	if result["ju_num"] == result["curr_ju"] then
		isEnterTotalResult = true
		--shisangshui_play_sys.Uninitialize()	
	else
		isEnterTotalResult = false
	end
	this.LoadAllResult(stRewards)
end

--[[--
 * @Description: 逻辑入口  
 ]]
function this.Start()
	this.registerevent()
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
	room_data.SetReadyTime(0)
	
	if this.gameObject == nil then
		return
	else
		this.StopTimer()
		GameObject.Destroy(this.gameObject)		
	end
end

function this.LoadAllResult(result)
	local tbSort={}
	local selfId = data_center.GetLoginUserInfo().uid
	local ScoreUid = {}	  ----最高分——uid表
	for i = 1, 6 do
		if result[i] ~= nil then
			local number= player_seat_mgr.GetLogicSeatByStr(result[i]._chair)
			local userData =room_usersdata_center.GetTempUserByLogicSeat(tonumber(number))
			ScoreUid[tostring(result[i]._uid)] = result[i].all_score	
			NameByuid[tostring(result[i]._uid)] = userData.name
			Trace("uid:"..tostring(result[i]._uid).."-------name:"..tostring(userData.name))
				-------非主机的其他用户----------
			if selfId ~= result[i]._uid then	
				Trace("判断是否本机"..selfId.."???"..result[i]._uid)
				table.insert(tbSort,result[i])
				--------主机用户放在首位---------
			else	
				Trace("判断:"..selfId .. "等于" .. result[i]._uid)
				local NameLbl = componentGet(child(this.transform,"Panel/Self/user/namelbl"), "UILabel") ----用户名设置
				local IDLbl = componentGet(child(this.transform,"Panel/Self/user/IDlbl"), "UILabel")				
				IDLbl.text="ID:"..result[i]._uid			
				cardGrid = child(this.transform, "Panel/Self/user/cards")
				if cardGrid == nil then
					Trace("cardGrid == nil")
					return
				end				
				for k, v in ipairs(result[i].stCards) do
					local cardObj =  newNormalUI("game_80011/scene/card/"..tostring(v), cardGrid)
					if cardObj ~= nil then
					cardObj.transform.localScale = Vector3(0.45,0.45,0.45)
					componentGet(cardObj, "BoxCollider").enabled = false
					end
					if  room_data.GetSssRoomDataInfo().isChip == true and v == 40 then
						child(cardObj.transform,"ma").gameObject:SetActive(true)
						local maSpriteName = componentGet(child(cardObj.transform,"ma"),"UISprite")
						maSpriteName.depth = maSpriteName.depth + 1
						maSpriteName.spriteName = "guang"
						componentGet(child(cardObj.transform,"num"),"UISprite").depth = componentGet(child(cardObj.transform,"bg"),"UISprite").depth + 2
						componentGet(child(cardObj.transform,"color1"),"UISprite").depth = componentGet(child(cardObj.transform,"bg"),"UISprite").depth + 2
						componentGet(child(cardObj.transform,"color2"),"UISprite").depth = componentGet(child(cardObj.transform,"bg"),"UISprite").depth + 2
					else
		
					end
				end
				
				local tex_photo= componentGet(child(this.transform, "Panel/Self/user/picFrame"), "UITexture")
                Trace("----------------------------------主机头像show-----------------------------------------") 
				hall_data.getuserimage(tex_photo,2,room_usersdata_center.GetTempUserByLogicSeat(number).headurl)
                --hall_data.getuserimage(tex_photo,2,room_usersdata_center.GetUserByLogicSeat(number).headurl)
				NameLbl.text = NameByuid[tostring(result[i]._uid)]			
				if result[i].nSpecialType~=nil then
					local SpecialSprite=componentGet(child(this.transform, "Panel/Self/user/specialCard"), "UISprite")
					if result[i].nSpecialType ~=0 then
						Trace("特殊牌型索引"..result[i].nSpecialType)
						SpecialSprite.spriteName = result[i].nSpecialType	
						SpecialSprite.gameObject:SetActive(true)				
					else
						SpecialSprite.gameObject:SetActive(false)
					end
				else
					Trace("result["..i.."].nSpecialType=nil")
				end
				local ScoreLbl = componentGet(child(this.transform, "Panel/Self/user/scorelbl"), "UILabel")
				local negScoreLbl = componentGet(child(this.transform, "Panel/Self/user/negscorelbl"), "UILabel")
				local totalScores=result[i].all_score
				if totalScores<=0 then
					negScoreLbl.gameObject:SetActive(true)
					ScoreLbl.gameObject:SetActive(false)
					negScoreLbl.text =tostring(totalScores)
				else
					negScoreLbl.gameObject:SetActive(false)
					ScoreLbl.gameObject:SetActive(true)
					ScoreLbl.text ="+"..tostring(totalScores)
				end
				------------判断本机用户是否房主-----------------------
				local fangzhu = componentGet(child(this.transform, "Panel/Self/user/fangzhu"), "UISprite")	
				if selfId == fangzhuId then	
					fangzhu.gameObject:SetActive(true)
				else
					fangzhu.gameObject:SetActive(false)
				end
			end
		end
	end	
	ScorestUid = this.FindHighestByuid(ScoreUid)
	this.ShowHighest(selfId,ScorestUid,0)
	this.ShowOthersResult(tbSort)
end

--------------------显示客机用户的结算数据-----------------
function this.ShowOthersResult(tbSort)
	table.sort(tbSort,function (a,b) return a.all_score > b.all_score end)			
		for i=1,5 do
			if tbSort[i] ~= nil then 
				local NameLbl = componentGet(child(this.transform,"Panel/resultList/userGrid/user"..i.."/namelbl"), "UILabel") ----用户名设置
				local IDLbl = componentGet(child(this.transform,"Panel/resultList/userGrid/user"..i.."/IDlbl"), "UILabel")		
				IDLbl.text="ID:"..tostring(tbSort[i]._uid)
				cardGrid = child(this.transform, "Panel/resultList/userGrid/user"..i.."/cards")
				if cardGrid == nil then
					Trace("cardGrid == nil")
					return
				end
				
				for k, v in ipairs(tbSort[i].stCards) do
					local cardObj =  newNormalUI("game_80011/scene/card/"..tostring(v), cardGrid)
					if cardObj ~= nil then
					cardObj.transform.localScale = Vector3(0.45,0.45,0.45)
					componentGet(cardObj,"BoxCollider").enabled = false
					end
					if  room_data.GetSssRoomDataInfo().isChip == true and v == 40 then
						child(cardObj.transform,"ma").gameObject:SetActive(true)
						componentGet(child(cardObj.transform,"ma"),"UISprite").depth = componentGet(child(cardObj.transform,"bg"),"UISprite").depth + 1
						componentGet(child(cardObj.transform,"num"),"UISprite").depth = componentGet(child(cardObj.transform,"bg"),"UISprite").depth + 2
						componentGet(child(cardObj.transform,"color1"),"UISprite").depth = componentGet(child(cardObj.transform,"bg"),"UISprite").depth + 2
						componentGet(child(cardObj.transform,"color2"),"UISprite").depth = componentGet(child(cardObj.transform,"bg"),"UISprite").depth + 2
					end
				end
				local tex_photo = componentGet(child(this.transform, "Panel/resultList/userGrid/user"..i.."/picFrame"), "UITexture")
                Trace("--------------------------------客机头像show-------------------------------------------") 
                local number = player_seat_mgr.GetLogicSeatByStr(tbSort[i]._chair)   
                hall_data.getuserimage(tex_photo,2,room_usersdata_center.GetTempUserByLogicSeat(number).headurl)
				--hall_data.getuserimage(tex_photo,2,room_usersdata_center.GetTempUserByLogicSeat(number).headurl)
				--local userData = room_usersdata_center.GetTempUserByLogicSeat(tonumber(number))
                NameLbl.text = NameByuid[tostring(tbSort[i]._uid)]
				
				if tbSort[i].nSpecialType~=nil then
					local SpecialSprite=componentGet(child(this.transform, "Panel/resultList/userGrid/user"..i.."/specialCard"), "UISprite")
					if tbSort[i].nSpecialType ~=0 then
						Trace("特殊牌型索引"..tbSort[i].nSpecialType)
						SpecialSprite.spriteName = tbSort[i].nSpecialType
						SpecialSprite.gameObject:SetActive(true)					
					else
						SpecialSprite.gameObject:SetActive(false)
					end
				else
					Trace("tbSort["..i.."].nSpecialType=nil")
				end
				local ScoreLbl = componentGet(child(this.transform, "Panel/resultList/userGrid/user"..i.."/scorelbl"), "UILabel")
				local negScoreLbl = componentGet(child(this.transform, "Panel/resultList/userGrid/user"..i.."/negscorelbl"), "UILabel")
				local totalScores = tbSort[i].all_score
				if totalScores<=0 then
					negScoreLbl.gameObject:SetActive(true)
					ScoreLbl.gameObject:SetActive(false)
					negScoreLbl.text =tostring(totalScores)
				else
					negScoreLbl.gameObject:SetActive(false)
					ScoreLbl.gameObject:SetActive(true)
					ScoreLbl.text ="+"..tostring(totalScores)
				end
		-------------非本机用户显示房主标志-------------
				local fangzhu = componentGet(child(this.transform, "Panel/resultList/userGrid/user"..i.."/fangzhu"), "UISprite")
				if tbSort[i]._uid == fangzhuId then		
					fangzhu.gameObject:SetActive(true)
				else
					fangzhu.gameObject:SetActive(false)
				end
				this.ShowHighest(tbSort[i]._uid,ScorestUid,i)
			else
				Trace("------user"..i..".tbSort=nill------")
				local trans = child(this.transform, "Panel/resultList/userGrid/user"..i)
				trans.gameObject:SetActive(false)
			end
		end
		local userNum = #tbSort
		local selfPos = child(this.transform, "Panel/Self")
		local other1Pos = child(this.transform, "Panel/resultList")
		if userNum == 1 then
			selfPos.transform.localPosition =  Vector3(255,0,0)	
			other1Pos.transform.localPosition =  Vector3(660,0,0)	
		elseif userNum == 2 then
			selfPos.transform.localPosition =  Vector3(95,0,0)
			other1Pos.transform.localPosition =  Vector3(466,0,0)
		else
			--other1Pos.gameObject:AddComponent(typeof(ScrollViewMoveFixed))
		end
end


--注册事件
function this.registerevent()
	Trace("注册事件")
	timeLbl = componentGet(child(this.transform, "Panel/ready/readylbl"), "UILabel")
	timeLbl.text = "继续"
	--local nowTime = os.time()
	--local timeo  = math.floor(room_data.GetReadyTime() - os.time() -this.msgReceiveTime)
	--[[if timeo > 0 then
		this.StartTimer(time or 30)
	end--]]
	this.BtnClickEvent()
end

function this.SetTimerStart(timeo)
	if(timer_Elapse == nil) then
		this.StartTimer(timeo)
	end
end


function this.BtnClickEvent()
	local btn_ready = child(this.transform, "Panel/ready")
	if btn_ready ~= nil then
		addClickCallbackSelf(btn_ready.gameObject, this.ReadyClick, this)
	end
end

---------------------------点击事件-------------------------
function this.ReadyClick(obj)
	ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/anjianxuanze")  ---按键声音
	this.Hide()
	Trace("结算完成： "..tostring(isEnterTotalResult))
	if isEnterTotalResult then
		Notifier.dispatchCmd(cmdName.GAME_SOCKET_LUMP_SUM, nil)
	else
		this.reset()
	end
	Trace("-----ReadyClick-----")
end

function this.reset()
	Trace("reset game")
	shisangshui_play_sys.ReadyGameReq()--发送准备好的状态进入下一局
end

------最高分加特技------
function this.ShowHighest(uid,ScorestuidList,IS)	-----IS=0 ：本机用户
	--local winCrown
	local winFrame
	for i=1,#ScorestuidList do
		if uid == tonumber(ScorestuidList[i]) then
			if IS == 0 then
				--winCrown=componentGet(child(this.transform, "Panel/user/crown"), "UISprite")
				winFrame=componentGet(child(this.transform, "Panel/Self/user/frame"), "UISprite")
				winFrame.gameObject:SetActive(false)
			else
				--winCrown=componentGet(child(this.transform, "Panel/userGrid/user"..IS.."/crown"), "UISprite")
				winFrame=componentGet(child(this.transform, "Panel/resultList/userGrid/user"..IS.."/frame"), "UISprite")
				winFrame.gameObject:SetActive(false)
			end
			--winCrown.gameObject:SetActive(true)
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
function this.StartTimer(time)
	Trace("定时器")
	if isEnterTotalResult ~= true then
		if(time <= 0) then
			timeLbl.text = "继续"
			return
		end
		timeLbl.text = (" 继续（" ..math.floor(time).."s）")
	end
	leftTime = time
	timer_Elapse = Timer.New(this.OnTimer_Proc,1,time)
	timer_Elapse:Start()
end

function this.OnTimer_Proc()
	if(leftTime >= 1)then
		leftTime = leftTime -1
		timeLbl.text = (" 继续（" .. math.floor(leftTime).."s）")
	else
		timeLbl.text = (" 继续")
	end
	
	if leftTime <= 0 and isEnterTotalResult ~= true then
		--this.ReadyClick()
		timeLbl.text = (" 继续")
		this.StopTimer()
		return
	end
end

function this.StopTimer()
	if timer_Elapse ~= nil then
		timer_Elapse:Stop()
		timer_Elapse = nil
	end
end