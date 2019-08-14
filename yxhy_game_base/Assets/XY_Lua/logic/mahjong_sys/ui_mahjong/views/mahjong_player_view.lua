local base = require "logic/framework/ui/uibase/ui_view_base"
local mahjong_player_view = class("mahjong_player_view", base)
local FlowerCardView = require ("logic/mahjong_sys/ui_mahjong/views/MahjongFlowersView")

local chatImgAnimationTbl = {
	["1"]="01_feiwen",["2"]="02_deyi",["3"]="03_haose",["4"]="04_tianping",["5"]="05_shaxiao",
	["6"]="06_paoxiao",["7"]="07_shuashuai",["8"]="08_chaoxiao",["9"]="09_xinsui",["10"]="10_daku",
	["11"]="11_tongku",["12"]="12_weiquku",["13"]="13_benkui",["14"]="14_tu",["15"]="15_jingdiaoya",
	["16"]="16_qituxue",["17"]="17_nibuxing",["18"]="19_qidao",["19"]="20_touyun",["20"]="22_bishi",
	["21"]="23_maohan",["22"]="24_zaijian",["23"]="25_gun",["24"]="26_kan",["25"]="27_jingkong",
	["26"]="28_zhuangpingmu",
}

function mahjong_player_view:ctor(go)
	self.usersdata = nil
	self.viewSeat = 0
	self.logicSeat = 0
	self.index = 0
	base.ctor(self, go)
end

function mahjong_player_view:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function mahjong_player_view:InitView()
	self.roomCardLabel = self:GetComponent("bg/roomCard/roomCardNum", typeof(UILabel))

	self.paoGo = self:GetGameObject("bg/pao")
	self.paoGo:SetActive(false)

	self.paoStateSp = self:GetComponent("bg/paoState", typeof(UISprite))
	self.paoStateSp.gameObject:SetActive(false)

	self.paoLabel = self:GetComponent("bg/pao/Label", typeof(UILabel))

	self.huaPointTr = self:GetGameObject("bg/roomCard").transform
	addPressedCallbackSelf(self.huaPointTr, "", self.OnHuaPointPress, self)

	self.bankerGo = self:GetGameObject("bg/head/headPanel/banker")
	self.bankerGo:SetActive(false)

	self.headPanelTr = self:GetGameObject("bg/head/headPanel").transform
	self.headTr = self:GetGameObject("bg/head").transform


	self.lianzhuangNumGo = self:GetGameObject("bg/head/headPanel/banker/lianzhuangNum")
	self.lianzhuangNumLabel = self:GetComponent("bg/head/headPanel/banker/lianzhuangNum", typeof(UILabel))
	self.lianzhuangNumGo:SetActive(false)

	self.fangzhuGo = self:GetGameObject("bg/head/headPanel/fangzhu")
	self.fangzhuGo:SetActive(false)

	-- self.machineGo = self:GetGameObject("bg/head/machine")
	-- self.machineGo:SetActive(false)

	self.offlineGo = self:GetGameObject("bg/head/offline")
	self.offlineGo:SetActive(false)

	-- self.interactGo = self:GetGameObject("bg/head/personalInfo")
	-- self.interactGo:SetActive(false)

	self.scoreRootGo = self:GetGameObject("bg/score")
	self.scoreLabel = self:GetComponent("bg/score/scorelabel", typeof(UILabel))

	self.nameLabel = self:GetComponent("bg/name", typeof(UILabel))

	self.readyStateGo = self:GetGameObject("bg/readystate")
	self.readyStateGo:SetActive(false)

	self.headGo = self:GetGameObject("bg/head")
	self.headTex = self:GetComponent("bg/head", typeof(UITexture))
	addClickCallbackSelf(self.headGo,self.Onbtn_PlayerIconClick,self)

	self.operPos = self:GetGameObject("bg/operPos").transform

	--显示正数总分
	self.positiveLabel = child(self.transform,"bg/addPoint/positiveLabel")
	if self.positiveLabel ~= nil then
		self.positiveLabel.gameObject:SetActive(false)
	end
	--显示负数总分
	self.negativeLabel = child(self.transform,"bg/addPoint/negativeLabel")
	if self.negativeLabel ~= nil then
		self.negativeLabel.gameObject:SetActive(false)
	end

	self.chatRootGo = self:GetGameObject("bg/chat")
	self.chatRootGo:SetActive(true)
 
 	self.chatImgRootGo = self:GetGameObject("bg/chat/img_root")
 	self.chatImgGo = self:GetGameObject("bg/chat/img_root/img")
	self.chatImgGo:SetActive(false)

	self.chatTextRootGo = self:GetGameObject("bg/chat/text_root")
	self.chatTextRootGo:SetActive(false)

	self.chatTextLabel = self:GetComponent("bg/chat/text_root/msg", typeof(UILabel))

	self.chatSoundRootGo = self:GetGameObject("bg/chat/sound_root")
	self.chatSoundRootGo:SetActive(false)


	local name = self.gameObject.name
 	if name == "Player1" then
		self.index = 1	
	elseif name == "Player2" then
		self.index = 2
	elseif name == "Player3" then
		self.index = 3
	elseif name == "Player4" then
		self.index = 4		
	end

	local go = self:GetGameObject("bg/flowerView")
	self.flowerView = FlowerCardView:create(go, self.index)

	self:OnDestroy()
