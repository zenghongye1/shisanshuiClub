local ClubControl = class("ClubControl")
local Time = Time
local REFRESH_TIME = 120
local REQUEST_ROOM_INTERVAL = 2

function ClubControl:Init()
	self.model = model_manager:GetModel("ClubModel")
	self.isStart = false
	-- self.refreshTime = REFRESH_TIME
	self.requsetRoomListInterval = 0
	self.needRequsetRoomList = true
	self:RegistEvent()
end

function ClubControl:RegistEvent()
	Notifier.regist(GameEvent.LoginSuccess, self.OnLoginSuccess, self)
	Notifier.regist(GameEvent.OnChangeScene, self.OnChangeScene, self)
	Notifier.regist(GameEvent.OnHallSocketReconnect, self.OnHallSocketReconnect, self)
end

function ClubControl:OnHallSocketReconnect()
	self.model:ResGetUserAllClubList(true)
	--self.model:ReqGetRoomList()
	self.model:ReqGetAllRoomList()
end

function ClubControl:OnLoginSuccess()
	self.isStart = true
	-- self.refreshTime = REFRESH_TIME
end

function ClubControl:CheckCanRequsetRoomList()
	if self.requsetRoomListInterval > 0 or game_scene.getCurSceneType() ~= scene_type.HALL  then
		self.needRequsetRoomList = true
		return false
	end
	-- self.needRequsetRoomList = false
	self.needRequsetRoomList = false
	self.requsetRoomListInterval = REQUEST_ROOM_INTERVAL
	return true
end



function ClubControl:OnChangeScene()
	if game_scene.getCurSceneType() == scene_type.LOGIN then
		self.isStart = false
	elseif game_scene.getCurSceneType() == scene_type.HALL then
		--self.model:ReqGetRoomList()
		self.model:ReqGetAllRoomList()
	end
end

function ClubControl:AutoRefresh()
	self.model:ResGetUserAllClubList(true)
	if self.model.currentClubInfo ~= nil then
		self.model:ReqGetClubUser(self.model.currentClubInfo.cid)
		if self.model:CheckCanSeeApplyList() then
			self.model:ReqGetClubApplyList(self.model.currentClubInfo.cid)
		end
	end
end

function ClubControl:Update()
	if not self.isStart then
		return
	end
	-- self.refreshTime = self.refreshTime - Time.deltaTime
	-- if self.refreshTime <= 0 then
	-- 	self.refreshTime = REFRESH_TIME
	-- 	self:AutoRefresh()
	-- end
	if self.requsetRoomListInterval > 0 then
		self.requsetRoomListInterval = self.requsetRoomListInterval - Time.deltaTime
		if self.requsetRoomListInterval <= 0 and self.needRequsetRoomList then
			self.needRequsetRoomList = false
			--self.model:ReqGetRoomList()
			self.model:ReqGetAllRoomList()
		end
	end
end

function ClubControl:Clear()
end

return ClubControl