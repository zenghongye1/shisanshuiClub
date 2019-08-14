--[[--
 * @Description: 玩家信息UI组件
 * @Author:      ShushingWong
 * @FileName:    mahjong_player_ui.lua
 * @DateTime:    2017-06-19 16:21:14
 ]]
 require "logic/gvoice_sys/gvoice_sys"

local base = require "logic/poker_sys/common/poker_player_ui_base"
local shisanshui_player_ui = class("shisanshui_player_ui",base)


--互动表情动画
local iEAnimTbl = {
	{frameName="woshou", frameCount=15},
	{frameName="songhua", frameCount=13},
	{frameName="xihongshi", frameCount=13},
	{frameName="zhuantou", frameCount=12},
	{frameName="poshui", frameCount=14},
}
--互动表情音效
local iESfxTbl = {
	"woshou", 
	"kiss_flowers", 
	"xihongshi", 
	"banzhuan", 
	"polenshui", 
}

function shisanshui_player_ui:ctor(transform,ui,index)
	base.ctor(self, transform, ui, index)
end

function shisanshui_player_ui:InitWidget()
	base.InitWidget(self)
	
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
	self.readystate = child(self.transform, "bg/obj/readystate")
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
	
	--显示水庄倍数
	self.beishuLabel = child(self.transform,"bg/pao/beishuLabel")
	if self.beishuLabel ~= nil then
		self.beishuLabel.gameObject:SetActive(false)
	end

	self.shoot = child(self.transform, "bg/obj/shoot")

	self.shootHole = {}
	self.shootHole[1] = child(self.transform, "bg/obj/shootHole1")
	self.shootHole[2] = child(self.transform, "bg/obj/shootHole2")
	self.shootHole[3] = child(self.transform, "bg/obj/shootHole3")
	--头像
	--self.head = child(self.transform,"bg/head")
	--addClickCallbackSelf(self.head.gameObject,self.Onbtn_PlayerIconClick,self)
	
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
 
	self.chat_text = child(self.chat_root,"text_root")
	if self.chat_text then
		self.chat_text.gameObject:SetActive(false)
		self.chat_text_label = child(self.chat_text,"msg")
	end

	self.chat_sound = child(self.chat_root,"sound_root")
	if self.chat_sound then
		self.chat_sound.gameObject:SetActive(false)
	end
end

--设置金币

function shisanshui_player_ui:SetScore( score )
	if self.scorelabel==nil then
		self.scorelabel = self.score.gameObject:GetComponent(typeof(UILabel))
	end
	if score == nil then score = 0 end
	self.all_score =  tonumber(self.all_score) + tonumber(score)

--	self.scorelabel.text = score
	self.scorelabel.text =  tostring(self.all_score)
end

function shisanshui_player_ui:AddScore(score)
	if self.scorelabel==nil then
		self.scorelabel = self.score.gameObject:GetComponent(typeof(UILabel))
	end
	if score == nil then score = 0 end
	self.all_score =  score
	self.scorelabel.text =  tostring(score)
end

function shisanshui_player_ui:SetTotalPoints(points)
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

function shisanshui_player_ui:HideTotalPoints()
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

function shisanshui_player_ui:SetBeiShu(beishu)
	local beishuLabel = self.beishuLabel.gameObject:GetComponent(typeof(UILabel))
	beishuLabel.text = tostring(beishu).."B"
	self.beishuLabel.gameObject:SetActive(true)
end

function shisanshui_player_ui:HideBeiShu()
	self.beishuLabel.gameObject:SetActive(false)
end

function shisanshui_player_ui:SetRoomCardNum( num )
	if self.roomCardLabel ~= nil then
		self.roomCardLabel.text = "X" .. num
	end
end


--设置昵称
function shisanshui_player_ui:SetName( name )
	if self.namelabel==nil then
		self.namelabel = self.name.gameObject:GetComponent(typeof(UILabel))
	end
	self.namelabel.text = name
end

