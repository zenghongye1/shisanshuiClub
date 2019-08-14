local base = require "logic/mahjong_sys/action/common/mahjong_action_base"
local lib_common = class("lib_common", base)


function lib_common:GetPaoCount(rewards, seat1, seat2, pao_type)
	local paoCount = 0
	if rewards[seat1].xiapao and rewards[seat2].xiapao and rewards[seat1].xiapao > 0 and rewards[seat2].xiapao > 0 then
		if pao_type == 1 then
			paoCount = tonumber(rewards[seat1].xiapao) + tonumber(rewards[seat2].xiapao)
		elseif pao_type == 2 then
			paoCount = math.max(tonumber(rewards[seat1].xiapao),tonumber(rewards[seat2].xiapao))
		end
	end
	return paoCount
end

function lib_common:GetGangAddNoWin(bGangAddNoWin)
	local ret = false
	if bGangAddNoWin == 2 or bGangAddNoWin == 0 then		
		ret = false			
	else
		ret = true
	end	
	return ret
end

function lib_common:GetSupportDealerAdd()
	return roomdata_center.gamesetting.bSupportDealerAdd
end

function lib_common:GetSupportGangPao()
	return roomdata_center.gamesetting.bSupportGangPao
end

function lib_common:GetSupportXiaPao()
	return roomdata_center.gamesetting.bSupportXiaPao
end

function lib_common:GetNPaoNum()
	return roomdata_center.gamesetting.nPaoNum
end

function lib_common:GetSupportByKey(key)
	return roomdata_center.gamesetting[key]
end

function lib_common:GetDealerBase(banker, i1, i2)
	local base = 0
	if self:GetSupportDealerAdd() and (banker == i1 or banker == i2) then
		base = 1
	end
	return base
end

function lib_common:GetWhichJiePao(rewards)
	local des = nil
	local chair = nil
	for i,v in ipairs(rewards) do
		if v.nJiePao == 1 then
			chair = v._chair
			break
		end
	end
	local viewSeat = nil 
	if chair ~= nil then		
		viewSeat = self.gvblFun(chair)
		if viewSeat == 1 then
			des = "本家"
		elseif viewSeat == 2 then
			des = "下家"
		elseif viewSeat == 3 then
			des = "对家"
		elseif viewSeat == 4 then		
			des = "上家"
		end
	end
	return viewSeat, des
end

function lib_common:GetAddFanInfo(winInfo, preDes, lastDes)
	local beishu = 0
	local fanTbl = {}
	if winInfo then
		for i,v in ipairs(winInfo) do
			local itemInfo = {}
			if v.byFanNumber ~= -1 then			
				itemInfo.num =preDes..tostring(v.byFanNumber)..lastDes
				beishu = beishu + v.byFanNumber
			end
			itemInfo.des = v.szFanName		
			table.insert(fanTbl, itemInfo)
		end
	end

	return beishu, fanTbl
end

function lib_common:GetMulFanInfo(winInfo, preDes, lastDes)
	local beishu = 1
	local fanTbl = {}
	for i,v in ipairs(winInfo) do
		local itemInfo = {}
		if v.byFanNumber ~= -1 then
			itemInfo.num = preDes..tostring(v.byFanNumber)..lastDes
			beishu = beishu * v.byFanNumber
		end
		itemInfo.des = v.szFanName		
		table.insert(fanTbl, itemInfo)
	end

	return beishu, fanTbl
end


