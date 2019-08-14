mahjong_small_reward_ui = ui_base.New()
local reward_player_item_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_player_item_view"
local reward_title_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_title_view"
local mahjong_opercard_view = require "logic/mahjong_sys/ui_mahjong/reward/mahjong_opercard_view"
local mahjong_handcard_view = require "logic/mahjong_sys/ui_mahjong/reward/mahjong_handcard_view"

local this = mahjong_small_reward_ui
local data 
function this.Show(tbl ,who_win,isBigReward,t_rid, winType)
	data = {
		tbl = tbl,
		who_win = who_win,
		isBigReward = isBigReward,
		t_rid = t_rid,
		winType = winType
	}
	if IsNil(this.gameObject) then
		this.gameObject = newNormalUI("game_18/ui/reward/mahjong_reward_ui")
    	this.gameObject.transform:SetParent(mahjong_ui.transform, false)
    	this.transform = this.gameObject.transform
	else
		this.gameObject:SetActive(true)
    	this.SetRewards(tbl ,who_win,isBigReward,t_rid, winType)
	end
end

function this.Hide()
	if not IsNil(this.gameObject) then
 		this.gameObject:SetActive(false)
 	end
 	data = nil
end

function this.Awake()
	this.InitView()
end

function this.Start()
	if data ~=nil then
		this.SetRewards(data.tbl ,data.who_win,data.isBigReward,data.t_rid,data.winType)
	end
end

function this.OnDestroy()
end

function this.InitView()
	this.titleView = reward_title_view:create(child(this.transform, "reward_panel/Panel_Top/titleView").gameObject)
	this.btnGo = child(this.transform, "reward_panel/Panel_Middle/button").gameObject
	-- this.selectIconTr = child(this.transform, "reward_panel/Panel_Middle/infoList/selectIcon")
	-- this.selectIconTr.gameObject:SetActive(false)
	this.operItemList_EX = child(this.transform, "reward_panel/Panel_Middle/infoList/operItemList").gameObject
	this.cardItemList_EX = child(this.transform, "reward_panel/Panel_Middle/infoList/cardItemList").gameObject
	this.itemList = {}

	for i = 1, 4 do
		local item = reward_player_item_view:create(child(this.transform, "reward_panel/Panel_Middle/infoList/playerInfoItem" .. i).gameObject)
		table.insert(this.itemList, item)
	end
	addClickCallbackSelf(this.btnGo, this.OnBtnClick, this)
end

function this.OnBtnClick()
	if data.isBigReward then
		bigSettlement_ui.Init(t_rid)
		this.Hide()
	    local rid = t_rid
	    Notifier.dispatchCmd(cmdName.GAME_SOCKET_LUMP_SUM, {rid})
	else
		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_ready", true))
		mahjong_play_sys.ReadyGameReq()
	end
end


function this.SetRewards(tbl ,win_viewSeat,isBigReward,t_rid, winType)
	this.SetTitleView(win_viewSeat, winType)
	
	local firstSeat = win_viewSeat
	-- 胡牌人是第一个，否则庄在第一个
	if winType ~= "huangpai" then
		this.itemList[1]:SetInfo(tbl[win_viewSeat],true, firstSeat)
		this.itemList[1]:ShowWin(true)
	else
		for i = 1, #tbl do
			if tbl[i].isBanker then
				firstSeat = i
				break
			end
		end
		this.itemList[1]:SetInfo(tbl[firstSeat],false, firstSeat)
		this.itemList[1]:ShowWin(false)
	end

	local itemIndex = 2
	for i=1,#tbl-1 do
		local seat = firstSeat + i
		if seat > #tbl then
			seat = seat - #tbl
		end

		this.itemList[itemIndex]:ShowWin(false)
		this.itemList[itemIndex]:SetInfo(tbl[seat],false, seat)
		itemIndex = itemIndex + 1
	end

	-- 隐藏多余item
	for i = roomdata_center.MaxPlayer() + 1, 4 do
		this.itemList[i]:SetActive(false)
	end

	-- this.SetSelfIcon(#tbl)
end

function this.SetSelfIcon(length)
	for i = 1, length do
		if room_usersdata_center.GetViewSeatByLogicSeatNum(i) == 1 then
			this.selectIconTr.gameObject:SetActive(true)
			this.selectIconTr.position = this.itemList[i].infoView:GetSelfIconPosition()
			return
		end
	end
	this.selectIconTr.gameObject:SetActive(false)
end

-- 添加胡牌类型枚举？
function this.SetTitleView(viewSeat, winType)
	if winType == "huangpai" then
		this.titleView:SetResult(3)
	elseif viewSeat == 1 then
		this.titleView:SetResult(1)
	else
		this.titleView:SetResult(2)
	end
end

local opercardList = {}
--local handcardList = {}

function this.GetOperCard()
	local opercard = nil
	if 0 == #opercardList then
		local go = newobject(this.operItemList_EX)
		opercard = mahjong_opercard_view:create(go)
		return opercard
	else
		while(#opercardList > 0)
		do
			if not IsNil(opercardList[#opercardList].gameObject) then
				return table.remove(opercardList)
			else
				table.remove(opercardList)
			end
		end
		return this.GetOperCard()
	end
end

function this.RecycleOperCard(item)
	if not IsNil(item.gameObject) then
		table.insert(opercardList,item)
		item:SetActive(false)
	end
end

function this.GetHandCard()
	local go = newobject(this.cardItemList_EX)
	local handcard = mahjong_handcard_view:create(go)
	return handcard
end

-- function this.GetHandCard()
-- 	local handcard = nil
-- 	if 0 == #handcardList then
-- 		local go = newobject(this.operItemList_EX)
-- 		handcard = mjItem_view:create(go)
-- 		return handcard
-- 	else
-- 		while(#handcardList > 0)
-- 		do
-- 			if not IsNil(handcardList[#handcardList].gameObject) then
-- 				handcard = handcardList[#handcardList]
-- 				return handcard
-- 			else
-- 				table.remove(handcardList)
-- 			end
-- 		end
-- 		return this.GetHandCard()
-- 	end
-- end

-- function this.RecycleHandCard(item)
-- 	if not IsNil(item.gameObject) then
-- 		table.insert(handcardList,item)
-- 		item:SetActive(false)
-- 	end
-- end