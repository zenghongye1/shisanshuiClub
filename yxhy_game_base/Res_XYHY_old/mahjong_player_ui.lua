--[[--
 * @Description: 玩家信息UI组件
 * @Author:      ShushingWong
 * @FileName:    mahjong_player_ui.lua
 * @DateTime:    2017-06-19 16:21:14
 ]]
require "logic/mahjong_sys/_model/room_usersdata_center"
require "logic/gvoice_sys/gvoice_sys"

mahjong_player_ui = {}

mahjong_player_ui.__index = mahjong_player_ui
this = mahjong_player_ui

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

function mahjong_player_ui.New( transform )
 	local this = {}
 	setmetatable(this, mahjong_player_ui)
 	this.transform = transform
 	this.usersdata = {}
 	this.isOffline = false

 	local function FindChild()
	 	this.roomCardLabel = subComponentGet(this.transform, "bg/roomCard/roomCardNum", typeof(UILabel))
	 	this.SetRoomCardNum(0)
	 	--吓跑
		this.pao = child(this.transform, "bg/pao")
		if this.pao~=nil then
		   this.pao.gobj = this.pao.gameObject
	       this.pao.gobj:SetActive(false)
	    end
	    this.paoStateSp = subComponentGet(this.transform, "bg/paoState", typeof(UISprite))
	    this.paoStateSp.gameObject:SetActive(false)
	    this.paoLabel = child(this.transform,"bg/pao/Label")
	    --VIP
		this.vip = child(this.transform, "bg/head/vip")
		if this.vip~=nil then
	       this.vip.gameObject:SetActive(false)
	    end

	 	-- 花牌图标
	 	this.huaPoint = child(this.transform, "bg/roomCard")
	 	addPressedCallback(this.transform, "bg/roomCard", this.OnHuaPointPress)

	    --庄家

		this.banker = child(this.transform, "bg/head/headPanel/banker")
		if this.banker~=nil then
	       this.banker.gameObject:SetActive(false)
	    end

	    --连庄数
	    this.lianzhuangNum = child(this.transform,"bg/head/headPanel/banker/lianzhuangNum")
	    if this.lianzhuangNum~=nil then
	    	this.lianzhuangNum.gameObject:SetActive(false)
	    end

	    -- 房主 
		this.fangzhu = child(this.transform, "bg/head/headPanel/fangzhu")
		if this.fangzhu~=nil then
	       this.fangzhu.gameObject:SetActive(false)
	    end

	    --托管
		this.machine = child(this.transform, "bg/head/machine")
		if this.machine~=nil then
	       this.machine.gameObject:SetActive(false)
	    end
	    --离线
		this.offline = child(this.transform, "bg/head/offline")
		if this.offline~=nil then
	       this.offline.gameObject:SetActive(false)
	    end
	    --互动
		this.interact = child(this.transform, "bg/head/personalInfo")
		if this.interact~=nil then
	       this.interact.gameObject:SetActive(false)
	    end
	    --金币
	    this.scoreRoot = child(this.transform, "bg/score")
	    this.score = child(this.transform, "bg/score/scorelabel")
	    this.SetScore(0)
	    --昵称
	    this.name = child(this.transform, "bg/name")
	    --准备状态
		this.readystate = child(this.transform, "bg/readystate")
		if this.readystate~=nil then
	       this.readystate.gameObject:SetActive(false)
	    end
	    
	    --头像
	    this.head = child(this.transform,"bg/head")
	    addClickCallbackSelf(this.head.gameObject,this.Onbtn_PlayerIconClick,this)
	    --吃碰杠显示位置
	    this.operPos = child(this.transform,"bg/operPos")

	    --头像圈
	    -- this.touxiangquan = child(this.transform,"bg/head/quan")
	    -- if this.touxiangquan~=nil then
	    -- 	this.touxiangquan.gameObject:SetActive(false)
	    -- end
	    
	    --聊天
	    this.chat_root = child(this.transform,"bg/chat")
	    if this.chat_root~=nil then
	    	this.chat_root.gameObject:SetActive(true)
		end
	    this.chat_img = child(this.chat_root,"img_root")
	    if this.chat_img~=nil then
	    	--this.chat_img.gameObject:SetActive(false)
	    end
	    this.chat_img_sprite = child(this.chat_img,"img")
	    if this.chat_img_sprite ~=nil then
	    	this.chat_img_sprite.gameObject:SetActive(false)
	    end
	    this.chat_text = child(this.chat_root,"text_root")
	    if this.chat_text~=nil then
	    	this.chat_text.gameObject:SetActive(false)
	    end
	    this.chat_text_label = child(this.chat_text,"msg")

	    this.chatSoundRoot = child(this.chat_root,"sound_root")
	    if this.chatSoundRoot~=nil then
	    	this.chatSoundRoot.gameObject:SetActive(false)
	    end

