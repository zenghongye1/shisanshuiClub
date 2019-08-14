local base = require "logic/framework/ui/uibase/ui_view_base"
local openRoom_view_item = class("openRoom_view_item",base)

function openRoom_view_item:InitView()
    self.lab_date_lb = subComponentGet(self.transform, "time","UILabel") --日期
    self.lab_type_lb = subComponentGet(self.transform, "name","UILabel") --类型
    self.lab_rno_lb = subComponentGet(self.transform, "number","UILabel") --类型
    self.ready_status = self:GetGameObject("ready")--未开局
    self.end_status = self:GetGameObject("end")--已结算
    self.start_status = self:GetGameObject("start")--已开局
    self.disabled_status = self:GetGameObject("disabled")--已失效
    self.btnEnable = self:GetGameObject("btnEnable")
    self.btnDisable = self:GetGameObject("btnDisable")
end

function openRoom_view_item:UpdateRecord(realindex,wraprecord)
	self.gameObject.name = realindex

    self.lab_date_lb.text ="".. os.date("%Y.%m.%d  %H:%M:%S",wraprecord.ctime)
    self.lab_type_lb.text=""..GameUtil.GetGameName(tonumber(wraprecord.gid))
    self.lab_rno_lb.text=""..wraprecord.rno

    self.ready_status:SetActive(false)
    self.end_status:SetActive(false)
    self.start_status:SetActive(false)
    self.disabled_status:SetActive(false)

    self.btnEnable:SetActive(false)
    self.btnDisable:SetActive(false)

    local status = wraprecord.status
    if status==nil then
        return
    end
    -- "status":状态0已开房1已开局2已结算3已失效
    if status == 0 then
        self.ready_status:SetActive(true)
        self.btnEnable:SetActive(true)
    elseif status == 1 then
        self.start_status:SetActive(true)
        self.btnDisable:SetActive(true)
    elseif status == 2 then
        self.end_status:SetActive(true)
        self.btnDisable:SetActive(true)
    elseif status == 3 then
        self.disabled_status:SetActive(true)
        self.btnDisable:SetActive(true)
    end   

end

return openRoom_view_item