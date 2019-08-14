local base = require("logic.framework.ui.uibase.ui_window")
local gps_ui = class("gps_ui",base)

local line = {
	[1]= "room_44",		----黄线带lbl
	[2]= "room_45",		----白线
	[3]= "room_49",		----虚线
}

local lineIndex = {
------"12":player1与player2的距离关系对应line1------
------"23":player2与player3的距离关系对应line6------
	["12"] = 1,
	["13"] = 2,
	["14"] = 3,
	["15"] = 4,
	["16"] = 5,
	["23"] = 6,
	["24"] = 7,
	["25"] = 8,
	["26"] = 9,
	["34"] = 10,
	["35"] = 11,
	["36"] = 12,
	["45"] = 13,
	["46"] = 14,
	["56"] = 15,
}

function gps_ui:ctor()
	base.ctor(self)
	self.tran_playerList = {}		--playerTranList
	self.sp_lineList = {}			--lineSpList
	self.playerData = nil
	self.seatList = {}
end

function gps_ui:OnInit()
	self:InitView()
end

function gps_ui:OnOpen(playerGpsList)
	if playerGpsList ~= nil and not isEmpty(playerGpsList) then
		self.playerData = playerGpsList
		self:UpdateView()
	end
end

function gps_ui:PlayOpenAmination()

end

function gps_ui:InitView()
	local btn_close = child(self.gameObject.transform,"gps_panel/top/btn_close")
	if btn_close ~= nil then
		addClickCallbackSelf(btn_close.gameObject,self.ClosWin,self)
	end
	if isEmpty(self.tran_playerList) then
		for i=1,6 do
			local tran_player = child(self.gameObject.transform,"gps_panel/middle/Player"..i)
			tran_player.gameObject:SetActive(false)
			table.insert(self.tran_playerList,tran_player)
		end
	end
	
	if isEmpty(self.sp_lineList) then
		for i=1,15 do
			local sp_line = componentGet(child(self.gameObject.transform,"gps_panel/middle/line/"..i).gameObject,"UISprite")
			sp_line.gameObject:SetActive(false)
			table.insert(self.sp_lineList,sp_line)
		end
	end
end

function gps_ui:UpdateView()
	if self.playerData == nil then
		logError("玩家信息岂能为空！")
		return
	end
	Trace("self.playerData----------"..GetTblData(self.playerData))
	self:InitHeadInfo()
	
	local coord = {}
	for k,v in pairs(self.playerData) do
		if v ~= nil and not isEmpty(v) then
			if v["viewSeat"] > 0 then
				local chairId = v["seatIndex"]
				table.insert(self.seatList,chairId)
				self.tran_playerList[chairId].gameObject:SetActive(true)
				local tex = componentGet(child(self.tran_playerList[chairId],"headTex").gameObject,"UITexture")
				HeadImageHelper.SetImage(tex,v["imageType"],v["imgUrl"])
				coord[chairId] = v["coordinate"]
				if (v["coordinate"]["latitude"]==0 and v["coordinate"]["longitude"]==0) then
					self:isCoordinateUnknow(chairId,true)
				else
					self:isCoordinateUnknow(chairId,false)
				end
			end
		end
	end
	local tbl = self:countDistance(coord)
	Trace("coord------"..GetTblData(tbl))
	self:UpdateLine(tbl)
end

function gps_ui:InitHeadInfo()
	local tbl = gps_data.GetPlayerIndexList()
	if tbl and not isEmpty(tbl) then
		for _,v in ipairs(tbl) do
			self.tran_playerList[v].gameObject:SetActive(true)
			self:isCoordinateUnknow(v,false)
		end
	end
end

----计算{["12"]=1}距离类型表
function gps_ui:countDistance(coordinate)
	local tbl = {}
	local lineType = 0
	for i = 1,6 do
		for j = 1,6 do
			if coordinate[i] ~= nil and coordinate[j] ~= nil then
				if (coordinate[i]["latitude"]==0 and coordinate[i]["longitude"]==0) or (coordinate[j]["latitude"]==0 and coordinate[j]["longitude"]==0) then
					lineType = 3 
				else
					local dist = YX_APIManage.Instance:getLocationDistance(coordinate[i]["latitude"],coordinate[i]["longitude"],coordinate[j]["latitude"],coordinate[j]["longitude"])
					if dist < 50 then
						lineType = 1
					else
						lineType = 2
					end
				end
				tbl[tostring(i)..tostring(j)] = lineType
				tbl[tostring(j)..tostring(i)] = lineType
			end
		end
	end
	return tbl
end

----表对应到line
function gps_ui:UpdateLine(tbl)
	for k,v in pairs(tbl) do
		local sp_line = self.sp_lineList[lineIndex[k]]
		if sp_line ~= nil then
			self:SetLineShowState(sp_line,v)
		end
	end
end

--地理位置是否未知
function gps_ui:isCoordinateUnknow(index,state)
	child(self.tran_playerList[index],"headTex/Signal").gameObject:SetActive(state)
end

--[[function gps_ui:IsLineExist()
	if not isEmpty(self.seatList) then	
		local notExist = true
		for i=1,6 do 
			for _,v in ipairs(self.seatList) do	
				if v==i then
					Trace("player"..v.."存在")
					notExist = false
				end		
				if notExist == true then
					notExist = false
					self:DisableLineShow(v)
				end
			end	
		end
	end
end

----隐藏index玩家六条相关线
function gps_ui:DisableLineShow(index)
	for k,v in pairs(lineIndex) do
		if string.find(k,tostring(index)) ~= nil then
			self.sp_lineList[v].gameObject:SetActive(false)
		end
	end
end--]]

----设置线的显示状态
function gps_ui:SetLineShowState(sp_line,lineType)
	sp_line.gameObject:SetActive(true)
	local go_distance = child(sp_line.transform,"distance").gameObject
	sp_line.spriteName = line[lineType]
	if lineType == 1 then
		LuaHelper.SetUISpriteType(sp_line,1)
		go_distance:SetActive(true)
	elseif lineType == 2 then
		LuaHelper.SetUISpriteType(sp_line,1)
		go_distance:SetActive(false)
	elseif lineType == 3 then
		LuaHelper.SetUISpriteType(sp_line,2)
		go_distance:SetActive(false)
	end
end

function gps_ui:ResetAll()
	for _,v in ipairs(self.tran_playerList) do
		v.gameObject:SetActive(false)
	end
	
	for _,v in ipairs(self.sp_lineList) do
		v.gameObject:SetActive(false)
	end
end

function gps_ui:ClosWin()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("gps_ui",true)
end

function gps_ui:OnClose()
	self.playerData = nil
	self.seatList = {}
	self:ResetAll()
end

return gps_ui