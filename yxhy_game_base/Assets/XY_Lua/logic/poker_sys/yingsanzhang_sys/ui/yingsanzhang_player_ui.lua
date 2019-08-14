local base = require "logic/poker_sys/common/poker_player_ui_base"
local yingsanzhang_player_ui = class("yingsanzhang_player_ui", base)

local spStr = {
	"ysz_03",	--失败
	"ysz_10",	--弃牌
}

local isShake = false	

function yingsanzhang_player_ui:ctor(transform,mainUi,index)
	base.ctor(self, transform, mainUi, index)
------
	self.isBanker = false
	self.isOut = false
	self.isOnTurn = false
end

function yingsanzhang_player_ui:InitWidget()
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
	
	--显示下注筹码数
	self.betChipTran = child(self.transform,"bg/betChip")
	self.chipLabel = subComponentGet(self.betChipTran,"beishuLabel","UILabel")
	if self.betChipTran then
		self.betChipTran.gameObject:SetActive(false)
	end

	self.shoot = child(self.transform, "bg/obj/shoot")

	
	--牌型状态
	self.cardStateLbl = componentGet(child(self.transform,"bg/state"),"UILabel")
	if self.cardStateLbl then
		self.cardStateLbl.gameObject:SetActive(false)
	end
	
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
	
	--庄家的外光圈
	self.turnFrameSp =componentGet(child(self.transform,"bg/head/biankuang").gameObject,"UISprite")
	self.turnFrameSp.gameObject:SetActive(false)
	self.turnFrameSp.fillAmount = 0
	
	self.colorCountDown = require("logic/common/ColorCountDown"):create(self.turnFrameSp.gameObject)
	self.colorCountDown:SetProcCallback(slot(self.TurnTimerProc,self))
	self.colorCountDown.speed = 0.1
	
	self.giveUpIconSp = componentGet(child(self.transform,"bg/obj/qipai_icon").gameObject,"UISprite")
	self.giveUpIconSp.gameObject:SetActive(false)
	
	self.bipaiImage = child(self.transform,"bg/obj/bipai_select_image")
	addClickCallbackSelf(self.bipaiImage.gameObject,self.BiPaiImageOnClick,self)
	self.bipaiImage.gameObject:SetActive(false)
	if self.viewSeat ~= 1 then
		local effect = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/".."Effect_huxikuang",1,-1)
		effect.transform:SetParent(self.bipaiImage.transform,false)
	end
end

function yingsanzhang_player_ui:SetTurnFrame(isShow,timeEnd,time,isForce)
	if self.isOnTurn == isShow and not isForce then
		return
	end
	self.turnFrameSp.gameObject:SetActive(isShow)
	self.isOnTurn = isShow
	if isShow then
		self.colorCountDown:StartTimer(timeEnd,time)
		isShake = true
	else
		self.colorCountDown:StopTimer()
		self.turnFrameSp.fillAmount = 0
		self.timeEnd = 0
	end
end

function yingsanzhang_player_ui:TurnTimerProc(amount,timeEnd)
	self.turnFrameSp.fillAmount = (1 - amount) or 0
	self.timeEnd = timeEnd
	if self.viewSeat == 1 and self.timeEnd == 5 and isShake then
		isShake = false
		Notifier.dispatchCmd(cmdName.MSG_SHAKE,{})
	end
	if self.timeEnd <= 0 then
		self.colorCountDown:StopTimer()
		self.turnFrameSp.fillAmount = 0
		self.timeEnd = 0
	end
end

function yingsanzhang_player_ui:SetState(IsShow,state)
	local isShow = IsShow
	if state ~= nil then
		self.readystate.spriteName = state
		self.readystate:MakePixelPerfect()
	else
		isShow = false
	end
	self.readystate.gameObject:SetActive(isShow)
end

function yingsanzhang_player_ui:GiveUpCalling(isGiveUp)
	self.giveUpIconSp.gameObject:SetActive(isGiveUp)
	self.giveUpIconSp.spriteName = spStr[2]
	if isGiveUp then
		self.headTexture.color = Color.New(0.5,0.5,0.5)
	else
		self.headTexture.color = Color.New(1,1,1)
	end
end

function yingsanzhang_player_ui:IsGiveUp()
	if self.giveUpIconSp.gameObject.activeSelf then
		return true
	else
		return false
	end
