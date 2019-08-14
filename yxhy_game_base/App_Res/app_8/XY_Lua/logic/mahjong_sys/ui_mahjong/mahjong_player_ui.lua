--[[--
 * @Description: 玩家信息UI组件
 * @Author:      ShushingWong
 * @FileName:    mahjong_player_ui.lua
 * @DateTime:    2017-06-19 16:21:14
 ]]
require "logic/hall_sys/user_ui"
require "logic/mahjong_sys/_model/room_usersdata_center"
require "logic/gvoice_sys/gvoice_sys"

mahjong_player_ui = {}

mahjong_player_ui.__index = mahjong_player_ui
this = mahjong_player_ui


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

	    this.shoot = child(this.transform, "bg/obj/shoot")

		this.shootHole = {}
	    this.shootHole[1] = child(this.transform, "bg/obj/shootHole1")
	    this.shootHole[2] = child(this.transform, "bg/obj/shootHole2")
	    this.shootHole[3] = child(this.transform, "bg/obj/shootHole3")
	    --头像
	    this.head = child(this.transform,"bg/head")
	    addClickCallbackSelf(this.head.gameObject,this.Onbtn_PlayerIconClick,this)
	    --吃碰杠显示位置
	    this.operPos = child(this.transform,"bg/operPos")
	    
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
			this.seat = 1	
		elseif transform.gameObject.name == "Player2" then
			this.seat = 2
		elseif transform.gameObject.name == "Player3" then
			this.seat = 3
		elseif transform.gameObject.name == "Player4" then
			this.seat = 4		
		end
		this.logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(this.seat)
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
			this.roomCardLabel.text = "X" .. num
		end
		if num > 0 then
			this:ShowRoomCardAnim()
			this:ShowhuaEff()
		end
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
		this.huaEff = animations_sys.PlayLoopAnimation(this.huaPoint, "game_18/effects/anim_hua", "hua_1", 100, 100, 3007)
	end

	function this:HideHuaEff()
		if this.huaEff ~= nil then
			animations_sys.StopPlayAnimationToCache(this.huaEff, "game_18/effects/anim_hua")
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
	function this.SetHead( url ,type)
		-- 自己不显示UI
		if this.viewSeat == 1 then
			return
		end
		if this.headTexture==nil then
			this.headTexture = this.head.gameObject:GetComponent(typeof(UITexture))
		end
		if url == nil then
			this.headTexture = Texuture2D.whiteTexture
		end
		--mahjong_ui_sys.GetHeadPic(this.headTexture,url)
		hall_data.getuserimage(this.headTexture,type or 2,url)
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
		this.SetName(usersdata.name)
		--this.SetScore( usersdata.coin )

		-- this.SetVIP(usersdata.vip)
		this.SetHead(usersdata.headurl,usersdata.imagetype)
		this.SetMachine(false)
		this.SetOffline(this.isOffline)
		this.SetFangzhu(usersdata.owner)
	end

	function this.Hide()
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


	--设置下跑
	function this.SetPao(num)
		this.pao.gameObject:SetActive(true)
		if this.paoLabel_comp == nil then
			this.paoLabel_comp = this.paoLabel:GetComponent(typeof(UILabel))
		end
		this.paoLabel_comp.text = "x"..num
	end

	function this.HidePao()
		this.pao.gameObject:SetActive(false)
	end

	--设置托管
	function this.SetMachine(isMachine)

		this.machine.gameObject:SetActive(isMachine or false)
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
	
	local chatImgAnimationTbl = {["1"]="applause",["2"]="terrified",["3"]="cry",["4"]="crazy step",["5"]="pray",["6"]="dance",["7"]="dizzy",["8"]="laugh",["9"]="lift table",["10"]="flaunt wealth",["11"]="self drawn beard",["12"]="Look"}
	--设置聊天
	function this.SetChatImg(content)
		--componentGet(this.chat_img_sprite,"UISprite").spriteName = content
		--this.LimitChatMsgHide()
		--this.chat_img.gameObject:SetActive(true)
		--this.LimitChatMsgShow()

		--animations_sys.PlayAnimation(this.chat_img.transform,"emoticon",chatImgAnimationTbl[content],60,60,false,function()
		animations_sys.PlayAnimationByScreenPosition(this.chat_img.transform,0,0,"app_8/effects/emoticon",chatImgAnimationTbl[content],80,80,false,function()
				--callback
				end)
	end
	function this.SetChatText(content)
		componentGet(this.chat_text_label,"UILabel").text = content

		this.LimitChatMsgHide()
		--this.chat_text.gameObject:SetActive(true)
		this.LimitChatMsgShow()

		local tIndex = chat_ui.GetChatIndexByContent(content)
		if tIndex~=nil then
			ui_sound_mgr.PlaySoundClip("game_18/sound/fuzhou/"..tIndex)
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
	this.isInteractOpen = false
	function this.Onbtn_PlayerIconClick()	
		--暂时屏蔽玩家互动
		if this.seat ==1 or true then
			this.openuserinfo(this.usersdata.uid)
			return				
		end

		if isInteractOpen == false then
			this.interact.gameObject:SetActive(true)
			isInteractOpen = true
			local interactSprite = componentGet(this.interact,"UISprite")
			interactSprite.enabled = true
		else
			this.interact.gameObject:SetActive(false)
			isInteractOpen = false
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

	function this.Onbtn_PlayerInfoClick()	
		Trace(this.usersdata)
		this.openuserinfo(this.usersdata.uid)

		this.Onbtn_PlayerIconClick()
	end

	function this.openuserinfo(userid)--打开个人信息
	    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
	    waiting_ui.Show()
	    local param={["uid"]=userid,["type"]=1}
	    print(tostring(userid))
	    if userid == nil then
	    	print("userid is null")
	    	return
	    end
	    http_request_interface.getGameInfo(param,function (str) 
	        print(str)
			local s=string.gsub(str,"\\/","/")
	        local t=ParseJsonStr(s)
	        user_ui.Show()
	        user_ui.playinfo["zhengzhoumj"]=t["data"] 
	        user_ui.updateinfo(user_ui.mjtype.zhengzhoumj)  
	        waiting_ui.Hide()
	    end)
	end

	function this.Onbtn_PlayerInteraction1()
		Trace("Onbtn_PlayerInteraction1")
		mahjong_play_sys.ChatReq(4,"1","p"..this.logicSeat)
	end
	function this.Onbtn_PlayerInteraction2()
		Trace("Onbtn_PlayerInteraction2")
		mahjong_play_sys.ChatReq(4,"2","p"..this.logicSeat)
	end
	function this.Onbtn_PlayerInteraction3()
		Trace("Onbtn_PlayerInteraction3")
		mahjong_play_sys.ChatReq(4,"3","p"..this.logicSeat)
	end
	function this.Onbtn_PlayerInteraction4()
		Trace("Onbtn_PlayerInteraction4")
		mahjong_play_sys.ChatReq(4,"4","p"..this.logicSeat)
	end
	function this.Onbtn_PlayerInteraction5()
		Trace("Onbtn_PlayerInteraction5")
		mahjong_play_sys.ChatReq(4,"5","p"..this.logicSeat)
	end

	function this.ShowInteractinAnimation(viewSeat,content)
		if content == "1" then
			animations_sys.PlayAnimationByScreenPosition(this.transform,0,0,"app_8/effects/chi_peng_gang_hu","chi1",100,100,false,function()
				--callback
				end)
		elseif content == "2" then
			animations_sys.PlayAnimationByScreenPosition(this.transform,0,0,"app_8/effects/chi_peng_gang_hu","gang1",100,100,false,function()
					--callback
				end)
		elseif content =="3" then
			animations_sys.PlayAnimationByScreenPosition(this.transform,0,0,"app_8/effects/chi_peng_gang_hu","hu1",100,100,false,function()
				--callback
				end)
		elseif content == "4" then
			animations_sys.PlayAnimationByScreenPosition(this.transform,0,0,"app_8/effects/chi_peng_gang_hu","peng1",100,100,false,function()
				--callback
				end)
		elseif content == "5" then
			animations_sys.PlayAnimationByScreenPosition(this.transform,0,0,"app_8/effects/chi_peng_gang_hu","zimo1",100,100,false,function()
				--callback
				end)
		end

		this.Onbtn_PlayerIconClick()
	end

	function this.ShootTran()
		return this.shoot
	end
	
	function this.ShootHoleTran(index)
		if index <= 3 then
			return this.shootHole[index]
		end
		return nil
	end

	-------------------///点击事件处理////-----------------------------
	function this.OnHuaPointPress(go , isPress)
		if isPress then
			local flowerCards = roomdata_center.GetFlowerCards(this.viewSeat)
			if #flowerCards == 0 then
				return
			end
			local pos = mahjong_ui.GetTransform():InverseTransformPoint(go.transform.position)
			
			mahjong_ui.cardShowView:ShowHua(pos, flowerCards, this.viewSeat)

		else
			mahjong_ui.cardShowView:Hide()
		end
	end

	FindChild()
	

 	return this
end




