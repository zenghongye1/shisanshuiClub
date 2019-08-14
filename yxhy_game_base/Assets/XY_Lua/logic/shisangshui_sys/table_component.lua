local table_component = class("table_component")
local player_component = require("logic.shisangshui_sys.player_component")

local codeMaterial =nil

function table_component:ctor()
	self.mostPlayerList = {}
	self.PlayerList = {} 		---玩家列表
	self.PlayerTransformList = {}
	self.tableCenter = nil
	self.cardTranPool = {}	
	self.gun = nil
	self.CardModelTrans = {}
	self.ShootAnimationTabel = {}
	self.compareCoroutine = nil
	self.resMgrComponet = resMgr_component.create()
	self.shisanshui_ui = UI_Manager:Instance():GetUiFormsInShowList("shisanshui_ui")
	self.pokerPool = require("logic.niuniu_sys.other.pokercard_pool"):create()
end

--[[--
 * @Description: 洗牌
 ]]
function table_component:WashCard(callback)
	coroutine.start(function()
		ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/xipai")   --洗牌音效
		self.tableCenter:SetActive(true)
		self.heguan_manage:PlayHeGuanAnimationByClipName("xipai")
		coroutine.wait(1.5)		--2.5
		self.tableCenter:SetActive(false)
		if callback ~= nil then
			callback()
			callback = nil
		end
	end)		
end

--[[--
 * @Description: 初始化手牌  
 ]]
function table_component:InitCardPool(callback)
	if self.cardTranPool == nil or #self.cardTranPool < 1 then
		for i = 1, table.getCount(self.PlayerList) * 13 do 
			local cardPrefab = newNormalObjSync(data_center.GetResPokerCommPath().. "/small_card/"..tostring(2), typeof(GameObject))
			local cardTran = newobject(cardPrefab).transform
			cardTran.parent = self.tableCenter.transform
			cardTran.localPosition = Vector3(0, -1-(-i*0.1), 2.5)
			cardTran.localEulerAngles = Vector3(0, 0, 180)
			table.insert(self.cardTranPool, cardTran)
		end
	end
	self:DealAnimation(callback)
end

--发牌动作
function table_component:DealAnimation(callback)
	local count = #self.cardTranPool
	self:ResetDeal()
	
	coroutine.start(function ()	
		self.heguan_manage:PlayHeGuanAnimationByClipName("daiji1")							
		self:ShowDeal()
		coroutine.wait(0.1)		--0.5
		for i =1, 13 do
			for j ,Player in pairs(self.PlayerList) do	
				ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/fapai_feichu")  ----发牌音效
				--需要边移动边旋转
				local tmpTran = Player.playerObj.transform
				self.cardTranPool[count]:DOMove(tmpTran.position,0.2, false)	--0.3
				self.cardTranPool[count]:DOScale(Vector3(1.3,1.3,1.3),0.2)	--0.3
				local toRotate = self.cardTranPool[count].localRotation + Vector3(0, i*50, 0)
				self.cardTranPool[count]:DOBlendableLocalRotateBy(toRotate, i*0.05, DG.Tweening.RotateMode.Fast)
				count = count - 1
			end
			coroutine.wait(0.01)
		end
		coroutine.wait(0.2)		--0.3
		self:ResetDeal()
		if callback ~= nil then 
			callback()
			callback = nil			
		end
		for i, player in pairs(self.PlayerList) do
			local data = {}
			data.viewSeat = player.viewSeat
			data.state = true
			data.position = Utils.WorldPosToScreenPos(player.playerObj.transform.position)
			Notifier.dispatchCmd(cmd_shisanshui.ReadCard, data)
		end
	end)
end