end

function mahjong_player_view:SetScore(score)
	self.scoreLabel.text = score
end

function mahjong_player_view:SetRoomCardNum(num)
	if not self.supprotSpecialFlower then
		if self.roomCardLabel ~= nil then
			if self.index == 2 then
				self.roomCardLabel.text =  num .. "X"
			else
				self.roomCardLabel.text = "X" .. num
			end
		end
		if num > 0 then
			self:ShowRoomCardAnim()
			self:ShowhuaEff()
		end
	else
		self:ShowFlowersView()
	end
end

function mahjong_player_view:ShowFlowersView()
	if not self.supprotSpecialFlower then
		return
	end
	local flowerCards = roomdata_center.GetFlowerCards(self.viewSeat)
	local specialFlowers = roomdata_center.GetspecialFlowers(self.viewSeat)
	self.flowerView:SetFlowers(flowerCards,specialFlowers)
end


function mahjong_player_view:ShowRoomCardAnim()
	if self.label_c ~= nil then
		coroutine.stop(self.label_c)
	end
	self.label_c = coroutine.start(function() 
		self.roomCardLabel.transform:DOScale(1.6, 0.5)
		coroutine.wait(0.5)
		self.roomCardLabel.transform:DOScale(1, 0.5)
		coroutine.wait(0.5)
		self:HideHuaEff()
		self.label_c = nil
		end)
end

function mahjong_player_view:ShowhuaEff()
	self:HideHuaEff()
	self.huaEff = animations_sys.PlayLoopAnimation(self.huaPointTr, mahjong_path_mgr.GetEffPath("anim_hua", mahjong_path_enum.mjCommon), "hua_1", 100, 100, 3007)
end

function mahjong_player_view:HideHuaEff()
	if self.huaEff ~= nil then
		animations_sys.StopPlayAnimationToCache(self.huaEff, mahjong_path_mgr.GetEffPath("anim_hua", mahjong_path_enum.mjCommon))
		self.huaEff = nil
	end
end

--设置昵称
function mahjong_player_view:SetName( name )
	name = name or nil
	self.nameLabel.text = name
end

--设置头像
function mahjong_player_view:SetHead( url ,_type)
	
	if url == nil then
		self.headTex = Texuture2D.whiteTexture
	end
	HeadImageHelper.SetImage(self.headTex,_type or 2,url)
end


function mahjong_player_view:Hide()
	gps_data.RemoveOne(self.index)
	self.gameObject:SetActive(false)
	self:SetReady(false)
end

--显示玩家用户

function mahjong_player_view:Show( usersdata, viewSeat )
	self.usersdata = usersdata
	self.gameObject:SetActive(true)
	self.viewSeat = viewSeat
	self.logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(self.viewSeat)
	self:SetName(usersdata.name)
	--self.SetScore( usersdata.coin )

	-- self.SetVIP(usersdata.vip)
	if usersdata.headurl and usersdata.headurl~="" then
		self:SetHead(usersdata.headurl,usersdata.imagetype)
	end
	-- self:SetMachine(false)
	self:SetOffline(self.isOffline)
	self:SetFangzhu(usersdata.owner)

	self.supprotSpecialFlower = mode_manager.GetCurrentMode().cfg.useSpecialUIFlowerCards
	self.flowerView:SetActive(self.supprotSpecialFlower)
	
	if usersdata.saved then
		gps_data.SetGpsData(usersdata.headurl,usersdata.imagetype,self.index,viewSeat,usersdata.saved)
	end
