local base = require "logic/framework/ui/uibase/ui_view_base"
local vote_view = class("vote_view", base)

local MaxProgress = 240
local MinProgress = 14
local BeginColor = Color(11/255,218/255,17/255)
local MidColor = Color(215/255,129/255,11/255)
local EndColor = Color(215/255,12/255,12/255)
local Speed = 0.05

function vote_view:InitView()
	self.spList = {}
	for i = 1, 6 do
		self.spList[i] = self:GetComponent("item" .. i, typeof(UISprite))
		self.spList[i].gameObject:SetActive(false)
	end
	-- self.timeLbl = self:GetComponent("timeLbl","UILabel")
	self.progressBar = self:GetComponent("progressBar","UISprite")
	self.agreeNum = 0
	self.totalPlayerNum = 0
	
end

function vote_view:Show(playerNum,time)
	self.agreeNum = 0
	
	self.time = time or 100
	self.timeEnd = self.time
	self.timeMid = self.time / 4

	self.MaxProgress = MaxProgress/6*playerNum
	self.MinProgress = MinProgress

	self.speed = Speed * 6 / playerNum

	self.totalPlayerNum = playerNum
	self:ResetAll()
	self:SetActive(true)
	for i = 1, self.totalPlayerNum do
		self.spList[i].gameObject:SetActive(true)
	end
	
	local basePos = self.spList[self.totalPlayerNum].transform.localPosition
	self.progressBar.transform.localPosition = Vector3(basePos.x - 20,28,0)
	-- self.timeLbl.transform.localPosition = Vector3(basePos.x - 30,basePos.y,basePos.z)
	-- self.timeLbl.gameObject:SetActive(true)
	-- self.timeLbl.text = "("..tostring(math.floor(self.timeEnd)).."s)"
	self:StartTimer()
end

function vote_view:AddVote(value, viewSeat)
	if viewSeat > #self.spList then
		return
	end
	local spName = "room_14"
	if value then
		spName = "room_15"
	end
	self.spList[viewSeat].spriteName = spName
	self.agreeNum = self.agreeNum + 1
	if self.agreeNum >= self.totalPlayerNum then
		-- self.timeLbl.gameObject:SetActive(false)
		self:StopTimer()
	end
end

function vote_view:StartTimer()
	if self.timer == nil then	
		self.timer = Timer.New(slot(self.OnTimer_Proc,self),self.speed,self.timeEnd/self.speed)
		self.timer:Start()
	end
end

function vote_view:OnTimer_Proc()
	-- self.timeLbl.text = "("..tostring(math.floor(self.timeEnd)).."s)"
	self.timeEnd = self.timeEnd - self.speed
	self.progressBar.width = (self.MaxProgress - self.MinProgress)/self.time * self.timeEnd + self.MinProgress
	local color
	if self.timeEnd > self.timeMid then
		color = Color(
						((215-11)/(self.time-self.timeMid)*(self.time-self.timeEnd)+11)/255,
						(218 - (218-129)/(self.time-self.timeMid)*(self.time-self.timeEnd))/255,
						17/255
					)
	else
		color = Color(
						215/255,
						(129 - (129-12)/(self.timeMid)*(self.timeMid-self.timeEnd))/255,
						12/255
					)
	end
	self.progressBar.color = color
	if self.timeEnd <= 0 then
		-- self.timeLbl.gameObject:SetActive(false)
		self:StopTimer()
	end
end

function vote_view:StopTimer()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
end

function vote_view:ResetAll()
	for i = 1, #self.spList do
		self.spList[i].spriteName = "room_13"
		self.spList[i].gameObject:SetActive(false)
	end
	self.progressBar.width = self.MaxProgress
	self.progressBar.color = BeginColor
end


function vote_view:Hide()
	self.agreeNum = 0
	self:SetActive(false)
	self:StopTimer()
end



return vote_view