end

function yingsanzhang_player_ui:showBiPaiKuang(isTrue)
	if self.isOut or self.viewSeat == 1 then
		self.bipaiImage.gameObject:SetActive(false)
	else
		self.bipaiImage.gameObject:SetActive(isTrue)
	end
	
end

function yingsanzhang_player_ui:BiPaiImageOnClick()
	Trace("比牌对象:"..tostring(self.logicSeat))
	pokerPlaySysHelper.GetCurPlaySys().CompareReq(self.logicSeat)
end

function yingsanzhang_player_ui:SetScore(score)
	if self.scorelabel == nil then
		self.scorelabel = self.score.gameObject:GetComponent(typeof(UILabel))
	end
	if score == nil then score = 0 end
	self.all_score =  tonumber(self.all_score) + tonumber(score)
	self.scorelabel.text =  tostring(self.all_score)
end
	
function yingsanzhang_player_ui:AddScore(score)
	if self.scorelabel==nil then
		self.scorelabel = self.score.gameObject:GetComponent(typeof(UILabel))
	end
	if score == nil then score = 0 end
	self.all_score =  score
	self.scorelabel.text =  tostring(score)
end

function yingsanzhang_player_ui:SetTotalPoints(points)
	self.positiveLabel.gameObject:SetActive(false)
	self.negativeLabel.gameObject:SetActive(false)
	if points ~= nil then
		if points > 0 then
			local pointsLabel = self.positiveLabel.gameObject:GetComponent(typeof(UILabel))
			pointsLabel.text = "+"..tostring(points)
			componentGet(self.positiveLabel,"TweenPosition"):ResetToBeginning ()
			self.positiveLabel.gameObject:SetActive(true)
			componentGet(self.positiveLabel,"TweenPosition").enabled =true
		--[[else
			local negativeLabel = self.negativeLabel.gameObject:GetComponent(typeof(UILabel))
			negativeLabel.text = tostring(points)
			componentGet(self.negativeLabel,"TweenPosition"):ResetToBeginning ()
			self.negativeLabel.gameObject:SetActive(true)
			componentGet(self.negativeLabel,"TweenPosition").enabled =true--]]
		end
	end
end

function yingsanzhang_player_ui:HideTotalPoints()
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

function yingsanzhang_player_ui:IsShowBetChip(state,chipCount)
	self.betChipTran.gameObject:SetActive(state)
	if state and chipCount then
		self.chipLabel.text = tostring(chipCount)
	else
		self.chipLabel.text = "0"
	end
	
end

function yingsanzhang_player_ui:SetRoomCardNum( num )
	if self.roomCardLabel ~= nil then
		self.roomCardLabel.text = "X" .. num
	end
end

--设置昵称
function yingsanzhang_player_ui:SetName( name )
	if self.namelabel==nil then
		self.namelabel = self.name.gameObject:GetComponent(typeof(UILabel))
	end
	self.namelabel.text = name
end

--设置头像
function yingsanzhang_player_ui:SetHead( url )
	HeadImageHelper.SetImage(self.headTexture,2,url)
end
	
--显示玩家用户
function yingsanzhang_player_ui:Show( usersdata, viewSeat )
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

function yingsanzhang_player_ui:Hide()
	gps_data.RemoveOne(self.position_index)
	self.transform.gameObject:SetActive(false)
	self:SetOffline(false)
end
	
function yingsanzhang_player_ui:Reset()
	self:HideTotalPoints()
	self:SetIsOut(false)
	self:showBiPaiKuang(false)
	self:IsShowBetChip(false)
	self:GiveUpCalling(false)
	self:SetTurnFrame(false)
end

--设置准备状态
function yingsanzhang_player_ui:SetReady( isReady )
	if isReady == true then
		self.readystate.spriteName = "yizhunbei"
		self.readystate:MakePixelPerfect()
	end
	self.readystate.gameObject:SetActive(isReady or false)
end

--设置准备按钮的坐标位置
function yingsanzhang_player_ui:SetReadyLocalPosition(x,y)
	self.readystate.gameObject.transform.localPosition = Vector3(x,y,0)
end
	