--初始化开局人数，创建开局人数列表
function table_component:InitPlayerTransForm()
	self.gun = GameObject.Find("qiang")
	self.gun:SetActive(false)

	self.tableCenter = GameObject.Find("tableCenter")
	if self.tableCenter == nil then 
		logError("tableCenter is nil Error")
	end
	if table.getCount(self.PlayerList) > 0 then 
		Trace("===InitPlayerTransFormError"..tostring(#self.PlayerList)) --
		return 
	end
	
	self:CreatePlayerList()
	self:SetRoomInfo()
	self:HeGuan()
	self:ChangeDeskCloth()
	self.heguan_manage:PlayHeGuanAnimationByClipName("daiji1")
end

function table_component:CreatePlayerList()
	if isEmpty(self.mostPlayerList)then
		for i = 1,8 do
			local playerGameObject = GameObject.Find("poker_players/Player_"..tostring(i))
			playerGameObject:SetActive(false)
			local player = player_component:create(playerGameObject)
			player.viewSeat = j
			player.resMgrComponet = self.resMgrComponet
			player.pokerPool = self.pokerPool
			player:InitCard()
			table.insert(self.mostPlayerList,player)
		end
	end
end

function table_component:SetCurPlayerList(vs)
	local peopleNum = roomdata_center.maxplayernum
	
	self.currentTable = poker_table_coordinate.poker_table[peopleNum]
	
	for viewSeat,index in pairs(self.currentTable) do
		if vs == viewSeat then
			self.PlayerList[viewSeat] = self.mostPlayerList[index]
			self.PlayerList[viewSeat]["viewSeat"] = viewSeat
		end
	end
end

function table_component:RemoveCurPlayerList(vs)
	for viewSeat,v in pairs(self.PlayerList) do
		if self.PlayerList[viewSeat] and vs == viewSeat then
			self.PlayerList[viewSeat] = nil
		end
	end
end

function table_component:SetRoomInfo()
	local trans = GameObject.Find("roominfos/roomNum").transform
	self.roomNumComp = require("logic/mahjong_sys/components/base/comp_mjRoomNum"):create(trans)
	self.roomNumComp:SetRoomNum(roomdata_center.roomnumber,data_center.GetResMJCommPath())
	local configData = roomdata_center.gamesetting

	if configData.nGhostAdd then
	--	"大小鬼")
		local tips2 = GameObject.Find("roominfos/roomInfo/tip2").transform
		self.roomNumComp:SetSpImgByTransform(tips2,"addGhost_"..tostring(configData.nGhostAdd),data_center.GetResPokerCommPath(),237,84)
	else	--新老版本兼容
		configData.nGhostAdd = configData.bSupportGhostCard and 2 or 0
		local tips2 = GameObject.Find("roominfos/roomInfo/tip2").transform
		self.roomNumComp:SetSpImgByTransform(tips2,"addGhost_"..tostring(configData.nGhostAdd),data_center.GetResPokerCommPath(),237,84)
	end
	
	local tips1 = GameObject.Find("roominfos/roomInfo/tip1").transform
	if configData.nBuyCode == 1 or configData.bSupportBuyCode then
	--	,"有马牌")
		self.roomNumComp:SetSpImgByTransform(tips1,"youma",data_center.GetResPokerCommPath(),163,84)
	else
	--	"无马牌")
		self.roomNumComp:SetSpImgByTransform(tips1,"wuma",data_center.GetResPokerCommPath(),163,84)
	end
	----游戏名字设置
	local gameIcon = GameObject.Find("roomInfo/gameIcon").transform
	if gameIcon ~= nil then
		self.roomNumComp:SetSpImgByTransform(gameIcon,"shisanzhang_"..tostring(player_data.GetGameId()),data_center.GetResPokerCommPath(),290,58)
	end
end

--[[--
 * @Description: 获取玩家  
 ]]
function table_component:GetPlayer(viewSeat)
	return self.PlayerList[viewSeat]
end

--[[--
 * @Description: 初始化牌形  
 ]]
function table_component:InitCard(callback)		
	self:InitCardPool(function()
		self.tableCenter:SetActive(false)
		if self.PlayerList ~= nil then				
			for i, player in pairs(self.PlayerList) do
				player.playerObj:SetActive(true)																									  
				player:shuffle(true)	 --展开牌
			end
		end

		if callback ~= nil then
			callback()	
			callback = nil
			self.tableCenter:SetActive(false)
		end
	end)			
end

--[[--
 * @Description: 摆牌ok处理   
 ]]
