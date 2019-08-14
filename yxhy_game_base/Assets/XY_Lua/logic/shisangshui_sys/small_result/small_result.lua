require "logic/shisangshui_sys/special_card_show/special_card_show"
require "logic/shisangshui_sys/card_data_manage"

local base = require("logic.framework.ui.uibase.ui_window")
local small_result_ui = class("small_result_ui",base)

local poker_result_item = require("logic.poker_sys.other.poker_result_item")

function small_result_ui:ctor()
	base.ctor(self)
	self.isEnterTotalResult = false
	self.userTranList = {}		--存放user的tran
	self.playerItemList = {}
	self.ScorestUid = {}
	self.shakeCount = 0
	self.destroyType = UIDestroyType.ChangeScene
	self.curPlayerCount = 0
end

--最大等待时间
local leftTime = 0
local timer_Elapse = nil

function small_result_ui:OnInit()
	self:InitView()
end

function small_result_ui:OnOpen(tbl)
	UI_Manager:Instance():CloseUiForms("chat_ui")
	UI_Manager:Instance():CloseUiForms("special_card_show")
	if tbl == nil then
		logError("small_result_ui-----------tbl == nil ")
		return
	end
	self.curPlayerCount = table.getCount(tbl["rewards"])
	self:CreateUserTran()
	self:UpdateView(tbl)
end

function small_result_ui:InitView()
	self.lbl_time = componentGet(child(self.gameObject.transform, "Panel/bottom/readyBtn/readylbl"), "UILabel")
	
	local btn_ready = child(self.gameObject.transform, "Panel/bottom/readyBtn")
	if btn_ready ~= nil then
		addClickCallbackSelf(btn_ready.gameObject,self.ReadyClick,self)
	end
	
	local btn_screenShot = child(self.gameObject.transform,"Panel/bottom/screenShotBtn")
	if btn_screenShot ~= nil then
		addClickCallbackSelf(btn_screenShot.gameObject,self.ScreenShotClick,self)
	end
	
	local tran_userSelf = child(self.gameObject.transform,"Panel/center/Self/user")
	table.insert(self.userTranList,tran_userSelf)
	self.tran_userOther = child(self.gameObject.transform,"Panel/center/resultList/user")
	
	self.lbl_roomInfo = componentGet(child(self.gameObject.transform, "Panel/bottom/room"),"UILabel")
	self.lbl_gameName = componentGet(child(self.gameObject.transform, "Panel/bottom/gameName"),"UILabel")
	self.lbl_date = componentGet(child(self.gameObject.transform,"Panel/bottom/date"),"UILabel")
	
	self.scrollView_result = child(self.gameObject.transform,"Panel/center/resultList")
	self.item_grid = subComponentGet(self.scrollView_result,"userGrid","UIGrid")
end

function small_result_ui:CreateUserTran()
	for i=1,roomdata_center.maxSupportPlayer do
		if i <= self.curPlayerCount then
			if not self.userTranList[i] then
				local obj = GameObject.Instantiate(self.tran_userOther.gameObject)
				obj.name = "user"..(i-1)
				obj.transform:SetParent(self.item_grid.transform,false)
				self.userTranList[i] = obj.transform
			end
			self.userTranList[i].gameObject:SetActive(true)
			if not self.playerItemList[i] then
				local item = poker_result_item:create(self.userTranList[i].gameObject)
				self.playerItemList[i] = item
			end
		else
			if self.userTranList[i] and not IsNil(self.userTranList[i].gameObject) then
				self.userTranList[i].gameObject:SetActive(false)
			end
		end
	end
	self.item_grid:Reposition()
end

function small_result_ui:UpdateView(result)
	self.scrollView_result.gameObject:SetActive(false)
	if result["ju_num"] == result["curr_ju"] then
		self.isEnterTotalResult = true
		self.lbl_time.text = "继续"
	else
		self.isEnterTotalResult = false
	end
	self:InitPokerResultSys()
	self.lbl_roomInfo.text = self.pokerResultSys:GetRoomNum()
	self.lbl_gameName.text = self.pokerResultSys:GetGameName()
	self.lbl_date.text = self.pokerResultSys:GetTime()
	self:LoadAllResult(result["rewards"])
end

function small_result_ui:InitPokerResultSys()
	self.pokerResultSys = require("logic/poker_largeResult_ui/pokerResult_sys"):create()
	self.pokerResultSys.fangzhuId = roomdata_center.ownerId 	 --房主ID
	self.pokerResultSys:SetRoomData()
end

