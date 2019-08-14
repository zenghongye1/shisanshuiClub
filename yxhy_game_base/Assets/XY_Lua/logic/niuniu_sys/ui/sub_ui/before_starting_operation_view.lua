local before_starting_operation_view = class("before_starting_operation_view")

function before_starting_operation_view:ctor(gameObject,controlObj)
	self.gameObject = gameObject
	self.transform = self.gameObject.transform
	self.controlObj = controlObj
	self.timeleftlbl = nil
	self.gridOpenCard = nil
	self.btn_Cuopai = nil
	self.btn_Opencard = nil
	self.is_RubCard = nil --是否搓牌
	self:InitView()
end

function before_starting_operation_view:InitView()
	self.timeleftlbl = componentGet(child(self.transform,"timeleftlbl"), "UILabel")
	self.gridOpenCard = componentGet(child(self.transform,"GridOpenCard"), "UIGrid")

	self.btn_Cuopai = child(self.transform,"GridOpenCard/btn_Cuopai")
	if self.btn_Cuopai ~= nil then
		addClickCallbackSelf(self.btn_Cuopai.gameObject,self.controlObj.OnBtnCuoPaiOnClick,self.controlObj)
		self.btn_Cuopai.gameObject:SetActive(false)
	end  
	
	self.btn_Opencard = child(self.transform,"GridOpenCard/btn_Opencard")
	if self.btn_Opencard ~= nil then
		addClickCallbackSelf(self.btn_Opencard.gameObject,self.controlObj.onbtn_openCardClick,self.controlObj)
		self.btn_Opencard.gameObject:SetActive(false)
	end
end

function  before_starting_operation_view:IsShowOpenCardBtn(IsShow,CardType)
	if self.btn_Opencard == nil then return end
	self.btn_Opencard.gameObject:SetActive(IsShow)
	if CardType ~= nil then
--		self.widgetTbl.btn_openCardLabel.text = niuniu_rule_define.PT_BULL_Text[CardType]
	end
	self.gridOpenCard:Reposition()
end

function  before_starting_operation_view:IsShowCuoPaiBtn(IsShow)
	if self.btn_Cuopai == nil then return end
--	local cuopaiSetting = require("logic.niuniu_sys.cmd_manage.niuniu_data_manage"):GetInstance().roomInfo.GameSetting.rubCard
	if not self.is_RubCard or self.is_RubCard == 0 then
		self.btn_Cuopai.gameObject:SetActive(false)
		return
	end
	self.btn_Cuopai.gameObject:SetActive(IsShow)
	
	self.gridOpenCard:Reposition()
end

return before_starting_operation_view