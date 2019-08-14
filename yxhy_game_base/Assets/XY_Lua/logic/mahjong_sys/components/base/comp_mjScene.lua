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
	self.cfg = self.mode.cfg

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
	self:AdjustScreenResolution()
	Notifier.dispatchCmd(GameEvent.OnMahjongSceneLoaded)
end

function comp_mjScene:InitConfig()
	if self.cfg.sceneCfg == nil then
		return
	end
	self.sceneCfg = MahjongSceneCfg[self.cfg.sceneCfg]
	self:SafeSetPos(self.mainCameraTr, self.sceneCfg, "mainCameraPos")
	self:SafeSetEulers(self.mainCameraTr, self.sceneCfg, "mainCameraEulers")
	self:SafeSetPos(self.twoDCameraTr, self.sceneCfg, "twoCameraPos")
	self:SafeSetEulers(self.twoDCameraTr, self.sceneCfg, "twoCameraEulers")
	self.twoDCamera.orthographicSize = self.sceneCfg.twoCameraSize
	self.mainCamera.fieldOfView = self.sceneCfg.mainCameraFieldOfView
end

function comp_mjScene:AdjustScreenResolution()
    local adjuster = 0
    local standardAspect = 1280 / 720
    local baseAspect = 4/3
    local deviceAspect = Screen.width / Screen.height
    adjuster = standardAspect / deviceAspect * 0.95

    if deviceAspect < standardAspect and deviceAspect > baseAspect then
       -- self.twoDCamera.orthographicSize = self.sceneCfg.twoCameraSize * adjuster
       -- self.twoDCamera.transform.localPosition = self.sceneCfg.twoCameraPos * adjuster

       self.twoDCamera.orthographicSize = ( self.sceneCfg.twoCameraSize *(deviceAspect - baseAspect) 
          + self.sceneCfg.twoCameraSize_4p3 *(standardAspect - deviceAspect) )
          / (standardAspect - baseAspect)

       self.twoDCamera.transform.localPosition = ( self.sceneCfg.twoCameraPos *(deviceAspect - baseAspect) 
          + self.sceneCfg.twoCameraPos_4p3 *(standardAspect - deviceAspect) )
          / (standardAspect - baseAspect)

       self.mainCamera.transform.localPosition = ( self.sceneCfg.mainCameraPos *(deviceAspect - baseAspect) 
          + self.sceneCfg.mainCameraPos_4p3 *(standardAspect - deviceAspect) )
          / (standardAspect - baseAspect)

       self.mainCamera.transform.localEulerAngles = ( self.sceneCfg.mainCameraEulers *(deviceAspect - baseAspect) 
          + self.sceneCfg.mainCameraEulers_4p3 *(standardAspect - deviceAspect) )
          / (standardAspect - baseAspect)

       self.mainCamera.fieldOfView = ( self.sceneCfg.mainCameraFieldOfView *(deviceAspect - baseAspect) 
          + self.sceneCfg.mainCameraFieldOfView_4p3 *(standardAspect - deviceAspect) )
          / (standardAspect - baseAspect)

    elseif deviceAspect <= baseAspect then
       self.twoDCamera.orthographicSize = self.sceneCfg.twoCameraSize_4p3
       self.twoDCamera.transform.localPosition = self.sceneCfg.twoCameraPos_4p3

       self.mainCamera.transform.localPosition = self.sceneCfg.mainCameraPos_4p3
       self.mainCamera.transform.localEulerAngles = self.sceneCfg.mainCameraEulers_4p3
       self.mainCamera.fieldOfView = self.sceneCfg.mainCameraFieldOfView_4p3
    end
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