--[[
	    --玩家交互
	    --个人信息
	    this.PlayerInfo = child(this.transform,"bg/head/personalInfo")
	    addClickCallbackSelf(this.PlayerInfo.gameObject,this.Onbtn_PlayerInfoClick,this)

	    this.PlayerInteraction1 = child(this.transform,"bg/head/personalInfo/1")
	    addClickCallbackSelf(this.PlayerInteraction1.gameObject,this.Onbtn_PlayerInteraction1,this)
	    this.PlayerInteraction2 = child(this.transform,"bg/head/personalInfo/2")
	    addClickCallbackSelf(this.PlayerInteraction2.gameObject,this.Onbtn_PlayerInteraction2,this)
	    this.PlayerInteraction3 = child(this.transform,"bg/head/personalInfo/3")
	    addClickCallbackSelf(this.PlayerInteraction3.gameObject,this.Onbtn_PlayerInteraction3,this)
	    this.PlayerInteraction4 = child(this.transform,"bg/head/personalInfo/4")
	    addClickCallbackSelf(this.PlayerInteraction4.gameObject,this.Onbtn_PlayerInteraction4,this)
	    this.PlayerInteraction5 = child(this.transform,"bg/head/personalInfo/5")
	    addClickCallbackSelf(this.PlayerInteraction5.gameObject,this.Onbtn_PlayerInteraction5,this)
]]
	    if transform.gameObject.name == "Player1" then
			this.index = 1	
		elseif transform.gameObject.name == "Player2" then
			this.index = 2
		elseif transform.gameObject.name == "Player3" then
			this.index = 3
		elseif transform.gameObject.name == "Player4" then
			this.index = 4		
		end

		-- 麻将2人特殊处理
		-- if roomdata_center.MaxPlayer() == 2 and this.index == 3 then 
	 --        this.seat = 2
	 --    end
	    
		--this.logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(this.viewSeat)
	end

    --设置金币
	function this.SetScore( score )
		if this.scorelabel==nil then
			this.scorelabel = this.score.gameObject:GetComponent(typeof(UILabel))
		end
		this.scorelabel.text = score
	end

	function this.SetRoomCardNum( num )
		if this.roomCardLabel ~= nil then
			if this.index == 2 then
				this.roomCardLabel.text =  num .. "X"
			else
				this.roomCardLabel.text = "X" .. num
			end
		end
		if num > 0 then
			this:ShowRoomCardAnim()
			this:ShowhuaEff()
		end

		local cards = roomdata_center.GetFlowerCards(self.viewSeat)
		self.flowerCards:SetFlowers(cards)
	end


	local lable_c
	function this:ShowRoomCardAnim()
		if lable_c ~= nil then
			coroutine.stop(lable_c)
		end
		lable_c = coroutine.start(function() 
			this:ShowhuaEff()
			this.roomCardLabel.transform:DOScale(1.6, 0.5)
			coroutine.wait(0.5)
			this.roomCardLabel.transform:DOScale(1, 0.5)
			coroutine.wait(0.5)
			this:HideHuaEff()
			lable_c = nil
			end)
	end

	function this:ShowhuaEff()
		this:HideHuaEff()
		this.huaEff = animations_sys.PlayLoopAnimation(this.huaPoint, mahjong_path_mgr.GetEffPath("anim_hua", mahjong_path_enum.mjCommon), "hua_1", 100, 100, 3007)
	end

	function this:HideHuaEff()
		if this.huaEff ~= nil then
			animations_sys.StopPlayAnimationToCache(this.huaEff, mahjong_path_mgr.GetEffPath("anim_hua", mahjong_path_enum.mjCommon))
			this.huaEff = nil
		end
	end


	--设置昵称
	function this.SetName( name )
		name = name or nil
		if this.namelabel==nil then
			this.namelabel = this.name.gameObject:GetComponent(typeof(UILabel))
		end
		this.namelabel.text = name
	end

	--设置头像
	function this.SetHead( url ,_type)
		-- 自己不显示UI
		if this.headTexture==nil then
			this.headTexture = this.head.gameObject:GetComponent(typeof(UITexture))
		end
		if url == nil then
			this.headTexture = Texuture2D.whiteTexture
		end
		hall_data.getuserimage(this.headTexture,_type or 2,url)
	end
	
	--设置VIP等级，0不显示
	function this.SetVIP(level)
		if level>0 then
			this.vip.gameObject:SetActive(true)
		else
			this.vip.gameObject:SetActive(false)
		end
	end

	--显示玩家用户

	function this.Show( usersdata, viewSeat )
		this.usersdata = usersdata
		this.transform.gameObject:SetActive(true)
		this.viewSeat = viewSeat
		this.logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(this.viewSeat)
		this.SetName(usersdata.name)
		--this.SetScore( usersdata.coin )

		-- this.SetVIP(usersdata.vip)
		if usersdata.headurl and usersdata.headurl~="" then
			this.SetHead(usersdata.headurl,usersdata.imagetype)
		end
		this.SetMachine(false)
		this.SetOffline(this.isOffline)
		this.SetFangzhu(usersdata.owner)
		if usersdata.saved then
			gps_data.SetGpsData(usersdata.headurl,usersdata.imagetype,this.index,viewSeat,usersdata.saved)
		end
	end

	function this.Hide()
		gps_data.RemoveOne(this.index)
		this.transform.gameObject:SetActive(false)
		this.SetReady(false)
	end

	--设置准备状态
	function this.SetReady( isReady )
		this.readystate.gameObject:SetActive(isReady or false)
	end

	--设置庄家
	function this.SetBanker(isBanker)
		if this.banker~=nil then
	       this.banker.gameObject:SetActive(isBanker or false)
	    end
	end

	--设置连庄数
	function this.SetLianZhuang(lianZhuang)
		if lianZhuang==nil then
			Trace("服务端没发连庄数过来，让服务端检查下")
			this.lianzhuangNum.gameObject:SetActive(false)
			return
		elseif lianZhuang == 0 then
			this.lianzhuangNum.gameObject:SetActive(false)
			return
		end
		lianZhuang = lianZhuang + 1
		Trace("viewSeat:"..tostring(this.viewSeat).."	连庄数："..tostring(lianZhuang))
		if this.lianzhuangNum~=nil then
			this.lianzhuangNum.gameObject:SetActive(true)
			componentGet(this.lianzhuangNum,"UILabel").text = tostring(lianZhuang)
		end
	end

	--设置房主
	function this.SetFangzhu(isFangzhu)
		if this.fangzhu~=nil then
	       this.fangzhu.gameObject:SetActive(isFangzhu or false)
	    end
	end

	-- 设置花信息是否显示

	function this.SetHuaPointVisible(value)
		if this.huaPoint ~= nil then
			this.huaPoint.gameObject:SetActive(value)
		end
	end

	function this.SetScoreVisible(value)
		if this.scoreRoot ~= nil then
			this.scoreRoot.gameObject:SetActive(value)
		end
	end


	function this.UpdateXiaPaoState(value)
		if value == 1 then
			this.paoStateSp.gameObject:SetActive(false)
			return
		end
		this.paoStateSp.gameObject:SetActive(true)
		if value == 2 then
			this.paoStateSp.spriteName = "room_niu_02"
		elseif value == 3 then
			this.paoStateSp.spriteName = "room_majiang_04"
		else
			this.paoStateSp.spriteName = "room_majiang_03"
		end
		this.paoStateSp:MakePixelPerfect()
	end


	--设置下跑
	function this.SetPao(num)
		this.pao.gameObject:SetActive(true)
		if this.paoLabel_comp == nil then
			this.paoLabel_comp = this.paoLabel:GetComponent(typeof(UILabel))
		end
		this.paoLabel_comp.text = "注+"..num
	end

	function this.HidePao()
		this.pao.gameObject:SetActive(false)
	end

	--设置托管
	function this.SetMachine(isMachine)

		--this.machine.gameObject:SetActive(isMachine or false)
	end


	--设置互动
	function this.SetInteract(isInteract)
		this.interact.gameObject:SetActive(isInteract or false)
	end

	--设置离线
	function this.SetOffline(isOffline)
		this.isOffline = isOffline
		this.offline.gameObject:SetActive(isOffline or false)
	end

	function this.GetHuaPointPos()
		return this.huaPoint.position
	end
	
	-- local chatImgAnimationTbl = {["1"]="applause",["2"]="terrified",["3"]="cry",["4"]="crazy step",["5"]="pray",["6"]="dance",["7"]="dizzy",["8"]="laugh",["9"]="lift table",["10"]="flaunt wealth",["11"]="self drawn beard",["12"]="Look"}
	-- --设置聊天
	-- function this.SetChatImg(content)
	-- 	--componentGet(this.chat_img_sprite,"UISprite").spriteName = content
	-- 	--this.LimitChatMsgHide()
	-- 	--this.chat_img.gameObject:SetActive(true)
	-- 	--this.LimitChatMsgShow()

	-- 	--animations_sys.PlayAnimation(this.chat_img.transform,"emoticon",chatImgAnimationTbl[content],60,60,false,function()
	-- 	local animtGObj = animations_sys.PlayAnimationByScreenPosition(this.chat_img.transform,0,0,data_center.GetAppConfDataTble().appPath.."/effects/emoticon",chatImgAnimationTbl[content],80,80,false,function()
	-- 			--callback
	-- 			end, 3010)

	-- 	if animtGObj and this.sortingOrder then
	-- 		local topLayerIndex = this.sortingOrder +this.m_subPanelCount +1
	-- 		Utils.SetEffectSortLayer(animtGObj, topLayerIndex)
	-- 	end
	-- end
	local chatImgAnimationTbl = {
			["1"]="01_feiwen",["2"]="02_deyi",["3"]="03_haose",["4"]="04_tianping",["5"]="05_shaxiao",
			["6"]="06_paoxiao",["7"]="07_shuashuai",["8"]="08_chaoxiao",["9"]="09_xinsui",["10"]="10_daku",
			["11"]="11_tongku",["12"]="12_weiquku",["13"]="13_benkui",["14"]="14_tu",["15"]="15_jingdiaoya",
			["16"]="16_qituxue",["17"]="17_nibuxing",["18"]="19_qidao",["19"]="20_touyun",["20"]="22_bishi",
			["21"]="23_maohan",["22"]="24_zaijian",["23"]="25_gun",["24"]="26_kan",["25"]="27_jingkong",
			["26"]="28_zhuangpingmu",
		}
	--设置聊天
	function this.SetChatImg(content)
		local renderQueue = 3500
		-- local nameLabel = subComponentGet(self.transform, "bg/name", typeof(UILabel))
		-- if nameLabel ~= nil then
		-- 	renderQueue = 3500
		-- end
		-- Trace("______"..tostring(content))

		local animPath = data_center.GetAppConfDataTble().appPath.."/effects/expression_new"
		local animtGObj = animations_sys.PlayAnimationByScreenPosition(child(this.transform, "chatAniRoot"),0,100,animPath,
			chatImgAnimationTbl[content],120,120,false, function()
			--
		end, renderQueue)

		if animtGObj and this.sortingOrder then
			local topLayerIndex = this.sortingOrder +this.m_subPanelCount +1
			Utils.SetEffectSortLayer(animtGObj, topLayerIndex)
			-- Trace("topLayerIndextopLayerIndextopLayerIndex--"..topLayerIndex)
		end
	end

	function this.SetChatText(content)
		componentGet(this.chat_text_label,"UILabel").text = content

		this.LimitChatMsgHide()
		--this.chat_text.gameObject:SetActive(true)
		this.LimitChatMsgShow()

		local tIndex = chat_model.GetChatIndexByContent(content)
		if tIndex~=nil then
			ui_sound_mgr.PlaySoundClip(data_center.GetAppPath().."/mj_common/sound/chat/woman/"..tIndex)
		else
			Trace("chat sound not exit!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		end
	end

	this.timer_Elapse = nil --消息时间间隔
	function this.LimitChatMsgShow()
		this.timer_Elapse = Timer.New(this.OnTimer_Proc , 3, 1)
		this.timer_Elapse:Start()
		this.chat_text.gameObject:SetActive(true)
	end
	function this.LimitChatMsgHide()
		if this.timer_Elapse ~= nil then
		    this.timer_Elapse:Stop()	
		   	this.timer_Elapse = nil	    
		end
		--this.chat_img.gameObject:SetActive(false)
		this.chat_text.gameObject:SetActive(false)
	end
	function this.OnTimer_Proc()
		--this.chat_img.gameObject:SetActive(false)
		if this.chat_text ~= nil and this.chat_text.gameObject ~= nil then
			this.chat_text.gameObject:SetActive(false)
		end
	end

	--互动功能
	function this.Onbtn_PlayerIconClick()
		if this.viewSeat ~= 1 then
			if not this.PlayerInfo then
			    this.PlayerInfo = child(this.transform,"bg/head/personalInfo")
			    addClickCallbackSelf(this.PlayerInfo.gameObject,this.Onbtn_PlayerInfoClick,this)
				
				-- 全局点击关闭
				local boxCollider = componentGet(this.PlayerInfo.transform,"BoxCollider")
				if boxCollider then
					boxCollider.size = Vector3(2500,1500,1)
				end
			end
			this.PlayerInfo.gameObject:SetActive(true)
			
			mahjong_ui.InteractionView.actionTran = this.PlayerInfo
			mahjong_ui.InteractionView.logicSeat = this.logicSeat
			mahjong_ui.InteractionView:RegisterOnClick()
		end
	end

	--语音聊天模块
	function this.SetSoundTextureState(state)
		this.chatSoundRoot.gameObject:SetActive(state)
        if state==true then
            ui_sound_mgr.SetAllAudioSourceMute(true)
        else
            ui_sound_mgr.SetAllAudioSourceMute(false)
        end
	end

	function this.OnDestroy()
		if this.headTexture ~= nil then
			--GameObject.Destroy(this.headTexture.mainTexture)
		end
	end

	function this.Onbtn_PlayerInfoClick(obj)	
		-- Trace(this.usersdata)
		-- this.openuserinfo(this.usersdata.uid)

		-- this.Onbtn_PlayerIconClick()

		-- Trace("Onbtn_PlayerInfoClick")
		if this.PlayerInfo and this.PlayerInfo.gameObject then
			this.PlayerInfo.gameObject:SetActive(false)
		end
	end
	function this.hidePlayerInfoClick()
		if this.PlayerInfo and this.PlayerInfo.gameObject then
			this.PlayerInfo.gameObject:SetActive(false)
		end
	end

	-- 播放互动表情
	function this.playInteractiveExpressionAnimation(_iKind, _fromPos, _toPos)
		
		-- 换图
		local prefabPath = data_center.GetAppConfDataTble().appPath.."/mj_common/effects/interactive_expression"
	    local prefabObj = newNormalObjSync(prefabPath, typeof(GameObject))
		if prefabObj then
		    local animObj = newobject(prefabObj)
		    animObj.transform.parent = this.transform

		    local headPanel = child(this.transform, "bg/head/headPanel")
		    if headPanel then
		    	animObj.transform.parent = headPanel

		    	-- 设置to相对坐标0
		    	local curPos = headPanel.transform.localPosition
				_toPos.x = _toPos.x -curPos.x
				_toPos.y = _toPos.y -curPos.y

			    local head = child(this.transform, "bg/head")
			    if head then
			    	-- 设置from相对坐标0
			    	local curPos2 = head.transform.localPosition
					_fromPos.x = _fromPos.x -curPos2.x -curPos.x
					_fromPos.y = _fromPos.y -curPos2.y -curPos.y
			    end
		    end

			local animIndex = 0
			local animData = iEAnimTbl[_iKind]
			-- this.InteractiveExSprite = subComponentGet(this.transform, "bg/InteractiveExSprite", typeof(UISprite))
			local interactiveExSprite = componentGet(animObj, "UISprite")
			interactiveExSprite.spriteName = animData.frameName..animIndex
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
					-- Trace("InteractiveExSpriteFrame:"..animData.frameName..animIndex)
		  	 		if animIndex <animData.frameCount then
						animIndex = animIndex +1
						interactiveExSprite.spriteName = animData.frameName..animIndex
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

	function this.ShowInteractinAnimation(viewSeat,content)
		Trace("ShowInteractinAnimation:"..viewSeat..","..content)
		
		local iAnimKind = 1
		if content == "1" then
			iAnimKind = 1
		elseif content == "2" then
			iAnimKind = 2
		elseif content =="3" then
			iAnimKind = 3
		elseif content == "4" then
			iAnimKind = 4
		elseif content == "5" then
			iAnimKind = 5
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
			local curPos = this.transform.localPosition
			fromPos = Vector3.New(fromPos.x-curPos.x, fromPos.y-curPos.y, 0)
			-- 播放动画
			this.playInteractiveExpressionAnimation(iAnimKind, fromPos, Vector3.zero)
		end

		-- 播放音效
		local sfxName = iESfxTbl[iAnimKind]
		if sfxName then
			ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/specialFace/"..sfxName)
		end

		-- this.Onbtn_PlayerIconClick()
	end

	function this.SetYoustatus(status)
		local aniId
		if status == 2 then
			aniId = 20010
		elseif status ==3 then
			aniId = 20011
		elseif status ==9 then
			aniId = 20012
		elseif status ==1 then
			aniId = 20013
		end

		mahjong_effectMgr:PlayUIEffectById(aniId,this.chat_img.transform)
	end

	function this.SetHeadEffect(state)
		if state then
			local effect = EffectMgr.PlayEffect(mahjong_path_mgr.GetEffPath("Effect_wanjiatouxiang",mahjong_path_enum.mjCommon),1,-1)
			if effect then
				effect.transform:SetParent(this.head,false)
			end
			return effect
		end
	    -- if this.touxiangquan~=nil then
	    -- 	this.touxiangquan.gameObject:SetActive(state)
	    -- end
	end


	-------------------///点击事件处理////-----------------------------
	function this.OnHuaPointPress(go , isPress)
		if isPress then
			local flowerCards = roomdata_center.GetFlowerCards(this.viewSeat)
			if #flowerCards == 0 then
				return
			end
			local pos = mahjong_ui:GetTransformPanel():InverseTransformPoint(go.transform.position)
			
			mahjong_ui.cardShowView:ShowHua(pos, flowerCards, this.viewSeat)

		else
			mahjong_ui.cardShowView:Hide()
		end
	end

	FindChild()
	

 	return this
end




