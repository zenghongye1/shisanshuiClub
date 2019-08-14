local mahjongHelper = require "logic/mahjong_sys/utils/mahjongHelper"

local personInfo_ctrl = class ("personInfo_ctrl")

function personInfo_ctrl:ctor()	
	self.personInfo_ui = nil
	self.userInfo = nil
	self.userGameInfo = {}
	self.userGameInfoByGid = {}
	self.pageCurrent = 1
	self.selfUserInfo = nil
	self.selfGameInfo = nil
end

function personInfo_ctrl:Init(Ui)
	self.personInfo_ui = Ui
end

--更新用户信息
function personInfo_ctrl:UpdateUserInfo()
	if self.userInfo == nil or isEmpty(self.userInfo) then
		return
	end
	HeadImageHelper.SetImage(self.personInfo_ui.tex_photo,2,self.userInfo.imageurl)
	self.personInfo_ui.lbl_name.text = self.userInfo.nickname
	self.personInfo_ui.lbl_id.text = "ID:"..self.userInfo.uid
	self.personInfo_ui.lbl_ticket.text = "房卡:"..self.userInfo.card
	self.personInfo_ui.lbl_vipLevel.text = self.userInfo.vip 	--VIP等级待处理
	
	if self.userInfo.city == nil or tonumber(self.userInfo.city) == 0 then
		self.personInfo_ui.lbl_address.text = "中国"
	else
		self.personInfo_ui.lbl_address.text = ClubUtil.GetLocationNameById(tonumber(self.userInfo.city),"中国")
	end

	self.personInfo_ui.curLocationId = tostring(self.userInfo.city)
	self.personInfo_ui.lbl_gameNum.text = "对局数："..self.userInfo.gamet
	self.personInfo_ui.lbl_winRate.text = "胜率："..string.format("%d",(self.userInfo.winrate*100)).."%"
	
end

--更新玩法信息
function personInfo_ctrl:UpdateBtnShowList()
	self:SetActiveToggle(4,false)
	self:EnableBtn("neither")
	if self.userGameInfo == nil or isEmpty(self.userGameInfo) then
		return
	end
	local maxLen = table.getn(self.userGameInfo)
	local maxPage = math.floor(maxLen/4) + 1	
	self:ShowBtnPage(maxPage,maxLen)
end

--设置当前页的按钮信息
function personInfo_ctrl:ShowBtnPage(mPage,mLen)
	if mPage == 0 or mLen == 0 then
		return
	end
	local index = 0
	for k,v in ipairs(self.userGameInfo) do
		if k > ((self.pageCurrent-1)*4) and k <= (self.pageCurrent*4) then
			index = index + 1
			self.personInfo_ui.btn_game[index].gameObject.name = v["gid"]
			componentGet(child(self.personInfo_ui.btn_game[index],"lbl"),"UILabel").text = v["gameName"]
			componentGet(child(self.personInfo_ui.btn_game[index],"lbl_selected"),"UILabel").text = v["gameName"]
		end
	end
	self:SetActiveToggle(index,true)
	
	if mLen <= 4 then
		self:EnableBtn("neither")
	else
		if self.pageCurrent == 1 then
			self:EnableBtn("right")
		else
			if mLen > (self.pageCurrent*4) then
				self:EnableBtn("both")
			else
				self:EnableBtn("left")
			end
		end
	end
end

--设置当前页toggle的活动状态
function personInfo_ctrl:SetActiveToggle(num,state)
	for i=1,num do
		self.personInfo_ui.btn_game[i].gameObject:SetActive(state)		
	end
end

--左右导航的活动状态
function personInfo_ctrl:EnableBtn(dirStr)
	if dirStr == "right" then
		self.personInfo_ui.boxCollider_left.enabled = false
		self.personInfo_ui.boxCollider_right.enabled = true
		self.personInfo_ui.sp_left.color = Color.New(1,1,1,50/255)
		self.personInfo_ui.sp_right.color = Color.New(1,1,1,1)
	elseif dirStr == "left" then
		self.personInfo_ui.boxCollider_left.enabled = true
		self.personInfo_ui.boxCollider_right.enabled = false
		self.personInfo_ui.sp_left.color = Color.New(1,1,1,1)
		self.personInfo_ui.sp_right.color = Color.New(1,1,1,50/255)
	elseif dirStr == "both" then
		self.personInfo_ui.boxCollider_left.enabled = true
		self.personInfo_ui.boxCollider_right.enabled = true
		self.personInfo_ui.sp_left.color = Color.New(1,1,1,1)
		self.personInfo_ui.sp_right.color = Color.New(1,1,1,1)
	elseif dirStr == "neither" then
		self.personInfo_ui.boxCollider_left.enabled = false
		self.personInfo_ui.boxCollider_right.enabled = false
		self.personInfo_ui.sp_left.color = Color.New(1,1,1,50/255)
		self.personInfo_ui.sp_right.color = Color.New(1,1,1,50/255)
	end
