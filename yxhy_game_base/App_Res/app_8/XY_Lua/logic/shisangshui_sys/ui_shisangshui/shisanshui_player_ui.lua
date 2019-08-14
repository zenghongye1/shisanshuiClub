--[[--
 * @Description: 玩家信息UI组件
 * @Author:      ShushingWong
 * @FileName:    mahjong_player_ui.lua
 * @DateTime:    2017-06-19 16:21:14
 ]]
 require "logic/gvoice_sys/gvoice_sys"

shisanshui_player_ui = {}

shisanshui_player_ui.__index = shisanshui_player_ui
this = shisanshui_player_ui


function shisanshui_player_ui.New( transform )
 	local this = {}
 	setmetatable(this, shisanshui_player_ui)
 	this.transform = transform
	this.viewSeat = -1
	this.all_score = 0
 	local function FindChild()
		-- --吓跑
		-- this.pao = child(this.transform, "bg/pao")
		-- if this.pao~=nil then
		--    this.pao.gobj = this.pao.gameObject
	 --       this.pao.gobj:SetActive(false)
	 --    end
	 --    this.paoLabel = child(this.transform,"bg/pao/Label")
	 --    --VIP
		-- this.vip = child(this.transform, "bg/head/vip")
		-- if this.vip~=nil then
	 --       this.vip.gameObject:SetActive(false)
	 --    end
	 	this.roomCardLabel = subComponentGet(this.transform, "bg/roomCard/roomCardNum", typeof(UILabel))
	 	this.SetRoomCardNum(0)

	 	-- 花牌图标
	 	this.huaPoint = child(this.transform, "bg/roomCard")

	    --庄家
		this.banker = child(this.transform, "bg/head/banker")
		if this.banker~=nil then
	       this.banker.gameObject:SetActive(false)
	    end
		--房主
		this.fangzhu = child(this.transform, "bg/head/fangzhu")
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
	    this.score = child(this.transform, "bg/score/scorelabel")
		if this.score ~= nil then
			--this.score.gameObject:SetActive(false)
			this.SetScore(this.all_score)
		end
	    --昵称
	    this.name = child(this.transform, "bg/name")
	    --准备状态
		this.readystate = child(this.transform, "bg/obj/readystate")
		if this.readystate~=nil then
	       this.readystate.gameObject:SetActive(false)
	    end
		
		--显示正数总分
		this.positiveLabel = child(this.transform,"bg/pao/positiveLabel")
		if this.positiveLabel ~= nil then
			this.positiveLabel.gameObject:SetActive(false)
		end
		
		--显示负数总分
		this.negativeLabel = child(this.transform,"bg/pao/negativeLabel")
		if this.negativeLabel ~= nil then
			this.negativeLabel.gameObject:SetActive(false)
			
		end
		
		--显示水庄倍数
		this.beishuLabel = child(this.transform,"bg/pao/beishuLabel")
		if this.beishuLabel ~= nil then
			this.beishuLabel.gameObject:SetActive(false)
		end

	    this.shoot = child(this.transform, "bg/obj/shoot")

		this.shootHole = {}
	    this.shootHole[1] = child(this.transform, "bg/obj/shootHole1")
	    this.shootHole[2] = child(this.transform, "bg/obj/shootHole2")
	    this.shootHole[3] = child(this.transform, "bg/obj/shootHole3")
	    --头像
	    this.head = child(this.transform,"bg/head")
	    
		 --聊天
	    this.chat_root = child(this.transform,"bg/chat")
	    if this.chat_root~=nil then
	    	this.chat_root.gameObject:SetActive(true)
		end
	    this.chat_img = child(this.chat_root,"img_root")
	    if this.chat_img~=nil then
	    	this.chat_img.gameObject:SetActive(true)
	    end
	    this.chat_img_sprite = child(this.chat_img,"img")
	    if this.chat_img_sprite ~=nil then
	    	this.chat_img_sprite.gameObject:SetActive(false)
	    end
	    this.chat_text_root = child(this.chat_root,"text_root")
	    if this.chat_text_root~=nil then
	    	this.chat_text_root.gameObject:SetActive(true)
	    	for i=0,this.chat_text_root.transform.childCount-1 do
	    		local child = this.chat_text_root.transform:GetChild(i)
	    		if child~=nil then
	    			child.gameObject:SetActive(false)
	    		end
	    	end
	    end
	    -- this.chat_text = child(this.chat_root,"text_root")
	    -- if this.chat_text~=nil then
	    -- 	this.chat_text.gameObject:SetActive(false)
	    -- end
	    -- this.chat_text_label = child(this.chat_text,"msg")

	    this.chatSoundRoot = child(this.chat_root,"sound_root")
	    if this.chatSoundRoot~=nil then
	    	this.chatSoundRoot.gameObject:SetActive(true)
	    	for i=0,this.chatSoundRoot.transform.childCount-1 do
	    		local child = this.chatSoundRoot.transform:GetChild(i)
	    		if child~=nil then
	    			child.gameObject:SetActive(false)
	    		end
	    	end
	    end

	    if transform.gameObject.name == "Player1" then
			this.seat = 1	
		elseif transform.gameObject.name == "Player2" then
			this.seat = 2
		elseif transform.gameObject.name == "Player3" then
			this.seat = 3
		elseif transform.gameObject.name == "Player4" then
			this.seat = 4		
		elseif transform.gameObject.name == "Player5" then
			this.seat = 5		
		elseif transform.gameObject.name == "Player6" then
			this.seat = 6		
		end
		this.logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(this.seat)

	end

    --设置金币
	
	function this.SetScore( score )
		if this.scorelabel==nil then
			this.scorelabel = this.score.gameObject:GetComponent(typeof(UILabel))
		end
		if score == nil then score = 0 end
		this.all_score =  tonumber(this.all_score) + tonumber(score)
		Trace("+++++更新总积分+++"..tostring(this.all_score).."坐位号"..tostring(this.viewSeat))
	--	this.scorelabel.text = score
		this.scorelabel.text =  tostring(this.all_score)
	end
	
	function this.AddScore(score)
		if this.scorelabel==nil then
			this.scorelabel = this.score.gameObject:GetComponent(typeof(UILabel))
		end
		if score == nil then score = 0 end
		this.all_score =  score
		this.scorelabel.text =  tostring(score)
	end
	
	function this.SetTotalPoints(points)
		this.positiveLabel.gameObject:SetActive(false)
		this.negativeLabel.gameObject:SetActive(false)
		if points ~= nil then
			if points > 0 then
				local pointsLabel = this.positiveLabel.gameObject:GetComponent(typeof(UILabel))
				pointsLabel.text = "+"..tostring(points)
				componentGet(this.positiveLabel,"TweenPosition"):ResetToBeginning ()
				this.positiveLabel.gameObject:SetActive(true)
				componentGet(this.positiveLabel,"TweenPosition").enabled =true
			else
				local negativeLabel = this.negativeLabel.gameObject:GetComponent(typeof(UILabel))
				negativeLabel.text = tostring(points)
				componentGet(this.negativeLabel,"TweenPosition"):ResetToBeginning ()
				this.negativeLabel.gameObject:SetActive(true)
				componentGet(this.negativeLabel,"TweenPosition").enabled =true
			end
		end
	end
	
	function this.HideTotalPoints()
		if this.positiveLabel == nil then
			this.positiveLabel = child(this.transform,"bg/pao/positiveLabel")
		end
		
		if this.negativeLabel == nil then
			this.negativeLabel = child(this.transform,"bg/pao/negativeLabel")
		end
		this.positiveLabel.gameObject:SetActive(false)
		this.negativeLabel.gameObject:SetActive(false)
		this.positiveLabel.localPosition=Vector3(0,0,0)
		this.negativeLabel.localPosition=Vector3(0,0,0)	
	end
	
	function this.SetBeiShu(beishu)
		local beishuLabel = this.beishuLabel.gameObject:GetComponent(typeof(UILabel))
		beishuLabel.text = tostring(beishu).."B"
		this.beishuLabel.gameObject:SetActive(true)
	end
	
	function this.HideBeiShu()
		this.beishuLabel.gameObject:SetActive(false)
	end
	
	function this.SetRoomCardNum( num )
		if this.roomCardLabel ~= nil then
			this.roomCardLabel.text = "X" .. num
		end
	end


	--设置昵称
	function this.SetName( name )
		if this.namelabel==nil then
			this.namelabel = this.name.gameObject:GetComponent(typeof(UILabel))
		end
		this.namelabel.text = name
	end

	--设置头像
	function this.SetHead( url )
		-- 自己不显示UI
		if this.viewSeat == 1 then
	--		return
		end
		if this.headTexture==nil then
			this.headTexture = this.head.gameObject:GetComponent(typeof(UITexture))
		end
		--hisangshui_ui_sys.GetHeadPic(this.headTexture,url)
		hall_data.getuserimage(this.headTexture,2,url)
	end
	
	--设置VIP等级，0不显示
	function this.SetVIP(level)
		-- if level>0 then
		-- 	this.vip.gameObject:SetActive(true)
		-- else
		-- 	this.vip.gameObject:SetActive(false)
		-- end
	end

	--显示玩家用户
	function this.Show( usersdata, viewSeat )
		this.transform.gameObject:SetActive(true)
		this.viewSeat = viewSeat
		this.SetName(usersdata.name)
	--	this.SetScore( this.all_score)
		-- this.SetVIP(usersdata.vip)
		this.SetHead(usersdata.headurl)
		this.SetMachine(false)
	--	this.SetOffline(false)
		this.SetFangzhu(usersdata.owner)
	end

	function this.Hide()
		this.transform.gameObject:SetActive(false)
		this.SetOffline(false)
	end

	--设置准备状态
	function this.SetReady( isReady )
		this.readystate.gameObject:SetActive(isReady or false)
	end
	
	--设置准备按钮的坐标位置
	function this.SetReadyLocalPosition(x,y)
		this.readystate.gameObject.transform.localPosition = Vector3(x,y,0)
	end

	--设置聊天消息坐标位置
	function this.SetChatTextLocalPosition(index,x,y)
		this.chat_text = child(this.chat_text_root,"text_root"..tostring(index))
	    if this.chat_text~=nil then
	    	this.chat_text.gameObject:SetActive(false)

	    	this.chat_text.transform.localPosition = Vector3.New(x,y,0)
	    end
	    this.chat_text_label = child(this.chat_text,"msg")
	end

	--设置语音消息坐标位置
	function this.SetChatSoundLocalPosition(index,x,y)
		this.chat_sound = child(this.chatSoundRoot,"sound_root"..tostring(index))
	    if this.chat_sound~=nil then
	    	this.chat_sound.gameObject:SetActive(false)

	    	this.chat_sound.transform.localPosition = Vector3.New(x,y,0)
	    end
	end

	--设置庄家
	function this.SetBanker(isBanker)
		this.banker.gameObject:SetActive(isBanker or false)
	end

	--设置房主
	function this.SetFangzhu(isFangzhu)
		this.fangzhu.gameObject:SetActive(isFangzhu or false)
	end
	
	--设置下跑
	function this.SetPao(num)
		-- this.pao.gameObject:SetActive(true)
		-- if this.paoLabel_comp == nil then
		-- 	this.paoLabel_comp = this.paoLabel:GetComponent(typeof(UILabel))
		-- end
		-- this.paoLabel_comp.text = "x"..num
	end

	function this.HidePao()
		-- this.pao.gameObject:SetActive(false)
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
		this.offline.gameObject:SetActive(isOffline or false)
	end

	function this.GetHuaPointPos()
		return this.huaPoint.position
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
	
	local chatImgAnimationTbl = {["1"]="benpao",["2"]="bishi",["3"]="buhaoyisi",["4"]="fanu",["5"]="haiye",["6"]="jingya",["7"]="kuqi",["8"]="shuqian",["9"]="xuanyao"}
	
	--设置聊天
	function this.SetChatImg(content)
		local renderQueue = 0
		local nameLabel = subComponentGet(this.transform, "bg/name", typeof(UILabel))
		-- local headTex = subComponentGet(this.transform, "bg/head", "UITexture")
		if nameLabel ~= nil then
			renderQueue = nameLabel.drawCall.renderQueue + 2
		end
		Trace("______"..tostring(content))
		animations_sys.PlayAnimationByScreenPosition(child(this.transform, "chatAniRoot"),0,0,"app_8/effects/emoticon2",chatImgAnimationTbl[content],120,120,false, function()			
		end, renderQueue)
	end

	function this.SetChatText(content)
		componentGet(this.chat_text_label,"UILabel").text = content

		this.LimitChatMsgHide()
		this.chat_text.gameObject:SetActive(true)
		this.LimitChatMsgShow()

		local tIndex = chat_ui.GetChatIndexByContent(content)
		if tIndex~=nil then
			ui_sound_mgr.PlaySoundClip("game_80011/sound/shisanshui/"..tIndex)
		else
			Trace("chat sound not exit!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		end
	end
	
	local timer_Elapse = nil --消息时间间隔
	function this.LimitChatMsgShow()
		timer_Elapse = Timer.New(this.OnTimer_Proc , 3, 1)
		timer_Elapse:Start()
		this.chat_text.gameObject:SetActive(true)
	end
	function this.LimitChatMsgHide()
		if timer_Elapse ~= nil then
		    timer_Elapse:Stop()		
		    timer_Elapse = nil    
		end
		--this.chat_img.gameObject:SetActive(false)
		this.chat_text.gameObject:SetActive(false)
	end
	
		function this.OnTimer_Proc()
		--this.chat_img.gameObject:SetActive(false)
		this.chat_text.gameObject:SetActive(false)
	end

	--语音聊天模块
	function this.SetSoundTextureState(state)
		this.chat_sound.gameObject:SetActive(state)
	end

	FindChild()

 	return this
end




