table_component = {}

function table_component.create()
	require "logic/mahjong_sys/mode_components/mode_comp_base"
	require "logic/hall_sys/openroom/room_data"
	local this = mode_comp_base.create()
	this.Class = table_component
	this.name = "table_component"
	this.PlayerList = {} 	--玩家列表
	this.PlayerTransformList = {}
	this.tableCenter = nil
	this.cardTranPool = {}	
	this.gun = nil
	this.CardModelTrans = {}
	this.ShootAnimationTabel = {}
	this.compareCoroutine = nil

	local pokerObj = nil

	this.resMgrComponet = resMgr_component.create()
	this.resMgrComponet.LoadCardMesh()


 	this.base_init = this.Initialize
 	this.base_uninit = this.Uninitialize
	function this:Initialize()
		this.base_init()
		
		this.Init()
	end

	function this:Uninitialize()
		this.base_uninit()
	end
	
	function this.Init()
		pokerObj = child(this.tableCenter.transform, "Poker_Animaiton").gameObject
	end

	--[[--
	 * @Description: 洗牌
	 ]]
	function this.WashCard(callback)
		coroutine.start(function()
			ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/xipai")   --洗牌音效
			if not IsNil(pokerObj) then
				this.tableCenter:SetActive(true)
				pokerObj:SetActive(true)		
				coroutine.wait(1.2)
				pokerObj:SetActive(false)
				this.tableCenter:SetActive(false)
			end
			if callback ~= nil then
				callback()
				callback = nil
			end
		end)		
	end

	--[[--
	 * @Description: 初始化手牌  
	 ]]
	function this.InitCardPool(callback)
		if this.cardTranPool == nil or #this.cardTranPool < 1 then
			for i = 1, #this.PlayerList * 13 do 
				local cardPrefab = newNormalObjSync("game_80011/scene/card",typeof(GameObject))
				local cardTran =  newobject(cardPrefab).transform
				cardTran.parent = this.tableCenter.transform
				cardTran.localPosition = Vector3(0, i/20, 0)
				cardTran.localEulerAngles = Vector3(0, 0, 180)
				table.insert(this.cardTranPool, cardTran)
			end
		end
		this.DealAnimation(callback)
	end

	--发牌动作
	function  this.DealAnimation(callback)
		local count = 1
		this.ResetDeal()

		coroutine.start(function ()								
			this.ShowDeal()
			ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/fapai")  ----发牌音效
			for i =1, #this.cardTranPool / #this.PlayerList do
				for j ,Player in ipairs(this.PlayerList) do				
					--需要边移动边旋转
					local tmpTran = Player.playerObj.transform
					this.cardTranPool[count]:DOMove(tmpTran.position, 0.3, false)
					local toRotate = this.cardTranPool[count].localRotation + Vector3(0, i*50, 0)
					this.cardTranPool[count]:DOBlendableLocalRotateBy(toRotate, i*0.05, DG.Tweening.RotateMode.Fast)
					count = count + 1
				end
				coroutine.wait(0.01)
			end

			coroutine.wait(0.5)
			this.ResetDeal()
			if callback ~= nil then 
				callback()
				callback = nil			
			end

			for i, player in pairs(this.PlayerList) do
				local data = {}
				data.viewSeat = player.viewSeat
				data.state = true
				data.position = Utils.WorldPosToScreenPos(player.playerObj.transform.position)
				Notifier.dispatchCmd(cmd_shisanshui.ReadCard, data)
			end
		end)
	end

	--初始化开局人数，创建开局人数列表
	function this.InitPlayerTransForm()
		this.gun = GameObject.Find("qiang")
		this.gun:SetActive(false)
		this.tableCenter = GameObject.Find("tableCenter")
		if this.tableCenter == nil then 
			Trace("tableCenter is nil Error")
		end
		pokerObj = child(this.tableCenter.transform, "Poker_Animaiton").gameObject
		if #this.PlayerList > 0 then 
			Trace("===InitPlayerTransFormError"..tostring(#this.PlayerList)) --
			return 
		end
		local PlayerTransformList = {}
		local room_num = room_data.GetSssRoomDataInfo().people_num
		for i = 1, room_num do
			local player = GameObject.Find("Player_"..tostring(i))
			PlayerTransformList[i] = player
		end
		--local PlayerTransformList = GameObject.FindGameObjectsWithTag("CardPlayer")
		for i = 1, #PlayerTransformList do
			local player = player_component.create()
			player.playerObj = PlayerTransformList[i]
			--print("玩家数组："..PlayerTransformList[i].name)
			player.viewSeat = i
			
			--local logicSeat = room_usersdata_center.SetMyLogicSeat(player.viewSeat)
			--player.usersdata = room_usersdata_center.usersDataList[logicSeat]
			player.resMgrComponet = this.resMgrComponet
			--local cards = player.playerObj.transform:GetComponentsInChildren(typeof(UnityEngine.MeshFilter))
			local cards = player.playerObj.transform:GetComponentsInChildren(typeof(UnityEngine.BoxCollider))
			if cards ~= nil then 
				for j = 0, cards.Length -1 do
					local cardObj = cards[j]
					table.insert(player.CardList, cardObj)
					if i == 1 then
						local cardPosition = cardObj.transform.localPosition
						local cardRotation = cardObj.transform.localRotation
						local cardScale = cardObj.transform.localScale
						local cardTrans = {}
						cardTrans.cardPosition = cardPosition
						cardTrans.cardRotation = cardRotation
						cardTrans.cardScale = cardScale
						table.insert(this.CardModelTrans,cardTrans)
					end
				end
			end
			player.playerObj:SetActive(false)
			player.CardOrgineTrans = this.CardModelTrans
			table.insert(this.PlayerList,player)
			table.insert(this.PlayerTransformList,PlayerTransformList[i].transform)
			if player == nil then
				Trace("Error Player is nil")
				return
			end
		end		
	end

	--[[--
	 * @Description: 获取玩家  
	 ]]
	function this.GetPlayer(index)
		return this.PlayerList[index]
	end

	--[[--
	 * @Description: 初始化牌形  
	 ]]
	function this.InitCard(callback)		
		this.InitCardPool(function()
			this.tableCenter:SetActive(false)
			if this.PlayerList ~= nil then				
				for i, player in pairs(this.PlayerList) do
					player.playerObj:SetActive(true)																									  
					player:shuffle()	 --摆牌
				end
			end
			
			coroutine.start(function()
				coroutine.wait(0.8)
				if callback ~= nil then
					callback()	
					callback = nil
					this.tableCenter:SetActive(false)
				end	
			end)
		end)			
	end

	--[[--
	 * @Description: 摆牌ok处理   
	 ]]
	function this.ChooseOKCard(tbl)
		Trace("============摆牌ok处理============="..tostring(tbl._src))
	--	local logicSeat = player_seat_mgr.GetLogicSeatByStr(tbl._src)
		local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(tbl._src) --查找当前座位号
		if viewSeat == 1 then
			place_card.Hide()
		end
		if this.PlayerList ~= nil then
			for i, player in pairs(this.PlayerList) do
				Trace("viewSeat-----------------------------------"..tostring(viewSeat))
				Trace("player.viewSeat-----------------------------------"..tostring(player.viewSeat))
				if tostring(viewSeat) == tostring(player.viewSeat) then
					player.playerObj:SetActive(true)
					player.ShowAllCard(180)

					local data = {}
					data.viewSeat = player.viewSeat
					data.state = false
					data.position = Utils.WorldPosToScreenPos(player.playerObj.transform.position)
					Notifier.dispatchCmd(cmd_shisanshui.ReadCard, data)
					break
				end
			end
		end		
	end


	--[[--
	 * @Description: 牌形比较处理 
	 ]]
	function this.CardCompareHandler()
		local scoreData = {}    --积分数据表
 
		local firstSort = {}    --第一次排序表
		local secondSort = {}   --第二次排序表
		local threeSort = {}    --第三次排序表
		local sortIndex = nil
		local special_card_count = 0
		local isSpecialCard = false
		local roomMasterViewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(1)--找到房主的坐位号
	
		local isSpecialCardForRoomMaster = false
		
		
		for i,v in ipairs(this.PlayerList) do
			sortIndex = v.compareResult["nOpenFirst"]
			table.insert(firstSort, sortIndex)
			sortIndex = v.compareResult["nOpenSecond"]
			table.insert(secondSort, sortIndex)
			sortIndex = v.compareResult["nOpenThird"]
			table.insert(threeSort, sortIndex)
			
			if v.compareResult["nSpecialType"] > 0 then
				special_card_count = special_card_count + 1 --统计拥有特殊牌型的人数
			end
			
			if v.viewSeat == roomMasterViewSeat then
				
				if v.compareResult["nSpecialType"] > 0 then
					isSpecialCardForRoomMaster = true
				end
			end
			
		end
		table.sort(firstSort)
		table.sort(secondSort)
		table.sort(threeSort)
		
		
		--判断是不是坐庄家特殊牌型，如是庄家是特殊牌型，则不进行比牌
		local roomInfo = room_data.GetSssRoomDataInfo()
		sessionData = player_data.GetSessionData()
		if roomInfo.isZhuang == true and isSpecialCardForRoomMaster == true then
			--总分
			local myPlayer = this.GetPlayer(1)
			local totallScore = myPlayer.compareResult["nTotallScore"]
		
			scoreData.index = 4
			scoreData.totallScore = totallScore
			Notifier.dispatchCmd(cmd_shisanshui.Three_Group_Compare_result ,scoreData)
		
			if compareFinshCallback ~= nil then
				compareFinshCallback()
				compareFinshCallback = nil
			end
			--播放打枪动画
			this.PlayGunAnim(function()  end)
			return
		end
		
		
		
		
		
		
		
		--如果牌局里面，只有一个人没有特殊牌型，那么不需要比牌，直接进入特殊排型展示
		local peopleNum = room_data.GetSssRoomDataInfo().people_num
		if tonumber(special_card_count) < tonumber(peopleNum)-1 then
		for j,k in ipairs(firstSort) do
			for i ,Player in ipairs(this.PlayerList) do
				if tonumber(Player.compareResult["nOpenFirst"]) == tonumber(k) then
					if tonumber(Player.compareResult["nSpecialType"]) < 1 then    	--检查是不是特殊牌型,特殊牌型不翻牌
						Player:PlayerGroupCard("Group1")
						local cards = Player:showFirstCardByType() 					--这里在通知UI界面显示相应排型
						Notifier.dispatchCmd(cmd_shisanshui.ShowPokerCard,cards)
						coroutine.wait(0.75)
						break
					else
						if Player.viewSeat == 1 then
							isSpecialCard = true
						end
						
					end
				end
			end
		end
		--这里增加一个事件，通知UI更新第一墩的积分数据
		if isSpecialCard == false then
			scoreData.index = 1
			scoreData.totallScore = 0			
			Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result, scoreData)
		end
		
		
		for j,k in ipairs(secondSort) do
			for i ,Player in ipairs(this.PlayerList) do
				if tonumber(Player.compareResult["nOpenSecond"]) == tonumber(k) then
					if tonumber(Player.compareResult["nSpecialType"]) < 1 then 	--检查是不是特殊牌型,特殊牌型不翻牌
						Player:PlayerGroupCard("Group2")
						local cards = Player:showSecondCardByType() 			--这里在通知UI界面显示相应排型
						Notifier.dispatchCmd(cmd_shisanshui.ShowPokerCard, cards)
						coroutine.wait(0.75)
						break
					end
				end
			end
		end
		--这里增加一个事件，通知UI更新第二墩的积分数据
		if isSpecialCard == false then
			scoreData.index = 2
			scoreData.totallScore = 0
			Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result , scoreData)
		end

		
		for j,k in ipairs(threeSort) do
			for i ,Player in ipairs(this.PlayerList) do
				if tonumber(Player.compareResult["nOpenThird"]) == tonumber(k) then
					if tonumber(Player.compareResult["nSpecialType"]) < 1 then --检查是不是特殊牌型,特殊牌型不翻牌
						Player:PlayerGroupCard("Group3")
						local cards = Player:showThreeCardByType() ----这里在通知UI界面显示相应排型
						Notifier.dispatchCmd(cmd_shisanshui.ShowPokerCard,cards)
						coroutine.wait(0.75)
						break
					end
				end
			end
		end
		
		--这里增加一个事件，通知UI更新第三墩的积分数据
		if isSpecialCard == false then
			scoreData.index = 3
			scoreData.totallScore = 0
			Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result , scoreData)
		end
		--总分
		local myPlayer = this.GetPlayer(1)
		local totallScore = myPlayer.compareResult["nTotallScore"]
		Trace("++++++++++++++++++totallScorefasdfsfsf++++++++++++++++++++++++++++="..tostring(totallScore))
		
		scoreData.index = 4
		scoreData.totallScore = totallScore
		Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result ,scoreData)
		
		if compareFinshCallback ~= nil then
			compareFinshCallback()
			compareFinshCallback = nil
		end
		
		else 
				--总分
		local myPlayer = this.GetPlayer(1)
		local totallScore = myPlayer.compareResult["nTotallScore"]
		Trace("++++++++++++++++++totallScorefasdfsfsf++++++++++++++++++++++++++++="..tostring(totallScore))
		
		scoreData.index = 4
		scoreData.totallScore = totallScore
		Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result ,scoreData)
		end
		
		--摆牌结束，通知UI播入打枪动画跟特殊牌型动画
		--Notifier.dispatchCmd(cmd_shisanshui.ShootingPlayerList,this.PlayerList)
		--播放打枪动画
		this.PlayGunAnim()

		--播放特殊牌形动画		
	end


	--[[--
	 * @Description: 比牌开始  
	 ]]
	function this.CompareStart(compareFinshCallback)
		Trace("CompareStart......................")
		for i ,Player in pairs(this.PlayerList) do
			Player:SetCardMesh() --设置牌的值
			--为特殊牌型显示一个展示图标
			if Player.compareResult["nSpecialType"] ~= nil then
				if tonumber(Player.compareResult["nSpecialType"]) > 0 then
					local data = {}
					data.viewSeat = Player.viewSeat
					data.position = Utils.WorldPosToScreenPos(Player.playerObj.transform.position)
					Notifier.dispatchCmd(cmd_shisanshui.SpecialCardType, data)
				end		
			end
		end

		this.compareCoroutine = coroutine.start(this.CardCompareHandler)
	end


	function this.sortPlayerList(sortKey)
		local test = true;
		table.sort(this.PlayerList, function (player1,player2)
			local firstType1 = player1.compareResult[sortKey]
			local firstType2 = player2.compareResult[sortKey]			
			--Trace("firstType1"..tostring(firstType1).."secondType"..tostring(firstType2))
			if firstType1 < firstType2 then
				return true
			elseif firstType1 == firstType2 then
				--牌形相同，再做进一步判断，暂时返回true
				--Trace("++++++++++++the same Group ++++++++++"..tostring(sortKey))
				--[[
				if test == true then
					test = false
					return test
				else
					test =true
					return test
				end
				]]
				return false
			else
				return false
			end	
		end)
		return this.PlayerList
	end


	--进入下一局重置所有的动作
	function this.ReSetAll()
		Trace("重置所有比牌动作")
		this.ResetPlayerList()
		this.ClearnAllShoot()
		
	end
	
	function this.ClearnAllShoot()
		Trace("删除所有的子弹孔")
		if this.ShootAnimationTabel ~= nil and #this.ShootAnimationTabel > 0 then
			for i,v in pairs(this.ShootAnimationTabel) do
				if not IsNil(v) then
					v.gameObject:SetActive(false)
					GameObject.Destroy(v.gameObject)
				end
			end
		end
	end

	--重置发牌动作
	function this.ResetDeal()
		this.tableCenter:SetActive(true)
		for i = 1, #this.cardTranPool do
			this.cardTranPool[i].transform.parent = this.tableCenter.transform
			this.cardTranPool[i].transform.localPosition = Vector3(0,i/20,0)
			this.cardTranPool[i].transform.localEulerAngles = Vector3(0,0,180)
			this.cardTranPool[i].gameObject:SetActive(false)
		end
	end
	
	function this.ShowDeal()
		for i = 1, #this.cardTranPool do
			this.cardTranPool[i].gameObject:SetActive(true)
		end
	end

	--重置发牌动作
	function this.ResetPlayerList()
		for i ,Player in pairs(this.PlayerList) do
			Player:PlayerReset()
		end
	end
	
	
	
	--播放打枪动画及以后流程
	function this.PlayGunAnim(CallBack)				
		local animator =  componentGet(this.gun.transform,"Animator")
		if this.gun ~= nil and animator ~=nil then	
			local isPlayed = false
			
			coroutine.wait(1.5)
			coroutine.start(function()
				for i,v in ipairs(this.PlayerList) do
					if v.compareResult["stShoots"] ~= nil then
						local shootList = v.compareResult["stShoots"]--找出每个人的打枪列表
						if shootList ~= nil and #shootList > 0 then
							if isPlayed ==false then
								Trace("打枪全屏动画")
								animations_sys.PlayAnimation(shisangshui_ui.transform, "game_80011/effects/shisanshui_shoot_kuang", "bomb box", 100, 100, false,nil,1401)
								--ui_sound_mgr.PlaySoundClip("audio/daqiang")  ---打枪
								ui_sound_mgr.PlaySoundClip("game_80011/sound/dub/daqiang_nv")  ---打枪提示
								isPlayed = true
								coroutine.wait(2.0)
								ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/daqiangzhunbei")  ---打枪准备
								coroutine.wait(0.4)
							end
						
							for j,k in ipairs(shootList) do
								local shootTargetViewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(k)
								local shootTargeObj = nil
								shootTargeObj = this.GetPlayer(shootTargetViewSeat).playerObj

								if shootTargeObj ~= nil then
									animator.transform.parent.localPosition = v.playerObj.transform.localPosition
									animator.transform.parent:LookAt(shootTargeObj.transform)   --把枪指向要打的人的对象
									
								    --for i =1 ,3 do --打枪三次
									local screenPos =  Utils.WorldPosToScreenPos(shootTargeObj.transform.position)  
									screenPos.z = 0
									if this.gun.gameObject.activeSelf == false then
										this.gun:SetActive(true)
									end
									animator:SetBool("gun_fire", true)
									ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/daqiang")  --枪声
									coroutine.wait(0.2)
									local shootAnimationObj_one = animations_sys.PlayAnimationByScreenPosition(shisangshui_ui.transform, screenPos.x + tonumber(math.random(-50,50)),screenPos.y + tonumber(math.random(-40,40)),"game_80011/effects/shisanshui_shoot" ,"Shoot2", 100, 100,false, nil, tonumber(math.random(1400,1500)),false)
									table.insert(this.ShootAnimationTabel,shootAnimationObj_one)
									ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/daqiang")  --枪声
									coroutine.wait(0.2)
									local shootAnimationObj_two = animations_sys.PlayAnimationByScreenPosition(shisangshui_ui.transform, screenPos.x + tonumber(math.random(-40,40)),screenPos.y + tonumber(math.random(-40,40)),"game_80011/effects/shisanshui_shoot", "Shoot2", 100, 100,false, nil, tonumber(math.random(1400,1500)),false)
									table.insert(this.ShootAnimationTabel,shootAnimationObj_two)
									ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/daqiang")  --枪声
									coroutine.wait(0.2)
									local shootAnimationObj_three = animations_sys.PlayAnimationByScreenPosition(shisangshui_ui.transform, screenPos.x + tonumber(math.random(-40,40)),screenPos.y + tonumber(math.random(-40,40)),"game_80011/effects/shisanshui_shoot", "Shoot2", 100, 100, false,nil,tonumber(math.random(1400,1500)),false)
									table.insert(this.ShootAnimationTabel,shootAnimationObj_three)
									animator:SetBool("gun_fire", false)
									this.gun:SetActive(false)
									coroutine.wait(0.5)
								end
							end
						end
					end
				end
				--this.gun:SetActive(false)
				
				
				for i, v in ipairs(this.PlayerList) do
					if v.compareResult["nSpecialType"] ~= nil  and v.compareResult["nSpecialType"] ~= 0 then
						Trace("打枪完成, 开始特殊牌型展示")
						special_card_show.Show(v.compareResult["stCards"], v.compareResult["nSpecialType"], v.viewSeat,1.8)
						coroutine.wait(2)
					end
				end
		
				if card_data_manage.allShootChairId ~= 0 then
					Trace("播放全垒打动画")
					animations_sys.PlayAnimation(shisangshui_ui.transform,"game_80011/effects/daqiang_quanleida","homer",100,100,false,nil,1401)
					ui_sound_mgr.PlaySoundClip("game_80011/sound/dub/quanleida_nv")  ---全垒打
					coroutine.wait(2)
				end
				
		
				shisangshui_play_sys.CompareFinish()--告诉服务器				
				Trace("====================开始结算=======================")
				
				--结算动画处理
				local totalPoints = {}
				for i,player in ipairs(this.PlayerList) do
					local points = player.compareResult["nTotallScore"]
					table.insert(totalPoints,points)
					shisangshui_ui.ShowPlayerTotalPoints(player.viewSeat,points)
				end
				table.sort(totalPoints)
				local maxTotalPoint =  totalPoints[#totalPoints]
				if maxTotalPoint ~= nil then
					for i,player in ipairs(this.PlayerList) do
						if tonumber(maxTotalPoint) == tonumber(player.compareResult["nTotallScore"]) then
							shisangshui_ui.SetPlayerLightFrame(player.viewSeat)
							coroutine.wait(1)
							shisangshui_ui.DisablePlayerLightFrame()
							--	coroutine.wait(0.1)
							break
						end
					end
				end
				
				if CallBack ~= nil then
					CallBack()
					CallBack = nil
				end
				Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_RESULT)--比牌结束
			end)
		end
	end
	

	return this
end
