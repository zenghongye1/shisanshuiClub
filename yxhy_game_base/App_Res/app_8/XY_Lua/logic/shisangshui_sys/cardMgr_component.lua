require "logic/shisangshui_sys/card_component"

cardMgr_component = {}

function cardMgr_component.create()
	require "logic/mahjong_sys/mode_components/mode_comp_base"
	local this = mode_comp_base.create()
	this.Class = cardMgr_component
	this.name = "cardMgr_component"
	
	this.cardCompList = {} --扑克牌的列表
	this.cardObjDict = {}
	this.base_init = this.Initialize
	
	function this:Initialize()
		this.base_init()
	end
	
	function this:InitCardList()
		if #this.cardCompList == 0 then
			for i = 1,54 do
				local card = card_component.create()
				card.gameObject.name = "card"..i
				card.Hide()
				table.insert(this.cardCompList,card)
				this.cardObjDict[card.gameObject] = card
			end
		else
			for i = 1 , 54 do
				this.cardCompList[i]:Hide()
			end
		end
	end
	this.base_unInit = this.Uninitialize
	
	function this:Uninitialize()
		this.base_unInit()
	end
	
	Trace("----------------------InitCardItem")
 --   this:InitCardList()

	return this
end