function yingsanzhang_player_ui:SetXiaZhuLocalPosition(x,y)
	self.beishuBg.gameObject.transform.localPosition = Vector3(x,y,0)
end

function yingsanzhang_player_ui:SetPaoAnchorLocalPosition(x,y)
	self.pao.gameObject.transform.localPosition = Vector3(x,y,0)
end

--设置庄家
function yingsanzhang_player_ui:SetBanker(isBanker)
	self.isBanker = isBanker
	self.banker.gameObject:SetActive(isBanker or false)
	if isBanker then
		local effect = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_zhuang",1)
		effect.transform:SetParent(self.banker.gameObject.transform,false)
		Utils.SetEffectSortLayer(effect.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
	end
end

--设置房主
function yingsanzhang_player_ui:SetFangzhu(isFangzhu)
	self.fangzhu.gameObject:SetActive(isFangzhu or false)
end

--设置下跑
function yingsanzhang_player_ui:SetPao(num)

end

function yingsanzhang_player_ui:HidePao()
	-- self.pao.gameObject:SetActive(false)
end

--设置托管
function yingsanzhang_player_ui:SetMachine(isMachine)
	self.machine.gameObject:SetActive(isMachine or false)
end


--设置离线
function yingsanzhang_player_ui:SetOffline(isOffline)
	self.offline.gameObject:SetActive(isOffline or false)
end

function yingsanzhang_player_ui:GetHuaPointPos()
	return self.huaPoint.position
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
function yingsanzhang_player_ui:SetChatImg(content)
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

function yingsanzhang_player_ui:SetChatText(content)
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
function yingsanzhang_player_ui:LimitChatMsgShow()
	self.timer_Elapse = Timer.New(slot(yingsanzhang_player_ui.OnTimer_Proc, self) , 3, 1)
	self.timer_Elapse:Start()
	self.chat_text.gameObject:SetActive(true)
end
function yingsanzhang_player_ui:LimitChatMsgHide()
	if self.timer_Elapse ~= nil then
		self.timer_Elapse:Stop()		
		self.timer_Elapse = nil    
	end
	self.chat_text.gameObject:SetActive(false)
end

function yingsanzhang_player_ui:OnTimer_Proc()
	self.chat_text.gameObject:SetActive(false)
end

--语音聊天模块
function yingsanzhang_player_ui:SetSoundTextureState(state)
	self.chat_sound.gameObject:SetActive(state)
	if state==true then
		ui_sound_mgr.SetAllAudioSourceMute(true)
	else
		ui_sound_mgr.SetAllAudioSourceMute(false)
	end
end

function yingsanzhang_player_ui:Onbtn_PlayerInfoClick(obj)
	-- Trace("Onbtn_PlayerInfoClick")
	if self.PlayerInfo and self.PlayerInfo.gameObject then
		self.PlayerInfo.gameObject:SetActive(false)
	end
end
function yingsanzhang_player_ui:hidePlayerInfoClick()
	if self.PlayerInfo and self.PlayerInfo.gameObject then
		self.PlayerInfo.gameObject:SetActive(false)
	end
end

function yingsanzhang_player_ui:GetExpressionCfg()
	local cfg = {}
	cfg.scale = Vector3(1.4,1.4,1.4)
	cfg.offset = Vector3(-6, 6)
	return cfg
end


function yingsanzhang_player_ui:SetCardStateShow(state,nCardType)	
	self.cardStateLbl.gameObject:SetActive(state)
	if state then
		if tonumber(nCardType) > 0 then
			self.cardStateLbl.text = yingsanzhang_rule_define.PT_YINGSANZHANG_CardText[nCardType] or ""
		else
			self.cardStateLbl.text = "已看牌"
		end
	else
		self.cardStateLbl.text = ""
	end
end

function yingsanzhang_player_ui:SetLoseGameState(isLose)
	self.giveUpIconSp.gameObject:SetActive(isLose)
	self.giveUpIconSp.spriteName = spStr[1]
	if isLose then
		self.headTexture.color = Color.New(0.5,0.5,0.5)
	else
		self.headTexture.color = Color.New(1,1,1)
	end
end

function yingsanzhang_player_ui:SetIsOut(state)
	self.isOut = state
	if self.isOut then
		self:showBiPaiKuang(false)
	end
end

return yingsanzhang_player_ui