function small_result_ui:LoadAllResult(result)
	local tbSort = {}
	local selfId = data_center.GetLoginUserInfo().uid
	local ScoreUid = {}	  ----最高分——uid表
	
	for i=1,self.curPlayerCount do
		if result[i] then
			ScoreUid[tostring(result[i]["_uid"])] = result[i]["all_score"]
				-------非主机的其他用户----------
			if selfId ~= result[i]._uid then	
				table.insert(tbSort,result[i])
			else	--------主机用户放在首位---------
				Trace("判断:"..selfId .. "等于" .. result[i]._uid)
				self.playerItemList[1]:SetItemInfo(result[i]["_chair"])	
				self.playerItemList[1]:SetSpecialShow(result[i]["nSpecialType"])
				self.playerItemList[1]:ShowCardData(result[i]["stCards"],result[i]["nSpecialType"])
				self.playerItemList[1]:SetScoreShow(result[i]["all_score"])
				self.playerItemList[1]:SetRoomer(result[i]["_uid"])
			end
		end
	end	
	self.ScorestUid = self.pokerResultSys:FindHighestByuid(ScoreUid)
	
	local isBigWin = false
	self.pokerResultSys:ShowHighest(selfId,self.ScorestUid,function()		
		isBigWin = true
	end)
	self.playerItemList[1]:SetBigWin(isBigWin)
	
	self:ShowOthersResult(tbSort)
	self:RefreshUI()
end

--------------------显示客机用户的结算数据-----------------
function small_result_ui:ShowOthersResult(tbSort)
	table.sort(tbSort,function (a,b) return a.all_score > b.all_score end)
	for i=1,self.curPlayerCount-1 do
		if tbSort[i] ~= nil then 
			self.userTranList[i+1].gameObject:SetActive(true)
			self.playerItemList[i+1]:SetItemInfo(tbSort[i]["_chair"])
			self.playerItemList[i+1]:SetSpecialShow(tbSort[i]["nSpecialType"])
			self.playerItemList[i+1]:ShowCardData(tbSort[i]["stCards"],tbSort[i]["nSpecialType"])
			self.playerItemList[i+1]:SetScoreShow(tbSort[i]["all_score"])
			self.playerItemList[i+1]:SetRoomer(tbSort[i]["_uid"])
			local isBigWin = false
			self.pokerResultSys:ShowHighest(tbSort[i]["_uid"],self.ScorestUid,function()		
				isBigWin = true
			end)
			self.playerItemList[i+1]:SetBigWin(isBigWin)
		end
	end
end

function small_result_ui:RefreshUI()
	self.scrollView_result.gameObject:SetActive(true)
	componentGet(self.scrollView_result,"UIScrollView"):ResetPosition()
	componentGet(self.scrollView_result,"UIPanel"):Refresh()
end

function small_result_ui:ReadyClick(obj)
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	if self.isEnterTotalResult then
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SMALL_SETTLEMENT) --确认完成第八局小结算完成消息
	else
		self:Reset()
		Notifier.dispatchCmd(cmdName.ReadyDisCountDowm,leftTime) --让牌局UI显示剩下的时间倒计时
	end
	self:CloseWin()
end

function small_result_ui:ScreenShotClick()
	screenshotHelper.ShotToPhoto(function ()
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10090))
	end)
end

function small_result_ui:Reset()
	pokerPlaySysHelper.GetCurPlaySys().ReadyGameReq()--发送准备好的状态进入下一局
end

function small_result_ui:CloseWin()
	UI_Manager:Instance():CloseUiForms("shisanshui_smallResult_ui")
end

function small_result_ui:SetTimerStart(timeo)
	if(timer_Elapse == nil) then
		self:StartTimer(timeo)
	end
end

function small_result_ui:StartTimer(time)
	if self.isEnterTotalResult ~= true then
		if(time <= 0) then
			self.lbl_time.text = "继续"
			return
		end
		self.lbl_time.text = ("继续(" ..math.floor(time).."s)")
	end
	leftTime = time
	timer_Elapse = Timer.New(function()
			self:OnTimer_Proc()
		end,1,time)
	timer_Elapse:Start()
end

function small_result_ui:OnTimer_Proc()
	self.shakeCount = self.shakeCount + 1
	if(leftTime >= 1)then
		leftTime = leftTime -1
		self.lbl_time.text = ("继续(" .. math.floor(leftTime).."s)")
	else
		self.lbl_time.text = ("继续")
	end
	
	if self.shakeCount == 30 then
		Notifier.dispatchCmd(cmdName.MSG_SHAKE,{}) 
		self.shakeCount = 0
	end
	
	if leftTime <= 0 and self.isEnterTotalResult ~= true then
		self.lbl_time.text = ("继续")
		self:StopTimer()
		return
	end
end

function small_result_ui:StopTimer()
	if timer_Elapse ~= nil then
		timer_Elapse:Stop()
		timer_Elapse = nil
		self.shakeCount = 0
	end
end

function small_result_ui:OnClose()
	self:StopTimer()
end

function small_result_ui:PlayOpenAmination()
	--打开动画重写
end

return small_result_ui