local mahjong_action_ctrl = class("mahjong_action_ctrl")

local ui_base_path = "logic/mahjong_sys/action/"
local mj_base_path = "logic/mahjong_sys/action/"

function mahjong_action_ctrl:ctor()
	-- ui_base_path  or mj_base_path
	self.basePath = ""
	self.actionCfg = nil
	self.actionType = 1
	self.actionList = {}
end

function mahjong_action_ctrl:Init(actionType)
	self.actionType = actionType
	self.mode =  mode_manager.GetCurrentMode()
	mode_manager.GetCurrentMode().actionCtrl = self
	if actionType == 1 then
		self.basePath = ui_base_path
		self.actionCfg = self.mode.config.uiActionCfg
	elseif actionType == 2 then
		self.basePath = mj_base_path 
		self.actionCfg = self.mode.config.mahjongActionCfg
	end
end

function mahjong_action_ctrl:GetAction(configKey)
	local actionName = self:GetActionPath(configKey)
	if actionName == "" then
		return nil
	end
	local requirePath = self.basePath .. actionName 
	local actionClass = require(requirePath)
	if actionClass == nil then
		logError("找不到 action", requirePath, configKey)
		return nil
	end
	local action = actionClass.new(self.mode)
	table.insert(self.actionList,action)
	return action
end


function mahjong_action_ctrl:GetActionPath(configKey)
	local actionCfg = nil
	if self.actionCfg ~= nil and 
		self.actionCfg[configKey] ~= nil then
		actionCfg = self.actionCfg
		-- baseConfig
	else
		return ""
	end
	local gameId = actionCfg[configKey][1]
	local actionName = actionCfg[configKey][2]
	local gamePath = ""
	local midPath = ""
	if gameId == 0 then
		gamePath = "common_1"
		-- if self.mode.modeId then
		-- 	gamePath = "common_"..self.mode.modeId
		-- end
	else
		gamePath = "game_" .. gameId
	end
	if self.actionType == 1 then
		midPath = "ui_action"
	else
		midPath = "mahjong_action"
	end

	return self:Concat(gamePath, midPath, actionName)
end

function mahjong_action_ctrl:Concat(...)
	local t = {...}
	return table.concat(t, "/")
end

function mahjong_action_ctrl:UnInit()
	for _,v in ipairs(self.actionList) do
		v:Uninitialize()
	end
end



return mahjong_action_ctrl 