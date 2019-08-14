--[[--
 * @Description: 进入大厅后，会产生表现逻辑的命令，目前包括：
                 1. 播放cg
 * @Author:      shine
 * @FileName:    after_cmd_base.lua
 * @DateTime:    2016-12-05 17:47:37
 ]]

after_cmd_base = {}
after_cmd_base.__index = after_cmd_base

--[[--
 * @Description: 构造函数  
 ]]
function after_cmd_base.New()
	local self = {}
	setmetatable(self, after_cmd_base)

	self.OPERATION_ID = -1
	self.excuted = false
	self.sequenceID = -1
	self.priority = -1

	return self
end

--[[--
 * @Description: 执行命令
 ]]
function after_cmd_base:Excute()
	self.excuted = true
end

function after_cmd_base:Clean()
	-- body
end

--[[--
 * @Description: 是否已执行
 ]]
function after_cmd_base:IsExcuted()
	return self.excuted
end

--[[--
 * @Description: 设置序列号
 ]]
function after_cmd_base:SetSequenceID(seqID)
	self.sequenceID = seqID
end

--[[--
 * @Description: 设置优先级
 ]]
function after_cmd_base:SetPriority(priority)
	self.priority = priority
end

function after_cmd_base:GetPriority()
	return self.priority
end





