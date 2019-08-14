local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjClickEvent = class('comp_mjClickEvent', mode_comp_base)

local Input = Input

function comp_mjClickEvent:ctor()
	self.name = "comp_clickevent"


	self.Camera2D = nil--2D相机comp
	self.cameraMain = nil--主摄像机comp
	self.comp_mjItemMgr = nil--麻将子管理组件
	self.ray = nil--射线
	self.isCast = false--是否碰撞
	self.rayhit = nil--碰撞体
end

function comp_mjClickEvent:Initialize()
	mode_comp_base.Initialize(self)
	self:Init()	
end

--[[--
* @Description: 初始化  
]]
function comp_mjClickEvent:Init()
    self.Camera2D = GameObject.Find("2D Camera"):GetComponent(typeof(Camera))
    self.cameraMain = Camera.main
    self.comp_mjItemMgr = mode_manager.GetCurrentMode():GetComponent("comp_mjItemMgr")
end

function comp_mjClickEvent:Update()
	if(Input.GetMouseButtonUp(0)) then
          -- self.ray = self.Camera2D:ScreenPointToRay(Input.mousePosition)
          -- --ray = self.cameraMain:ScreenPointToRay(Input.mousePosition)
          
          -- if self.ray ~= nil then
          --       self.isCast, self.rayhit = Physics.Raycast(self.ray, nil)
          -- end
          -- if(self.isCast) then
          -- 	local tempObj = self.rayhit.collider.gameObject
          --       --Trace("tempObj.layer---------------------------------"..tostring(tempObj.layer))
          -- 	if (tempObj.name == "mjobj") and tempObj.layer == 8 then                                 	
          -- 		local mjComp = self.comp_mjItemMgr.mjObjDict[tempObj.transform.parent.gameObject]
          -- 		if(mjComp~=nil) then
          --    --                if mjComp.isDrag then
          --    --                      return
          --    --                end
          -- 			-- if mjComp.eventPai~=nil then
          -- 			-- 	-- mjComp.eventPai(mjComp)
          --    --                      return
          -- 			-- else
          -- 			-- 	Trace("Click not hand card")
          -- 			-- end
          --       return
          -- 		else
          --                   if tempObj.transform.parent.gameObject.name == "MJ(Clone)" then
          --                         tempObj.transform.parent.gameObject:SetActive(false)
          --                   end
          -- 			Trace("!!!!!!!!!!!!!mjComp error")
          -- 		end
          -- 	end
          -- end
          -- self.mode:GetComponent("comp_playerMgr"):GetPlayer(1):CancelClick()
          -- self.mode:GetComponent("comp_playerMgr"):HideHighLight()

          Notifier.dispatchCmd(cmdName.MSG_MOUSE_BTN_UP,Input.mousePosition)
    end
    if Input.GetMouseButtonDown(0) then
      Notifier.dispatchCmd(cmdName.MSG_MOUSE_BTN_DOWN,Input.mousePosition)
    end

    if Input.GetMouseButton(0) then
      Notifier.dispatchCmd(cmdName.MSG_MOUSE_BTN,Input.mousePosition)
    end
end


return comp_mjClickEvent