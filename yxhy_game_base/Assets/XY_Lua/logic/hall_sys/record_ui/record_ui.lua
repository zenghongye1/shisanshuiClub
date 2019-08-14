local record_view = require "logic/hall_sys/record_ui/record_view"
local openRoom_view = require "logic/hall_sys/record_ui/openRoom_view"

local base = require("logic.framework.ui.uibase.ui_window")
local record_ui = class("record_ui",base)

function record_ui:ctor()
    base.ctor(self)
    self.initItemCount = 7
    self.isSellectRecord = false
    self.record_data = nil
    self.openRoom_data = nil
    self.destroyType = UIDestroyType.ChangeScene
end

function record_ui:OnInit()
  base.OnInit(self)
  self:FindChild()
end

function record_ui:OnOpen(...)
    base.OnOpen(self,...)

    self.isSellectRecord = false
    self.record_toggle.value = true
    self.record_go:SetActive(false)
    self.openRoom_go:SetActive(false)

    UI_Manager:Instance():ShowUiForms("waiting_ui")
    local param = {}
    --param.time = os.date("%Y-%m-%d",os.time() - 30*24*3600)
    HttpProxy.SendRoomRequest(HttpCmdName.GetRoomRecordList, param, 
        function (msgTab,str) 
            UI_Manager:Instance():CloseUiForms("waiting_ui")
            local t = msgTab.game_list
            self.roundNum.text = msgTab.total_num.."局"
            self.scoreNum.text = msgTab.total_score.."分"
            if t == nil then
              t = {}
            end
        self.record_data = t
        self.record_go:SetActive(true)
        self.openRoom_go:SetActive(false)
        self.record_view:Initdate(self.record_data)
        self.isSellectRecord = not self.isSellectRecord
    end, nil)

    http_request_interface.getRoomSimpleList(nil,99,0,function (str)
          local s=string.gsub(str,"\\/","/")  
          local t=ParseJsonStr(s)   
          if t.data == nil then
          return
        end
            self.openRoom_data = t.data
      end) 

end

function record_ui:PlayOpenAmination()
end

function record_ui:close()
  self.record_view.record_wrap = nil
  self.openRoom_view.openRoom_wrap = nil
  ui_sound_mgr.PlayCloseClick()
  UI_Manager:Instance():CloseUiForms("record_ui")
end

function record_ui:OnClose()
  self.record_view:OnClose()
end

function record_ui:FindChild()
    self.btn_close=child(self.transform,"backBtn")
    if self.btn_close~=nil then
        addClickCallbackSelf(self.btn_close.gameObject,self.close,self)
    end 

    self.record_toggle = subComponentGet(self.transform,"toggle/record_toggle",typeof(UIToggle))
    addClickCallbackSelf(self.record_toggle.gameObject,self.OnRecordToggleClick,self)
    self.openRoom_toggle = subComponentGet(self.transform,"toggle/openRoom_toggle",typeof(UIToggle))
    addClickCallbackSelf(self.openRoom_toggle.gameObject,self.OnOpenRoomToggleClick,self)

    -- 初始化 子界面
    self.record_go = child(self.transform,"record").gameObject
    self.record_Top = child(self.transform,"record/Top").gameObject ------------
    self.roundNum = subComponentGet(self.transform,"record/Top/Round/roundNum",typeof(UILabel))
    self.scoreNum = subComponentGet(self.transform,"record/Top/Score/scoreNum",typeof(UILabel))
    self.record_view = record_view:create(self.record_go)
    self.record_view:InitRecord()

    self.openRoom_go = child(self.transform,"openRoom").gameObject
    self.openRoom_view = openRoom_view:create(self.openRoom_go)
    self.openRoom_view:InitOpenRoom()
end



--[[--
 * @Description: 战绩纪录点击  
 ]]
function record_ui:OnRecordToggleClick()
    ui_sound_mgr.PlayButtonClick()

    if self.record_view.record_data == nil then
        self.record_view.record_data = self.record_data
    end
    self.record_go:SetActive(true)
    self.openRoom_go:SetActive(false)
    self.record_view:Initdate(self.record_view.record_data)
    self.isSellectRecord = not self.isSellectRecord
end

--[[--
 * @Description: 开房记录点击  
 ]]
function record_ui:OnOpenRoomToggleClick()
    self.record_view:Clear()
    self.record_view:Updateheight()
    ui_sound_mgr.PlayButtonClick()
    if not self.isSellectRecord or self.openRoom_data == nil then
        return
    end
    self.openRoom_go:SetActive(true)
    self.record_go:SetActive(false)
    self.openRoom_view:Show(self.openRoom_data)

    self.isSellectRecord = not self.isSellectRecord
end




return record_ui