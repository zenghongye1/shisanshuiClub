local game_setting = class("game_setting")

function game_setting:ctor(Ui)	
	self.mahjongTableIcon = {
	[1] = "Set_16",
	[2] = "Set_17",
	[3] = "Set_18",
	}
	self.pokerTableIcon = {
	[1] = "Set_05",
	[2] = "Set_06",
	[3] = "Set_07",
	}
	self.game_setting = Ui
	self:InitView()
	self:UpdateView()
end

--[[local tableClothNameList = 
{
  "暗香疏影" , "高山流水", "幽静竹林"
}--]]

function game_setting:InitView()
	self.currentGid = player_data.GetGameId()
	self.tran_DeskCloth = child(self.game_setting,"DeskCloth")
	self.grid_table = child(self.game_setting,"DeskCloth/ScrollView/GridTable")	--麻将更换桌布待需求
    for i=1,self.grid_table.transform.childCount do
        local btn_t = self.grid_table.transform:GetChild(i-1)
        if btn_t ~= nil then
            addClickCallbackSelf(btn_t.gameObject,self.ChangeDesk,self)
        end
		local bg = componentGet(child(btn_t.gameObject.transform,"bg"),"UISprite")
		if GameUtil.CheckGameIdIsMahjong(self.currentGid) then
			bg.spriteName = self.mahjongTableIcon[i]
		else
			bg.spriteName = self.pokerTableIcon[i]
		end
		bg:MakePixelPerfect()
    end
	
	self.tran_CardStyle = child(self.game_setting,"CardStyle")
	self.grid_card = child(self.game_setting,"CardStyle/ScrollView/GridCard")	--麻将更换桌布待需求
    for i=1,self.grid_card.transform.childCount do
        local btn_t = self.grid_card.transform:GetChild(i-1)
        if btn_t ~= nil then
            addClickCallbackSelf(btn_t.gameObject,self.ChangeCard,self)
        end
    end
	
	self.lbl_tip = child(self.game_setting,"LblTip")
	self.lbl_tip.gameObject:SetActive(false)
end

function game_setting:UpdateView()
	self:UpdateTableCloth()
	self:UpdateCardStyle()
	
	self.tran_DeskCloth.gameObject:SetActive(true)
	self.tran_CardStyle.gameObject:SetActive(false)		--未设计先屏蔽

end

function game_setting:ChangeDesk(obj2) 
    local s = string.split(obj2.name,"_")
	if GameUtil.CheckGameIdIsMahjong(self.currentGid) then
		hall_data.SetPlayerPrefs("desk",s[2])	--mahjong
	else
		 PlayerPrefs.SetString("poker_desk", s[2])
	end
    Notifier.dispatchCmd(cmdName.MSG_CHANGE_DESK) 
    PlayerPrefs.Save()
end

function game_setting:ChangeCard(obj2) 
	logError(tostring(obj2.name))
	--[[local s = string.split(obj2.name,"_")
    hall_data.SetPlayerPrefs("desk",s[2])	--mahjong
    Notifier.dispatchCmd(cmdName.MSG_CHANGE_DESK) 
    PlayerPrefs.Save()--]]
end

function game_setting:UpdateTableCloth()
	local index = 1
	if GameUtil.CheckGameIdIsMahjong(self.currentGid) then
		index = tonumber(hall_data.GetPlayerPrefs("desk"))
	else
		if  PlayerPrefs.HasKey("poker_desk") then
			index = tonumber(hall_data.GetPlayerPrefs("poker_desk"))
		end
	end
	if tonumber(index) > 0 then
		local select_item = child(self.grid_table,"btn_"..index)
		componentGet(select_item.gameObject,"UIToggle").value = true
	end
end

function game_setting:UpdateCardStyle()
   --[[ local index = tonumber(hall_data.GetPlayerPrefs("desk"))
	if tonumber(index) > 0 then
		local select_item = child(self.grid_table,"btn_"..index)
		componentGet(select_item.gameObject,"UIToggle").value = true
	end--]]
end

return game_setting