--[[--
 * @Description: 房间数据
 * @Author:      zhy, shine走读代码
 * @FileName:    room_data.lua
 * @DateTime:    2017-06-30
 ]]

require "logic/network/shisanshui_request_interface"
require "logic/network/messagedefine"
require "logic/shisangshui_sys/card_data_manage"

room_data = {}
local this = room_data 

--局数
PlayNum = {
	[1] = 8,
	[2] = 12, 
	[3] = 16
}
--人数
PeopleNum={
	[1] = 2,
	[2] = 3,
	[3] = 4,
	[4] = 5,
	[5] = 6
}
--加色
AddCard={
	[1] = 0,
	[2] = 1,
	[3] = 2
}
--买码
AddChip={
	[1] = 0,
	[2] = 1
}
--闲家最大倍数
MaxMultiple={
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5
}
local recommond_cards
--十三水房间配置数据
local sssroomDataInfo = 
{
	--加一色做庄
	isZhuang=false,
	--买码
	isChip=false,
	--总局数
	play_num = PlayNum[1],
	--当前局
	cur_playNum = 8,
	-- 人数
	people_num = PeopleNum[1],
	-- 加色
	add_card= AddCard[1],
	-- 大小鬼
	add_ghost = AddChip[1],
	-- 闲家最大倍数
	max_multiple = MaxMultiple[1],
	gid =11,
	rno = nil,
	owner_uid = nil, --房主的uid不是自已的uid
	mySelf_uid = nil, --自已的uid
	rid = nil,
	defaut = {},
	
	ready_time = 0,
	place_card_time = 0,--截止时间
	placeCardTime = 300
}
local SSroundInfo=
{
    ["2"]={["8"]=1,["12"]=2,["16"]=3},
    ["3"]={["8"]=1,["12"]=2,["16"]=3},
    ["4"]={["8"]=2,["12"]=3,["16"]=4},
    ["5"]={["8"]=3,["12"]=4,["16"]=5},
    ["6"]={["8"]=4,["12"]=5,["16"]=6}
}

function this.ShiSanShuiConfigReset()
	sssroomDataInfo.isZhuang = false
	sssroomDataInfo.isChip = false
	sssroomDataInfo.play_num = PlayNum[1]
	sssroomDataInfo.cur_playNum = 8
	sssroomDataInfo.people_num = PeopleNum[3]
	sssroomDataInfo.add_card= AddCard[1]
	sssroomDataInfo.add_ghost = AddChip[1]
	sssroomDataInfo.max_multiple = MaxMultiple[1]
end

function this.GetShareString()
	local configStr = ""
	if sssroomDataInfo ~= nil then
		if sssroomDataInfo.isZhuang  == true then
			configStr = configStr.."加一色坐庄、"
		end
		if sssroomDataInfo.add_ghost == 1 then
			configStr = configStr.."大小鬼、"
		end
		if tonumber(sssroomDataInfo.add_card) == 0 then
			configStr = configStr.."不加色、"
		elseif tonumber (sssroomDataInfo.add_card) == 1 then
			configStr = configStr.."加一色、"
		elseif tonumber(sssroomDataInfo.add_card) ==2 then
			configStr = configStr.."加两色、"
		end
		if sssroomDataInfo.isChip == true then
			configStr = configStr.."有马牌、"
		end
		if sssroomDataInfo.isZhuang == true then
			configStr = configStr.."闲家倍数:"..tostring(sssroomDataInfo.max_multiple).."倍、"
		end
		configStr = configStr..tostring(sssroomDataInfo.people_num).."人、"
		configStr = configStr..tostring(sssroomDataInfo.play_num).."局.\n"
		configStr =  configStr.."有闲你就来，玩本地十三水"
		end
	return configStr
end


--福州麻将配置数据
local fzmjroomDataInfo = 
{
	rounds = 4,
	pnum = 4,
	settlement = 0,
	halfpure = nil,   --半清一色
	allpure = nil,    --全清一色
	kindD = nil,      --可胡金龙
	DkingD = nil,     --单调剩金不平胡
	gid =18,
    selectindex={},
}

local buttonInfo=
{ 
}

