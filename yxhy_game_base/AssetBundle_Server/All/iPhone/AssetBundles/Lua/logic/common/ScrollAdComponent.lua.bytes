local base = require "logic/framework/ui/uibase/ui_view_base"
local ScrollAdComponent = class("ScrollAdComponent", base)

local timeInterval = 5		--5S间隔
local isMove = false 	--动画播放状态
local playState = {
	[1] = "club_68",	--未播放
	[2] = "club_69",	--播放中
}

--[[--
 * @Description: 	ScrollAdComponent-ScrollView-Container-Texture
 * _go				ScrollAdComponent
 * _callback		单个texItem点击回调
 * _scrollSizeX		ScrollView的sizeX
 * _texTbl			存储展示tex的表
 * _isAuto			自动轮播
 * _moveLeft		轮播方向  false:向右,true:向左
 ]]

function ScrollAdComponent:ctor(_go,_callback,_scrollSizeX,_texTbl,_isAuto,_moveLeft)
	base.ctor(self, _go)
	self._callback = _callback
	self.containerWidth = (_scrollSizeX + 10)
	self.itemImgTbl = _texTbl
	self.itemMaxCount = table.getn(_texTbl)
	self.isAuto = _isAuto
	self.moveDir = _moveLeft and 1 or -1
	
	self.palyStateList = {}
	self:OnInit()
end

function ScrollAdComponent:OnInit()
	if not self.svObj then
		self.svObj = self:GetGameObject("ScrollView")
	end
	
	if not self.svContainer then
		self.svContainer = child(self.svObj.transform, "Container")
	end
	
	if not self.imgItem then
		self.imgItem = child(self.svObj.transform, "Container/Texture")
		self.itemBasePos = self.imgItem.transform.localPosition
		self.imgItem.gameObject:SetActive(false)
	end

	if self.imgItem and self.itemImgTbl and not isEmpty(self.itemImgTbl) then
		self.texItemList = {}
		for i=1,self.itemMaxCount do
			local item = child(self.svContainer,tostring(i))
			if not item then
				local newImgItem = GameObject.Instantiate(self.imgItem)
				newImgItem.name = tostring(i)
				newImgItem.transform.parent = self.svContainer
				newImgItem.transform.localScale = Vector3.one
				newImgItem.transform.localPosition = Vector3((i-1)*self.containerWidth,0,0)
				componentGet(newImgItem.gameObject,"UITexture").mainTexture = self.itemImgTbl[i]
				addClickCallbackSelf(newImgItem.gameObject,self.askCallback,self)
				self:registerDragEvent(newImgItem)		--注册滑动事件
				newImgItem.gameObject:SetActive(true)
				self.texItemList[i] = newImgItem
			else
				item.transform.localPosition = Vector3((i-1)*self.containerWidth,0,0)
				item.transform.localScale = Vector3.one
				componentGet(item.gameObject,"UITexture").mainTexture = self.itemImgTbl[i]
				addClickCallbackSelf(item.gameObject,self.askCallback,self)
				self:registerDragEvent(item)		--注册滑动事件
				self.texItemList[i] = item
			end
		end
	end
		
	if not self.playStateGrid or isEmpty(self.palyStateList) then
		self.playStateGrid = self:GetComponent("playStateGrid","UIGrid")
		if self.playStateGrid then
			for i=1,self.itemMaxCount do
				local childGo = child(self.playStateGrid.transform,tostring(i)).gameObject
				childGo.name = tostring(i)
				componentGet(childGo,"UISprite").spriteName = playState[1]
				childGo:SetActive(true)
				self.palyStateList[i] = childGo
			end
		end
	end
	
	if self.itemMaxCount == 1 then				--仅一张图直接显示该图
		self.palyStateList[1]:SetActive(false)
		return
	end
	
	self:SetPlayState(1)	---默认先展示第一张图
	---开启自动轮播
	if self.isAuto then
		self.updateTimer = Timer.New(function()
				self:playPageAnimation(true)
			end,timeInterval,-1)
		self.updateTimer:Start()
	end
end

function ScrollAdComponent:Clear()
	if self.updateTimer then
		self.updateTimer:Stop()
		self.updateTimer = nil
	end

	if self.svObj then
		if self.svContainer then
			self.svContainer.transform:DOKill(false)
			self.svContainer.transform.localPosition = Vector3.zero
		end
		if self.imgItem then
			self.imgItem.gameObject.transform.localPosition = Vector3.zero
		end
	end
	self.texItemList = nil
end

