--[[--
 * @Description: 进入大厅后，会产生表现逻辑的命令管理器
 * @Author:      shine
 * @FileName:    after_cmds_mgr.lua
 * @DateTime:    2016-12-05 17:47:37
 ]]

after_cmds_mgr = {}
local this = after_cmds_mgr
local cmdList = {}

local ExcuteNextCmd = nil
local On_HALL_MAIN_UI_SHOWED = nil
local On_MSG_SCENARIO_SEND_EVENT = nil
local CheckToExcuteCmds = nil
local SortCmds = nil
local ExcuteCmds = nil

local hallUIShowd = false
local scenarioEnd = false

function this.Init()
	Notifier.regist(cmdName.HALL_MAIN_UI_SHOWED, On_HALL_MAIN_UI_SHOWED)
end

function this.UnInit()
	Notifier.remove(cmdName.HALL_MAIN_UI_SHOWED, On_HALL_MAIN_UI_SHOWED)
end

function this.Start()
	hallUIShowd = false
	scenarioEnd = false
end

function this.AddCmd(cmd)
	local findSameOprationFlag = false
	for k, v in ipairs(cmdList) do
		if (v.OPERATION_ID == cmd.OPERATION_ID) then
			findSameOprationFlag = true
			break
		end
	end

	if (not findSameOprationFlag) then
		local nextSeqID = table.getn(cmdList) + 1
		cmd:SetSequenceID(nextSeqID)
		table.insert(cmdList, cmd)
	end

	if table.getn(cmdList) ==1 then
		CheckToExcuteCmds()
	end

end

function this.ClearCmds()
	cmdList = {}
end

function ExcuteCmds()
	Notifier.regist(cmdName.MSG_AFEN_CMD_EXCUTED_OVER, ExcuteNextCmd)
	local firstCmd = cmdList[1]
	if (firstCmd ~= nil) then
		firstCmd:Excute()
	end
end

--[[--
 * @Description: 执行下一个命令
 ]]
function ExcuteNextCmd(lastSeqID)
	if (lastSeqID < table.getn(cmdList)) then
		local cmd = cmdList[lastSeqID + 1]
		if (cmd ~= nil) then
			local mainSceneRoot = hallui_mainscene.gameObject
			if (not IsNil(mainSceneRoot)) then
				cmd:Excute()
			else
				this.ClearCmds()
			end
		end
	else
		Notifier.remove(cmdName.MSG_AFEN_CMD_EXCUTED_OVER, ExcuteNextCmd)
		cmdList = {}
	end
end

--[[--
 * @Description: 处理mainui显示出来
 ]]
function On_HALL_MAIN_UI_SHOWED()
	hallUIShowd = true
	CheckToExcuteCmds()
end

function On_MSG_SCENARIO_SEND_EVENT()
	scenarioEnd = true
	CheckToExcuteCmds()
end

function CheckToExcuteCmds()
	if (hallUIShowd and scenarioEnd) then
		coroutine.start(function ()
			coroutine.step(5) -- 等5帧，应该差不多了

			local mainSceneRoot = hallui_mainscene.gameObject
			if (not IsNil(mainSceneRoot) and not hallui_mainscene.isPlainType) then
				SortCmds()
				ExcuteCmds()
			else
				this.ClearCmds()
			end
		end)
	end
end

--[[--
 * @Description: 根据优先级排列各个命令
 ]]
function SortCmds()
	if (table.getn(cmdList) > 1) then
		table.sort(cmdList, function (cmd1, cmd2)
			return cmd1.priority > cmd2.priority
		end)
	end
end




