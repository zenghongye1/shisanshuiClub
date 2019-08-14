
PokerShareSpecialDeal = {}
local this = PokerShareSpecialDeal

local specialKey = {
	"baseScore",		--底分
	"multipleRule",		--翻倍规则
}
local isDealGid = {
	[1] = ENUM_GAME_TYPE.TYPE_NIUNIU,
	[2] = ENUM_GAME_TYPE.TYPE_SANGONG,
}

--[[local NiuNiuStrDefine = {
	[1] = "无牛",
	[2] = "牛一",
	[3] = "牛二",
	[4] = "牛三",
	[5] = "牛四",
	[6] = "牛五",
	[7] = "牛六",
	[8] = "牛七",
	[9] = "牛八",
	[10] = "牛九",
	[11] = "牛牛",
}--]]

--[[local SanGongStrDefine = {
	[1] = "零点",
	[2] = "一点",
	[3] = "二点",
	[4] = "三点",
	[5] = "四点",
	[6] = "五点",
	[7] = "六点",
	[8] = "七点",
	[9] = "八点",
	[10] = "九点",
	[11] = "混三公",
	[12] = "小三公",
	[13] = "大三公",
}--]]

function this.ProduceValue(gid,key,shareData)
	if gid == isDealGid[1] or gid == isDealGid[2] then
		if key == specialKey[1] then
			return this.GetBaseScoreStr(shareData)
		end
		
		if key == specialKey[2] then
			return this.GetMultipleRuleStr(gid,shareData)
		end
	else
		return nil
	end
end

function this.GetBaseScoreStr(gameData)
	local str = "底分:"
	if gameData ~= nil and not isEmpty(gameData) then
		local count = table.getCount(gameData)
		for k,v in ipairs(gameData) do
			str = str..tostring(v)
			if k < count then
				str = str.."/"
			end
		end		
	end
	Trace("GetBaseScoreStr-----"..str)
	return str
end

function this.GetMultipleRuleStr(gid,gameData)
	local str = ""
	if gameData ~= nil and not isEmpty(gameData) then		
		for k,v in ipairs(gameData) do
			if tonumber(v) >= 2 then
				if gid == ENUM_GAME_TYPE.TYPE_NIUNIU then
					require "logic/niuniu_sys/other/niuniu_rule_define"
					str = niuniu_rule_define.PT_BULL_Text[k].."x"..tostring(v)..str
				elseif gid == ENUM_GAME_TYPE.TYPE_SANGONG then
					require "logic/poker_sys/sangong_sys/other/sangong_rule_define"
					str = sangong_rule_define.PT_SANGONG_Text[k].."x"..tostring(v)..str
				end
			end
		end
	end 
	Trace(gid.."----gid-----GetMultipleRuleStr-----"..str)
	return str
end