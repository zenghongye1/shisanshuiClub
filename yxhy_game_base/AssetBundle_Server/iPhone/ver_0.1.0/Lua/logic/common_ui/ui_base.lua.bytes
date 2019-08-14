--[[--
 * @Description: 目前只负责ui-scene绑定关系
 * @Author:      shine
 * @FileName:    ui_base.lua
 * @DateTime:    2016-01-13 19:39:33
 ]]

require("logic/scene_sys/scene_type")
require "logic/common_ui/ui_stack_mgr"

ui_base = 
{
	sceneBelong = scene_type.NONE, 
	sceneIDBelong = nil,

	isVisible = nil,
	pageName = "",

	keepHoldUIs = {
	[cmdName.SHOW_PAGE_HALL] = cmdName.SHOW_PAGE_HALL,
	},

	needToHideOther = false,
	posVisible = true,
	preserveAtRunTime = false, 
	fakeDestroyed = true,
}

ui_base.__index = ui_base

function ui_base.New()
	local self = {}
	setmetatable(self, ui_base)
	Notifier.regist(cmdName.SHOW_SCENE, slot(self.OnSceneChange_x, self))
	return self
end

--[[--
 * @Description: 注册UI-scene关系，使用当前SceneType
 ]]
function ui_base:RegistUSRelation(needToHideOther)
	self.sceneBelong = GetCurrSceneType()
	self.sceneIDBelong = game_scene.GetCurSceneID
	if (not IsNil(self.transform)) then
		self.logicBaseLuaScript = componentGet(self.transform, typeof(LogicBaseLua))
	end
	Notifier.regist(cmdName.SHOW_SCENE, slot(self.OnSceneChange_x, self))
	self.needToHideOther = needToHideOther
	ui_stack_mgr.PushToStack(self)

end

--[[--
 * @Description: 注销UI-scene关系
 ]]
function ui_base:UnRegistUSRelation()
	Notifier.remove(cmdName.SHOW_SCENE, slot(self.OnSceneChange_x, self))
	ui_stack_mgr.PopFromStack(self)
	self.logicBaseLuaScript = nil
end

function ui_base:RegistSceneEvent()
	Notifier.regist(cmdName.SHOW_SCENE, slot(self.OnSceneChange_x, self))
end

function ui_base:UnRegistSceneEvent()
	Notifier.remove(cmdName.SHOW_SCENE, slot(self.OnSceneChange_x, self))
end

--[[--
 * @Description: 注册对话框打开关闭事件
 ]]
function ui_base:RegistDialogueEvent(pageName)

end

--[[--
 * @Description: 注销对话框打开关闭事件
 ]]
function ui_base:UnRegistDialogueEvent()

end

--[[--
 * @Description: 响应场景跳转
 ]]
function ui_base:OnSceneChange_x(paras)
	if (self.sceneIDBelong ~= nil and self.sceneIDBelong ~= paras.sceneID) then

		if (not IsNil(self.gameObject)) then
			if (not self.preserveAtRunTime) then
				destroy(self.gameObject)
				self.gameObject = nil
			else
				if (self.FakeDestroy ~= nil) then
					self:FakeDestroy()
				end
			end
		end
	end
end

function ui_base:FastShow()
	if (IsNil(self.logicBaseLuaScript)) then
		self.logicBaseLuaScript = componentGet(self.transform, typeof(LogicBaseLua))
	end

	if (self.logicBaseLuaScript ~= nil) then
		self.logicBaseLuaScript:FastShow()
	end
end

function ui_base:FastHide()
	if (IsNil(self.logicBaseLuaScript)) then
		self.logicBaseLuaScript = componentGet(self.transform, typeof(LogicBaseLua))
	end

	if (self.logicBaseLuaScript ~= nil) then
		self.logicBaseLuaScript:FastHide()
	end
end

function ui_base:RefreshPanelDepth( ... )
	if (IsNil(self.logicBaseLuaScript)) then
		self.logicBaseLuaScript = componentGet(self.transform, typeof(LogicBaseLua))
	end

	if (self.logicBaseLuaScript ~= nil) then
		self.logicBaseLuaScript:RefreshPanelDepth()
	end
end

function ui_base:InitPanelRenderQueue()
	if (IsNil(self.logicBaseLuaScript)) then
		self.logicBaseLuaScript = componentGet(self.transform, typeof(LogicBaseLua))
	end

	if (self.logicBaseLuaScript ~= nil) then
		self.logicBaseLuaScript:InitPanelRenderQueue()
	end
end