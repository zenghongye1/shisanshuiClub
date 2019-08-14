local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjScene = class("comp_mjScene", mode_comp_base)

function comp_mjScene:ctor()
	self.sceneGo = nil
	self.name = "comp_mjScene"
	self.sceneTr = nil
	self.mainCamera = nil
	self.mainCameraTr = nil
	self.twoDCamera = nil
	self.twoDCameraTr = nil
	self.directLightTr = nil
	self.spotlightTr = nil
end


function comp_mjScene:Initialize()
	self.config = self.mode.config

	self:InitScene()
end

function comp_mjScene:InitScene()
	local res = newNormalObjSync(mahjong_path_mgr.GetMjPath("mjscene"), typeof(GameObject))	
	self.sceneGo = newobject(res)
	self.sceneTr = self.sceneGo.transform

	self.mainCamera = subComponentGet(self.sceneTr, "Main Camera", typeof(Camera))
	self.mainCameraTr = self.mainCamera.transform

	self.twoDCamera = subComponentGet(self.sceneTr, "2D Camera", typeof(Camera))
	self.twoDCameraTr = self.twoDCamera.transform

	self.directLightTr = child(self.sceneTr, "Directional light")
	self.spotlightTr = child(self.sceneTr, "Spotlight")

	self:InitConfig()
end

function comp_mjScene:InitConfig()
	if self.config.sceneCfg == nil then
		return
	end
	self:SafeSetPos(self.mainCameraTr, self.config.sceneCfg, "mainCameraPos")
	self:SafeSetEulers(self.mainCameraTr, self.config.sceneCfg, "mainCameraEulers")
	self:SafeSetPos(self.twoDCameraTr, self.config.sceneCfg, "twoCameraPos")
	self:SafeSetEulers(self.twoDCameraTr, self.config.sceneCfg, "twoCameraEulers")
end


function comp_mjScene:SafeSetPos(tr, config, field)
	if tr == nil or config == nil then
		return
	end
	local value = config[field]
	if value == nil then
		return
	end
	tr.localPosition = value
end

function comp_mjScene:SafeSetEulers(tr, config, field)
	if tr == nil or config == nil then
		return
	end
	local value = config[field]
	if value == nil then
		return
	end
	tr.localEulerAngles = value
end

function comp_mjScene:Uninitialize()
	destroy(self.sceneGo)
	self.sceneGo = nil
end

return comp_mjScene