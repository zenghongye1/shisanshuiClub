
local base = require "logic/poker_sys/common/poker_player_ui_base"
local sangong_player_ui = class("sangong_player_ui", base)

function sangong_player_ui:InitWidget()
	base.InitWidget(self)
    --设置金币
	self.roomCardLabel = subComponentGet(self.transform, "bg/roomCard/roomCardNum", typeof(UILabel))
	self:SetRoomCardNum(0)
	-- 花牌图标
	self.huaPoint = child(self.transform, "bg/roomCard")
	
	--庄家
	self.banker = child(self.transform, "bg/head/banker")
	if self.banker~=nil then
	   self.banker.gameObject:SetActive(false)
	end
	--房主
	self.fangzhu = child(self.transform, "bg/head/fangzhu")
	if self.fangzhu~=nil then
	   self.fangzhu.gameObject:SetActive(false)
	end
	--托管
	self.machine = child(self.transform, "bg/head/machine")
	if self.machine~=nil then
	   self.machine.gameObject:SetActive(false)
	end
	--离线
	self.offline = child(self.transform, "bg/head/offline")
	if self.offline~=nil then
	   self.offline.gameObject:SetActive(false)
	end
	
	--金币
	self.score = child(self.transform, "bg/score/scorelabel")
	if self.score ~= nil then
		--self.score.gameObject:SetActive(false)
		self:SetScore(self.all_score)
	end
	--昵称
	self.name = child(self.transform, "bg/name")
	--准备状态
	self.readystate = componentGet(child(self.transform, "bg/obj/readystate"),"UISprite")
	if self.readystate~=nil then
	   self.readystate.gameObject:SetActive(false)
	end
	
	--显示正数总分
	self.positiveLabel = child(self.transform,"bg/pao/positiveLabel")
	if self.positiveLabel ~= nil then
		self.positiveLabel.gameObject:SetActive(false)
	end
	
	--显示负数总分
	self.negativeLabel = child(self.transform,"bg/pao/negativeLabel")
	if self.negativeLabel ~= nil then
		self.negativeLabel.gameObject:SetActive(false)
	end
	
	self.pao = child(self.transform,"bg/pao")
	
	--显示水庄倍数
	self.beishuLabel = child(self.transform,"bg/xiazhu/beishuLabel")
	self.beishuBg = child(self.transform,"bg/xiazhu")
	if self.beishuLabel ~= nil then
		self.beishuLabel.gameObject:SetActive(false)
		self.beishuBg.gameObject:SetActive(false)
	end
	self.beishuTypeSprite = componentGet(child(self.transform,"bg/xiazhu/sprite").transform,"UISprite")

	self.shoot = child(self.transform, "bg/obj/shoot")

	self.shootHole = {}
	self.shootHole[1] = child(self.transform, "bg/obj/shootHole1")
	self.shootHole[2] = child(self.transform, "bg/obj/shootHole2")
	self.shootHole[3] = child(self.transform, "bg/obj/shootHole3")
	
	 --聊天
	self.chat_root = child(self.transform,"bg/chat")
	if self.chat_root~=nil then
		self.chat_root.gameObject:SetActive(true)
	end
	self.chat_img = child(self.chat_root,"img_root")
	if self.chat_img~=nil then
		self.chat_img.gameObject:SetActive(true)
	end
	self.chat_img_sprite = child(self.chat_img,"img")
	if self.chat_img_sprite ~=nil then
		self.chat_img_sprite.gameObject:SetActive(false)
	end
	-- self.chat_text_root = child(self.chat_root,"text_root")
	-- if self.chat_text_root~=nil then
	-- 	self.chat_text_root.gameObject:SetActive(true)
	-- 	for i=0,self.chat_text_root.transform.childCount-1 do
	-- 		local child = self.chat_text_root.transform:GetChild(i)
	-- 		if child~=nil then
	-- 			child.gameObject:SetActive(false)
	-- 		end
	-- 	end
	-- end
	self.chat_text = child(self.chat_root,"text_root")
	if self.chat_text then
		self.chat_text.gameObject:SetActive(false)
	    self.chat_text_label = child(self.chat_text,"msg")
	end

	-- self.chatSoundRoot = child(self.chat_root,"sound_root")
	-- if self.chatSoundRoot~=nil then
	-- 	self.chatSoundRoot.gameObject:SetActive(true)
	-- 	for i=0,self.chatSoundRoot.transform.childCount-1 do
	-- 		local child = self.chatSoundRoot.transform:GetChild(i)
	-- 		if child~=nil then
	-- 			child.gameObject:SetActive(false)
	-- 		end
	-- 	end
	-- end
	self.chat_sound = child(self.chat_root,"sound_root")
	if self.chat_sound then
		self.chat_sound.gameObject:SetActive(false)
	end