--设置头像
function shisanshui_player_ui:SetHead( url )
	-- 自己不显示UI
	if self.viewSeat == 1 then
--		return
	end
	if self.headTexture==nil then
		self.headTexture = self.head.gameObject:GetComponent(typeof(UITexture))
	end
	--hisangshui_ui_sys.GetHeadPic(self.headTexture,url)
	HeadImageHelper.SetImage(self.headTexture,2,url)
end

--设置VIP等级，0不显示
function shisanshui_player_ui:SetVIP(level)
	-- if level>0 then
	-- 	self.vip.gameObject:SetActive(true)
	-- else
	-- 	self.vip.gameObject:SetActive(false)
	-- end
end

--显示玩家用户
function shisanshui_player_ui:Show( usersdata, viewSeat )
	self.transform.gameObject:SetActive(true)
	self.viewSeat = viewSeat
	self.userdata = usersdata
	self.logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(self.viewSeat)
	self:SetName(usersdata.name)
--	self:SetScore( self.all_score)
	-- self:SetVIP(usersdata.vip)
	self:SetHead(usersdata.headurl)
	self:SetMachine(false)
--	self:SetOffline(false)
	self:SetFangzhu(usersdata.owner)
	if (self.userdata.saved ~= nil) then
		gps_data.SetGpsData(usersdata.headurl,2,self.position_index,self.viewSeat,self.userdata.saved)
	end
end

function shisanshui_player_ui:Hide()
	gps_data.RemoveOne(self.position_index)
	self.transform.gameObject:SetActive(false)
	self:SetOffline(false)
	self.all_score = 0
	self.scorelabel.text =  0
	self:SetReady(false)
	self:SetBanker(false)
	self:SetFangzhu(false)
end

--设置准备状态
function shisanshui_player_ui:SetReady( isReady )
	self.readystate.gameObject:SetActive(isReady or false)
end

--设置准备按钮的坐标位置
function shisanshui_player_ui:SetReadyLocalPosition(x,y)
	self.readystate.gameObject.transform.localPosition = Vector3(x,y,0)
end

--设置聊天消息坐标位置
function shisanshui_player_ui:SetChatTextLocalPosition(index,x,y)
	 
end

--设置语音消息坐标位置
function shisanshui_player_ui:SetChatSoundLocalPosition(index,x,y)
	 
end

