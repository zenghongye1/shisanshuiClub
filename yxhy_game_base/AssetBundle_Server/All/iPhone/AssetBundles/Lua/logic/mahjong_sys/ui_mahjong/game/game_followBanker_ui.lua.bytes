local game_followBanker_ui = {}

local this = game_followBanker_ui

local hide_timer = nil
local num_label = nil

function this.Show(num)
	if IsNil(this.gameObject) then
		local gameObject_prefab = newNormalObjSync(data_center.GetResMJCommPath().."/ui/game/followBanker", typeof(GameObject))
		this.gameObject = newobject(gameObject_prefab)
		mahjong_ui:SetChild(this.gameObject.transform,"Anchor_Center")
		num_label = subComponentGet(this.gameObject.transform,"num","UILabel")
	end
	this.gameObject:SetActive(true)
	num_label.text = tostring(num)
	if hide_timer then
		hide_timer:Stop()
		hide_timer = nil
	end
	hide_timer = Timer.New(this.Hide, 2, 1)
	hide_timer:Start()
end

function this.Hide()
	this.gameObject:SetActive(false)
end

return game_followBanker_ui