function table_component:ChooseOKCard(tbl)
	Trace("============摆牌ok处理============="..tostring(tbl._src))
	local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(tbl._src) --查找当前座位号
	
	if self.PlayerList ~= nil then
		for i, player in pairs(self.PlayerList) do
			Trace("viewSeat------ "..tostring(viewSeat).."  ,player.viewSeat------- "..tostring(player.viewSeat))
			if tostring(viewSeat) == tostring(player.viewSeat) then
				if viewSeat == 1 then
					UI_Manager:Instance():CloseUiForms("place_card")
					
					player:SetCardMesh(tbl["_para"]["cards"])
					player.playerObj:SetActive(true)
					player:ShowAllCard(180)
					if tbl["_para"]["nSpecialType"] ~= nil and tbl["_para"]["nSpecialType"] > 0 then
						local data = {}
						data.SpecialType = tbl["_para"]["nSpecialType"]
						data.position = Utils.WorldPosToScreenPos(player.playerObj.transform.position)
						Notifier.dispatchCmd(cmd_shisanshui.SpecialChoose_Show,data)
					end				
				else
					player:ShowAllCard(180)
					player.playerObj:SetActive(true)								
				end
					local data = {}
					data.viewSeat = player.viewSeat
					data.state = false
					data.position = Utils.WorldPosToScreenPos(player.playerObj.transform.position)
					Notifier.dispatchCmd(cmd_shisanshui.ReadCard, data)
				break
			end
		end
	end	

	self.heguan_manage:PlayHeGuanAnimationByClipName("daiji2")	
end


--[[--
 * @Description: 牌形比较处理 
 ]]