--[[	if self.transform.gameObject.name == "Player1" then
		self.seat = 1	
	elseif self.transform.gameObject.name == "Player2" then
		self.seat = 2
	elseif self.transform.gameObject.name == "Player3" then
		self.seat = 3
	elseif self.transform.gameObject.name == "Player4" then
		self.seat = 4		
	elseif self.transform.gameObject.name == "Player5" then
		self.seat = 5		
	elseif self.transform.gameObject.name == "Player6" then
		self.seat = 6		
	end--]]
	

	
	--抢庄，搓牌状态
--	self.state_before = componentGet(child(self.transform, "bg/state/state_before"),"UISprite")
--	self.state_before.gameObject:SetActive(false)
	--庄家的外光圈
	self.biankuang = child(self.transform,"bg/head/biankuang")
	self.biankuang.gameObject:SetActive(false)

end

function sangong_player_ui:SetBianKuang(IsShow)
	self.biankuang.gameObject:SetActive(IsShow)
end

function sangong_player_ui:SetState(IsShow,state)
	local isShow = IsShow
	if state ~= nil then
		self.readystate.spriteName = state
		self.readystate:MakePixelPerfect()
	else
		isShow = false
	end
	self.readystate.gameObject:SetActive(isShow)
	
end

function sangong_player_ui:SetScore(score)
	if self.scorelabel == nil then
		self.scorelabel = self.score.gameObject:GetComponent(typeof(UILabel))
	end
	if score == nil then score = 0 end
	self.all_score =  tonumber(self.all_score) + tonumber(score)
	
--	self.scorelabel.text = score
	self.scorelabel.text =  tostring(self.all_score)
end
	
	function sangong_player_ui:AddScore(score)
		if self.scorelabel==nil then
			self.scorelabel = self.score.gameObject:GetComponent(typeof(UILabel))
		end
		if score == nil then score = 0 end
		self.all_score =  score
		self.scorelabel.text =  tostring(score)
	end
	
	function sangong_player_ui:SetTotalPoints(points)
		self.positiveLabel.gameObject:SetActive(false)
		self.negativeLabel.gameObject:SetActive(false)
		if points ~= nil then
			if points > 0 then
				local pointsLabel = self.positiveLabel.gameObject:GetComponent(typeof(UILabel))
				pointsLabel.text = "+"..tostring(points)
				componentGet(self.positiveLabel,"TweenPosition"):ResetToBeginning ()
				self.positiveLabel.gameObject:SetActive(true)
				componentGet(self.positiveLabel,"TweenPosition").enabled =true
			else
				local negativeLabel = self.negativeLabel.gameObject:GetComponent(typeof(UILabel))
				negativeLabel.text = tostring(points)
				componentGet(self.negativeLabel,"TweenPosition"):ResetToBeginning ()
				self.negativeLabel.gameObject:SetActive(true)
				componentGet(self.negativeLabel,"TweenPosition").enabled =true
			end
		end
	end
	
	function sangong_player_ui:HideTotalPoints()
		if self.positiveLabel == nil then
			self.positiveLabel = child(self.transform,"bg/pao/positiveLabel")
		end
		
		if self.negativeLabel == nil then
			self.negativeLabel = child(self.transform,"bg/pao/negativeLabel")
		end
		self.positiveLabel.gameObject:SetActive(false)
		self.negativeLabel.gameObject:SetActive(false)
		self.positiveLabel.localPosition=Vector3(0,0,0)
		self.negativeLabel.localPosition=Vector3(0,0,0)	
	end
	
	function sangong_player_ui:SetBeiShu(beishu,beishuType)
		local beishuLabel = self.beishuLabel.gameObject:GetComponent(typeof(UISprite))
	--	beishuLabel.text = tostring(beishu)
		beishuLabel.spriteName = niuniu_rule_define.SUB_BULL_SCORE[beishu]
		self.beishuLabel.gameObject:SetActive(true)
		self.beishuBg.gameObject:SetActive(true)
		if beishuType == "分" then
			self.beishuTypeSprite.spriteName = "room_niu_04"
		elseif beishuType == "倍" then
			self.beishuTypeSprite.spriteName = "room_niu_03"
		end
	end
	
	function sangong_player_ui:HideBeiShu()
		self.beishuLabel.gameObject:SetActive(false)
		self.beishuBg.gameObject:SetActive(false)
	end
	
	function sangong_player_ui:SetRoomCardNum( num )
		if self.roomCardLabel ~= nil then
			self.roomCardLabel.text = "X" .. num
		end
	end


	--设置昵称
	function sangong_player_ui:SetName( name )
		if self.namelabel==nil then
			self.namelabel = self.name.gameObject:GetComponent(typeof(UILabel))
		end
		self.namelabel.text = name
	end

	--设置头像
	function sangong_player_ui:SetHead( url )
		HeadImageHelper.SetImage(self.headTexture,2,url)
	end
	
	--设置VIP等级，0不显示
	function sangong_player_ui:SetVIP(level)
		-- if level>0 then
		-- 	self.vip.gameObject:SetActive(true)
		-- else
		-- 	self.vip.gameObject:SetActive(false)
		-- end
	end

	--显示玩家用户
	function sangong_player_ui:Show( usersdata, viewSeat )
		self.transform.gameObject:SetActive(true)
		self.viewSeat = viewSeat
		self.userdata = usersdata
		self.logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(self.viewSeat)
		self:SetName(usersdata.name)
		self:SetHead(usersdata.headurl)
		self:SetMachine(false)
		self:SetFangzhu(usersdata.owner)
		if (self.userdata.saved ~= nil) then
			gps_data.SetGpsData(usersdata.headurl,2,self.position_index,self.viewSeat,self.userdata.saved)
		end
	end

	function sangong_player_ui:Hide()
		gps_data.RemoveOne(self.position_index)
		self.transform.gameObject:SetActive(false)
		self:SetOffline(false)
	end

	--设置准备状态
	function sangong_player_ui:SetReady( isReady )
		if isReady == true then
			self.readystate.spriteName = "yizhunbei"
			self.readystate:MakePixelPerfect()
		end
		self.readystate.gameObject:SetActive(isReady or false)
	end
	
	--设置准备按钮的坐标位置
	function sangong_player_ui:SetReadyLocalPosition(x,y)
		self.readystate.gameObject.transform.localPosition = Vector3(x,y,0)
	end
	
