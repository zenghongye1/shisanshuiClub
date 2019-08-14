local base = require "logic/framework/ui/uibase/ui_view_base"
local BetBtnView = class("BetBtnView", base)
local yingsanzhang_data_manage = require("logic.poker_sys.yingsanzhang_sys.cmd_manage.yingsanzhang_data_manage")

local activeSpName = "button_09"
local inactiveSpName = "button_22"

function BetBtnView:InitView()
	self.btnSpList = {}
	for i = 1,4 do 
		local btnSp = self:GetComponent("Anchor/"..i,"UISprite")
		if btnSp then
			addClickCallbackSelf(btnSp.gameObject,self.BtnBeiShuOnClick,self)
			self.btnSpList[i] = btnSp
		end
	end
	
	self.bgBtn = child(self.transform,"bg")
	if self.bgBtn ~= nil then
		addClickCallbackSelf(self.bgBtn.gameObject,self.BtnBGOnClick,self)
	end	
end

function BetBtnView:BtnBeiShuOnClick(obj)
	local multArray = yingsanzhang_data_manage:GetInstance()["betMultTbl"]
	if multArray and #multArray > 0 then
		local beishu = multArray[tonumber(obj.gameObject.name)]
		pokerPlaySysHelper.GetCurPlaySys().RaiseReq(tonumber(beishu))
	end
	self:SetActive(false)
end

function BetBtnView:BtnBGOnClick()
	self:SetActive(false)
end

---设置下注按钮使能状态
function BetBtnView:SetBetBtnActive(curBetMult)
	local multArray = yingsanzhang_data_manage:GetInstance()["betMultTbl"]
	if multArray then
		for _,v in ipairs(self.btnSpList) do
			local betMult = multArray[tonumber(v.gameObject.name)] or 0
			if curBetMult >= betMult then
				v.spriteName = inactiveSpName
				componentGet(v.gameObject,"BoxCollider").enabled = false
			else
				v.spriteName = activeSpName
				componentGet(v.gameObject,"BoxCollider").enabled = true
			end
			subComponentGet(v.transform,"label","UILabel").text = tostring(betMult)
		end
	end
end

return BetBtnView