function table_component:CardCompareHandler()
	local scoreData = {}    --积分数据表

	local firstSort = {}    --第一次排序表
	local secondSort = {}   --第二次排序表
	local threeSort = {}    --第三次排序表
	local sortIndex = nil
	local special_card_count = 0
	local isSpecialCard = false
	local bankerViewSeat = roomdata_center.zhuang_viewSeat --player_seat_mgr.GetViewSeatByLogicSeatNum(1)--找到房主的坐位号

	local isSpecialCardFromBanker = false
	
	
	for i,v in pairs(self.PlayerList) do
		sortIndex = v.compareResult["nOpenFirst"]
		table.insert(firstSort, sortIndex)
		sortIndex = v.compareResult["nOpenSecond"]
		table.insert(secondSort, sortIndex)
		sortIndex = v.compareResult["nOpenThird"]
		table.insert(threeSort, sortIndex)
		
		if v.compareResult["nSpecialType"] > 0 then
			special_card_count = special_card_count + 1 --统计拥有特殊牌型的人数
		end
		
		if v.viewSeat == bankerViewSeat then
			
			if v.compareResult["nSpecialType"] > 0 then
				isSpecialCardFromBanker = true
			end
		end
		
	end
	table.sort(firstSort)
	table.sort(secondSort)
	table.sort(threeSort)
		
	--判断是不是坐庄家特殊牌型，如是庄家是特殊牌型，则不进行比牌
	local roomInfo = roomdata_center.gamesetting
	if roomInfo.bSupportWaterBanker == true and isSpecialCardFromBanker == true then
		--总分
		local myPlayer = self:GetPlayer(1)
		local totallScore = myPlayer.compareResult["nTotallScore"]
	
		scoreData.index = 4
		scoreData.totallScore = totallScore
		Notifier.dispatchCmd(cmd_shisanshui.Three_Group_Compare_result ,scoreData)
	
		if compareFinshCallback ~= nil then
			compareFinshCallback()
			compareFinshCallback = nil
		end
		--播放打枪动画
		self:PlayGunAnim()
		return
	end
	
	--如果牌局里面，只有一个人没有特殊牌型，那么不需要比牌，直接进入特殊排型展示
	local peopleNum = roomdata_center.maxplayernum
	if tonumber(special_card_count) < tonumber(peopleNum)-1 then
		for i ,Player in pairs(self.PlayerList) do
			if tonumber(Player.compareResult["nSpecialType"]) < 1 then    	--检查是不是特殊牌型,特殊牌型不翻牌
				if(Player.viewSeat == 1) then
					local groupScreenPos = Player:GetCardGroupScreenPos()
					Notifier.dispatchCmd(cmd_shisanshui.FuZhouSSS_SetScore,groupScreenPos)	--通知ui界面显示初始零分
				end
			end
		end		
	
	--[[
	--这里增加一个事件，通知UI更新第一墩的积分数据
	if isSpecialCard == false then
		scoreData.index = 1
		scoreData.totallScore = 0			
		Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result, scoreData)
	end
	--]]
	for j,k in ipairs(firstSort) do
		for i ,Player in pairs(self.PlayerList) do
			if tonumber(Player.compareResult["nOpenFirst"]) == tonumber(k) then
				if tonumber(Player.compareResult["nSpecialType"]) < 1 then    	--检查是不是特殊牌型,特殊牌型不翻牌
					Player:PlayerGroupCard("Group1")
					local cards = Player:showFirstCardByType() 					--这里在通知UI界面显示相应排型
					Notifier.dispatchCmd(cmd_shisanshui.ShowPokerCard,cards)
											
					if card_data_manage.stCompareScores ~= nil then
						for i,v in pairs(card_data_manage.stCompareScores) do
							local chairId = v.toChairid
							local viewSeatId = player_seat_mgr.GetViewSeatByLogicSeatNum(chairId)
							if tonumber(viewSeatId) == Player.viewSeat then
								if(v.nSpecialScore == 0)then
									scoreData.index = 1
									scoreData.totallScore = v.nFirstScore
									Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result, scoreData)
								end
								break
							end
						end
					end										
					coroutine.wait(0.6)	--0.75
					break
				else
					if Player.viewSeat == 1 then
						isSpecialCard = true
					end					
				end
			end
		end
	end
	---通知UI更新第二墩的积分数据
	for j,k in ipairs(secondSort) do
		for i ,Player in pairs(self.PlayerList) do
			if tonumber(Player.compareResult["nOpenSecond"]) == tonumber(k) then
				if tonumber(Player.compareResult["nSpecialType"]) < 1 then 	--检查是不是特殊牌型,特殊牌型不翻牌
					Player:PlayerGroupCard("Group2")
					local cards = Player:showSecondCardByType() 			--这里在通知UI界面显示相应排型
					Notifier.dispatchCmd(cmd_shisanshui.ShowPokerCard, cards)
										
					if card_data_manage.stCompareScores ~= nil then
						for i,v in pairs(card_data_manage.stCompareScores) do
							local chairId = v.toChairid
							local viewSeatId = player_seat_mgr.GetViewSeatByLogicSeatNum(chairId)
							if tonumber(viewSeatId) == Player.viewSeat then
								if(v.nSpecialScore == 0)then
									scoreData.index = 2
									scoreData.totallScore = v.nSecondScore
									Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result, scoreData)
								end
								break
							end
						end
					end					
					coroutine.wait(0.6)		--0.75
					break
				end
			end
		end
	end
	---通知UI更新第三墩的积分数据	
	for j,k in ipairs(threeSort) do
		for i ,Player in pairs(self.PlayerList) do
			if tonumber(Player.compareResult["nOpenThird"]) == tonumber(k) then
				if tonumber(Player.compareResult["nSpecialType"]) < 1 then --检查是不是特殊牌型,特殊牌型不翻牌
					Player:PlayerGroupCard("Group3")
					local cards = Player:showThreeCardByType() ----这里在通知UI界面显示相应排型
					Notifier.dispatchCmd(cmd_shisanshui.ShowPokerCard,cards)
					
					if card_data_manage.stCompareScores ~= nil then
						for i,v in pairs(card_data_manage.stCompareScores) do
							local chairId = v.toChairid
							local viewSeatId = player_seat_mgr.GetViewSeatByLogicSeatNum(chairId)
							if tonumber(viewSeatId) == Player.viewSeat then
								if(v.nSpecialScore == 0)then
									scoreData.index = 3
									scoreData.totallScore = v.nThirdScore
									Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result, scoreData)
								end
								break
							end
						end
					end									
					coroutine.wait(0.6)		--0.75
					break
				end
			end
		end
	end	
	--总分
		local myPlayer = self:GetPlayer(1)
		local totallScore = myPlayer.compareResult["nTotallScore"]
		
		scoreData.index = 4
		scoreData.totallScore = totallScore
		Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result ,scoreData)
		
		if compareFinshCallback ~= nil then
			compareFinshCallback()
			compareFinshCallback = nil
		end		
	else 
			--总分
		local myPlayer = self:GetPlayer(1)
		local totallScore = myPlayer.compareResult["nTotallScore"]
		
		scoreData.index = 4
		scoreData.totallScore = totallScore
		Notifier.dispatchCmd(cmd_shisanshui.Group_Compare_result ,scoreData)
	end
	
	--播放打枪动画
	self:PlayGunAnim()	
	--播放特殊牌形动画		
