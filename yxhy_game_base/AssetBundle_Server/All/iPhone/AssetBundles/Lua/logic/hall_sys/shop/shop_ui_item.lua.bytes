local base = require "logic/framework/ui/uibase/ui_view_base"
local shop_ui_item = class("shop_ui_item",base)

function shop_ui_item:InitView()
	self.vip_go = self:GetGameObject("vipinfo")
	self.vip_go:SetActive(false)
	self.sign_go = self:GetGameObject("sign")
	self.sign_sprite = self:GetComponent("sign/Sprite", "UISprite")
	self.sign_go:SetActive(false)
	self.pic_list = {}
	self.pic_sprite1 = self:GetComponent("Sprite1", "UISprite")
	table.insert(self.pic_list,self.pic_sprite1)
	self.pic_sprite2 = self:GetComponent("Sprite2", "UISprite")
	table.insert(self.pic_list,self.pic_sprite2)
	self.pic_sprite3 = self:GetComponent("Sprite3", "UISprite")
	table.insert(self.pic_list,self.pic_sprite3)
	self.number_label = self:GetComponent("number", "UILabel")
	self.btn_tr = child(self.transform,"buyBtn") 
	self.rmb_label = self:GetComponent("buyBtn/rmb", "UILabel")

	self.cardPos = {
		{{-7,27,15}},
		{{15,14,0},{-21,27,30}},
		{{19.6,5,0},{3,25,30},{-29,29,60}},
	}
end

function shop_ui_item:Update()
	
end

function shop_ui_item:SetHoySign()
	self.sign_sprite.spriteName = "shop_05"
	self.sign_go:SetActive(true)
end

function shop_ui_item:SetPopularSign()
	self.sign_sprite.spriteName = "shop_04"
	self.sign_go:SetActive(true)
end

function shop_ui_item:SetPic(index,count)
	local spriteName = "shop_13"
	if index == 1 then
		spriteName = "shop_11"
	elseif index == 2 then
		spriteName = "shop_12"
	end

	self.pic_sprite1.spriteName = spriteName
	self.pic_sprite2.spriteName = spriteName
	self.pic_sprite3.spriteName = spriteName
	for i=1,count do
		local value = self.cardPos[count][i]
		self.pic_list[i].transform.localPosition = Vector3(value[1],value[2],0)
		self.pic_list[i].transform.localEulerAngles = Vector3(0,0,value[3])
		self.pic_list[i].gameObject:SetActive(true)
	end
	for i=count+1,3 do
		self.pic_list[i].gameObject:SetActive(false)
	end
end

function shop_ui_item:SetPicNew(index)
	local spriteName = "shop_23"
	if index ==1 then
		spriteName = "shop_20"
	elseif index ==2 then
		spriteName = "shop_18"
	elseif index ==3 then
		spriteName = "shop_19"
	elseif index ==4 then
		spriteName = "shop_21"
	elseif index ==5 then
		spriteName = "shop_22"
	end
	self.pic_sprite1.spriteName = spriteName
	self.pic_sprite1:MakePixelPerfect()
	self.pic_sprite2.gameObject:SetActive(false)
	self.pic_sprite3.gameObject:SetActive(false)
end

function shop_ui_item:SetNumber(num)
	self.number_label.text = "x"..num
end

function shop_ui_item:SetRMB(rmb)
	self.rmb_label.text = math.ceil(rmb).."元"
end

return shop_ui_item