function lib_common:GetFanInfo(winInfo, preDes, lastDes, exBeiType, huBeiType)
	local beishu = 1
	if exBeiType == 0 then	
		beishu = 0
	else
		beishu = 1
	end
	local fanTbl = {}
	local hubeiNum = 1
	for i,v in ipairs(winInfo) do
		local itemInfo = {}
		if huBeiType == 0 then   	--相加
			if exBeiType == 0 then	--相加
				if v.byFanNumber ~= -1 then
					itemInfo.num = preDes..tostring(v.byFanNumber)..lastDes
					beishu = beishu + v.byFanNumber
				end				
			elseif exBeiType == 1 then  --相乘
				if v.byFanNumber ~= -1 then
					itemInfo.num = preDes..tostring(v.byFanNumber)..lastDes
					beishu = beishu * v.byFanNumber
				end				
			end		
		elseif huBeiType == 1 then	--相乘
			if v.byFanType == 18 or v.byFanType == 19 then
				hubeiNum = v.byFanNumber
				itemInfo.num = preDes..tostring(v.byFanNumber)..lastDes
			else
				if exBeiType == 0 then	--相加
					if v.byFanNumber ~= -1 then
						itemInfo.num = preDes..tostring(v.byFanNumber)..lastDes
						beishu = beishu + v.byFanNumber	
					end			
				elseif exBeiType == 1 then  --相乘
					if v.byFanNumber ~= -1 then
						itemInfo.num = preDes..tostring(v.byFanNumber)..lastDes
						beishu = beishu * v.byFanNumber
					end
				end				
			end
		end
		if v.byFanNumber ~= -1 then
			itemInfo.des = v.szFanName		
			table.insert(fanTbl, itemInfo)
		end
	end

	if huBeiType == 1 then
		beishu = beishu * hubeiNum
	end
	return beishu, fanTbl	
end

function lib_common:calFanInfo(config,winInfo,suffix,fix)
	if not (config and type(config) == "table") then
		logError("结算数据异常: no config")
		return
	end
	if not (winInfo and type(winInfo) == "table") then
		return
	end
	local beishu = nil
	local cardTypeBeishu = 0 --牌型倍数
	local extraTypeBeishu = 0 --另加倍倍数
	local winTypeFanNum = 1
	--结算中牌型倍数的初始化
	if config.cardTypeCalType == 1 then
		cardTypeBeishu = 0   -- 加是0
	else
		cardTypeBeishu = 1	 -- 乘是1
	end
	--结算中加倍类型倍数的初始化
	if config.ADDBeiTypeMethod == 1 then
		winTypeFanNum = 0
	else
		winTypeFanNum = 1
	end
	--结算中另加倍类型的初始化
	if config.extraFanTypeCalType == 1 then
		extraTypeBeishu = 0
	else
		extraTypeBeishu = 1
	end

	local fanTbl = {}
	if winInfo then
		for i,v in ipairs(winInfo) do
			local itemInfo = {}
			if v.byFanNumber ~= -1 then
				if table.contains(config.cardTypes,v.byFanType) then
					--结算中牌型倍数的计算
					if config.cardTypeCalType == 1 then
						cardTypeBeishu = cardTypeBeishu + v.byFanNumber
					else
						cardTypeBeishu = cardTypeBeishu * v.byFanNumber
					end
					--结算中加倍类型倍数的计算
				elseif table.contains(config.rewardWinType,v.byFanType) then
				 	if config.ADDBeiTypeMethod == 1 then
				 		winTypeFanNum = winTypeFanNum + v.byFanNumber
				 	else
				 		winTypeFanNum = winTypeFanNum * v.byFanNumber
				 	end 
				else
					--结算中另加倍类型的计算
					if config.extraFanTypeCalType == 1 then
						extraTypeBeishu = extraTypeBeishu + v.byFanNumber
					else
						extraTypeBeishu = extraTypeBeishu * v.byFanNumber
					end
				end
				itemInfo.num =suffix..tostring(v.byFanNumber)..fix
			end
			itemInfo.des = v.szFanName		
			table.insert(fanTbl, itemInfo)
		end
	end
	--结算中另加倍类型的初始化
	if config.cardType_ExtraCalType== 1 then
		beishu = cardTypeBeishu + extraTypeBeishu
	else
		beishu = cardTypeBeishu * extraTypeBeishu
	end
	if config.isSupportADDBei == true then
		if config.rewardWinTypeCalMethod == 1 then
			beishu = beishu + winTypeFanNum
		else
			beishu = beishu * winTypeFanNum
		end
	end 
	return beishu, fanTbl
end


return lib_common