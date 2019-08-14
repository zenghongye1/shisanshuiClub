---切牌
local CutCardSys = class("CutCardSys")

function CutCardSys:ctor(callback)
	self.callback = callback
end

function CutCardSys:CutCardAction()
	local chatModel = model_manager:GetModel("ChatModel")
	local cutCardConfig = chatModel:GetCutCardConfig()
	chatModel:ReqSendPaidFace(cutCardConfig["face_id"],roomdata_center.rid, function() 
		self:SendChat()
		if self.callback then
			self.callback()
		end
	end)
end

function CutCardSys:SendChat()
	if GameUtil.CheckGameIdIsMahjong(roomdata_center.gid) then
	else
		pokerPlaySysHelper.GetCurPlaySys().ChatReq(6,nil,nil)
	end
end

return CutCardSys