local poolBaseClass = require "logic/common/poolBaseClass"
local HallClubRoomListItem = require "logic/club_sys/View/new/HallClubRoomListItem"
local HallClubRoomsView = class("HallClubRoomsView",HallClubRoomListItem)

local UIManager = UI_Manager:Instance() 
local hidePosX = -300
local showPosX = 350
local isInitItemOK = true
local itemMaxCount = 50			---展示的最大item数量	
local onShowItemMaxCount = 3	---展示的最大可见item数量

function HallClubRoomsView:InitView()	
	self.isMoving = false
	self.isShow = false
	self.itemObjList = {}
	self.proItemCount = 0
	
	self.model = model_manager:GetModel("ClubModel")
	self.hideBtnGo = self:GetGameObject("hideBtn")
	addClickCallbackSelf(self.hideBtnGo, self.OnHideClick, self)
	self.tipsGo = self:GetGameObject("container/scrollview/ui_table/tips")
	self.copyItem = self:GetGameObject("container/item")
	self.scrollviewRoot = self:GetComponent("container/scrollview",typeof(UIScrollView))
	self.tableRoot = self:GetComponent("container/scrollview/ui_table",typeof(UITable))
	
	self.refreshLabelGo = self:GetGameObject("container/refreshLabel")
	self.refreshLabelGo:SetActive(false)
	self.refreshLabel = self:GetComponent("container/refreshLabel", typeof(UILabel))
	self.refreshIconTr = self:GetGameObject("container/refreshLabel/icon").transform
	self.isShowRefreshLabel = false

	self.loadGo = self:GetGameObject("container/scrollview/ui_table/loadLabel")
	self.loadGo:SetActive(false)
	self.isShowLoading = false
	self.loadingTimer = nil

	self.scrollPanel = self:GetComponent("container/scrollview", typeof(UIPanel))

	--self.scrollviewRoot.onMomentumMove = function() self:OnScrollMove() end

	self.scrollviewRoot.onStoppedMoving = function() self:OnScrollStopMove() end

	self.scrollviewRoot.onDragFinished = function() self:OnScrollDragFinished() end

	self.scrollviewRoot.onDragStarted = function() self:OnScrollDragStart() end


	self:InitItems()
end

function HallClubRoomsView:InitItems()
	local createFunc = function () 
		local prefab = newobject(self.copyItem)
		return prefab	
	end

	local recycleFunc = function (obj)
		self:PutToPoolRoot(obj)
	end

	self.roomItemPool = poolBaseClass:create(createFunc,nil,recycleFunc)
    for i=1,10 do
        local obj = self.roomItemPool:Get()
		self.itemObjList[i] = obj
    end
	for i=1,10 do
        self.roomItemPool:Recycle(self.itemObjList[i])
    end
	self:UpdateDatas()
end


-- 松手到停止移动时  才会触发，拖动过程不会触发
function HallClubRoomsView:OnScrollMove()
	if self.scrollPanel.clipOffset.y > 120 then
		self:ShowRefreshLabel(true,1)
	elseif self.scrollPanel.clipOffset.y > 30 then
		self:ShowRefreshLabel(true,2)
	else
		self:ShowRefreshLabel(false)
	end
end

function HallClubRoomsView:OnScrollStopMove()
	--SpringPanel.Begin(self.scrollviewRoot.gameObject, Vector3(0,0,0), 8)
	self:StopTimer()
	self:ShowRefreshLabel(false)
end

function HallClubRoomsView:OnScrollDragFinished()
	self:StopTimer()

	self:ShowRefreshLabel(false)
	-- logError(SpringPanel)
	--self.scrollviewRoot:DisableSpring()
	-- self.scrollviewRoot:SetDragAmount(0,0, false)
	--SpringPanel.Begin(self.scrollviewRoot.gameObject, Vector3(0,0,0), 8)
	if self:ShouldReturnToTop() then
		self.scrollviewRoot:SetDragAmount(0,0, false)
	end

end

function HallClubRoomsView:OnScrollDragStart()
	self:StartTimer()
