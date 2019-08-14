local base = require "logic/framework/ui/uibase/ui_load_view_base"
local game_buyHourse_view = class("game_buyHourse_view", base)

function game_buyHourse_view:InitPrefabPath()
	self.prefabPath = data_center.GetResMJCommPath().."/ui/game/buyHouseView"
end

function game_buyHourse_view:InitView()
	self.buyHorseDataList = {}
	self.txtLabelList = {}
	self.btnGoList = {}
	self.title_sp = self:GetComponent("title", typeof(UISprite))
	self.grid = self:GetComponent("grid", typeof(UIGrid))

	for i = 1, 4 do
		local lbl = self:GetComponent("grid/btn" .. i .. "/Label", typeof(UILabel))
		self.txtLabelList[i] = lbl
		self.btnGoList[i] = self:GetGameObject("grid/btn" .. i)
		addClickCallbackSelf(self:GetGameObject("grid/btn" .. i), 
			function() 
				self:OnBtnClick(i)
			end
			 , self)
	end
end

function game_buyHourse_view:OnLoaded()
	mahjong_ui:SetChild(self.transform, nil, nil, Vector3(-5, - 113, 0))
end

function game_buyHourse_view:OnBtnClick(index)
	if self.buyHorseDataList[index] == nil then
		return
	end
	mahjong_play_sys.XiaPaoReq(self.buyHorseDataList[index])
	self:Hide()
end

function game_buyHourse_view:Refresh(list,cfg)
	if self.title_sp then
		self.title_sp.spriteName = cfg.xiapaoTitleSpriteName
		self.title_sp:MakePixelPerfect()
	end
	self.buyHorseDataList = list
	local count = #list
	for i = 1, 4 do
		if i <= count then
			self.btnGoList[i]:SetActive(true)
		else
			self.btnGoList[i]:SetActive(false)
		end
	end

	self.grid:Reposition()

	for i = 1, #list do
		if list[i] == 0 and cfg.isNotChi then
			self.txtLabelList[i].text = "不吃跑"
		else
			self.txtLabelList[i].text = "+" .. list[i]
		end
	end

end


return game_buyHourse_view