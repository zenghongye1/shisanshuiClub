--[[--
 * @Description: 扣牌选择界面
 * @Author:      ShushingWong
 * @FileName:    game_kou_view.lua
 * @DateTime:    2018-04-08 19:55:45
 ]]
local base = require "logic/framework/ui/uibase/ui_load_view_base"
local game_kou_view = class("game_kou_view", base)

function game_kou_view:InitPrefabPath()
	self.prefabPath = data_center.GetResMJCommPath().."/ui/game/kouView"
end

function game_kou_view:InitView()
	self.select = self:GetGameObject("select")
	self.guo = self:GetGameObject("guo")

	addClickCallbackSelf(self.select,self.OnSelectBtnClick,self)
	addClickCallbackSelf(self.guo,self.OnGuoBtnClick,self)
end

function game_kou_view:OnSelectBtnClick()
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Liang)
	local combine = tbl.combine
	--[[--
	 * @Description: combine = {
	 * 		[combine] = {1,1,1}
	 * 		[tingInfo] = cardTingGroup
	 * }  
	 ]]
	local kouCardList = mahjong_ui:GetKouCardList()
	local tingInfo = tbl.tingInfo
	if combine and kouCardList and #kouCardList > 0 then
		table.sort(kouCardList)
		local isLegal = false
		for _,v in ipairs(combine) do
			if IntArrayCheckSame(v.combine,kouCardList) then
				isLegal = true
				if v.tingInfo then
					tingInfo = v.tingInfo
				end
				break
			end
		end
		if not isLegal then
			UIManager:FastTip("已选扣牌改变了听牌牌型，请选择其它牌")
			return
		end
	end
	roomdata_center.kouCardList = kouCardList
	
	local cacheTbl = {tingType = tbl.tingType,tingInfo = tingInfo}
	for _,v in ipairs(kouCardList) do
		for i=#cacheTbl.tingInfo,1,-1 do
			local stTingCards = cacheTbl.tingInfo[i]
			if stTingCards.give == v then
				table.remove(cacheTbl.tingInfo,i)
			end
		end
	end
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, cacheTbl)

	mahjong_ui:HideAndKou()
end

function game_kou_view:OnGuoBtnClick()
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD)
	mahjong_ui:HideAndKou()
end

function game_kou_view:OnLoaded()
	mahjong_ui:SetChild(self.transform, nil, nil, Vector3(0, 0, 0))
end

function game_kou_view:Refresh()
	self:SetValue(true)
end

function game_kou_view:SetValue()

end

return game_kou_view