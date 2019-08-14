--[[--
 * @Description: 吃碰杠胡操作数据类
 * @Author:      ShushingWong
 * @FileName:    operatordata.lua
 * @DateTime:    2017-06-20 15:27:11
 ]]

require "logic/mahjong_sys/const/mahjongConst"

operatordata = {
	operType = MahjongOperAllEnum.None,
	operCard = 0,
	otherOperCard = {}
}

operatordata.__index = operatordata

function operatordata:New(operType,operCard,otherOperCard)
	local this = {}
	setmetatable(this,operatordata)
	this.operType = operType
	this.operCard = operCard
	this.otherOperCard = otherOperCard
	return this
end

-- 获取需要横置的牌的下标
function  operatordata:GetKeyCardIndex()
	local keyIndex = 0
	--Trace("this.operType----------------------------------"..tostring(this.operType))
	if(self.operCard~=0 and self.operType~=MahjongOperAllEnum.None) then
		--Trace("operatordata.operType----------------------------------"..tostring(self.operType))
		if(self.operType==MahjongOperAllEnum.TripletLeft) then
			keyIndex = 1
		else
			if(self.operType==MahjongOperAllEnum.TripletCenter) then
				keyIndex = 2
			else
				if(self.operType==MahjongOperAllEnum.TripletRight) then
					keyIndex = 3
				else
					if(self.operType==MahjongOperAllEnum.BrightBarLeft) then
						keyIndex = 1
					else
						if(self.operType==MahjongOperAllEnum.BrightBarCenter) then
							keyIndex = 2
						else
							if(self.operType==MahjongOperAllEnum.BrightBarRight) then
								keyIndex = 4
							end
						end
					end
				end
			end
		end
		if(keyIndex~=-1)then
			return keyIndex
		end
	end
	return keyIndex
end

operatorTipsData = {
	operType = MahjongOperAllEnum.None,
	operTbl = {}
}

function operatorTipsData:New(operType,operTbl)
	local this = {}
	setmetatable(this,operatorTipsData)
	this.operType = operType
	this.operTbl = operTbl
	return this
end