end

function mahjong_player_view:SetTotalPoints(points)
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

function mahjong_player_view:HideTotalPoints()
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

--设置离线
function mahjong_player_view:SetOffline(isOffline)
	self.isOffline = isOffline
	self.offlineGo:SetActive(isOffline or false)
end


--设置准备状态
function mahjong_player_view:SetReady( isReady )
	self.readyStateGo:SetActive(isReady or false)
end


--设置庄家
function mahjong_player_view:SetBanker(isBanker)
   self.bankerGo:SetActive(isBanker or false)
end

--设置连庄数
function mahjong_player_view:SetLianZhuang(lianZhuang)
	if lianZhuang==nil then
		Trace("服务端没发连庄数过来，让服务端检查下")
		self.lianzhuangNumGo:SetActive(false)
		return
	elseif lianZhuang == 0 then
		self.lianzhuangNumGo:SetActive(false)
		return
	end
	lianZhuang = lianZhuang + 1
	self.lianzhuangNumGo:SetActive(true)
	self.lianzhuangNumLabel.text = tostring(lianZhuang)
end

--设置房主
function mahjong_player_view:SetFangzhu(isFangzhu)
    self.fangzhuGo:SetActive(isFangzhu or false)
end

	-- 设置花信息是否显示

function mahjong_player_view:SetHuaPointVisible(value)
	if value == false and self.supprotSpecialFlower  then
		self.flowerView:Clear()
	end
	
	if self.supprotSpecialFlower then
		value = false
	end
	self.huaPointTr.gameObject:SetActive(value)
end

function mahjong_player_view:SetScoreVisible(value)
	self.scoreRootGo:SetActive(value)
end

function mahjong_player_view:UpdateXiaPaoState(value,cfg)
	local cfg = cfg
	if value == 1 then
		self.paoStateSp.gameObject:SetActive(false)
		return
	end
	self.paoStateSp.gameObject:SetActive(true)
	if value == 2 then
		self.paoStateSp.spriteName = cfg.xiapaoingStateSpriteName
	elseif value == 3 then
		self.paoStateSp.spriteName = cfg.xiapaoedStateSpriteName
	else
		self.paoStateSp.spriteName = cfg.noxiapaoStateSpriteName
	end

	self.paoStateSp:MakePixelPerfect()
end

--设置下跑
function mahjong_player_view:SetPao(str)
	self.paoGo:SetActive(true)
	self.paoLabel.text = str
end

function mahjong_player_view:HidePao()
	self.paoGo:SetActive(false)
end

--设置聊天
function mahjong_player_view:SetChatImg(content)
	local renderQueue = 3500
	local animPath = data_center.GetAppConfDataTble().appPath.."/effects/expression_new"
	local animtGObj = animations_sys.PlayAnimationByScreenPosition(child(self.transform, "chatAniRoot"),0,100,animPath,
		chatImgAnimationTbl[content],120,120,false, function()
		--
	end, renderQueue)

	if animtGObj and self.sortingOrder then
		local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(animtGObj, topLayerIndex)
		-- Trace("topLayerIndextopLayerIndextopLayerIndex--"..topLayerIndex)
	end
end