end
	
--[[--
 * @Description: 比牌开始  
 ]]
function table_component:CompareStart(compareFinshCallback)
	self.heguan_manage:PlayHeGuanAnimationByClipName("daiji2")
	
	local pNum = table.getCount(self.PlayerList)
	for i ,Player in pairs(self.PlayerList) do
		Player:SetCardMesh() --设置牌的值
		---为特殊牌型显示一个展示图标
		if Player.compareResult["nSpecialType"] ~= nil then
			if tonumber(Player.compareResult["nSpecialType"]) > 0 then
				if(Player["viewSeat"] ~= 1) then
					local data = {}
					data.chairIndex = poker_table_coordinate.GetChairIndex(pNum,Player.viewSeat)
					data.position = Utils.WorldPosToScreenPos(Player.playerObj.transform.position)
					Notifier.dispatchCmd(cmd_shisanshui.SpecialCardType, data)
				end
			end		
		end
	end
	self.compareCoroutine = coroutine.start(function ()
		for i, player in pairs(self.PlayerList) do
			if player.viewSeat == 1 then
				player:ShowAllCard(180)
				if tonumber(player.compareResult["nSpecialType"]) > 0 then
					Notifier.dispatchCmd(cmd_shisanshui.IsShowSelfSpecial,true)
				end
			end
		end
		coroutine.wait(0.2)  	---------展示剩余牌时间
		self:CardCompareHandler()
	end)
end

--进入下一局重置所有的动作
function table_component:ReSetAll()
	Trace("重置所有比牌动作")
	self:ResetPlayerList()
	self:ClearnAllShoot()
end
	
function table_component:ClearnAllShoot()
	Trace("删除所有的子弹孔")
	if self.ShootAnimationTabel ~= nil and #self.ShootAnimationTabel > 0 then
		for i,v in pairs(self.ShootAnimationTabel) do
			if not IsNil(v) then
				v.gameObject:SetActive(false)
				--GameObject.Destroy(v.gameObject)
				EffectMgr.StopEffect(v.gameObject)
			end
		end
	end
end

--重置发牌动作
function table_component:ResetDeal()
	self.tableCenter:SetActive(true)
	for i = 1, #self.cardTranPool do
		self.cardTranPool[i].transform.parent = self.tableCenter.transform
		self.cardTranPool[i].transform.localPosition = Vector3(0,i/20,2.5)
		self.cardTranPool[i].transform.localEulerAngles = Vector3(0,0,180)
		self.cardTranPool[i].gameObject:SetActive(false)
	end
end
	
function table_component:ShowDeal()
	for i = 1, #self.cardTranPool do
		self.cardTranPool[i].gameObject:SetActive(true)
		self.cardTranPool[i].gameObject.transform.localScale = Vector3(0.4,0.4,0.4)
	end
end

--重置发牌动作
function table_component:ResetPlayerList()
	for i ,Player in pairs(self.PlayerList) do
		Player:PlayerReset()
	end
end
	
