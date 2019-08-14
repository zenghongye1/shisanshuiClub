local openRoom_view_item = require "logic/hall_sys/record_ui/openRoom_view_item"

local base = require "logic/framework/ui/uibase/ui_view_base"
local openRoom_view = class("openRoom_view", base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"

function openRoom_view:InitView()
	self.initItemCount = 6
	self.curToggleName = nil
	self.openRoom_data = nil

    self.openRoom_wrapcontent_tr = child(self.transform,"right_bg/scrollview/ui_wrapcontent")
    self.openRoom_item_tr = child(self.transform,"right_bg/openRoom_item")
    self.tips_go = child(self.transform,"right_bg/tips").gameObject

    self.all_go = self:GetGameObject("menu_toggle/all")
    self.end_go = self:GetGameObject("menu_toggle/end")
    self.ready_go = self:GetGameObject("menu_toggle/ready")
    self.start_go = self:GetGameObject("menu_toggle/start")
    addClickCallbackSelf(self.all_go,self.OnToggleClick,self)
    addClickCallbackSelf(self.end_go,self.OnToggleClick,self)
    addClickCallbackSelf(self.ready_go,self.OnToggleClick,self)
    addClickCallbackSelf(self.start_go,self.OnToggleClick,self)

    self.itemList = {}
end

--[[--
 * @Description: 初始化  
 ]]
function openRoom_view:InitOpenRoom()
    for i=1,self.initItemCount do
        local go = newobject(self.openRoom_item_tr.gameObject)
        go.transform:SetParent(self.openRoom_wrapcontent_tr,false)
        local item = openRoom_view_item:create(go)
        item:SetActive(true)
        addClickCallbackSelf(item.gameObject,self.opendetails,self)
        addClickCallbackSelf(item.btnEnable,self.opendetailsOpenRoom,self)
        table.insert(self.itemList,item)
    end
end

function openRoom_view:Show(openRoom_data)
    self.openRoom_wrap = ui_wrap:create(child(self.transform,"right_bg").gameObject)
    self.openRoom_wrap.OnUpdateItemInfo=function (go,realindex,index)
        self:UpdataOpenOpenRoom(go,realindex,index)
    end 
    self.openRoom_wrap:InitUI(107)
    self.openRoom_wrap.OnUpdateToEnd=function ()
        self:OnUpdateToEndOpenRoom()
    end

	self:GetComponent("menu_toggle/all", "UIToggle").value = true
	self.curToggleName = "all"
    self:Initdate(openRoom_data)
end

--[[--
 * @Description: 选项点击事件  
 ]]
function openRoom_view:OnToggleClick(obj)
    ui_sound_mgr.PlayButtonClick()
	local toggle_name = tostring(obj.name)
	if self.curToggleName == toggle_name then
		return
	end
	self.curToggleName = toggle_name
	http_request_interface.getRoomSimpleList(nil,self:GetReqType(),0,function (str)
        local s=string.gsub(str,"\\/","/")  
        local t=ParseJsonStr(s)   
        if t.data == nil then
          	return
        end
        	self:Initdate(t.data)
      	end) 
end

--[[--
 * @Description: 显示  
 ]]
function openRoom_view:Initdate(openRoom_data)
	self.openRoom_data = openRoom_data
    if self.openRoom_wrap then
	   self.openRoom_wrap:Initdate(openRoom_data)
    end
    if #openRoom_data > 0 then
        self.tips_go:SetActive(false)
    else
        self.tips_go:SetActive(true)
    end
end

--[[--
 * @Description: 刷新item  
 ]]
function openRoom_view:UpdataOpenOpenRoom(go,realindex,index)
    
    if self.openRoom_wrap.wraprecord[realindex] == nil then
        warning("self.openRoom_wrap.wraprecord[rindext] is nil")
        return
    end

    local item = self.itemList[index]
    if item then
        item:UpdateRecord(realindex,self.openRoom_wrap.wraprecord[realindex])
    end
end

--[[--
 * @Description: 战绩详情点击事件  
 ]]
function openRoom_view:opendetails(obj1)
    local data = self.openRoom_wrap.wraprecord[tonumber(obj1.name)]
    local rid=data.rid   
    local status = data.status
    if status ~= 2 then
        return
    end
    ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
    report_sys.EventUpload(14)
    if rid==0 then
        recorddetails_ui.Show()    
    else 
       --  UI_Manager:Instance():ShowUiForms("waiting_ui")
       --  http_request_interface.getRoomByRid(rid,1,function (str)   
       --     local s=string.gsub(str,"\\/","/")  
       --     local t=ParseJsonStr(s) 
       --      UI_Manager:Instance():ShowUiForms("recorddetails_ui",UiCloseType.UiCloseType_CloseNothing,function() 
       --                              Trace("Close recorddetails_ui")
       --                            end,t)
       --     UI_Manager:Instance():CloseUiForms("waiting_ui")
       -- end)
        HttpProxy.SendRoomRequest(
            HttpCmdName.GetRoomRecordInfo, {rid = rid}, 
            function (_param, _errno)   
                UI_Manager:Instance():ShowUiForms("recorddetails_ui",UiCloseType.UiCloseType_CloseNothing,nil,_param)
            end, nil, HttpProxy.ShowWaitingSendCfg)
    end  
end

--[[--
 * @Description: 进入房间按钮事件
 ]]
function openRoom_view:opendetailsOpenRoom(obj1)
    ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
    local rno=self.openRoom_wrap.wraprecord[tonumber(obj1.transform.parent.name)].rno   
	join_room_ctrl.JoinRoomByRno(rno)
end

--[[--
 * @Description: 底部刷新  
 ]]
function openRoom_view:OnUpdateToEndOpenRoom()
    http_request_interface.getRoomSimpleList(nil,self:GetReqType(),self.openRoom_wrap.page,function (str)
        if self.openRoom_wrap then
            local s=string.gsub(str,"\\/","/")  
            local t=ParseJsonStr(s) 
            local count=table.getCount(self.openRoom_wrap.wraprecord) 
            if table.getCount(t.data)<=0 then
                return
            end
            for i=1,table.getCount(t.data) do
                self.openRoom_wrap.wraprecord[i+count]=t.data[i]
            end
            self.openRoom_wrap.page=self.openRoom_wrap.page+1
            self.openRoom_wrap.maxCount=table.getCount(self.openRoom_wrap.wraprecord)
            self.openRoom_wrap.wrap.minIndex = -self.openRoom_wrap.maxCount+1 
        end
    end) 
end

function openRoom_view:GetReqType()
	local reqType = 99
	if self.curToggleName == "all" then
		reqType = 99
	elseif self.curToggleName == "end" then
		reqType = {2}
	elseif self.curToggleName == "ready" then
		reqType = {0,3}
	elseif self.curToggleName == "start" then
		reqType = {1}
	end
	return reqType
end

return openRoom_view