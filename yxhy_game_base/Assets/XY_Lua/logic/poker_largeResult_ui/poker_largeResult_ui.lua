local base = require("logic.framework.ui.uibase.ui_window")
local poker_largeResult_ui = class("poker_largeResult_ui",base)

local poker_largeResult_item = require("logic.poker_largeResult_ui.poker_largeResult_item")

function poker_largeResult_ui:ctor()
	base.ctor(self)
	self.userTranList = {}		
	self.playerItemList = {}
	self.highestUid = {}
	self.destroyType = UIDestroyType.Immediately
	self.curPlayerCount = 0
end

function poker_largeResult_ui:OnInit()	
	self:InitView()
end

function poker_largeResult_ui:OnOpen(data)
	UI_Manager:Instance():CloseUiForms("shisanshui_smallResult_ui")
	
	if data.result ~= nil and not isEmpty(data.result) then
		Trace("总结算large_result------"..GetTblData(data.result))
		self:UpdateView(data.result)
	else
		largeResultData = nil
		logError("牌类服务器给大结算空")
	end
	roomdata_center.isStart = false
end

function poker_largeResult_ui:PlayOpenAmination()
	--打开动画重写
end

--注册事件
function poker_largeResult_ui:InitView()
	local btn_back = child(self.gameObject.transform, "panel/btn/btn_back")
	addClickCallbackSelf(btn_back.gameObject,self.CloseWin,self)
	local btn_end = child(self.gameObject.transform, "panel/btn/btn_end")
	addClickCallbackSelf(btn_end.gameObject,self.CloseWin,self)
    local btn_share = child(self.gameObject.transform,"panel/btn/btn_share")
	addClickCallbackSelf(btn_share.gameObject,self.ShareClick,self)
	
	self.lbl_roomNum = componentGet(child(self.gameObject.transform,"panel/Anchor_TopRight/roomNum"),"UILabel")
	self.lbl_time = componentGet(child(self.gameObject.transform,"panel/Anchor_TopRight/time"),"UILabel")
	self.lbl_gameName = componentGet(child(self.gameObject.transform,"panel/Anchor_TopRight/gameName"),"UILabel")
	
	--苹果审核隐藏界面
	if G_isAppleVerifyInvite then
		if btn_share then
			btn_share.gameObject:SetActive(false)
		end
		if btn_end then
			LuaHelper.SetTransformLocalX(btn_end.gameObject.transform, 0)
		end
	end
end

function poker_largeResult_ui:UpdateView(data)
	self.curPlayerCount = table.getCount(data["players"])
	self:CreatePlayerTran()
	self:InitPokerResultSys(data["owner_uid"])	--房主的uid
	
	local clubName = ""
	if roomdata_center.gt_cfg and roomdata_center.gt_cfg.cid then
		local clubInfo = model_manager:GetModel("ClubModel").clubMap[roomdata_center.gt_cfg.cid]
		if clubInfo and clubInfo["ctype"] ~= 1 then
			clubName = clubInfo.cname
		end
	end
	self.lbl_roomNum.text = self.pokerResultSys:GetGameName().." 房号:  "..tostring(data["rno"]).." ("..tostring(data["curr_ju"]).."/"..tostring(data["ju_num"]).."局"..")"
	self.lbl_time.text = self.pokerResultSys:GetTime()
	self.lbl_gameName.text = clubName
	
	self:LoadAllResult(data["players"])
end

function poker_largeResult_ui:CreatePlayerTran()
	if self.curPlayerCount <= 4 then
		self.inViewTran = child(self.transform,"panel/below4Root")
	else
		self.inViewTran = child(self.transform,"panel/over4Root")
	end
	self.inViewTran.gameObject:SetActive(true)
	self.item_grid = subComponentGet(self.inViewTran,"playerGrid","UIGrid")
	self.playerItem = child(self.inViewTran,"player1")
	self.playerItem.gameObject:SetActive(false)
	
	for i=1,roomdata_center.maxSupportPlayer do
		if i <= self.curPlayerCount then
			if not self.userTranList[i] then
				local obj = GameObject.Instantiate(self.playerItem.gameObject)
				obj.name = "player"..i
				obj.transform:SetParent(self.item_grid.transform,false)
				self.userTranList[i] = obj.transform
			end
			self.userTranList[i].gameObject:SetActive(true)
			if not self.playerItemList[i] then
				local item = poker_largeResult_item:create(self.userTranList[i].gameObject)
				self.playerItemList[i] = item
			end
		else
			if self.userTranList[i] and not IsNil(self.userTranList[i].gameObject) then
				self.userTranList[i].gameObject:SetActive(false)
			end
		end
	end
	self.item_grid:Reposition()