--播放打枪后的流程
function table_component:PlayGunAnim(CallBack)				
	local animator =  componentGet(self.gun.transform,"Animator")
	if self.gun ~= nil and animator ~=nil then	
		local isPlayed = false
		
		coroutine.wait(1)
		coroutine.start(function()
			for i,v in pairs(self.PlayerList) do
				local pos = self.shisanshui_ui:GetAllShootPos(v["viewSeat"])
				v["headPos"] = pos
				
				local shootList = v.compareResult["stShoots"]--找出每个人的打枪列表
				if shootList ~= nil and #shootList > 0 then
					if isPlayed == false then
						Trace("打枪全屏动画")
						local effect = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/Effect_daqiang03",1,1)		--1
						effect.transform:SetParent(self.shisanshui_ui.transform,false)
						ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/daqiang_nv")  ---打枪提示
						isPlayed = true
						coroutine.wait(0.8)	--1
						ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/daqiangzhunbei")  ---打枪准备
						coroutine.wait(0.4)
					end
				
					for j,k in ipairs(shootList) do
						local shootTargetViewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(k)
						local shootTargeObj = nil
						shootTargeObj = self:GetPlayer(shootTargetViewSeat).playerObj

						if shootTargeObj ~= nil then
							animator.transform.parent.localPosition = v.playerObj.transform.localPosition
							animator.transform.parent:LookAt(shootTargeObj.transform)   --把枪指向要打的人的对象
							
							--for i =1 ,3 do --打枪三次
							--local screenPos =  Utils.WorldPosToScreenPos(shootTargeObj.transform.position)  
							--screenPos.z = 0
							if self.gun.gameObject.activeSelf == false then
								self.gun:SetActive(true)
							end
							animator:SetBool("gun_fire", true)
							---第一枪
							local gunFireEffect = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/Effect_daqiang01",1,0.2)
							gunFireEffect.transform:SetParent(child(self.gun.transform,"guadian"),false)								
							ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/daqiang")  --枪声
							coroutine.wait(0.2)	--0.25
							local shootAnimationObj_one = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/Effect_daqiang02",1,1)
							shootAnimationObj_one.transform:SetParent(shootTargeObj.transform,false)
							shootAnimationObj_one.transform.localPosition = Vector3(math.random(1,-2.5),2,math.random(-3.5,1.5))
							table.insert(self.ShootAnimationTabel,shootAnimationObj_one)
							---第二枪
							local gunFireEffect = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/Effect_daqiang01",1,0.2)
							gunFireEffect.transform:SetParent(child(self.gun.transform,"guadian"),false)
							ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/daqiang")  --枪声
							coroutine.wait(0.2)	--0.25
							local shootAnimationObj_two = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/Effect_daqiang02",1,1)
							shootAnimationObj_two.transform:SetParent(shootTargeObj.transform,false)
							shootAnimationObj_two.transform.localPosition = Vector3(math.random(1,-2.5),2,math.random(-3.5,1.5))
							table.insert(self.ShootAnimationTabel,shootAnimationObj_two)
							---第三枪
							local gunFireEffect = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/Effect_daqiang01",1,0.2)
							gunFireEffect.transform:SetParent(child(self.gun.transform,"guadian"),false)
							ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/daqiang")  --枪声
							coroutine.wait(0.2)	--0.25
							local shootAnimationObj_three = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/Effect_daqiang02",1,1)
							shootAnimationObj_three.transform:SetParent(shootTargeObj.transform,false)
							shootAnimationObj_three.transform.localPosition = Vector3(math.random(1,-2.5),2,math.random(-3.5,1.5))
							table.insert(self.ShootAnimationTabel,shootAnimationObj_three)
							--打枪分数变动
							local isZhuangMode = roomdata_center.gamesetting["bSupportWaterBanker"]
							if v["viewSeat"] == 1 then
								if not isZhuangMode then
									local CompareScorestbl = card_data_manage.stCompareScores
									for s,t in ipairs(CompareScorestbl) do
										if(t.toChairid == k) then	
											Notifier.dispatchCmd(cmd_shisanshui.Shoot_Compare_result, t)
										end
									end
								end
							elseif shootTargetViewSeat == 1 then
								if not isZhuangMode then
									local CompareScorestbl = card_data_manage.stCompareScores
									for s,t in ipairs(CompareScorestbl) do
										local shooter = player_seat_mgr.GetViewSeatByLogicSeatNum(t.toChairid)
										if(t.nShoot == -1 and shooter == v["viewSeat"]) then
											Notifier.dispatchCmd(cmd_shisanshui.Shoot_Compare_result, t)
										end
									end
								end
							end
							coroutine.wait(0.2)
							animator:SetBool("gun_fire", false)
							self.gun:SetActive(false)
							coroutine.wait(0.3)		--0.5
						end
					end
				end
			end
			
			----打枪后开马
			local isSelfSpecial = 0
			local isOtherSpecial = true
			local codeExist = false
			for i,Player in pairs(self.PlayerList) do		--马牌算分
				if card_data_manage.stCompareScores ~= nil and Player.viewSeat == 1 then
					if(Player["viewSeat"] == 1 and Player.compareResult["nSpecialType"] ~= 0) then
						isSelfSpecial = 1
					end
					for i,v in pairs(card_data_manage.stCompareScores) do
						if (v.nSpCompare == 0) then
							isOtherSpecial = false
						end
					end
				end
			end
			local codeCardList = {}
			for i ,Player in pairs(self.PlayerList) do		--寻找马牌
				for t=1,3 do
					local codeTranList = Player:GetCodeCardTran("Group"..tostring(t))
					if codeTranList and not isEmpty(codeTranList) then
						for _,v in ipairs (codeTranList) do 
							Trace("码牌z"..v.localEulerAngles.z)
							table.insert(codeCardList,v)
						end
					end
				end
			end
			for _,v in ipairs(codeCardList) do
				if v then
					if(v.localEulerAngles.z <10 and v.localEulerAngles.z >-10) then
						Trace("码牌展示处理")
						self:SetCodeCardEffect(v)
						if(isSelfSpecial ~= 1) then
							codeExist = true
							v:DOLocalMove(Vector3(v.localPosition.x,v.localPosition.y,v.localPosition.z+1.66),0.4,false)
						end
					end
				end
			end
			if codeExist then
				coroutine.wait(0.4)	--0.3
				for _,v in ipairs(codeCardList) do
					if v then
						v:DOLocalMove(Vector3(v.localPosition.x,v.localPosition.y,v.localPosition.z-1.66),0.4,false)--3.35-1.69 =1.66
					end
				end
			end
			
			for i,Player in pairs(self.PlayerList) do		--马牌算分
				if card_data_manage.stCompareScores ~= nil and Player.viewSeat == 1 then
					local codeScore = {}				
					codeScore[1] = 0 
					codeScore[2] = 0
					codeScore[3] = 0
					for i,v in pairs(card_data_manage.stCompareScores) do
						if (v.nHasCode ~= 0	) then
							if (v.nSpCompare == 0) then
								codeScore[1] = codeScore[1] + v.stSoreChange[1][3] - v.stSoreChange[1][2]
								codeScore[2] = codeScore[2] + v.stSoreChange[2][3] - v.stSoreChange[2][2]
								codeScore[3] = codeScore[3] + v.stSoreChange[3][3] - v.stSoreChange[3][2]
							end
						end
					end
					if isSelfSpecial ~=1 then
						if (codeExist == true) then
							if (isOtherSpecial == false) then
								Notifier.dispatchCmd(cmd_shisanshui.Code__Compare_result,codeScore)
							end
							coroutine.wait(0.4)		--0.7
						end
					end
				end													
			end
		
			for i, v in pairs(self.PlayerList) do
				if v.compareResult["nSpecialType"] ~= nil  and v.compareResult["nSpecialType"] ~= 0 then
					Trace("打枪完成, 开始特殊牌型展示")
					UI_Manager:Instance():CloseUiForms("special_card_show")
					UI_Manager:Instance():ShowUiForms("special_card_show",nil,nil,v.compareResult["stCards"], v.compareResult["nSpecialType"], v.viewSeat,1.8)
					coroutine.wait(2)
				end
			end
	
			if card_data_manage.allShootChairId ~= 0 then
				Trace("播放全垒打动画")
				local animationLayer = self.shisanshui_ui.sortingOrder + self.shisanshui_ui.m_subPanelCount + 1
				local allShooterViewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(card_data_manage.allShootChairId)
				local screenPos = self.PlayerList[allShooterViewSeat].headPos  
				animations_sys.PlayAnimation(self.shisanshui_ui.transform,data_center.GetResRootPath().."/effects/daqiang_quanleida","homer",100,100,false,nil,nil,animationLayer)
				ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/quanleida_nv")  ---全垒打
				coroutine.wait(1.2)
				ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/hongzhaji")  ---全垒打轰炸机全程
				animations_sys.PlayAnimationByScreenPosition(self.shisanshui_ui.transform,screenPos.x,screenPos.y-25,data_center.GetResRootPath().."/effects/daqiang_hongzhaji","quanleida01",100,100,false,nil,nil,true,animationLayer)
				coroutine.wait(1.8)
				animations_sys.PlayAnimation(self.shisanshui_ui.transform,data_center.GetResRootPath().."/effects/daqiang_hongzhaji","quanleida02",100,100,false,nil,nil,animationLayer)
				coroutine.wait(1)
				for i,v in pairs(self.PlayerList) do 
					local CompareScorestbl = card_data_manage.stCompareScores
					if tonumber(v.viewSeat) ~= allShooterViewSeat then  --viewSeat不是全垒打则锁定投弹，并若viewseat是自己则更新分数 
						local shootTargeObj = nil
						shootTargeObj = self:GetPlayer(v.viewSeat).playerObj
						local screenPos =  Utils.WorldPosToScreenPos(shootTargeObj.transform.position)
						screenPos.z = 0
						animations_sys.PlayAnimationByScreenPosition(self.shisanshui_ui.transform,screenPos.x+20,screenPos.y+220,data_center.GetResRootPath().."/effects/daqiang_paodan","zhadan",100,100,false,nil,nil,true,animationLayer)
						coroutine.wait(0.1)
						for s,t in ipairs(CompareScorestbl) do
							local shooted = player_seat_mgr.GetViewSeatByLogicSeatNum(t.toChairid)
							if tonumber(v.viewSeat) == 1 and shooted == allShooterViewSeat then  --viewseat是自己，并是被全垒打的枪分
								t.selfAllShoot = false
								Notifier.dispatchCmd(cmd_shisanshui.AllShoot_Compare_result,t)
							end			
						end
					elseif allShooterViewSeat == 1 then		--判断全垒打的人是自己，更新分数
						CompareScorestbl.selfAllShoot = true
						Notifier.dispatchCmd(cmd_shisanshui.AllShoot_Compare_result,CompareScorestbl)
					end
				end
				coroutine.wait(1)	--2
			end
			
	
			pokerPlaySysHelper.GetCurPlaySys().CompareFinish()--告诉服务器				
			Trace("====================开始结算=======================")
			
			--结算动画处理
			local totalPoints = {}
			for i,player in pairs(self.PlayerList) do
				local points = player.compareResult["nTotallScore"]
				table.insert(totalPoints,points)
				self.shisanshui_ui:ShowPlayerTotalPoints(player.viewSeat,points)
			end
			table.sort(totalPoints)
			local maxTotalPoint =  totalPoints[#totalPoints]
			if maxTotalPoint ~= nil then
				for i,player in pairs(self.PlayerList) do
					if tonumber(maxTotalPoint) == tonumber(player.compareResult["nTotallScore"]) then
						self.shisanshui_ui:SetPlayerLightFrame(player.viewSeat)
						coroutine.wait(1)
						-- self.shisanshui_ui:DisablePlayerLightFrame()
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
	
function table_component:SetCodeCardEffect(tran)
	if roomdata_center.gamesetting["nBuyCode"] > 0 then	
		local dipai = child(tran,"dipai")
	
		local meshRender = componentGet(dipai.transform, "MeshRenderer")
		local originMatInfo = {}
		originMatInfo.meshRender = meshRender
		originMatInfo.sharedMaterial = meshRender.sharedMaterial
		codeMaterial = originMatInfo
		--table.insert(codeMaterial, originMatInfo)				
		if meshRender ~= nil then
			local highLightMatTbl = self.resMgrComponet.GetHighLightMat()
			LuaHelper.AddMatToMeshRenderer(meshRender, highLightMatTbl.mat1, highLightMatTbl.mat2)					 
		end
	end
	
end
		
function table_component:HeGuan()
	if self.heguan_manage == nil then
		self.heguan_manage = require("logic/poker_sys/other/heguan_manage"):create()
	end
end
	
--翻牌
function table_component:OpenCard(state)
	for i, player in pairs(self.PlayerList) do
		if player.viewSeat == 1 then
			if state then
				player:ShowAllCard(0)
			else
				player:ShowAllCard(180)
			end
		end
	end
end
	
function table_component:ChangeDeskCloth()
	if self.poker_chaneg_desk == nil then
		local poker_table = GameObject.Find("poker_table/poker_table01")
		if poker_table ~= nil then
			self.poker_chaneg_desk = require("logic.poker_sys.other.poker_change_desk"):create(poker_table,self.roomNumComp)
		end
	end
	self.poker_chaneg_desk:ChangeDeskCloth()
end

function table_component:MouseBinDown(position)	
	self.heguan_manage:MouseBinDown(position)
end


return table_component
