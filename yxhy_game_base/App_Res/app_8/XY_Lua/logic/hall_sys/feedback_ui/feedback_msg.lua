
feedback_msg = {}

local this = feedback_msg

this.time = ""
this.type = 0
this.msg = ""

feedback_msg.__index = feedback_msg

function feedback_msg.New()
	local this = {}
	setmetatable(this,feedback_msg)
	return this
end