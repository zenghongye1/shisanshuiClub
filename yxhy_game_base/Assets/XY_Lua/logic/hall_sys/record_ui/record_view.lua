local record_view_item = require "logic/hall_sys/record_ui/record_view_item"
local base = require "logic/framework/ui/uibase/ui_view_base"
local record_view = class("record_view", base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local dateItem = "logic/hall_sys/record_ui/item/dateItem"
local clubModel = model_manager:GetModel("ClubModel")
local timeList = 
{
    [1] = {"今天",os.date("%Y-%m-%d",os.time())}, -- 今天
    [2] = {"昨天",os.date("%Y-%m-%d",os.time() - 24*3600)}, --昨天
    [3] = {"7天",os.date("%Y-%m-%d",os.time() - 7*24*3600)}, --7天
    [4] = {"30天",os.date("%Y-%m-%d",os.time() - 30*24*3600)}    --30天
}
local param = {}
local itemHeight = 70
function record_view:InitView()
	self.initItemCount = 7

    
    self.record_wrapcontent_tr = child(self.transform,"scrollview/ui_wrapcontent")
    self.record_item_tr = child(self.transform,"record_item")
    self.model = model_manager:GetModel("ClubModel")
    --新加选择功能
    self.Grid = subComponentGet(self.transform,"Top/Grid","UIGrid")
    self.scrollview_c = subComponentGet(self.transform,"Top/Club/clubchoose/Scroll View","UIScrollView")
    self.scrollview_g = subComponentGet(self.transform,"Top/Game/gamechoose/Scroll View","UIScrollView")
    self.scroll_Gird_c = subComponentGet(self.transform,"Top/Club/clubchoose/Scroll View/Grid","UIGrid")
    self.scroll_Gird_g = subComponentGet(self.transform,"Top/Game/gamechoose/Scroll View/Grid","UIGrid")
    --self.scrollview = child(self.transform,"Top/Grid/Scroll View")
    self.dateChoose =subComponentGet(self.transform,"Top/Date/datechoose","UISprite") --日期选择
    self.datelabel =subComponentGet(self.transform,"Top/Date/datechoose/Label","UILabel")
    addClickCallbackSelf(self.dateChoose.gameObject,self.OnDateClick,self)
    self.clubChoose = subComponentGet(self.transform,"Top/Club/clubchoose","UISprite")--俱乐部选择
    self.clublabel =subComponentGet(self.transform,"Top/Club/clubchoose/Label","UILabel")
    addClickCallbackSelf(self.clubChoose.gameObject,self.OnClubClick,self)
    self.gameChoose = subComponentGet(self.transform,"Top/Game/gamechoose","UISprite")--游戏选择
    self.gamelabel =subComponentGet(self.transform,"Top/Game/gamechoose/Label","UILabel")
    addClickCallbackSelf(self.gameChoose.gameObject,self.OnGameClick,self)
    self.roundnum =subComponentGet(self.transform,"Top/Round/roundNum","UILabel") --牌局数
    self.scorenum = subComponentGet(self.transform,"Top/Score/scoreNum","UILabel") --分数
    self.item = subComponentGet(self.transform,"Top/Item","UILabel")
    self.item.gameObject:SetActive(false)
    self.tips_go = child(self.transform,"tips").gameObject
    self.itemList = {}

    child(self.dateChoose.transform,"light").gameObject:SetActive(false)
    child(self.clubChoose.transform,"light").gameObject:SetActive(false)
    child(self.gameChoose.transform,"light").gameObject:SetActive(false)
end

--[[--
 * @Description: 初始化刷新事件和item  
 ]]
function record_view:InitRecord()
    for i=1,self.initItemCount do
        local go = newobject(self.record_item_tr.gameObject)
        go.transform:SetParent(self.record_wrapcontent_tr,false)
        local item = record_view_item:create(go)
        item:SetActive(true)
        addClickCallbackSelf(item.gameObject,self.opendetails,self)
        table.insert(self.itemList,item)
    end
end

--[[--
 * @Description: 显示  
 ]]
function record_view:Initdate(record_data)
    self.record_wrap = ui_wrap:create(self.gameObject)
    self.record_wrap.OnUpdateItemInfo=function (go,realindex,index)
        self:UpdateRecord(go,realindex,index)
    end 
    self.record_wrap:InitUI(110)
    self.record_wrap.OnUpdateToEnd=function ()
        self:OnUpdateToEnd()
    end
	self.record_wrap:Initdate(record_data)
    if #record_data > 0 then
        self.tips_go:SetActive(false)
    else
        self.tips_go:SetActive(true)
    end
end
    
--[[--
 * @Description: item刷新  
 ]]
function record_view:UpdateRecord(go,realindex,index) 
    if self.record_wrap.wraprecord[realindex] == nil then
        return
    end

    local item = self.itemList[index]
    if item then
        item:UpdateRecord(realindex,self.record_wrap.wraprecord[realindex])
    end
end

--[[--
 * @Description: 战绩详情点击事件  
 ]]
function record_view:opendetails(obj1)
    ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
	report_sys.EventUpload(14)
    if self.record_wrap.wraprecord[tonumber(obj1.name)] == nil then
        return
    end
    local rid=self.record_wrap.wraprecord[tonumber(obj1.name)].rid   
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

function record_view:OnClose()
    self.time = nil
    self.cid = nil 
    self.gid = nil
    self.record_data = {}
    self.datelabel.text = "今天"
    self.clublabel.text = "全部"
    self.gamelabel.text = "全部"
    self.dateChoose.height = 50
    self.clubChoose.height = 50
    self.gameChoose.height = 50
    self:Clear()

end

function record_view:Updateheight()
    self.dateChoose.height = 50
    self.clubChoose.height = 50
    self.gameChoose.height = 50
end

--[[--
 * @Description: 底部刷新  
 ]]
function record_view:OnUpdateToEnd()
    local param = {}
    param.time = self.time
    param.cid = self.cid
    param.gid = self.gid
    param.page = self.record_wrap.page + 1
    HttpProxy.SendRoomRequest(HttpCmdName.GetRoomRecordList,param,
    function (msgTab,str)
      if self.record_wrap then
            local t= msgTab.game_list
            local count=table.getCount(self.record_wrap.wraprecord)
            if table.getCount(t)<=0 then
                return
            end
            for i=1,table.getCount(t) do
                self.record_wrap.wraprecord[i+count]=t[i]
            end
            self.record_wrap.page=self.record_wrap.page+1
            self.record_wrap.maxCount=table.getCount(self.record_wrap.wraprecord)
            self.record_wrap.wrap.minIndex = -self.record_wrap.maxCount+1 
        end
    end,nil)
end

function record_view:HideItem()
    self.record_data = {}
    if self.record_wrapcontent_tr then
        if self.record_wrapcontent_tr.transform.childCount == 0 then
            return
        end
        for i = 0,self.record_wrapcontent_tr.transform.childCount - 1 do
            self.record_wrapcontent_tr.transform:GetChild(i).gameObject:SetActive(false)
        end
    end
end

--清除Grid下的子物体
function record_view:Clear()
    if self.scroll_Gird_c then
      for i = (self.scroll_Gird_c.transform.childCount -1),0,-1 do
          GameObject.DestroyImmediate(self.scroll_Gird_c.transform:GetChild(i).gameObject)
      end
    end
    self.scrollview_c.transform.gameObject:SetActive(false)
    if self.scroll_Gird_g then
      for i = (self.scroll_Gird_g.transform.childCount -1),0,-1 do
          GameObject.DestroyImmediate(self.scroll_Gird_g.transform:GetChild(i).gameObject)
      end
    end
    self.scrollview_g.transform.gameObject:SetActive(false)
    for i=(self.Grid.transform.childCount - 1),0,-1 do
        GameObject.DestroyImmediate(self.Grid.transform:GetChild(i).gameObject)
    end
    self.Grid.transform.gameObject:SetActive(false)
end
--[[--
 * @Description: 选择功能  
 ]]
function record_view:OnDateClick()
    self:Clear()
    self.gameChoose.height = 50
    self.clubChoose.height = 50
    child(self.dateChoose.transform,"light").gameObject:SetActive(true)
    self.Grid.transform.gameObject:SetActive(true)
    self.Grid.transform.localPosition = Vector3(-475,162,0)
    local height = 50
    if self.dateChoose.height > 51 then
        self.dateChoose.height = 50
        child(self.dateChoose.transform,"light").gameObject:SetActive(false)
        return
    end
    local length = #timeList
    if length >= 4 then
        length = 4 
    end
    self.dateChoose.height = height + length*itemHeight
    
    --请求数据
    for i=1, #timeList do
        local Obj = GameObject.Instantiate(self.item.gameObject)
        Obj.transform:SetParent(self.Grid.transform,false)
        Obj.transform.localPosition = Vector3(0,0,0)
        Obj.transform.localScale = Vector3(1,1,1)
        Obj.transform.name = i
        local objLabel = componentGet(Obj.gameObject,"UILabel")
        local objLine = componentGet(child(Obj.transform,"Sprite"),"UISprite")
        objLine.width = 100
        objLabel.text = timeList[i][1]
        Obj.transform.gameObject:SetActive(true)
        addClickCallbackSelf(Obj.transform.gameObject,self.OnChooseDate,self)
    end
    componentGet(self.Grid,"UIGrid").enabled = true

end

function record_view:OnClubClick()
    self:Clear()
    self.dateChoose.height = 50
    self.gameChoose.height = 50 
    child(self.clubChoose.transform,"light").gameObject:SetActive(true)
    self.scrollview_c.transform.gameObject:SetActive(true)
    local height = 50
    if self.clubChoose.height ~= 50 then
        self.clubChoose.height = 50 
        child(self.clubChoose.transform,"light").gameObject:SetActive(false)
        return
    end
    local length = #self.model.unofficalClubList + 1
    if length >= 6 then
        length = 6 
    end
    self.clubChoose.height = height + length*itemHeight
    --logError(#self.model.unofficalClubList,json.encode(self.model.unofficalClubList))
    for i=1, #self.model.unofficalClubList + 1 do
        local Obj = GameObject.Instantiate(self.item.gameObject)
        Obj.transform:SetParent(self.scroll_Gird_c.transform,false)
        Obj.transform.localPosition = Vector3(0,0,0)
        Obj.transform.localScale = Vector3(1,1,1)
        Obj.transform.name = i
        local objLabel = componentGet(Obj.gameObject,"UILabel")
        local objLine = componentGet(child(Obj.transform,"Sprite"),"UISprite")
        objLine.width = 220

        if i == 1 then
            objLabel.text = "全部"
        else
            objLabel.text = self.model.unofficalClubList[ i - 1].cname
        end
        Obj.transform.gameObject:SetActive(true)
        addClickCallbackSelf(Obj.transform.gameObject,self.OnChooseClub,self)
    end
    componentGet(self.scroll_Gird_c,"UIGrid").enabled = true
end

function record_view:OnGameClick()
    if self.cid == nil then
        return 
    end
    child(self.gameChoose.transform,"light").gameObject:SetActive(true)
    self:Clear()
    self.clubChoose.height = 50
    self.dateChoose.height = 50
    self.scrollview_g.transform.gameObject:SetActive(true)
    local height = 50
    if self.gameChoose.height ~= 50 then 
        self.gameChoose.height = 50
        child(self.gameChoose.transform,"light").gameObject:SetActive(false)
        return
    end
    local length = #self.model.clubMap[self.cid].gids + 1
    if length >= 6 then
        length = 6 
    end
    self.gameChoose.height = height + length*itemHeight

    for i=1, #self.model.clubMap[self.cid].gids + 1 do
        local Obj = GameObject.Instantiate(self.item.gameObject)
        Obj.transform:SetParent(self.scroll_Gird_g.transform,false)
        Obj.transform.localPosition = Vector3(0,0,0)
        Obj.transform.localScale = Vector3(1,1,1)
        Obj.transform.name = i
        local objLabel = componentGet(Obj.gameObject,"UILabel")
        local objLine = componentGet(child(Obj.transform,"Sprite"),"UISprite")
        objLine.width = 220
        
        if i == 1 then
            objLabel.text = "全部"
        else
            objLabel.text =GameUtil.GetGameName(self.model.clubMap[self.cid].gids[i - 1]) 
        end
        Obj.transform.gameObject:SetActive(true)
        addClickCallbackSelf(Obj.transform.gameObject,self.OnChooseGame,self)
    end
    componentGet(self.scroll_Gird_g,"UIGrid").enabled = true
end
--[[--
 * @Description: 选择功能  
 ]]
 function record_view:OnChooseDate(Obj)

    self.dateChoose.height = 50

    self.time = timeList[tonumber(Obj.gameObject.name)][2]
    param.cid = self.cid
    param.gid = self.gid
    param.time = self.time
    param.page = 1
    self.datelabel.text = timeList[tonumber(Obj.gameObject.name)][1]
    model_manager:GetModel("ClubModel"):GetRoomRecordList(param,function(msgTab)
        self:SetInfo(msgTab)      
    end)
    self:Clear()
 end
 function record_view:OnChooseClub(Obj)
    self.gamelabel.text = "全部"
    self.clubChoose.height = 50
    if tonumber(Obj.gameObject.name) ==  1 then
       self.clublabel.text = "全部"
       self.cid = nil
       self.gid = nil
    else
        self.cid = self.model.unofficalClubList[tonumber(Obj.gameObject.name) - 1].cid
        self.clublabel.text = self.model.unofficalClubList[tonumber(Obj.gameObject.name) - 1].cname
    end    
    param.cid = self.cid
    param.gid = self.gid
    param.time = self.time
    param.page = 1
    
    model_manager:GetModel("ClubModel"):GetRoomRecordList(param,function(msgTab)
        self:SetInfo(msgTab)       
    end)
    self:Clear()
 end
 function record_view:OnChooseGame(Obj)
    self.gameChoose.height = 50
    if tonumber(Obj.gameObject.name) == 1 then
        self.gamelabel.text = "全部"
        self.gid = nil
    else
        self.gid =self.model.clubMap[self.cid].gids[tonumber(Obj.gameObject.name) - 1]
        self.gamelabel.text = GameUtil.GetGameName(self.gid)
    end
    param.cid = self.cid
    param.gid = self.gid
    param.time = self.time
    param.page = 1
    model_manager:GetModel("ClubModel"):GetRoomRecordList(param,function(msgTab) 
        self:SetInfo(msgTab)       
    end)
    self:Clear()
 end

 function record_view:SetInfo(msgTab)
    self:HideItem()
    if msgTab.game_list == nil then
        self.record_data = {}
        return
    end
    self.roundnum.text = msgTab.total_num.."局"
    self.scorenum.text = msgTab.total_score.."分"
    self.record_data = msgTab.game_list
    self:Initdate(self.record_data)
 end

return record_view