local FZroundInfo=
{
    ["2"]={["4"]=1,["8"]=2,["16"]=3},
    ["3"]={["4"]=1,["8"]=2,["16"]=3},
    ["4"]={["4"]=1,["8"]=2,["16"]=3}
}

function this.GetFZShareString()
	local strTab = {}
	if fzmjroomDataInfo ~= nil then
		table.insert(strTab, fzmjroomDataInfo.pnum .. "人、")
		table.insert(strTab, fzmjroomDataInfo.rounds .. "局、")
		if fzmjroomDataInfo.allpure == 1 then
			table.insert(strTab, "清一色、")
		end
		if fzmjroomDataInfo.kindD == 1 then
			table.insert(strTab, "可胡金龙、")
		end
		if fzmjroomDataInfo.settlement == 0 then
			table.insert(strTab, "放炮三家赔。")
		end
		if fzmjroomDataInfo.settlement == 1 then
			table.insert(strTab, "放炮单赔。")
		end
	end
	table.insert(strTab, "\n有闲你就来，玩地道福州麻将")
	return table.concat(strTab)
end




function this.InitData()
	Trace("room_data.InitData-------------------------------------2")
	--读取十三水配置数据
	this.ReadSssConfData()

	--读取福州麻将配置数据
	--this.ReadFzmjConfData()
end

--[[--
 * @Description: 读取十三水配置数据  
 ]]
function this.ReadSssConfData()
	local str = FileReader.ReadFile(global_define.sss_path)
 	local roomConfData = nil
 	if nil ~= str and "" ~= str then
		roomConfData = ParseJsonStr(str)
	end
	
	if roomConfData ~= nil then
		local tmp_table = nil
		for i,v in ipairs(roomConfData) do
			if	i == 1 then	
	 			tmp_table = v
				for a,b in ipairs(tmp_table)  do
					if b~=nil then
						local selectIndex = b["selectIndex"]
						sssroomDataInfo.play_num = b["exData"][selectIndex]
					end
				end
			elseif	i == 2 then	
	 			tmp_table = v
				for a,b in ipairs(tmp_table)  do
					if b~=nil then
						local selectIndex = b["selectIndex"]
						sssroomDataInfo.people_num = b["exData"][selectIndex]
					end
				end
			elseif	i == 3 then	
	 			tmp_table = v
				for a,b in ipairs(tmp_table)  do
					if b~=nil then
						local selectIndex = b["selectIndex"]
						sssroomDataInfo.add_card = b["exData"][selectIndex]
					end
				end	
			elseif	i == 4 then	
	 			tmp_table = v
				for a,b in ipairs(tmp_table)  do
					if b~=nil then
						local selectIndex = b["selectIndex"]
						sssroomDataInfo.isChip = b["exData"][selectIndex]
					end
				end	
			elseif	i == 5 then	
	 			tmp_table = v
				for a,b in ipairs(tmp_table)  do
					if b~=nil then
						local selectIndex = b["selectIndex"]
						sssroomDataInfo.isZhuang = b["selectIndex"][1]
						sssroomDataInfo.add_ghost = b["selectIndex"][2]
					end
				end
			elseif	i == 6 then	
	 			tmp_table = v
				for a,b in ipairs(tmp_table)  do
					if b~=nil then
						local selectIndex = b["selectIndex"]
						sssroomDataInfo.max_multiple = b["exData"][selectIndex]				
					end
				end	
			end
		end	
	else
		Fatal("read sss room config data failed, please check your file fullpath!")
	end
end

--[[--
 * @Description: 读取福州麻将配置数据  
 ]]
