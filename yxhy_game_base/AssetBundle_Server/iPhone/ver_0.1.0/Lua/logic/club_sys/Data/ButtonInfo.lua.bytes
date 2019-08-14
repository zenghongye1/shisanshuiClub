local ButtonInfo = class("ButtonInfo")

function ButtonInfo:ctor()
	self.text = ''
	self.callback = nil
	self.target = nil
	self.data = nil
	self.bgSp = "button_03"
end

function ButtonInfo:Call(d)
	local data = d
	if data == nil then
		data = self.data
	end
	if self.callback ~= nil then
		if self.target ~= nil then
			self.callback(self.target, self.data)
		else
			self.callback(self.data)
		end
	end
end

return ButtonInfo