end

--初始化
function personInfo_ctrl:InitGameInfo()
	self.personInfo_ui.lbl_gameCount.text = "游戏局数："
	self.personInfo_ui.lbl_gameWinRate.text = "胜率："
	self.personInfo_ui.lbl_maxWinCount.text = "最大赢数："
	self.personInfo_ui.tran_pokerShow.gameObject:SetActive(false)
end

--根据gid显示数据详情
function personInfo_ctrl:UpdateGameInfoByGid(gid)
	if self.userGameInfoByGid == nil or isEmpty(self.userGameInfoByGid) then
		return
	end
	--Trace("userGameInfoByGid------------"..GetTblData(self.userGameInfoByGid[gid]))
	self.personInfo_ui.lbl_gameCount.text = "游戏局数："..self.userGameInfoByGid[gid]["gameCount"]
	self.personInfo_ui.lbl_gameWinRate.text = "胜率："..string.format("%d",(self.userGameInfoByGid[gid]["winRate"]*100)).."%"
	self.personInfo_ui.lbl_maxWinCount.text = "最大赢数："..self.userGameInfoByGid[gid]["maxWinCount"]
	self.personInfo_ui.lbl_maxWinScore.text = "输赢总分："..self.userGameInfoByGid[gid]["maxWinScore"]
	
	self:ShowMaxCardData(self.userGameInfoByGid[gid]["cardShow"],gid)
end

--显示最大牌型详情
function personInfo_ctrl:ShowMaxCardData(cardData,gid)
	if not GameUtil.CheckGameIdIsMahjong(gid) then
		self.personInfo_ui.tips.gameObject:SetActive(false)
		self.personInfo_ui.tran_itemList.gameObject:SetActive(false)
		if table.getCount(cardData)<=0 then
			self.personInfo_ui.tips.gameObject:SetActive(true)
			self.personInfo_ui.tran_pokerShow.gameObject:SetActive(false)
			return
		end
		self.personInfo_ui.tran_pokerShow.gameObject:SetActive(true)
		local cardShow = require("logic/cardShow/poker_cardShow"):create(self.personInfo_ui.tran_pokerShow,cardData["cards"],cardData["nSpecialType"])
		cardShow:SetPokerCardShow(gid)
	else
		self.personInfo_ui.tips.gameObject:SetActive(false)
		local replaceSpecialCardValue = nil
		if tonumber(gid)==ENUM_GAME_TYPE.TYPE_XIAMEN_MJ or 
            tonumber(gid)==ENUM_GAME_TYPE.TYPE_ZHANGZHOU_MJ or
            tonumber(gid)==ENUM_GAME_TYPE.TYPE_LONGYAN_MJ or
            tonumber(gid)==ENUM_GAME_TYPE.TYPE_NINGDE_MJ or
            tonumber(gid)==ENUM_GAME_TYPE.TYPE_DAXI_MJ then
            replaceSpecialCardValue = 37
        end
		self.personInfo_ui.tran_pokerShow.gameObject:SetActive(false)
		local specialCardType = config_mgr.getConfig("cfg_mahjongconfig",gid).specialCardSpriteName
		self:ShowMJ(cardData,cardData.laizicards,replaceSpecialCardValue,specialCardType)	
	end
end

