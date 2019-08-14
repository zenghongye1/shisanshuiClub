--[[--
 * @Description: 倍数计算
 * @Author:      shine
 * @FileName:    lib_beishu.lua
 * @DateTime:    2017-11-27 16:19:37
 ]]
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local lib_beishu = class("lib_beishu", base)

function lib_beishu:CaculateBeishuByWinType(winType)	
	local beishu = 1
	local beishuInfo = self.config.beishu_wintype_dic[winType]
	--logError("winType----------------------"..tostring(winType))
	if beishuInfo ~= nil then
		Trace("beishuInfo[1]----------------------"..tostring(beishuInfo[1]))
		if roomdata_center.gamesetting[beishuInfo[1]] then
			beishu = beishuInfo[2][2]
		else
			beishu = beishuInfo[2][1]
		end	
	end

	if beishu == nil then
		beishu = 1
	end

	return beishu	
end


function lib_beishu:CaculateBeishuByWinInfo(winInfo)
	local beishu = 0
	if winInfo ~= nil then		
		for k,v in ipairs(self.config.beishu_wininfo_dic) do			
			if roomdata_center.gamesetting[v[1]] and winInfo[v[2]] and winInfo[v[2]] == 1 then	
				beishu = beishu + v[4]
			end
		end
	end		

	return beishu
end


function lib_beishu:CaculateBeishuByWinInfo2(winInfo)
	local beishu = 0
	if winInfo ~= nil then		
		for k,v in ipairs(self.config.beishu_wininfo_dic) do			
			if winInfo[v[1]] and winInfo[v[1]] == 1 then	
				beishu = beishu + v[3]
			end
		end
	end		

	return beishu
end

function lib_beishu:CaculateScoreItemByWinType(winType,winInfo)
	local beishuInfo = self.config.beishu_wintype_dic[winType]
	local beishu = 1
	local LastScore = {}
	if beishuInfo ~= nil then
		if roomdata_center.gamesetting[beishuInfo[1]] then
			beishu = beishuInfo[2][2]
		else
			beishu = beishuInfo[2][1]
		end
		for i,v in ipairs(winInfo) do
			if beishu ~= nil then
				local beishu = beishu * v.byFanNumber
			end		
		end
	end

	return beishu 
end
return lib_beishu