function sangong_player_ui:SetXiaZhuLocalPosition(x,y)
	self.beishuBg.gameObject.transform.localPosition = Vector3(x,y,0)
end

function sangong_player_ui:SetPaoAnchorLocalPosition(x,y)
	self.pao.gameObject.transform.localPosition = Vector3(x,y,0)
end

	-- --设置聊天消息坐标位置
	-- function sangong_player_ui:SetChatTextLocalPosition(index,x,y)

	-- 	--坐标调整
	-- 	if self.transform.localPosition.x >30 then
	-- 		if self.transform.localPosition.y >30 then
	-- 			index = 2
	-- 			x = -220
	-- 			y = -50
	-- 		else
	-- 			index = 2
	-- 			x = -220
	-- 			y = 0
	-- 		end
	-- 	else
	-- 		if self.transform.localPosition.y <-30 then
	-- 			index = 1
	-- 			x = 180
	-- 			y = 120
	-- 		else
	-- 			index = 4
	-- 			x = 220
	-- 			y = 0
	-- 		end
	-- 	end

	-- 	self.chat_text = child(self.chat_text_root,"text_root"..tostring(index))
	--     if self.chat_text~=nil then
	--     	self.chat_text.gameObject:SetActive(false)

	--     	self.chat_text.transform.localPosition = Vector3.New(x,y,0)
	--     end
	--     self.chat_text_label = child(self.chat_text,"msg")
	-- end

	-- --设置语音消息坐标位置
	-- function sangong_player_ui:SetChatSoundLocalPosition(index,x,y)

	-- 	--坐标调整
	-- 	if self.transform.localPosition.x >30 then
	-- 		index = 2
	-- 		x = 50
	-- 		y = 50
	-- 	else
	-- 		if self.transform.localPosition.y <-30 then
	-- 			index = 1
	-- 			x = 220
	-- 			y = 150
	-- 		else
	-- 			index = 3
	-- 			x = 240
	-- 			y = 50
	-- 		end
	-- 	end
		
	-- 	self.chat_sound = child(self.chatSoundRoot,"sound_root"..tostring(index))
	--     if self.chat_sound~=nil then
	--     	self.chat_sound.gameObject:SetActive(false)
	--     	self.chat_sound.transform.localPosition = Vector3.New(x,y,0)
	--     end
	-- end

	--设置庄家
	function sangong_player_ui:SetBanker(isBanker)
		self.banker.gameObject:SetActive(isBanker or false)
		self:SetBianKuang(isBanker or false)
		if isBanker then
			local effect = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_zhuang",1)
			effect.transform:SetParent(self.banker.gameObject.transform,false)
			Utils.SetEffectSortLayer(effect.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
		end
	end

	--设置房主
	function sangong_player_ui:SetFangzhu(isFangzhu)
		self.fangzhu.gameObject:SetActive(isFangzhu or false)
	end
	
	--设置下跑
	function sangong_player_ui:SetPao(num)
		-- self.pao.gameObject:SetActive(true)
		-- if self.paoLabel_comp == nil then
		-- 	self.paoLabel_comp = self.paoLabel:GetComponent(typeof(UILabel))
		-- end
		-- self.paoLabel_comp.text = "x"..num
	end

	function sangong_player_ui:HidePao()
		-- self.pao.gameObject:SetActive(false)
	end

	--设置托管
	function sangong_player_ui:SetMachine(isMachine)
		self.machine.gameObject:SetActive(isMachine or false)
	end

	--设置离线
	function sangong_player_ui:SetOffline(isOffline)
		self.offline.gameObject:SetActive(isOffline or false)
	end

	function sangong_player_ui:GetHuaPointPos()
		return self.huaPoint.position
	end
	
	function sangong_player_ui:ShootTran()
		return self.shoot
	end
	
	function sangong_player_ui:ShootHoleTran(index)
		if index <= 3 then
			return self.shootHole[index]
		end
		return nil
	end
	
	local chatImgAnimationTbl = {
			["1"]="01_feiwen",["2"]="02_deyi",["3"]="03_haose",["4"]="04_tianping",["5"]="05_shaxiao",
			["6"]="06_paoxiao",["7"]="07_shuashuai",["8"]="08_chaoxiao",["9"]="09_xinsui",["10"]="10_daku",
			["11"]="11_tongku",["12"]="12_weiquku",["13"]="13_benkui",["14"]="14_tu",["15"]="15_jingdiaoya",
			["16"]="16_qituxue",["17"]="17_nibuxing",["18"]="19_qidao",["19"]="20_touyun",["20"]="22_bishi",
			["21"]="23_maohan",["22"]="24_zaijian",["23"]="25_gun",["24"]="26_kan",["25"]="27_jingkong",
			["26"]="28_zhuangpingmu",
		}
	
--设置聊天
function sangong_player_ui:SetChatImg(content)
	local renderQueue = 0
	local nameLabel = subComponentGet(self.transform, "bg/name", typeof(UILabel))
	-- local headTex = subComponentGet(self.transform, "bg/head", "UITexture")
	if nameLabel ~= nil then
	--	renderQueue = 3015 -- nameLabel.drawCall.renderQueue + 2
		renderQueue = 3500
	end
	Trace("______"..tostring(content))
	local animPath = data_center.GetAppConfDataTble().appPath.."/effects/expression_new"
	local animtGObj = animations_sys.PlayAnimationByScreenPosition(child(self.transform, "chatAniRoot"),0,100,animPath,chatImgAnimationTbl[content],120,120,false, function()			
	end, renderQueue)

	if animtGObj and self.sortingOrder then
		local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(animtGObj, topLayerIndex)
		Trace("topLayerIndextopLayerIndextopLayerIndex--"..topLayerIndex)
	end
end

function sangong_player_ui:SetChatText(content)
	componentGet(self.chat_text_label,"UILabel").text = content

	self:LimitChatMsgHide()
	self.chat_text.gameObject:SetActive(true)
	self:LimitChatMsgShow()

	local tIndex = model_manager:GetModel("ChatModel"):GetChatIndexByContent(content)
	if tIndex~=nil then
		-- ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().gamePathLst[1].."/sound/shisanshui/"..tIndex)
		ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/niuniu/"..tIndex)
	else
		Trace("chat sound not exit!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	end
end

--消息时间间隔
function sangong_player_ui:LimitChatMsgShow()
	self.timer_Elapse = Timer.New(slot(sangong_player_ui.OnTimer_Proc, self) , 3, 1)
	self.timer_Elapse:Start()
	self.chat_text.gameObject:SetActive(true)
end
function sangong_player_ui:LimitChatMsgHide()
	if self.timer_Elapse ~= nil then
		self.timer_Elapse:Stop()		
		self.timer_Elapse = nil    
	end
	self.chat_text.gameObject:SetActive(false)
end

function sangong_player_ui:OnTimer_Proc()
	self.chat_text.gameObject:SetActive(false)
end

--语音聊天模块
function sangong_player_ui:SetSoundTextureState(state)
	self.chat_sound.gameObject:SetActive(state)
	if state==true then
		ui_sound_mgr.SetAllAudioSourceMute(true)
	else
		ui_sound_mgr.SetAllAudioSourceMute(false)
	end
end



function sangong_player_ui:Onbtn_PlayerInfoClick(obj)
	-- Trace("Onbtn_PlayerInfoClick")
	if self.PlayerInfo and self.PlayerInfo.gameObject then
		self.PlayerInfo.gameObject:SetActive(false)
	end
end
function sangong_player_ui:hidePlayerInfoClick()
	if self.PlayerInfo and self.PlayerInfo.gameObject then
		self.PlayerInfo.gameObject:SetActive(false)
	end
end


return sangong_player_ui