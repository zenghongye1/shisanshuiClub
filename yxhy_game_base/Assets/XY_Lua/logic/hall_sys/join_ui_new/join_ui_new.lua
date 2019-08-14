--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local base = require("logic.framework.ui.uibase.ui_window")
local join_ui_new = class("join_ui_new",base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local curClubNoselectColor = Color.New(143/255, 74/255, 18/255)
local curClubSelectColor = Color.New(34/255, 46/255, 106/255)

 local UILabelFormat = UILabelFormat


local iconSp = {
	[1] = "icon_27",
	[2] = "icon_28",
	[3] = "icon_29",
}


--[[
加入俱乐部相关
]]

local clubStateBtn_join="已加入"
local clubStateBtn_nojoin="申请加入"
function join_ui_new:ctor()
	base.ctor(self)	
    
   
end

function join_ui_new:OnInit()
	base.OnInit(self)

end	

function join_ui_new:OnOpen() 
    base.OnOpen(self)	
    self.itemList={}
    self.page=1
    self.size=20
    self.btn_apply=nil
    self.SelecIndex=nil
    self.re=nil
    self.selectItem=nil
    self.CurrentClubID=nil 
    self.clubInfo=nil
    self.clubState = nil
    self.detailpanel={}
    self.model = model_manager:GetModel("ClubModel")
    self.wrap = ui_wrap:create(self:GetGameObject("panel/left/container"))
	self.wrap:InitUI(106)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)  self:OnItemUpdate(go, index, rindex)  end
	self.wrap:InitWrap(0)
    self.wrap.OnUpdateToEnd=function () self:WrapToEnd() end
    self:InitItemList()
	self:InitView()
    self:InitCommonInput() 
	self:UpdateView() 
    self:SearchClubList()

end

function join_ui_new:SearchClubList()
	self.model:ReqSearchOClubList(self.page,self.size,function(msg) 
        self.clubList= msg.clublist 
        self.page=self.page+1
	    self:CallUpdateView()
        --self:WrapToEnd()  
    end)
end
 
function join_ui_new:InitItemList()
	for i = 1, 7 do
		local go = self:GetGameObject("panel/left/container/scrollview/ui_wrapcontent/" .. i) 
		go:SetActive(false)
        if self.re==nil then 
            local e=child(go.transform,"return")
            if e~=nil then
                self.re=e
            end
        end 
        go.selfTable={}
        local name=subComponentGet(go.transform,"name","UILabel")
        local num=subComponentGet(go.transform,"num","UILabel")
        local game=subComponentGet(go.transform,"game","UILabel") 
		local headIcon = subComponentGet(go.transform,"headIcon","UISprite")
        local sp=componentGet(go,"UISprite")
        local join=child(go.transform,"join").gameObject
        go.selfTable.name=name
        go.selfTable.num=num
        go.selfTable.game=game
		go.selfTable.headIcon = headIcon
        go.selfTable.sp=sp 
        go.selfTable.join=join 
        self.itemList[i]=go
	end