end

function HallClubRoomsView:ShouldReturnToTop()
		local b = self.scrollviewRoot.bounds;
		if b:GetSize().y > self.scrollPanel.baseClipRegion.w then
			return false
		else
			return true;
		end
end


function HallClubRoomsView:ShowRefreshLabel(value, type)
	if value == true then
		if type == 1 then
			self.refreshIconTr.localEulerAngles = Vector3.zero
			self.refreshLabel.text = "松开手指刷新列表"
		else
			self.refreshIconTr.localEulerAngles = Vector3(0,0,180)
			self.refreshLabel.text = "下拉刷新"
		end
	end

	if value == self.isShowRefreshLabel then
		return
	end
	if value == false then
		self.model:ReqGetAllRoomList(false)
		self:StartLoadingTimer()
	else
		self:StopLoadingTimer()
	end
	self.isShowRefreshLabel = value
	self.refreshLabelGo:SetActive(value)
end

function HallClubRoomsView:ShowLoadingGo(value)
	if value == self.isShowLoading then
		return
	end
	self.isShowLoading = value
	self.loadGo:SetActive(value)
	self.tableRoot:Reposition()
	self.scrollviewRoot:DisableSpring()
	self.scrollPanel.clipOffset={x=0,y=0}
    self.scrollPanel.transform.localPosition={x=0,y=0,z=0}
	self.scrollviewRoot:ResetPosition()
	if self.isShowLoading == false then
		-- self.scrollviewRoot:ResetPosition()
	end
end


function HallClubRoomsView:StartTimer()
	self:StopTimer()
	self.timer = Timer.New(slot(self.OnScrollMove, self), 0.1, -1)
	self.timer:Start()
end

function HallClubRoomsView:StopTimer()
	if self.timer ~= nil then
		self.timer:Stop()
		self.timer = nil
	end
	self:ShowRefreshLabel(false)
end


function HallClubRoomsView:StartLoadingTimer()
	if not self.isShowRefreshLabel then
		return
	end
	self:StopLoadingTimer()
	self.loadingTimer = Timer.New(function() self:StopLoadingTimer() end, 1, 1)
	self:ShowLoadingGo(true)
	self.loadingTimer:Start()
end

function HallClubRoomsView:StopLoadingTimer()
	if self.loadingTimer ~= nil then
		self.loadingTimer:Stop()
		self.loadingTimer = nil
	end
	self:ShowLoadingGo(false)
end


function HallClubRoomsView:PutToPoolRoot(obj)
    if IsNil(self.poolRoot_tr) then
        local o = GameObject.New("HallRoomPoolRoot")
        o:SetActive(false)
        self.poolRoot_tr = o.transform
    end
    obj.transform:SetParent(self.poolRoot_tr,false)
end

function HallClubRoomsView:UpdateDatas()
	if not self.model:HasClub() then
		self.tipsGo:SetActive(true)
		return
	end
	local roomListMap = self.model.allClubRoomMap
	local curDataNum = self.model.allClubRoomNums
	local roomCidList = self.model.roomClubCidList
	
	self.tipsGo:SetActive(roomListMap == nil or table.nums(roomListMap) == 0 or isEmpty(roomCidList))
	if not roomListMap then
		return
	end	
	if curDataNum > self.proItemCount then
		self:AddRoomItem(curDataNum)
	elseif curDataNum < self.proItemCount then
		self:RemoveRoomItem(curDataNum)
	end
	
	local dataIndex = 0
	-- for _,club in pairs(roomListMap) do
	for _,cid in ipairs(roomCidList) do
		if roomListMap[cid] then
			for k,v in ipairs(roomListMap[cid]) do
				dataIndex = dataIndex + 1
				if dataIndex <= itemMaxCount then	
					self.itemObjList[dataIndex]:SetActive(true)
					local item = HallClubRoomListItem:create(self.itemObjList[dataIndex])
					item:SetCallback(self.OnItemClick,self)
					item:SetInfo(v)
					if k > 1 then
						item:ShowClubNameLbl(false)
					end
				end
			end
		end
	end
	self.tableRoot.transform.localPosition = Vector3.zero
	self.tableRoot.repositionNow = true
	if curDataNum <= onShowItemMaxCount then
		--self.scrollviewRoot:ResetPosition()	
	end

	self.proItemCount = curDataNum
