local game_threePeng_ui = {}

local this = game_threePeng_ui

local hide_timer = nil

function this.Show()
	if IsNil(this.gameObject) then
		local gameObject_prefab = newNormalObjSync(data_center.GetResMJCommPath().."/ui/game/threePeng", typeof(GameObject))
		this.gameObject = newobject(gameObject_prefab)
		mahjong_ui:SetChild(this.gameObject.transform,"Anchor_Center")
	end
	this.gameObject:SetActive(true)
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

return game_threePeng_ui