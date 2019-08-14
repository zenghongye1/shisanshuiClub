local mahjong_effectMgr = class("mahjong_effectMgr")
local poolBaseClass = require "logic/common/poolBaseClass"

local pathRoot = "app_4/mj_common/effects/"

function mahjong_effectMgr:ctor()
	local new = function ()
		return GameObject.New()
	end
	self.objectPool = poolBaseClass:create(new)
end

--[[--
 * @Description: 通过cfg_artconfig的id播放  
 ]]
function mahjong_effectMgr:PlayUIEffectById(id,parent,time)
	local config = config_mgr.getConfig("cfg_artconfig",id)
	return self:SetParent(self:PlayUIEffect(config,time),parent)
end

function mahjong_effectMgr:SetParent(obj,parent)
	if parent then
		obj.transform:SetParent(parent,false)
	end
	return obj
end

function mahjong_effectMgr:PlayUIEffect(data,time)
	local prefabName = data.prefabName
	local efSpriteName = data.efSpriteName
	local fireworkType = data.fireworkType
	local time = time or 1

	local effect 
	if fireworkType then
		effect = EffectMgr.PlayEffect(pathRoot..fireworkType,1,time)
	else
		logError("error fireworkType",GetTblData(data))
	end
	local effectFont
	if prefabName and efSpriteName then
		effectFont = EffectMgr.PlayEffect(pathRoot..prefabName,1,time)
		local sprite = effectFont:GetComponentInChildren(typeof(UISprite))
		if sprite then
			sprite.spriteName = efSpriteName
		else
			logError("error prefabName",prefabName)
		end
	end

	local obj = self.objectPool:Get()
	local trans = obj.transform
	if effect then
		effect.transform:SetParent(trans,false)
	end
	if effectFont then
		effectFont.transform:SetParent(trans,false)
	end

	local recycleTimer = Timer.New(function ()
    			self.objectPool:Recycle(obj)
    	   end, time, 1)
   	recycleTimer:Start()

	return obj
end

return mahjong_effectMgr