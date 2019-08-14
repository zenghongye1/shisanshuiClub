--[[--
 * @Description: 发牌下来时判断特殊牌型
 * @Author:      zhy
 * @FileName:    prepare_special.lua
 * @DateTime:    2017-07-05
 ]]
 
require "logic/shisangshui_sys/place_card/place_card"
--require "logic/shisangshui_sys/shisangshui_play_sys"
require "logic/shisangshui_sys/lib_sp_card_logic"
require "logic/shisangshui_sys/card_define"

 
common_card = ui_base.New()
local this = common_card 
local transform;  

--最大等待时间
local timeSecond = 3
--所有牌
local my_cards = {}

local cardTranTbl = {}
--特殊牌型
local card_type

local card_type_bg

local bg_type_altasName = {
    [1] = "wulong",                          --散牌(乌龙)    
     [2] = "duizi",                          --一对
     [3] = "erdui",                          --两对
     [4] = "santiao",                             --三条
     [5] = "shunzi",                        --顺子
     [6] = "tonghua",                             --同花
     [7] = "hulu",                        --葫芦
     [8] = "tiezhi",                              --铁支(炸弹)
     [9] = "tonghuashun",                    --同花顺
     [10] = "wutong",                           -- 五同
	[11] = "chongsan",						--冲三
	[12] = "zhongdunhulu",					--中墩葫芦
	[13] = "duiguichongqian"				--对鬼冲三
}

function this.Awake()
   this.initinfor()
  	--this.registerevent() 
end

function this.Show(cards, nSpecialType, pos, localSecond,index)
	Trace("显示普通牌型"..tostring(nSpecialType))
	
	if tonumber(nSpecialType) == 4 then 
		if index == 1 then
			-- 在首墩就叫冲
			nSpecialType = 11
		end
	elseif tonumber(nSpecialType) == 7 then
		if index == 2 then
			nSpecialType = 12
		end
	end	
	ui_sound_mgr.PlaySoundClip("game_80011/sound/cardtpye_girl/normaltype/".. NormalTypeMusicConfig[nSpecialType])
	
	
	
	
	if this.gameObject==nil then
		require ("logic/shisangshui_sys/common_card/common_card")
		this.gameObject=newNormalUI("game_80011/ui/common_card")
	else
		for i = #cardTranTbl, 1, -1 do
			if cardTranTbl[i] ~= nil then
				GameObject.Destroy(cardTranTbl[i].gameObject)
			end
		end
		cardTranTbl = {}
		this.gameObject:SetActive(true)
	end
	this.transform.localPosition = pos
	if localSecond ~= nil then
		timeSecond =0.65
	else
		timeSecond =0.65
	end
	this.transform.localScale = Vector3.New(0.8, 0.8, 0.8)
--	this.transform:DOScale(Vector3.New(1, 1, 1), 0.2)
	
	--OutBounce
	this.transform:DOScale(Vector3(0.9, 0.9, 0.9), 0.2):SetEase(DG.Tweening.Ease.Linear):OnComplete(function ()
			this.transform:DOScale(Vector3(0.8,0.8,1), 0.2):SetEase(DG.Tweening.Ease.Linear)
			end)
	
	
	Trace("---------cards------"..tostring(cards).."  dun: "..tostring(dun))
	my_cards = cards


	
	this.LoadAllCard(cards, nSpecialType)
  	--this.addlistener()
end

function this.Hide()
	--[[
	for i = 1, #cardTranTbl do
		if cardTranTbl[i] ~= nil then
			GameObject.Destroy(cardTranTbl[i].gameObject)
		end
	end
	--]]
	if this.gameObject == nil then
		return
	else
		GameObject.Destroy(this.gameObject)
		this.gameObject = nil
	end
end

--[[--
 * @Description: 逻辑入口  
 ]]
function this.Start()
	this.registerevent()
end

--[[--
 * @Description: 销毁  
 ]]
function this.OnDestroy()
end

function this.initinfor()
	card_type_bg = componentGet(child(this.transform, "bg"), "UISprite")
end

--注册事件
function this.registerevent()
end

function this.LoadAllCard(cards, nSpecialType)
---[[
	
	local min = 1
	local max = 5
	if #cards == 3 then
		min = 2
		max = 4
	end
	for i = 1, #cards do
		local cardParent = child(this.transform, "cardGrid/"..tostring(min))
		min = min + 1
		if cardParent == nil then
			print("cardGrid == nil")
			return
		end
		local cardObj = newNormalUI("game_80011/scene/card/"..tostring(cards[i]), cardParent)
		cardTranTbl[i] = cardObj
		cardObj.transform.localRotation = Quaternion.identity
		componentGet(child(cardTranTbl[i].transform, "bg"),"UISprite").depth = i * 2 + 3
		componentGet(child(cardTranTbl[i].transform, "num"),"UISprite").depth = i * 2 + 5
		componentGet(child(cardTranTbl[i].transform, "color1"),"UISprite").depth = i * 2 + 5
		componentGet(child(cardTranTbl[i].transform, "color2"),"UISprite").depth = i * 2 + 5
		if room_data.GetSssRoomDataInfo().isChip == true and cards[i] == 40 then
			child(cardTranTbl[i].transform,"ma").gameObject:SetActive(true)
			componentGet(child(cardTranTbl[i].transform,"ma"),"UISprite").depth = i * 2 + 4
		end
	end
	
	

	card_type_bg.spriteName = bg_type_altasName[nSpecialType]
	
	--]]

	--obj.transform.localPosition = Vector3.New(delte.x, delte.y, obj.transform.localPosition.z)
end

function this.Update()
	if timeSecond <= 0 then
		this.gameObject:SetActive(false)
		return
	end
	timeDelt = Time.deltaTime
	timeSecond =  timeSecond - timeDelt
	if math.floor(timeSecond) < 0 then
		timeSecond = 0
	end
end


