local mahjongHandCardPoolClass = require "logic/mahjong_sys/utils/mahjongHandCardPoolClass"
local base = require("logic.framework.ui.uibase.ui_window")
local personInfo_ui = class("personInfo_ui",base)

function personInfo_ui:ctor()
	base.ctor(self)
	self.curLocationId = 0
	self.opercardList = {}
	self.btn_select = 0
end

function personInfo_ui:OnInit()
	self:InitView()
	self:InitPersonInfoCtrl()
end

function personInfo_ui:OnOpen(id)
	self.uid = id or data_center.GetLoginUserInfo().uid
	--每次打开刷新第一页
	self.personInfo_ctrl.pageCurrent = 1
	self:UpdateView(self.uid)
end

-- function personInfo_ui:PlayOpenAmination()
-- 	--打开动画重写
-- end

function personInfo_ui:OnRefreshDepth()
	local uiEffect = child(self.gameObject.transform, "personInfo_panel/Panel_Top/Title/Effect_youxifenxiang")
	if uiEffect and self.sortingOrder then
	local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
	end
end

function personInfo_ui:PlayOpenAnimationFinishCallBack()	--tween动画播放再刷新界面，否则会出现渲染空白的问题
	-- self:UpdateView(self.uid)
end

function personInfo_ui:InitView()
	local btn_close = child(self.gameObject.transform,"personInfo_panel/Panel_Top/btn_close")
	if btn_close ~= nil then
		addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
	end
	
	local Panel_Middle = child(self.gameObject.transform,"personInfo_panel/Panel_Middle")
	self.tex_photo = componentGet(child(Panel_Middle,"left/head"),"UITexture")
	self.lbl_name = componentGet(child(Panel_Middle,"left/info/name"),"UILabel")
	self.lbl_id = componentGet(child(Panel_Middle,"left/info/id"),"UILabel")
	self.lbl_ticket = componentGet(child(Panel_Middle,"left/info/ticket"),"UILabel")
	self.lbl_vipLevel = componentGet(child(Panel_Middle,"left/info/vip/Label"),"UILabel")
	
	self.lbl_address = componentGet(child(Panel_Middle,"right/totalInfo/address/self"),"UILabel")
	self.lbl_gameNum = componentGet(child(Panel_Middle,"right/totalInfo/winInfo/gameNum"),"UILabel")
	self.lbl_winRate = componentGet(child(Panel_Middle,"right/totalInfo/winInfo/winRate"),"UILabel")
	self.btn_address = child(Panel_Middle,"right/totalInfo/btnAddress")
	if self.btn_address ~= nil then
		addClickCallbackSelf(self.btn_address.gameObject,self.ChangeAddress,self)
	end
	
	self.btn_copy = child(Panel_Middle,"left/copyBtn")
	if self.btn_copy then
		addClickCallbackSelf(self.btn_copy.gameObject,self.ClickCopyBtn,self)
		self.btn_copy.gameObject:SetActive(false)
	end
	
	self.tran_vip = child(Panel_Middle,"left/info/vip")		--vip未设计先屏蔽
	self.tran_vip.gameObject:SetActive(false)
	local btn_vip = child(Panel_Middle,"left/vipBtn")
	btn_vip.gameObject:SetActive(false)
	if btn_vip ~= nil then
		addClickCallbackSelf(btn_vip.gameObject,self.ClickVipInfo,self)
	end
	
	local tran_btnList = child(Panel_Middle,"right/btnList")
	local btnLeft = child(tran_btnList,"btnLeft")
	if btnLeft ~= nil then
		self.boxCollider_left = componentGet(btnLeft,"BoxCollider")
		self.sp_left = componentGet(child(btnLeft,"Sprite"),"UISprite")
		addClickCallbackSelf(btnLeft.gameObject,self.ClickLeftMove,self)
	end
	local btnRight = child(tran_btnList,"btnRight")
	if btnRight ~= nil then
		self.boxCollider_right = componentGet(btnRight,"BoxCollider")
		self.sp_right = componentGet(child(btnRight,"Sprite"),"UISprite")
		addClickCallbackSelf(btnRight.gameObject,self.ClickRightMove,self)
	end
	self.btn_game = {}
	for i =1,4 do
		table.insert(self.btn_game,child(tran_btnList,"btn"..i))
		addClickCallbackSelf(self.btn_game[i].gameObject,self.ChooseGameBtn,self)
	end
	
	self.tran_gameInfo = child(Panel_Middle,"right/gameInfo")
	self.lbl_gameCount = componentGet(child(self.tran_gameInfo,"gameCount"),"UILabel")
	self.lbl_gameWinRate = componentGet(child(self.tran_gameInfo,"winRate"),"UILabel")
	self.lbl_maxWinCount = componentGet(child(self.tran_gameInfo,"maxWinCount"),"UILabel")
	self.lbl_maxWinScore = componentGet(child(self.tran_gameInfo,"maxWinScore"),"UILabel")
	self.tran_pokerShow = child(self.tran_gameInfo,"pokerShow")
	self.tips = child(self.tran_gameInfo,"tips")
	componentGet(self.tips,"UILabel").text = ""
	self.noGameTips = child(Panel_Middle,"right/noGameTips")

	self.tran_itemList = child(self.tran_gameInfo,"infoList")
	local operItemList_EX = child(self.tran_gameInfo, "infoList/operItemList").gameObject
    local cardItemList_EX = child(self.tran_gameInfo, "infoList/cardItemList").gameObject

    self.handCardPool = mahjongHandCardPoolClass:create(operItemList_EX,cardItemList_EX)
end

function personInfo_ui:GetOperCard()
   return self.handCardPool:GetOperCard()
