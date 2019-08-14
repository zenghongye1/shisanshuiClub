 --region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require "logic/shisangshui_sys/card_data_manage"
 
local base = require("logic.framework.ui.uibase.ui_window")
local joinRoom_ui = class("joinRoom_ui",base)

function joinRoom_ui:ctor()
	base.ctor(self)	
end

function joinRoom_ui:OnInit()
	self:InitView()
end

function joinRoom_ui:OnOpen() 
	self:UpdateView()
end

-- function joinRoom_ui:PlayOpenAmination()

-- end

function joinRoom_ui:InitView()
    local btn_close = child(self.gameObject.transform,"join_panel/Panel_Top/btn_close")
    if btn_close ~= nil then
        addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
    end

    self.grid_number = child(self.gameObject.transform,"join_panel/Panel_Middle/gird_number")
    self.grid_input = child(self.gameObject.transform,"join_panel/Panel_Middle/grid_input")
	self.panel_fastEnter = child(self.gameObject.transform,"join_panel/Panel_Right")
end

function joinRoom_ui:UpdateView()
	self:InitCommonInput()
	self.panel_fastEnter.gameObject:SetActive(false)
	self:InitFastEnter()
end

function joinRoom_ui:InitCommonInput()
	self.input_ui = require "logic/hall_sys/CommonInput/CommonInput":create(self.grid_input,self.grid_number,nil,slot(self.RequestGetInRoom, self))
	self.input_ui:InitView()
end

function joinRoom_ui:RequestGetInRoom()
	local numList = self.input_ui:GetNumList()
	if #numList == 6 then
		local rno = table.concat(numList)
		join_room_ctrl.JoinRoomByRno(rno)
		self.input_ui:ClearNumList()
	end
end 

function joinRoom_ui:InitFastEnter()			--快速加入

	YX_APIManage.Instance:getCopy(function (msg)
		--Trace("getCopy------"..GetTblData(msg))--GAME_LOG: {"text":"197376","result":0}
		local tab = nil 
		local msg = string.gsub(msg, "\\/", "/")
		if not pcall( function() tab = ParseJsonStr(msg) end) then
			return
		end
		local retStr = tab
		if retStr.text == nil then
			return
		end
		local roomN = string.match(tostring(retStr.text),"%d%d%d%d%d%d")
		if roomN == nil then
			return
		end	
		-- http_request_interface.getRoomByRno(roomN, function (str)
		-- 	local s = string.gsub(str, "\\/", "/")
		-- 	local dataTbl = ParseJsonStr(s)
		-- 	Trace("房号："..roomN.."  请求加入数据------------"..GetTblData(dataTbl))
		-- 	if tonumber(dataTbl.ret) == 0 then
		-- 		self.rno =  roomN	
		-- 		self.panel_fastEnter.gameObject:SetActive(true)
		-- 		self.lbl_fastEnter = child(self.panel_fastEnter,"middle/roomNum/obj2/Label")
		-- 		if (self.lbl_fastEnter ~= nil) then
		-- 			componentGet(self.lbl_fastEnter.gameObject,"UILabel").text = self.rno
		-- 		end
		-- 		self.btn_fastEnter = child(self.panel_fastEnter,"middle/fastEnterBtn")
		-- 		if (self.btn_fastEnter ~= nil) then
		-- 			addClickCallbackSelf(self.btn_fastEnter.gameObject,self.FastEnter,self)
		-- 		end
		-- 	else
		-- 		Trace("InitFastEnter------getRoomByRno------------ret:  "..dataTbl.ret)
		-- 	end
		-- end, true)

		join_room_ctrl.GetRoomByRno(roomN, function(roomInfo)
			self.rno =  roomN	
			self.panel_fastEnter.gameObject:SetActive(true)
			self.lbl_fastEnter = child(self.panel_fastEnter,"middle/roomNum/obj2/Label")
			if (self.lbl_fastEnter ~= nil) then
				componentGet(self.lbl_fastEnter.gameObject,"UILabel").text = self.rno
			end
			self.btn_fastEnter = child(self.panel_fastEnter,"middle/fastEnterBtn")
			if (self.btn_fastEnter ~= nil) then
				addClickCallbackSelf(self.btn_fastEnter.gameObject,self.FastEnter,self)
			end
		end, false, true)
	end)
end

function joinRoom_ui:FastEnter()
	join_room_ctrl.JoinRoomByRno(self.rno)
end

function  joinRoom_ui:CloseWin()
    ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("joinRoom_ui")
end

function joinRoom_ui:OnRefreshDepth()

  local uiEffect = child(self.gameObject.transform, "join_panel/Panel_Top/Title/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

return joinRoom_ui