function this.ReadFzmjConfData()
 	local str = FileReader.ReadFile(global_define.fzmj_path)
 	--Trace("str========================="..tostring(str))
 	local roomConfData = nil
 	if nil ~= str and "" ~= str then
		roomConfData = ParseJsonStr(str)
	end 

	if roomConfData ~= nil then
		local tmp_table = nil
		for i,v in ipairs(roomConfData) do		 
			if	i == 1 then	
	 			tmp_table = v 
				for a,b in ipairs(tmp_table)  do
					if b~=nil then
						fzmjroomDataInfo.rounds = b["exData"][b["selectIndex"][1]] 
                        buttonInfo[b["id"]]=b.data
					end
				end
			elseif i == 2 then
				tmp_table = v
				for c,d in ipairs(tmp_table) do
					if c==1 and d~=nil then
						if d["exData"][1]~=nil then
							fzmjroomDataInfo.pnum = d["exData"][d["selectIndex"][1]] 
                            buttonInfo[d["id"]]=d.data
						end
					elseif c==2 and d~=nil then
						fzmjroomDataInfo.settlement = d["selectIndex"][1] 
                        buttonInfo[d["id"]]=d.data
					end
				end
			elseif i==3 then 
	            tmp_table = v 
	            fzmjroomDataInfo.selectindex["playtype"]=tmp_table[1]["selectIndex"]  
                for k,v in ipairs(tmp_table[1]["id"]) do
                    buttonInfo[v]=tmp_table[1].data[k]
                end
	            for k,v in  pairs(fzmjroomDataInfo.selectindex["playtype"]) do
	                if v==1 then 
	                    fzmjroomDataInfo.halfpure =1 
	                end
				    if v==2 then
	                    fzmjroomDataInfo.allpure =1 
	                end
	                if v==3 then
	                     fzmjroomDataInfo.kindD =1 
	                end 
	            end 
			end          
		end	
	else
		Fatal("read fzmj room config data failed, please check your file fullpath!")
	end
end

--////////////////////////////////////////外部调用接口start//////////////////////////////////
--[[--
 * @Description: 获取十三水房间配置数据  
 ]]
function this.GetSssRoomDataInfo()
	return sssroomDataInfo
end

function this.SetSssRoomDataInfo(data)
	sssroomDataInfo = data
end
function this.GetSssRoundInfo()
    return SSroundInfo
end

function this.GetUid()
	return sssroomDataInfo.owner_uid
end

function this.GetRid()
	return sssroomDataInfo.rid
end

--判断我自己是不是房主
function this.IsOwner()
	local isOwner = false
	local mySelfUid =  data_center.GetLoginUserInfo().uid
	if tonumber(sssroomDataInfo.owner_uid) == tonumber(mySelfUid) then
		isOwner = true
	end
	return isOwner
end

function this.SetReadyTime(readyTime)
	sssroomDataInfo.ready_time = readyTime + os.time()
end

function this.SetPlaceCardTime(placeCardEndTime)
	sssroomDataInfo.place_card_time = placeCardEndTime
end

function this.SetPlaceCardSerTime(timeo)
	if timeo ~= nil then
		sssroomDataInfo.place_card_time = timeo + os.time()
		--sssroomDataInfo.placeCardTime = timeo
	end
end

function this.GetReadyTime()
	if sssroomDataInfo.ready_time == nil then
		sssroomDataInfo.ready_time = 0
	end
	return sssroomDataInfo.ready_time
end

function this.GetPlaceCardTime()
	if sssroomDataInfo.place_card_time == nil then
		sssroomDataInfo.place_card_time = 0
	end
	return sssroomDataInfo.place_card_time
end

function this.GetRecommondCard()
	return recommond_cards
end

function this.SetRecommondCard(cards)
	recommond_cards = cards
	if place_card.gameObject ~= nil and cards ~= nil then
		place_card.SetRecommondCard(recommendCards)
	end
end

function this.GetShareTitle()
	local title = "开房打十三水，速来：房间号："..tostring(sssroomDataInfo.rno).."]"
	return title
end

function this.GetShareContent()
	
--	local context = "有闲你就来，最有榕城特色的十三水，最真实的在线十三水！就在有闲棋牌！"
	local context = "加一色坐庄，大小鬼，不加色/加一色/加两色，有马牌/无马牌！"
	return context
end

--[[--
 * @Description: 获取福州麻将配置数据  
 ]]
function this.GetFzmjRoomDataInfo()
	return fzmjroomDataInfo
end

function this.GetButtonInfo()
    return buttonInfo
end

function this.SetFzmjRoomDataInfo(data)
	data.selectindex = fzmjroomDataInfo.selectindex
	fzmjroomDataInfo = data
end

function this.GetRoundInfo()
    return FZroundInfo
end

--////////////////////////////////////////外部调用接口end////////////////////////////////////