--刷新界面
function ScrollAdComponent:playPageAnimation(_isTimer)
	if not _isTimer then
		return
	end
	
	local moveDir = self.moveDir 
	local containerPos = self.svContainer.transform.localPosition
	local curItemIndex = math.floor(-1 * (containerPos.x)/self.containerWidth)
	local tempIndex = self:GetTempItemIndex(curItemIndex)
	for i,v in ipairs({-1,0,1}) do
		local tempItemIndex = curItemIndex + v
		local itemIndex = ((tempIndex + v)==0 and self.itemMaxCount) or ((tempIndex + v)==(self.itemMaxCount+1) and 1) or (tempIndex + v)
		--logStr = logStr .. itemIndex	---测试log
		local curItem = child(self.svContainer,tostring(itemIndex))
		curItem.transform.localPosition = Vector3(self.itemBasePos.x + self.containerWidth * tempItemIndex,self.itemBasePos.y,self.itemBasePos.z)
	end
	
	local itemIndex = ((tempIndex - moveDir)==0 and self.itemMaxCount) or ((tempIndex - moveDir)==(self.itemMaxCount+1) and 1) or (tempIndex - moveDir)
	
	local newPos = Vector3((-1*curItemIndex + moveDir)*self.containerWidth, containerPos.y, containerPos.z)
	isMove = true
	local animTweener = self.svContainer.transform:DOLocalMove(newPos,0.5, true)
	animTweener:SetEase(DG.Tweening.Ease.Linear):OnComplete(function()
		self:SetPlayState(itemIndex)
		isMove = false
	end)
	animTweener:OnKill(function() end)
end

---注册滑动事件
function ScrollAdComponent:registerDragEvent(obj)
    local dragDir = 1
	
    addDragCallbackSelf(obj.gameObject, function(go,delta)
		if self.itemMaxCount <= 1 then
			return		---一张图不可拖动
		end
		dragDir = delta.x <0 and -1 or 1 
				
		local containerPos = self.svContainer.transform.localPosition
		local iSign = containerPos.x <0 and -1 or 1
		self.svContainer.transform.localPosition = Vector3(containerPos.x +delta.x, containerPos.y, containerPos.z)
		local curItemIndex = math.floor(-1 * (containerPos.x)/self.containerWidth)
		local tempIndex = self:GetTempItemIndex(curItemIndex)
		for i,v in ipairs({-1,0,1}) do
			local tempItemIndex = curItemIndex + v
			local itemIndex = ((tempIndex + v)==0 and self.itemMaxCount) or ((tempIndex + v)==(self.itemMaxCount+1) and 1) or (tempIndex + v)
			--logStr = logStr .. itemIndex	---测试log
			local curItem = child(self.svContainer,tostring(itemIndex))
			curItem.transform.localPosition = Vector3(self.itemBasePos.x + self.containerWidth * tempItemIndex,self.itemBasePos.y,self.itemBasePos.z)
		end
    end)
		---滑动开始关闭自动播放定时器
    addDragStartCallbackSelf(obj.gameObject,function (go)
		if self.updateTimer then
			self.updateTimer:Stop()
		end
    end)
		---相对滑动svContainer
    addDragEndCallbackSelf(obj.gameObject,function (go)
		local containerPos = self.svContainer.transform.localPosition
		local curItemIndex
		if dragDir == -1 then
			curItemIndex = math.floor((containerPos.x + self.containerWidth/2) / self.containerWidth)
		elseif dragDir == 1 then
			curItemIndex = math.floor((containerPos.x + self.containerWidth/2) / self.containerWidth)
		end
		
		local itemIndex = self:GetTempItemIndex(math.floor((-1*(containerPos.x) + self.containerWidth/2)/self.containerWidth))
		local newPos = Vector3(curItemIndex * self.containerWidth, containerPos.y, containerPos.z)
		isMove = true
		local animTweener = self.svContainer.transform:DOLocalMove(newPos,0.5, true)
		animTweener:SetEase(DG.Tweening.Ease.Linear):OnComplete(function()
			self:SetPlayState(itemIndex)
			isMove = false
			self.updateTimer:Reset(function()
				self:playPageAnimation(true)
			end,timeInterval,-1)
			self.updateTimer:Start()
		end)
		animTweener:OnKill(function() end)
    end)
end

function ScrollAdComponent:askCallback(obj)
	if self._callback then
		self._callback(obj.name)
	end
end

function ScrollAdComponent:GetTempItemIndex(curRealItemIndex)
	local index = (curRealItemIndex + 1) % self.itemMaxCount
	if index == 0 then
		index = self.itemMaxCount
	end
	return index
end

function ScrollAdComponent:SetPlayState(itemIndex)
	if isEmpty(self.palyStateList) then
		return
	end
	local childCount = self.playStateGrid.transform.childCount
	for i=0,childCount-1 do
		local childGo = self.playStateGrid.transform:GetChild(i).gameObject
		if childGo.name == tostring(itemIndex) then
			componentGet(childGo,"UISprite").spriteName = playState[2]
		else
			componentGet(childGo,"UISprite").spriteName = playState[1]
		end
	end
end

return ScrollAdComponent