function personInfo_ctrl:ShowMJ(info,specialCardValues,replaceSpecialCardValue,specialCardType)
	if table.getCount(info)<=0 then
		self.personInfo_ui.tips.gameObject:SetActive(true)
		self.personInfo_ui.tran_itemList.gameObject:SetActive(false)
		return
	end

  local isWin = table.getCount(info.win_card)>0

  self.personInfo_ui.tran_itemList.gameObject:SetActive(true)
  local handCards = mahjongHelper:GetMJHandCard(info.cards,info.win_card[1],specialCardValues,replaceSpecialCardValue)
  local valueList = mahjongHelper:GetOperValueList(info.combineTile,specialCardValues,replaceSpecialCardValue)

  local distance = 151
  for i=1,#self.personInfo_ui.opercardList do
    self.personInfo_ui:RecycleOperCard(self.personInfo_ui.opercardList[i])
  end
  self.personInfo_ui.opercardList = {}
  for i=1,#valueList do
    local operItem = self.personInfo_ui:GetOperCard()
    operItem:SetActive(true)
    operItem.transform.parent = self.personInfo_ui.tran_itemList
    operItem.transform.localPosition = Vector3((i-1)*distance,0,0)
    operItem.transform.localScale = Vector3.one
    operItem:SetInfo(valueList[i],specialCardValues,specialCardType)
    table.insert(self.personInfo_ui.opercardList,operItem)
  end
  if self.personInfo_ui.handcard==nil or IsNil(self.personInfo_ui.handcard.gameObject) then
    self.personInfo_ui.handcard = self.personInfo_ui:GetHandCard()
    self.personInfo_ui.handcard:SetActive(true)
  end
  self.personInfo_ui.handcard.transform.parent = self.personInfo_ui.tran_itemList
  self.personInfo_ui.handcard.transform.localPosition = Vector3((#valueList)*distance,0,0)
  self.personInfo_ui.handcard.transform.localScale = Vector3.one
  self.personInfo_ui.handcard:SetInfo(handCards,isWin,specialCardValues,specialCardType)

end

--请求数据
function personInfo_ctrl:SetInfoData(uid,callback)
	self:UseSelfCacheData(uid, callback)
	http_request_interface.GetUserInfo(uid,function (str)
		local s = string.gsub(str,"\\/","/")  
		local t = ParseJsonStr(s)
		if t.ret == 0 then
			self:SetUserInfo(t.userinfo)
			self:SetPlayGameListOrder(t.usergameinfo)
			callback()

			if t.userinfo.uid == data_center.GetLoginUserInfo().uid then
				self.selfUserInfo = t.userinfo
				self.selfGameInfo = t.usergameinfo
			end
		else
			--waiting_ui.Hide()
			UI_Manager:Instance():FastTip("获取玩家信息失败！")
		end
	end)
end

function personInfo_ctrl:UseSelfCacheData(uid ,callback)
	if uid ~= data_center.GetLoginUserInfo().uid then
		return
	end
	if self.selfUserInfo ~= nil and self.selfGameInfo ~= nil then
		self:SetUserInfo(self.selfUserInfo)
		self:SetPlayGameListOrder(self.selfGameInfo)
		callback()
	end
end




function personInfo_ctrl:SetUserInfo(data)
	self.userInfo = data
end

function personInfo_ctrl:SetPlayGameListOrder(data)
	if data == nil or isEmpty(data) then
		logError("SetPlayGameListOrder == nil")
		return
	end
	self.userGameInfo = {}
	for k,v in ipairs(data) do
		local gameCount = v["wint"] + v["loset"] + v["drawt"]
		if gameCount > 0 then
			local order = GameUtil.GetGameListOrderKeys(v["gid"])
			local name = GameUtil.GetGameName(v["gid"])
			local t = {}
			t["gameCount"] = gameCount
			t["winRate"] = v["wint"]/gameCount
			t["maxWinCount"] = v["maxwin"]
			t["maxWinScore"] = v["allscore"] or 0
			t["cardShow"] = v["maxcard"]
			t["showOrder"] = order
			t["gameName"] = name
			t["gid"] = v["gid"]
			table.insert(self.userGameInfo,t)
		end
	end
	table.sort(self.userGameInfo,function (a,b) return b["showOrder"] > a["showOrder"] end)
	self:SetPlayGameListByGid()
end

function personInfo_ctrl:SetPlayGameListByGid()
	self.userGameInfoByGid = {}
	for k,v in ipairs(self.userGameInfo) do
		self.userGameInfoByGid[v["gid"]] = v
	end
end

function personInfo_ctrl:SetUserCity(cityID,callback)
	http_request_interface.SetUserCity(cityID,function (str)
		local s = string.gsub(str,"\\/","/")  
		local t = ParseJsonStr(s)
		if t.ret == 0 then
			callback()
		else
			UI_Manager:Instance():FastTip("设置位置失败！")
		end
	end)
end

--[[--
 * @Description: 获取用户信息 
 ]]
function personInfo_ctrl:GetUserInfo()
	return self.userInfo
end

--[[--
 * @Description: 获取已排序的游戏数据表
 ]]
function personInfo_ctrl:GetPlayGameListOrder()
	return self.userGameInfo
end

--[[--
 * @Description: 获取gid索引的游戏数据表
 ]]
function personInfo_ctrl:GetPlayGameListByGid()
	return self.userGameInfoByGid
end

--[[--
 * @Description: 获取已排序的游戏数据表长
 ]]
function personInfo_ctrl:GetPlayGameListOrderLen()
	return table.getCount(self.userGameInfo)
end

return personInfo_ctrl