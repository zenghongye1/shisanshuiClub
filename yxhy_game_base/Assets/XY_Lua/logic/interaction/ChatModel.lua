local ChatModel = class("ChatModel")
local HttpCmdName = HttpCmdName
local HttpProxy = HttpProxy
local GameEvent = GameEvent


function ChatModel:Init()
	self.chatTextTab = {}
	self.chatImgTab = {}
	self.facePriceMap = {}
	self.gratuityConfig = {}
	self.cutCardConfig = {}
	self:RegistEvent()
end

function ChatModel:RegistEvent()
	Notifier.regist(HttpCmdName.GetPaidFace, self.OnResGetPaidFace, self)
end

function ChatModel:ReqGetPaidFace()
	HttpProxy.SendUserRequest(HttpCmdName.GetPaidFace, {})
end


function ChatModel:ReqSendPaidFace(faceId, rid, callback)
	local param = {}
	param.face_id = faceId
	param.rid = rid
	HttpProxy.SendUserRequest(HttpCmdName.SendPaidFace, param, callback)
end


local actionType = {
	interact = 0,	
	cutCards = 1,	--切牌
	gratuity = 2,	--打赏
}
function ChatModel:OnResGetPaidFace(msg)
	if msg.data == nil then
		return
	end
	self.facePriceMap = {}
	for i = 1, #msg.data do
		if msg.data[i].action_type == actionType.interact then
			self.facePriceMap[msg.data[i].face_id] = msg.data[i]
		elseif msg.data[i].action_type == actionType.cutCards then
			self.cutCardConfig = msg.data[i]
		elseif msg.data[i].action_type == actionType.gratuity then
			self.gratuityConfig = msg.data[i]
		else
			self.facePriceMap[msg.data[i].face_id] = msg.data[i]
		end
	end
	Notifier.dispatchCmd(GameEvent.OnExpressionPriceUpdate)
end

function ChatModel:GetExpressionPrice(faceId)
	if self.facePriceMap[faceId] ~= nil then
		return self.facePriceMap[faceId]
	end
	return nil
end

---获取打赏配置
function ChatModel:GetGratuityConfig()
	return self.gratuityConfig
end

---获取切牌配置
function ChatModel:GetCutCardConfig()
	return self.cutCardConfig
end

function ChatModel:DealChat(viewSeat,contentType,content,givewho)
	local para = {}
		para["viewSeat"]=viewSeat
		para["contentType"]=contentType
		para["content"]=content
		para["givewho"]=givewho

	if contentType == 1 then
		--文字聊天
		Notifier.dispatchCmd(cmdName.MSG_CHAT_TEXT, para)
    if viewSeat == 1 then
		--  self:HideChatPanel()
		UI_Manager:Instance():CloseUiForms("chat_ui")
    end
	elseif contentType ==2 then
		--表情聊天
		Notifier.dispatchCmd(cmdName.MSG_CHAT_IMAGA, para)
    if viewSeat ==  1 then
		--  self:HideChatPanel()
		UI_Manager:Instance():CloseUiForms("chat_ui")
    end
	elseif contentType == 3 then
		--语音聊天
    Trace("------recive voice msg---------------")  
    --if viewSeat~=1 then
      local voiceInfoTbl = {}
      voiceInfoTbl.fileID = content
      voiceInfoTbl.viewSeat = viewSeat
      voiceInfoTbl.flag = 2
      gvoice_sys.AddDownloadFile(voiceInfoTbl)
    --end
	elseif contentType == 4 then
		--玩家互动
		Notifier.dispatchCmd(cmdName.MSG_CHAT_INTERACTIN, para)
	elseif contentType == 5 then
		--打赏荷官
		Notifier.dispatchCmd(cmd_poker.gratuity, para)
	end
end

function ChatModel:GetChatIndexByContent(content)
  local tIndex = nil
  for k, value in pairs(self.chatTextTab) do
    if value == content and k <=defaultTxtCount then
      tIndex = k
      break
    end
  end
  return tIndex
end


return ChatModel