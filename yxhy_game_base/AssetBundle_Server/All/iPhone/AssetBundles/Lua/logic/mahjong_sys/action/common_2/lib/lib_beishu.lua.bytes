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
	if winInfo ~= nil and self.config.beishu_wininfo_dic~=nil then		
		for k,v in ipairs(self.config.beishu_wininfo_dic) do	 
			if roomdata_center.gamesetting[v[1]] and winInfo[v[2]] and winInfo[v[2]] == 1 then	
                local number=1 
                --添加加倍数量
                if winInfo.nFanDetailInfo~=nil then
                    for j,l in pairs(winInfo.nFanDetailInfo) do
                        if l.byFanType==v[3] then
                            number=l.byCount
                        end
                    end
                end
				beishu = beishu + (v[4])*number
			end
		end
	end		

	return beishu
end
function lib_beishu:CalAddBei(winInfo)
    local beishu = 0 
	if winInfo ~= nil then		
		for k,v in ipairs(self.config.addbei_wininfo_dic) do	 
			if roomdata_center.gamesetting[v[1]] and winInfo[v[2]] and winInfo[v[2]] == 1 then	
                local number=1 
                --添加加倍数量
                if winInfo.nFanDetailInfo~=nil then
                    for j,l in pairs(winInfo.nFanDetailInfo) do
                        if l.byFanType==v[3] then
                            number=l.byCount
                        end
                    end
                end
				beishu = beishu + (v[4])*number
			end
		end
	end		

	return beishu
end

return lib_beishu