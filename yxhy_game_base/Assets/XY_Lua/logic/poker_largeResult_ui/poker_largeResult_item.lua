local base = require("logic.poker_sys.other.poker_result_item")
local poker_largeResult_item = class("poker_largeResult_item",base)

function poker_largeResult_item:InitView()
	base.InitView(self)
	self.bigLoserObj = self:GetGameObject("bigLoser")
	self.winInfoGrid = self:GetComponent("scoreScrollView/grid","UIGrid")
end

function poker_largeResult_item:SetItemInfo(userData)
	self.nameLbl.text = userData["name"]
	self.idLbl.text = userData["uid"]
	HeadImageHelper.SetImage(self.texHead,2,userData["headurl"])
end

function poker_largeResult_item:SetWinInfo(List)
	for i,v in ipairs(List) do
		local tran_item = child(self.winInfoGrid.transform,"item"..i)
		tran_item.gameObject:SetActive(true)
	   	componentGet(child(tran_item,"type"),"UILabel").text = tostring(v[1])
		componentGet(child(tran_item,"count"),"UILabel").text = tostring(v[2])
	end
	self.winInfoGrid:Reposition()
end

function poker_largeResult_item:SetBigLose(state)
	self.bigLoserObj.gameObject:SetActive(state)
end

return poker_largeResult_item