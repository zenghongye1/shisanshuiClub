---打赏荷官
local GratuitySys = class("GratuitySys")

function GratuitySys:ctor()
	self:Init()
end

function GratuitySys:Init()
	local nodeObj = GameObject.Find("sceneroot/TableAnchor/heguan/feixinPos")
	if nodeObj and not IsNil(nodeObj) then
		self.gratuityPos = Utils.WorldPosToScreenPos(nodeObj.transform.position)
	else
		self.gratuityPos = Vector3(0,0,0)
	end
end

function GratuitySys:GratuityAction()
	local chatModel = model_manager:GetModel("ChatModel")
	local gratuityConfig = chatModel:GetGratuityConfig()
	chatModel:ReqSendPaidFace(gratuityConfig["face_id"],roomdata_center.rid, function() 
		self:SendChat()
	end)
end

function GratuitySys:SendChat()
	if GameUtil.CheckGameIdIsMahjong(roomdata_center.gid) then
	else
		local content = json.encode(self.gratuityPos)
		pokerPlaySysHelper.GetCurPlaySys().ChatReq(5,content,nil)
	end
end

return GratuitySys