end


function HallClubRoomsView:AddRoomItem(curItemCount)
	for i =1,itemMaxCount do
		if i <= curItemCount and i > self.proItemCount then
			local go = self.roomItemPool:Get()
			go.transform.parent = self.tableRoot.transform
			go.transform.localScale = {x=1,y=1,z=1}
			self.itemObjList[i] = go
		end
	end
end

function HallClubRoomsView:RemoveRoomItem(curItemCount)
	for i=1,itemMaxCount do
		if i > curItemCount and i <= self.proItemCount then
			self.roomItemPool:Recycle(self.itemObjList[i])
			self.itemObjList[i] = nil
		end
	end
end

function HallClubRoomsView:OnHideClick()
	ui_sound_mgr.PlayButtonClick()
	hall_ui:SetShowClubRoomsViewFalse()
	self:Hide()
end

function HallClubRoomsView:OnItemClick(item)
	ui_sound_mgr.PlayButtonClick()
	-- local title = LanguageMgr.GetWord(10049, GameUtil.GetGameName(item.info.gid))
	-- local content, contentTbl = ShareStrUtil.GetRoomShareStr(item.info.gid, item.info, true)
	-- if contentTbl then
	-- 	local subTitle = string.format("付费方式: %s   ", string.gsub(contentTbl[1], "、", ""))
	-- 	contentTbl[1] = ""
	-- 	local contentStr = table.concat(contentTbl)
	-- 	contentTbl = {title,subTitle,contentStr}
	-- end
	-- MessageBox.ShowYesNoBox(contentTbl,
	-- function()
	-- 	join_room_ctrl.JoinRoomByRno(item.info.rno)
	-- end)
	
	--TER0327-label
	local title = LanguageMgr.GetWord(10230)
	local content, contentTbl = ShareStrUtil.GetRoomShareStr(item.info.gid,item.info,true)
	if contentTbl then
		local subTitle = LanguageMgr.GetWord(10049, GameUtil.GetGameName(item.info.gid), string.gsub(contentTbl[1], "、", ""))
		contentTbl[1] = ""
		local contentStr = LanguageMgr.GetWord(10231)..table.concat(contentTbl)
		contentTbl = {title,subTitle,contentStr}
	end
	MessageBox.ShowYesNoBox(contentTbl,function()
		join_room_ctrl.JoinRoomByRno(item.info.rno)
	end)
end

function HallClubRoomsView:SetCallback(moveCallback, target)
	self.moveCallback = moveCallback
	self.target = target
end

function HallClubRoomsView:Show()
	self:SetActive(true)
	if self.isMoving then
		return
	end
	self.isShow = true
	self.hideBtnGo:SetActive(false)
	self:DoMove(showPosX)
end

function HallClubRoomsView:Hide(now)
	if self.isMoving and not now then
		return
	end
	self.isShow = false
	self.hideBtnGo:SetActive(false)
	self:DoMove(hidePosX, now)
end

function HallClubRoomsView:DoMove(posX, now)
	self.isMoving = true
	local time = 0.4
	if now then
		time = 0
	end
	self.transform:DOLocalMoveX(posX, time, false):SetEase(DG.Tweening.Ease.InOutQuad):OnComplete(
	function()
		self.isMoving = false
		self.hideBtnGo:SetActive(true)
		if self.moveCallback ~= nil then
			self.moveCallback(self.target)
		end
		if not self.isShow then
			self:SetActive(false)
		end
		if self.isShow then
			self.scrollviewRoot:ResetPosition()
			self.tableRoot:Reposition()
			self.tableRoot.gameObject:SetActive(false)
			self.tableRoot.gameObject:SetActive(true)
		end
	end)
end

return HallClubRoomsView
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               