end  
function join_ui_new:UpdateView()
	local count = 0
	--self.tipsGo:SetActive(self.clubList == nil or #self.clubList == 0)
	if self.clubList ~= nil then
		count = #self.clubList
	end
	self.wrap:InitWrap(count)
end
function join_ui_new:WrapToEnd()
    self.model:ReqSearchOClubList(self.page,self.size,function(msg) 
        if msg.clubList and  #msg.clublist>0 then
             for i=1,#msg.clublist do 
                 table.insert(self.clubList,msg.clublist[i])
             end    
             --self:UpdateView()  
             self.wrap.wrap.minIndex = -#self.clubList+1
             self.wrap.maxCount=#self.clubList
             self.page=self.page+1
         end  
        local t={}
        for i=1,30 do
            table.insert(t,self.clubList[i])
        end 
        --(json.encode(t)) 
     end)

end

function join_ui_new:PlayOpenAmination()

end

function join_ui_new:OnRefreshDepth()
  local uiEffect = child(self.gameObject.transform, "bg/top/title/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

function join_ui_new:InitView()
    local btn_close = child(self.gameObject.transform,"backBtn")
    if btn_close ~= nil then
        addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
    end
    self.club_detail=child(self.gameObject.transform,"panel/right/club_detail")
    self.club_detail.gameObject:SetActive(false)
    self.join_ui=child(self.gameObject.transform,"panel/right/join_ui")
    self.join_ui.gameObject:SetActive(true)
    self.grid_number = child(self.gameObject.transform,"panel/right/join_ui/key/gird_number")
    self.grid_input = child(self.gameObject.transform,"panel/right/join_ui/key/grid_input")
    self.btn_apply=child(self.gameObject.transform,"panel/right/club_detail/apply")
    if self.btn_apply ~= nil then
        addClickCallbackSelf(self.btn_apply.gameObject,self.ApplyClub,self)
    end 
    local close=child(self.club_detail.transform,"close")
    if close~=nil then
        addClickCallbackSelf(close.gameObject,self.CloseDetail,self)
    end
    if self.re==nil then 
        self.re=child(self.club_detail.transform,"return")
    end 
    self.detailpanel.club_name=subComponentGet(self.club_detail,"title/club_name","UILabel") 
    self.detailpanel.club_id=subComponentGet(self.club_detail,"title/club_id","UILabel")
    self.detailpanel.club_level=subComponentGet(self.club_detail,"title/club_level","UILabel")
    self.detailpanel.club_num=subComponentGet(self.club_detail,"title/club_num","UILabel")
    self.detailpanel.name=subComponentGet(self.club_detail,"detail/name","UILabel")
    self.detailpanel.phone=subComponentGet(self.club_detail,"detail/phone","UILabel")
    self.detailpanel.game=subComponentGet(self.club_detail,"detail/type","UILabel")
    self.detailpanel.des=subComponentGet(self.club_detail,"detail/des","UILabel")
    self.detailpanel.icon = subComponentGet(self.club_detail, "title/Sprite", "UISprite")
end
 
function join_ui_new:CloseDetail()
    self.club_detail.gameObject:SetActive(false)
    self.join_ui.gameObject:SetActive(true)
    self:SetSelectState(self.selectItem,false)
    self.re.gameObject:SetActive(false)

end
function join_ui_new:InitCommonInput()
	self.input_ui = require "logic/hall_sys/CommonInput/CommonInput":create(self.grid_input,self.grid_number,slot(self.RequestGetInRoom, self))
	self.input_ui:InitView()
end

function join_ui_new:OnItemUpdate(go, index, rindex)  
	if self.itemList[index] ~= nil then  
	    local item=	self.itemList[index] 
        item:SetActive(true)
        local data=self.clubList[rindex]  
        local clubState = self.model:GetClubState(data.cid)
        if clubState~= ClubMemberState.none then
            item.selfTable.join:SetActive(true)
        else
            item.selfTable.join:SetActive(false)
        end
        self:SetSelectState(item,false)
        addClickCallbackSelf(item,function() self:OnItemClick(item,rindex)end,item)  
        item.selfTable.name.text=data.cname
        item.selfTable.num.text=(data.clubusernum or 0) .."/".. (data.maxusernum or 0)
        item.selfTable.game.text=ClubUtil.GetGameContent(data.gids, "/")
		item.selfTable.headIcon.spriteName = iconSp[data.icon] or iconSp[1]
        local re=child(go.transform,"return")
        if self.SelecIndex~=rindex then 
            if re~=nil then 
                re.gameObject:SetActive(false)
            end 
        else
            self:SetSelectState(item,true)
            if re~=nil then 
                re.gameObject:SetActive(true)
            end 
        end
        
	end
end

function join_ui_new:ApplyClub()  
    ui_sound_mgr.PlayButtonClick()

	-- if self.clubState == ClubMemberState.none then
	-- 	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10044, self.clubInfo.nickname, self.clubInfo.cname), 
	-- 		function()
	-- 			self.model:ReqApplyClub(self.CurrentClubID)
	-- 		end)
	-- else
	-- 	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10044, self.clubInfo.nickname, self.clubInfo.cname), function () 
 --        self.model:ReqApplyClub(self.CurrentClubID)
	-- 		--self.model:ReqQuitClub(self.clubInfo.cid)
	-- 		--UIManager:CloseUiForms("ClubInfoUI")
	-- 	end)
	-- end 

    --TER0327-label
    local content = LanguageMgr.GetWord(10044, self.clubInfo.nickname, self.clubInfo.cname)
    local msgBox = MessageBox.ShowYesNoBox(content, function()
        self.model:ReqApplyClub(self.CurrentClubID)
    end)
    if msgBox and msgBox.EnableContentBBCode then
        msgBox:EnableContentBBCode()
    end