end

function personInfo_ui:RecycleOperCard(item)
  self.handCardPool:RecycleOperCard(item)
end

function personInfo_ui:GetHandCard()
  return self.handCardPool:GetHandCard()
end

function personInfo_ui:UpdateView(uid)
	if uid ~= data_center.GetLoginUserInfo().uid then
		self.btn_address.gameObject:SetActive(false)
	else
		self.btn_address.gameObject:SetActive(true)
	end
	self.personInfo_ctrl:SetInfoData(uid,function ()
		if self.IsOpened then
			self.personInfo_ctrl:UpdateUserInfo()
			self.personInfo_ctrl:InitGameInfo()
			self.personInfo_ctrl:UpdateBtnShowList()
			self:SetDefaultSelect()
			self.btn_copy.gameObject:SetActive(true)
		end
	end)
end

function personInfo_ui:InitPersonInfoCtrl()
	local Ui = self
	self.personInfo_ctrl = require("logic/hall_sys/personInfo_ui/personInfo_ctrl"):create()
	self.personInfo_ctrl:Init(Ui)
end

function personInfo_ui:ClickVipInfo()
	Trace("ClickVipInfo--------------------------") 
end

function personInfo_ui:ChangeAddress()
	UI_Manager:Instance():ShowUiForms("ProvinceSelectUI", nil, nil, ClubUtil.SupportProvinceList, self.OnProvinceSelected, self)
	--UI_Manager:Instance():ShowUiForms("ClubGameSelectUI", nil, nil, ClubGameSelectEnum.locations, self.curLocationId, self.OnPositionSelected, self)
end


function personInfo_ui:OnProvinceSelected(province)
	UI_Manager:Instance():ShowUiForms("ClubGameSelectUI", nil, nil, ClubGameSelectEnum.locations, self.curLocationId, self.OnPositionSelected, self, province)
end


function personInfo_ui:OnPositionSelected(id)

	UI_Manager:Instance():CloseUiForms("ProvinceSelectUI")
	if id == nil or id == 0 then
		return
	end
	if self.curLocationId == id then
		return
	end
	self.personInfo_ctrl:SetUserCity(id,function()	
		self.curLocationId = id
		self.lbl_address.text = ClubUtil.GetLocationNameById(id,"中国")
	end)
end

--设置默认显示的玩法信息
function personInfo_ui:SetDefaultSelect()
	local len = self.personInfo_ctrl:GetPlayGameListOrderLen()
	if len <= 0 then
		self:NeverPlayGame()
		return
	end
	self.noGameTips.gameObject:SetActive(false)
	self.tran_gameInfo.gameObject:SetActive(true)
	local obj = self.btn_game[1].gameObject
	self:ChooseGameBtn(obj)
end

function personInfo_ui:NeverPlayGame()
	self.tran_gameInfo.gameObject:SetActive(false)
	self.noGameTips.gameObject:SetActive(true)
end

function personInfo_ui:ChooseGameBtn(obj)
	self:CheckBtnState(obj.name)
	if self.btn_select == obj.name then
		return
	end
	self.btn_select = obj.name
	self.personInfo_ctrl:UpdateGameInfoByGid(tonumber(obj.name))
end

--上一页
function personInfo_ui:ClickLeftMove()
	self.personInfo_ctrl.pageCurrent = self.personInfo_ctrl.pageCurrent - 1
	self.personInfo_ctrl:UpdateBtnShowList()
	self:CheckBtnState(self.btn_select)
end

--下一页
function personInfo_ui:ClickRightMove()
	self.personInfo_ctrl.pageCurrent = self.personInfo_ctrl.pageCurrent + 1
	self.personInfo_ctrl:UpdateBtnShowList()
	self:CheckBtnState(self.btn_select)
end

--处理toggle按钮的活动状态
function personInfo_ui:CheckBtnState(name)
	for i=1,4 do
		if self.btn_game[i].gameObject.name == name then
			if self.btn_game[i].gameObject.activeSelf == false then
				componentGet(self.btn_game[i].gameObject,"UIToggle").value = false
			else
				componentGet(self.btn_game[i].gameObject,"UIToggle").value = true
			end
		else
			componentGet(self.btn_game[i].gameObject,"UIToggle").value = false
		end	
	end
end

---复制id
function personInfo_ui:ClickCopyBtn()
	local str = self.personInfo_ctrl:GetUserInfo().uid
	Trace("Id --- OnCopyBtnClick:"..tostring(str))
	YX_APIManage.Instance:onCopy(str,function()UI_Manager:Instance():FastTip(GetDictString(6043))end)
end

function personInfo_ui:CloseWin()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("personInfo_ui")
end

function personInfo_ui:ReSetState()
	self.btn_select = 0
	self.tex_photo.mainTexture = newNormalObjSync(data_center.GetAppConfDataTble().appPath.."/uitextures/art/common_head", typeof(UnityEngine.Texture2D))
	self.lbl_name.text = ""
	self.lbl_id.text = "ID："
	self.lbl_ticket.text = "房卡："
	self.lbl_address.text = "中国"
	self.lbl_gameNum.text = "对局数："
	self.lbl_winRate.text = "胜率："
	self.btn_copy.gameObject:SetActive(false)
	self.tran_gameInfo.gameObject:SetActive(false)
	self.noGameTips.gameObject:SetActive(false)
	for i=1,4 do
		self.btn_game[i].gameObject:SetActive(false)
	end
	self.personInfo_ctrl:EnableBtn("neither")
	self.btn_address.gameObject:SetActive(false)
end

function personInfo_ui:OnClose()
	self:ReSetState()
end

return personInfo_ui