function mahjong_player_view:SetChatText(content)
	-- componentGet(this.chat_text_label,"UILabel").text = content
	self.chatTextLabel.text = content

	self:LimitChatMsgHide()
	--this.chat_text.gameObject:SetActive(true)
	self:LimitChatMsgShow()

	local tIndex = model_manager:GetModel("ChatModel"):GetChatIndexByContent(content)
	if tIndex~=nil then
		ui_sound_mgr.PlaySoundClip(data_center.GetAppPath().."/mj_common/sound/chat/woman/"..tIndex)
	else
		Trace("chat sound not exit!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	end
end

function mahjong_player_view:LimitChatMsgShow()
	self.timer_Elapse = Timer.New(slot(self.OnTimer_Proc, self) , 3, 1)
	self.timer_Elapse:Start()
	self.chatTextRootGo:SetActive(true)
end
function mahjong_player_view:LimitChatMsgHide()
	if self.timer_Elapse ~= nil then
	    self.timer_Elapse:Stop()	
	   	self.timer_Elapse = nil	    
	end
	--this.chat_img.gameObject:SetActive(false)
	self.chatTextRootGo:SetActive(false)
end
function mahjong_player_view:OnTimer_Proc()
	self.chatTextRootGo:SetActive(false)
end

function mahjong_player_view:GetHuaPointPos()
	return self.huaPointTr.position
end

function mahjong_player_view:OnHuaPointPress(go , isPress)
	if isPress then
		local flowerCards = roomdata_center.GetFlowerCards(self.viewSeat)
		if #flowerCards == 0 then
			return
		end
		local pos = mahjong_ui:GetTransformPanel():InverseTransformPoint(go.transform.position)
		
		mahjong_ui.cardShowView:ShowHua(pos, flowerCards, self.viewSeat)

	else
		mahjong_ui.cardShowView:Hide()
	end
end

function mahjong_player_view:Onbtn_PlayerIconClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
	-- if self.viewSeat ~= 1 then
	-- 	-- if not this.PlayerInfo then
	-- 	--     this.PlayerInfo = child(this.transform,"bg/head/personalInfo")
	-- 	--     addClickCallbackSelf(this.PlayerInfo.gameObject,this.Onbtn_PlayerInfoClick,this)
			
			
	-- 	-- end
	-- 	-- 全局点击关闭
	-- 	local boxCollider = componentGet(self.playerInfoGo.transform,"BoxCollider")
	-- 	if boxCollider then
	-- 		boxCollider.size = Vector3(2500,1500,1)
	-- 	end
	-- 	self.playerInfoGo:SetActive(true)
		
	-- end
end


--语音聊天模块
function mahjong_player_view:SetSoundTextureState(state)
	self.chatSoundRootGo:SetActive(state)
    if state==true then
        ui_sound_mgr.SetAllAudioSourceMute(true)
    else
        ui_sound_mgr.SetAllAudioSourceMute(false)
    end
end

-- 播放互动表情
function mahjong_player_view:playInteractiveExpressionAnimation(cfg,_iKind, _fromPos, _toPos)
	
	-- 换图
	local prefabPath = data_center.GetAppConfDataTble().appPath.."/mj_common/effects/" .. cfg.prefab
    local prefabObj = newNormalObjSync(prefabPath, typeof(GameObject))
	if prefabObj then
	    local animObj = newobject(prefabObj)
	    animObj.transform.parent = self.transform

	    -- local headPanel = child(self.transform, "bg/head/headPanel")
	    if self.headPanelTr then
	    	animObj.transform.parent = self.headPanelTr

	    	-- 设置to相对坐标0
	    	local curPos = self.headPanelTr.transform.localPosition
			_toPos.x = _toPos.x -curPos.x
			_toPos.y = _toPos.y -curPos.y

		    local head = child(self.transform, "bg/head")
		    if head then
		    	-- 设置from相对坐标0
		    	local curPos2 = head.transform.localPosition
				_fromPos.x = _fromPos.x -curPos2.x -curPos.x
				_fromPos.y = _fromPos.y -curPos2.y -curPos.y
		    end
	    end

		local animIndex = 0
		-- this.InteractiveExSprite = subComponentGet(this.transform, "bg/InteractiveExSprite", typeof(UISprite))
		local interactiveExSprite = componentGet(animObj, "UISprite")
		interactiveExSprite.spriteName = cfg.frameName..animIndex
		interactiveExSprite:MakePixelPerfect()
		interactiveExSprite.gameObject:SetActive(true)

		local animSpriteObj = interactiveExSprite.gameObject
		-- scale 
		-- animSpriteObj.transform.localScale = Vector3.New(1.2, 1.2, 1)
		-- rotation 
		if _fromPos.x >_toPos.x then
			-- flipX
			animSpriteObj.transform.localRotation = Vector3.New(0, 180, 0)
		else
			animSpriteObj.transform.localRotation = Vector3.zero
		end
		-- move 
		animSpriteObj.transform.localPosition = _fromPos

		-- 播放帧动画
		local function playAnimation()
			local animationTimer = nil
			animationTimer = Timer.New(function ()
				-- Trace("InteractiveExSprite:"..animIndex)
	  	 		if animIndex < cfg.frameCount then
					animIndex = animIndex +1
					interactiveExSprite.spriteName = cfg.frameName..animIndex
					interactiveExSprite:MakePixelPerfect()
				else
					animationTimer:Stop()
					-- interactiveExSprite.gameObject:SetActive(false)
					-- interactiveExSprite = nil

					-- 销毁动画对象
					if animObj then
						destroy(animObj)
						animObj = nil
					end
				end
		  	end, 0.1, -1)
			animationTimer:Start()
		end
		-- 移到指定位置
		if _fromPos.x >_toPos.x then
			-- 泼水坐标修正
			if _iKind ==5 then
				_toPos.x = _toPos.x -23
				_toPos.y = _toPos.y +16
			end
		else
			-- 泼水坐标修正
			if _iKind ==5 then
				_toPos.x = _toPos.x +23
				_toPos.y = _toPos.y +16
			end
		end

		local isMoveEnd = false
		-- local animTweener = animSpriteObj.transform:DOLocalJump(_toPos, 1,1, 0.5, true)
		local animTweener = animSpriteObj.transform:DOLocalMove(_toPos, 0.3, true)
		animTweener:SetEase(DG.Tweening.Ease.Linear):OnComplete(function()
			playAnimation()
			isMoveEnd = true
		end)
		animTweener:OnKill(function()
			-- 销毁动画对象
			if animObj and not isMoveEnd then
				destroy(animObj)
				animObj = nil
			end
		end)
	end
end

function mahjong_player_view:ShowInteractinAnimation(viewSeat,content)
	
	local cfg = config_mgr.getConfig("cfg_interact",tonumber(content))

	if cfg == nil then
		logError("找不到互动表情", content)
		return
	end
	

	local fromPlayer = mahjong_ui.playerList[viewSeat]
	if fromPlayer then
		local fromPos = fromPlayer.transform.localPosition
	    local head = child(fromPlayer.transform, "bg/head")
	    if head then
	    	-- 设置from相对坐标0
	    	local curPos = head.transform.localPosition
			fromPos.x = fromPos.x +curPos.x
			fromPos.y = fromPos.y +curPos.y
	    end
		-- 计算相对坐标
		local curPos = self.transform.localPosition
		fromPos = Vector3.New(fromPos.x-curPos.x, fromPos.y-curPos.y, 0)
		-- 播放动画
		self:playInteractiveExpressionAnimation(cfg, tonumber(content), fromPos, Vector3.zero)
	end

	-- 播放音效
	local sfxName = cfg.sound
	if sfxName then
		ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/specialFace/"..sfxName)
	end

	-- this.Onbtn_PlayerIconClick()
end

--[[--
 * @Description: 报听特效显示  
 ]]
function mahjong_player_view:SetYoustatus(aniId,isShowTingSign)
	local callback
	local time = 1.5
	if aniId ==20004 then -- 听
		callback = function ()
       		self:ShowTing(true)
       end
    elseif aniId ==20020 then -- 硬扣
       callback = function ()
       		self:ShowYingKou(true) 
       end
   	elseif aniId ==20021 then -- 潇洒
   		callback = function ()
       		self:ShowTing(true)
       end
	end

	if aniId then
		mahjong_effectMgr:PlayUIEffectById(aniId,self.chatImgRootGo.transform)
	end
	if callback then
		coroutine.start(function ()
		 	coroutine.wait(time)
			callback()
		end)
	end
end

function mahjong_player_view:ShowTing(value)  
   local ting=child(self.operPos,"ting")
   if ting~=nil then
      ting.gameObject:SetActive(value)
   end
end

function mahjong_player_view:ShowYingKou(value) 
   local yingkou=child(self.operPos,"yingkou")
   local ting=child(self.operPos,"ting")
   if ting~=nil and ting.gameObject.activeSelf then
      ting.gameObject:SetActive(false)
   end
   if yingkou~=nil then
      yingkou.gameObject:SetActive(value)
   end
end
 
function mahjong_player_view:SetHeadEffect(state)
	if state then
		local effect = EffectMgr.PlayEffect(mahjong_path_mgr.GetEffPath("Effect_wanjiatouxiang",mahjong_path_enum.mjCommon),1,-1)
		local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(effect, topLayerIndex)
		if effect then
			effect.transform:SetParent(self.headGo.transform,false)
		end
		return effect
	end
    -- if this.touxiangquan~=nil then
    -- 	this.touxiangquan.gameObject:SetActive(state)
    -- end
end


-- 河北扎马
function mahjong_player_view:SetZhama(state, num)
end


function mahjong_player_view:OnDestroy()
	self:SetRoomCardNum(0)
	self:SetScore(0)
	self:SetHuaPointVisible(false)
	self:SetLianZhuang(0)
	self:SetBanker(false)
end


return mahjong_player_view