end

function join_ui_new:OnItemClick(obj1,index)  
    self:SetSelectState(self.selectItem,false)
    self.selectItem=obj1
    if self.re~=nil then
        self.re.gameObject:SetActive(true)
        self.re.transform.parent=obj1.transform
        self.re.transform.localPosition={x=328,y=0,z=0}
    end
    self.join_ui.gameObject:SetActive(false)
    self.club_detail.gameObject:SetActive(true)
    self:SetSelectState(obj1,true)
    self.SelecIndex=index
    self:InitDetailView(self.clubList[index])
end

function join_ui_new:InitDetailView(data) 
    
    self.detailpanel.club_name.text=data.cname
    self.detailpanel.club_id.text=data.shid
    self.CurrentClubID=data.shid
    self.clubInfo=data
    self.clubState = self.model:GetClubState(data.cid)
    local clubStatebtn=subComponentGet(self.btn_apply,"Label","UILabel")
    local btn=componentGet(self.btn_apply.gameObject,"UIButton")
    if self.clubState == ClubMemberState.none then  
        clubStatebtn.text=clubStateBtn_nojoin
        -- clubStatebtn.effectColor=Color.New(107/255,38/255,1/255)
        -- clubStatebtn.color=Color.New(254/255,234/255,200/255)
        clubStatebtn:SetLabelFormat(UILabelFormat.F53)
        btn.isEnabled=true
	elseif self.clubState then 
        clubStatebtn.text=clubStateBtn_join
        clubStatebtn:SetLabelFormat(UILabelFormat.F51)
        btn.isEnabled=false
	end 
    self.detailpanel.club_level.text=data.level
    self.detailpanel.club_num.text=(data.clubusernum or 0).."/"..(data.maxusernum or 0)
    self.detailpanel.name.text=data.nickname
    self.detailpanel.phone.text=data.club_phone
    self.detailpanel.game.text=ClubUtil.GetGameContent(data.gids, "/")
    self.detailpanel.des.text=data.content
    self.detailpanel.icon.spriteName = ClubUtil.GetClubIconName(data.icon)
    

end

function join_ui_new:SetSelectState(item,boo) 
    if item==nil then
        return
    end
    local format
    if boo then
        item.selfTable.name:SetLabelFormat(UILabelFormat.F4)
        item.selfTable.num:SetLabelFormat(UILabelFormat.F4)
        item.selfTable.game:SetLabelFormat(UILabelFormat.F18)
        item.selfTable.sp.spriteName="common_04"
    else
        item.selfTable.name:SetLabelFormat(UILabelFormat.F8)
        item.selfTable.num:SetLabelFormat(UILabelFormat.F8)
        item.selfTable.game:SetLabelFormat(UILabelFormat.F19)
        item.selfTable.sp.spriteName="common_82"
    end
end

function join_ui_new:CallUpdateView()
	local time = FrameTimer.New(
		function() 
			self:UpdateView() 
		end,1,1)
	time:Start()
end


function join_ui_new:RequestGetInRoom()
	local numList = self.input_ui:GetNumList()
	if #numList == 6 then
		local rno = table.concat(numList)
		self.model:ReqApplyClub(rno)
		self.input_ui:ClearNumList()
    else
        UIManager:FastTip(LanguageMgr.GetWord(10041))
	end
end 
function  join_ui_new:CloseWin()
    ui_sound_mgr.PlayCloseClick()   
	UI_Manager:Instance():CloseUiForms("join_ui_new",true)
end 
return join_ui_new