--设置庄家
function shisanshui_player_ui:SetBanker(isBanker)
	self.banker.gameObject:SetActive(isBanker or false)
	if isBanker then
		local effect = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_zhuang",1)
		effect.transform:SetParent(self.banker.gameObject.transform,false)
		Utils.SetEffectSortLayer(effect.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
	end
end

--设置房主
function shisanshui_player_ui:SetFangzhu(isFangzhu)
	self.fangzhu.gameObject:SetActive(isFangzhu or false)
end

--设置下跑
function shisanshui_player_ui:SetPao(num)
	-- self.pao.gameObject:SetActive(true)
	-- if self.paoLabel_comp == nil then
	-- 	self.paoLabel_comp = self.paoLabel:GetComponent(typeof(UILabel))
	-- end
	-- self.paoLabel_comp.text = "x"..num
end

function shisanshui_player_ui:HidePao()
	-- self.pao.gameObject:SetActive(false)
end

--设置托管
function shisanshui_player_ui:SetMachine(isMachine)
	self.machine.gameObject:SetActive(isMachine or false)
end

--设置离线
function shisanshui_player_ui:SetOffline(isOffline)
	self.offline.gameObject:SetActive(isOffline or false)
end

function shisanshui_player_ui:GetHuaPointPos()
	return self.huaPoint.position
end

function shisanshui_player_ui:ShootTran()
	return self.shoot
end

function shisanshui_player_ui:ShootHoleTran(index)
	if index <= 3 then
		return self.shootHole[index]
	end
	return nil
end

-- local chatImgAnimationTbl = {["1"]="benpao",["2"]="bishi",["3"]="buhaoyisi",["4"]="fanu",["5"]="haiye",["6"]="jingya",["7"]="kuqi",["8"]="shuqian",["9"]="xuanyao"}
local chatImgAnimationTbl = {
		["1"]="01_feiwen",["2"]="02_deyi",["3"]="03_haose",["4"]="04_tianping",["5"]="05_shaxiao",
		["6"]="06_paoxiao",["7"]="07_shuashuai",["8"]="08_chaoxiao",["9"]="09_xinsui",["10"]="10_daku",
		["11"]="11_tongku",["12"]="12_weiquku",["13"]="13_benkui",["14"]="14_tu",["15"]="15_jingdiaoya",
		["16"]="16_qituxue",["17"]="17_nibuxing",["18"]="19_qidao",["19"]="20_touyun",["20"]="22_bishi",
		["21"]="23_maohan",["22"]="24_zaijian",["23"]="25_gun",["24"]="26_kan",["25"]="27_jingkong",
		["26"]="28_zhuangpingmu",
	}

--设置聊天
function shisanshui_player_ui:SetChatImg(content)
	local renderQueue = 0
	local nameLabel = subComponentGet(self.transform, "bg/name", typeof(UILabel))
	-- local headTex = subComponentGet(self.transform, "bg/head", "UITexture")
	if nameLabel ~= nil then
		renderQueue = 3015--nameLabel.drawCall.renderQueue + 2
	end
	Trace("______"..tostring(content))
	-- local animPath = data_center.GetAppConfDataTble().appPath.."/effects/emoticon2"
	local animPath = data_center.GetAppConfDataTble().appPath.."/effects/expression_new"
	local animtGObj = animations_sys.PlayAnimationByScreenPosition(child(self.transform, "chatAniRoot"),0,100,animPath,chatImgAnimationTbl[content],120,120,false, function()			
	end, renderQueue)
	
	if animtGObj and self.sortingOrder then
		local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(animtGObj, topLayerIndex)
	end
end

function shisanshui_player_ui:SetChatText(content)
	componentGet(self.chat_text_label,"UILabel").text = content

	self:LimitChatMsgHide()
	self.chat_text.gameObject:SetActive(true)
	self:LimitChatMsgShow()

	local tIndex = model_manager:GetModel("ChatModel"):GetChatIndexByContent(content)
	if tIndex~=nil then
		ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/shisanshui/"..tIndex)
	else
		Trace("chat sound not exit!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	end
end

local timer_Elapse = nil --消息时间间隔
function shisanshui_player_ui:LimitChatMsgShow()
	timer_Elapse = Timer.New(slot(self.OnTimer_Proc,self), 3, 1)
	timer_Elapse:Start()
	self.chat_text.gameObject:SetActive(true)
end
function shisanshui_player_ui:LimitChatMsgHide()
	if timer_Elapse ~= nil then
		timer_Elapse:Stop()		
		timer_Elapse = nil    
	end
	--self.chat_img.gameObject:SetActive(false)
	self.chat_text.gameObject:SetActive(false)
end

function shisanshui_player_ui:OnTimer_Proc()
	--self.chat_img.gameObject:SetActive(false)
	if self.chat_text.gameObject ~= nil then
		self.chat_text.gameObject:SetActive(false)
	end
end

--语音聊天模块
function shisanshui_player_ui:SetSoundTextureState(state)
	self.chat_sound.gameObject:SetActive(state)
	if state==true then
		ui_sound_mgr.SetAllAudioSourceMute(true)
	else
		ui_sound_mgr.SetAllAudioSourceMute(false)
	end
end

function shisanshui_player_ui:Onbtn_PlayerInfoClick(obj)	
	-- Trace(self.usersdata)

	if self.PlayerInfo and self.PlayerInfo.gameObject then
		self.PlayerInfo.gameObject:SetActive(false)
	end
end
function shisanshui_player_ui:hidePlayerInfoClick()
	if self.PlayerInfo and self.PlayerInfo.gameObject then
		self.PlayerInfo.gameObject:SetActive(false)
	end
end

return shisanshui_player_ui