-------------居中控制-------------
	self:SetUserGridPos()
end

function poker_largeResult_ui:InitPokerResultSys(ownerId)
	self.pokerResultSys = require("logic/poker_largeResult_ui/pokerResult_sys"):create()
	self.pokerResultSys.fangzhuId = ownerId
	self.pokerResultSys:SetRoomData()
end

function poker_largeResult_ui:LoadAllResult(players)
	local selfId = data_center.GetLoginUserInfo().uid		--本机uid
	local otherResult = {}
	local Score_Uid = {}	  	--- uid - score表	
	
	if players ~= nil then
		for k,v in pairs(players) do		
			Score_Uid[tostring(v["userData"]["uid"])] = v["all_score"]	
			
			Trace("总结算判断不是本机"..selfId.."-------"..v["userData"]["uid"])
			if tonumber(selfId) ~= tonumber(v["userData"]["uid"]) then	
				table.insert(otherResult,v)
			else	   --------本机用户放在首位---------
				self.playerItemList[1]:SetItemInfo(v["userData"])
				self.playerItemList[1]:SetScoreShow(v["all_score"])
				self.playerItemList[1]:SetRoomer(v["userData"]["uid"])			
				self.playerItemList[1]:SetWinInfo(v["tList"])
			end
		end
		self.highestUid = self.pokerResultSys:FindHighestByuid(Score_Uid) 		----获取最高分的uid
		self.lowestUid = self.pokerResultSys:FindLowestByuid(Score_Uid) 		----获取最低分的uid
		-------------本机用户显示大赢家-------------
		local isBigWin = false
		self.pokerResultSys:ShowHighest(selfId,self.highestUid,function()
			isBigWin = true
		end)
		self.playerItemList[1]:SetBigWin(isBigWin)
		local isBigLoser = false
		self.pokerResultSys:ShowHighest(selfId,self.lowestUid,function ()
			isBigLoser = true
		end)
		self.playerItemList[1]:SetBigLose(isBigLoser)		
		self:ShowOthersResult(otherResult)
	end
end
				
--------------------非主机用户结算信息----------------------			
function poker_largeResult_ui:ShowOthersResult(result)
	local orderScore = result
	table.sort(orderScore,function (a,b) return a.all_score > b.all_score end)	
	for k,v in ipairs(orderScore) do
		if v ~= nil then
			self.playerItemList[k+1]:SetItemInfo(v["userData"])
			self.playerItemList[k+1]:SetScoreShow(v["all_score"])
			self.playerItemList[k+1]:SetRoomer(v["userData"]["uid"])			
			self.playerItemList[k+1]:SetWinInfo(v["tList"])

			local isBigWin = false
			self.pokerResultSys:ShowHighest(v["userData"]["uid"],self.highestUid,function ()
				isBigWin = true
			end)
			self.playerItemList[k+1]:SetBigWin(isBigWin)
			local isBigLoser = false
			self.pokerResultSys:ShowHighest(v["userData"]["uid"],self.lowestUid,function ()
				isBigLoser = true
			end)
			self.playerItemList[k+1]:SetBigLose(isBigLoser)
		end
	end
end

function poker_largeResult_ui:SetUserGridPos()
	if self.curPlayerCount == 2 then
		self.inViewTran.localPosition = Vector3(312,0,0)		
	elseif self.curPlayerCount == 3 then
		self.inViewTran.localPosition = Vector3(154,0,0)
	else
		self.inViewTran.localPosition = Vector3(0,0,0)
	end
end

function poker_largeResult_ui:ShareClick(obj)
	report_sys.EventUpload(38,player_data.GetGameId())
	local loginType = data_center.GetPlatform()
	screenshotHelper.GetShot(loginType,0,2,"分享战绩","http://connect.qq.com/","分享战绩")
end

function poker_largeResult_ui:CloseWin(obj)
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音	
	UI_Manager:Instance():CloseUiForms("poker_largeResult_ui",true)
	pokerPlaySysHelper.GetCurPlaySys().LeaveReq()
end

function poker_largeResult_ui:OnClose()
	self.inViewTran.gameObject:SetActive(false)
	self.userTranList = {}
end

return poker_largeResult_ui