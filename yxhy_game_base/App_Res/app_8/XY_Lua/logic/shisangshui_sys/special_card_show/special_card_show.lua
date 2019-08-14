--[[--
 * @Description: 发牌下来时判断特殊牌型
 * @Author:      zhy
 * @FileName:    prepare_special.lua
 * @DateTime:    2017-07-05
 ]]
 
require "logic/shisangshui_sys/place_card/place_card"
--require "logic/shisangshui_sys/shisangshui_play_sys"
require "logic/shisangshui_sys/lib_sp_card_logic"

 
special_card_show = ui_base.New()
local this = special_card_show 
local transform;  

--最大等待时间
local timeSecond = 3
--所有牌
local my_cards = {}

local cardTranTbl = {}
--特殊牌型
local card_type

local animalPar

local SpecialAnimalName = {
	[GStars_Special_Type.PT_SP_NIL] = "散牌",
    [GStars_Special_Type.PT_SP_THREE_FLUSH] = "santonghua",              --三同花
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT] = "shanshunzi",           --三顺子
    [GStars_Special_Type.PT_SP_SIX_PAIRS] = "liuduiban",                --六对半   6对+散牌
    [GStars_Special_Type.PT_SP_FIVE_PAIR_AND_THREE] = "wuduisantiao",      --五队冲三 5对+3条
    [GStars_Special_Type.PT_SP_SAME_SUIT] = "couyise",             --凑一色
    [GStars_Special_Type.PT_SP_ALL_SMALL] = "quanxiao",             --全小
    [GStars_Special_Type.PT_SP_ALL_BIG] = "quanda",                 --全大
    [GStars_Special_Type.PT_SP_SIX] = "liuliudashun",                     --六六大顺  6同
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT_FLUSH] = "santonghuashun",    --三同花顺
    [GStars_Special_Type.PT_SP_ALL_KING] = "shierhuangzu",                --十二皇族
    [GStars_Special_Type.PT_SP_FIVE_AND_THREE_KING] = "sanhuangwudi",     --三皇五帝 2个5同+3条
    [GStars_Special_Type.PT_SP_THREE_BOMB] = "sanfentianxia",              --三炸弹   3个铁枝
    [GStars_Special_Type.PT_SP_FOUR_THREE] = "ditaosantiao" ,             --四套三条  4个3条
    [GStars_Special_Type.PT_SP_STRAIGHT] = "yitiaolong",               --一条龙
    [GStars_Special_Type.PT_SP_STRAIGHT_FLUSH] = "zhizunqinglong",			--至尊清龙
	[GStars_Special_Type.PT_SP_SEVEN] = "qikaidesheng",			--旗开得胜
	[GStars_Special_Type.PT_SP_EIGHT] = "baxianguohai",			--八仙过海
                  
}

function this.Awake()
   this.initinfor()
  	--this.registerevent() 
end

function this.Show(cards, nSpecialType,viewSeat,show_time)
	cards = Array.CardSort(cards, nSpecialType)
	ui_sound_mgr.PlaySoundClip("game_80011/sound/cardtpye_girl/specialtype/".. SpecialTypeMusicConfig[nSpecialType])
	timeSecond = show_time
	Trace("---------cards------"..tostring(cards).."  dun: "..tostring(dun))
	my_cards = cards
	if this.gameObject==nil then
		require ("logic/shisangshui_sys/special_card_show/special_card_show")
		this.gameObject=newNormalUI("game_80011/ui/special_card_show")
	else
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
	this.LoadUserInfo(viewSeat)
	this.LoadAllCard(cards, nSpecialType)
  	--this.addlistener()
end

function this.Hide()
	for i, v in ipairs(cardTranTbl) do
		if v ~= nil then
			GameObject.Destroy(v.gameObject)
		end
	end
	
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
	animalPar = child(this.transform, "animalPar")
end

--注册事件
function this.registerevent()
end

function this.LoadAllCard(cards, nSpecialType)
---[[
	local cardGrid = child(this.transform, "cardGrid")
	if cardGrid == nil then
		print("cardGrid == nil")
		return
	end
	if cards == nil then
	print("cards: ")
end
	for i, v in pairs(cards) do
		local cardObj = newNormalUI("game_80011/scene/card/"..tostring(v), cardGrid)
		cardTranTbl[v] = cardObj
		componentGet(child(cardTranTbl[v].transform, "bg"),"UISprite").depth = i * 2 + 3
		componentGet(child(cardTranTbl[v].transform, "num"),"UISprite").depth = i * 2 + 5
		componentGet(child(cardTranTbl[v].transform, "color1"),"UISprite").depth = i * 2 + 5
		componentGet(child(cardTranTbl[v].transform, "color2"),"UISprite").depth = i * 2 + 5
		if room_data.GetSssRoomDataInfo().isChip == true and v == 40 then
			child(cardTranTbl[v].transform,"ma").gameObject:SetActive(true)
			componentGet(child(cardTranTbl[v].transform, "ma"),"UISprite").depth = i * 2 + 4
		end

	end
	animations_sys.PlayAnimation(animalPar,"game_80011/effects/special_card_type",SpecialAnimalName[nSpecialType],100,100,false, callback)
	--]]

	--obj.transform.localPosition = Vector3.New(delte.x, delte.y, obj.transform.localPosition.z)
end

function this.Update()
	if timeSecond <= 0 then
		this.Hide()
		return
	end
	timeDelt = Time.deltaTime
	timeSecond =  timeSecond - timeDelt
end

function this.LoadUserInfo(viewSeat)
	local tex_photo= componentGet(child(this.transform, "head/headPic"), "UITexture")
	local NameLbl = componentGet(child(this.transform,"head/Label"), "UILabel")
	local userData = room_usersdata_center.GetUserByViewSeat(viewSeat)
	Trace(GetTblData(userData))
	NameLbl.text = userData.name
	hall_data.getuserimage(tex_photo,2,userData.headurl)
	--hall_data.getuserimage(tex_photo,2,room_usersdata_center.GetTempUserByLogicSeat(number).headurl)
end


