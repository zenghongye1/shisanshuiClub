local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjTable = class("comp_mjTable", mode_comp_base)
local mahjong_path_mgr = mahjong_path_mgr

function comp_mjTable:ctor()
	self.name = "comp_mjTable"
	self.config = nil

   	self.config = nil

    self.compMjItemMgr = nil -- 麻将子管理组件
    self.compPlayerMgr = nil -- 玩家管理组件
    self.tableObj = nil -- 桌子对象
    self.tableModelObj = nil -- 桌子模型对象

    --local diceObj1 = nil -- 骰子1对象
    --local diceObj2 = nil -- 骰子2对象

    self.mjSelectObj = nil -- 麻将选择效果对象
    self.mjDirObj = nil -- 牌桌东南西北对象

    self.timeLeft_trans = {} --倒计时十位列表
    self.timeRight_trans = {} --倒计时个位列表

    self.threeDCenterRoot = nil
    self.twoDCeneterRoot = nil

    self.mjWallPoints = {}

    --- coroutines    @todo  统一管理
    self.Wall_C_List = {}
    self.SendAllHandCard_c = nil
    self.InitShowLai_c = nil



    ---- 计时相关 ----
    self.time_timer = nil --倒计时 计时器
    self.time_isAlarm = false
    self.time_alarmTime = 0
    self.time_count = 0 --倒计时 次数
    self.time_callback = nil -- 回调
end


function comp_mjTable:Initialize()
	--self.class.super.Initialize(self)
	mode_comp_base.Initialize(self)
    self.compMjItemMgr = self.mode:GetComponent("comp_mjItemMgr")
    self.compPlayerMgr = self.mode:GetComponent("comp_playerMgr")
    self.config = self.mode.config

    Trace("----------------------enter comp_mjTable")
    self:InitTable()
    self:GetWallPoints() 
end

--[[--
 * @Description: 初始化牌桌对象  
 ]]
function comp_mjTable:InitTable()
	local resTableObj = newNormalObjSync(mahjong_path_mgr.GetMjPath("mjtable"), typeof(GameObject))	
	self.tableObj = newobject(resTableObj)

    self.tableModelObj = child(self.tableObj.transform, "majiangzhuo").gameObject
    self:ChangeDeskCloth()

    local mjSelect = newNormalObjSync(mahjong_path_mgr.GetMjPath("mj_select"), typeof(GameObject))
    self.mjSelectObj = newobject(mjSelect)

    self.mjDirObj = child(self.tableObj.transform, "direction")

    self.threeDCenterRoot = child(self.tableObj.transform, "3DCenterPoint")
    self.twoDCenterRoot = child(self.tableObj.transform, "2DCenterPoint")

    local timeleft = child(self.mjDirObj, "time/left")
    local timeright = child(self.mjDirObj, "time/right")
    for i=0,9 do
        local numl = child(timeleft,tostring(i))
        table.insert(self.timeLeft_trans,numl)
        local numr = child(timeright,tostring(i))
        table.insert(self.timeRight_trans,numr)
    end
end

function comp_mjTable:GetWallPoints()
    local mjWall = self.tableObj.transform:FindChild("MJWall")
    for i=1,4,1 do
        self.mjWallPoints[i] = mjWall:FindChild(i):FindChild("WallPoint")
    end
end

    --[[--
 * @Description: 初始化麻将墙  
 ]]
function comp_mjTable:InitWall()
    local x,y,z,index = 0,0,0,1
    for i=1,self.config.MahjongDunCount,1 do
        x= (i-1)*mahjongConst.MahjongOffset_x
        for j=1,2,1 do
            y = (j-1)*mahjongConst.MahjongOffset_y
            for k=1,4,1 do
                local mj = self.compMjItemMgr.mjItemList[(k-1) * self.config.MahjongDunCount * 2 + index]
                mj:HideAndReset()
                mj:SetParent(self.mjWallPoints[k], false)
                mj.transform.localPosition = Vector3(x, y, 0)
            end
            index = index + 1
        end
    end
end

function comp_mjTable:GetMJDirObj()
    return self.mjDirObj
end

function comp_mjTable:ShowWall(cb)
    local InitWall_c = coroutine.start(function ()     

        local x,y,z,index = 0,0,0,1
        for i=1,self.config.MahjongDunCount,1 do
            x= (i-1)*mahjongConst.MahjongOffset_x
            for j=1,2,1 do
                y = (j-1)*mahjongConst.MahjongOffset_y
                for k=1,4,1 do
                    local mj = self.compMjItemMgr.mjItemList[(k-1) * self.config.MahjongDunCount * 2 + index]
                    mj:SetParent(self.mjWallPoints[k], true)
                    mj.transform.localPosition = Vector3(x, y, 0)
                    mj:Show(false)
                    mj:SetState(MahjongItemState.inWall)
                end
                index = index + 1
            end
            ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_showwall", true))
            if i~=self.config.MahjongDunCount then
                coroutine.wait(0.07)--0.133牌墙显示音效长度
            end
        end
        if cb~=nil then
            cb()
        end
    end)
    table.insert(self.Wall_C_List, InitWall_c)
end

 --[[--
 * @Description: 发手牌  
 * @param:       dun        牌墩，从视图玩家1左边开始数，墩数从1开始 
 * @param:       viewSeat   取哪个视图玩家前面的牌墙
 * @param        cards      玩家手牌数据
 * @return:      nil
 ]]
function comp_mjTable:SendAllHandCard(dun,viewSeat,cards,cb)
    self.SendAllHandCard_c = coroutine.start(function ()            
        self.sendIndex = dun * 2 + (viewSeat-1) * 34 --发牌位置
        self.lastIndex = self.sendIndex + 2
        local cardsIndex = 1
        local zhunagOffset =  roomdata_center.zhuang_viewSeat - 1
        local waitTime = 0.1

        --4圈牌
        for i = 1,4,1 do
            --人数
            for j = 1,roomdata_center.MaxPlayer(),1 do
                local num = 4
                if (i == 4) then
                    if (1 == j) then
                        num = 2
                    else
                        num = 1
                    end
                end
                --牌数
                for k = 1,num,1 do
                    if (self.sendIndex <= 0) then
                        self.sendIndex = 136
                    end

                    local mj = self:GetMJItem(self.sendIndex)                       
                    if i==4 and j==1 and k==1 then                            
                        self.sendIndex = self.sendIndex - 4                   
                    elseif i==4 and j==1 and k==2 then
                        if zhunagOffset == 0 then
                            waitTime = 0.5
                        end
                        self.sendIndex = self.sendIndex + 3
                    elseif i==4 and j==4 then
                        self.sendIndex = self.sendIndex - 2
                    else
                        waitTime = 0.2
                        self.sendIndex = self.sendIndex - 1 
                    end                     

                    local playerVSeat = j + zhunagOffset
                    if playerVSeat > roomdata_center.MaxPlayer() then
                        playerVSeat = playerVSeat - roomdata_center.MaxPlayer()
                    end

                    local paiValue = MahjongTools.GetRandomCard()
                    if playerVSeat == 1 then
                        paiValue = cards[cardsIndex]
                        cardsIndex = cardsIndex + 1
                    end

                    if mj ~= nil then
                        mj:SetMesh(paiValue)
                        self.compPlayerMgr:GetPlayer(playerVSeat):AddDun(mj)
                    end
                end
                ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_deal_card", true))

                coroutine.wait(waitTime)
            end
        end

        for i=1,roomdata_center.MaxPlayer() do
            if i == 1 then
                self.compPlayerMgr:GetPlayer(i):ArrangeHandCard(cb)
            else
                self.compPlayerMgr:GetPlayer(i):ArrangeHandCard()
            end
        end

    end)
end

function comp_mjTable:ShowLai(dun, cardValue, isAnim,callback)
    Trace("ShowLai !!!!!!!!!!!!! dun "..dun.." cardValue "..cardValue)
    local laiIndex = self.lastIndex+(dun-1)*2
    if(laiIndex>self.config.MahjongTotalCount) then
        laiIndex = laiIndex - self.config.MahjongTotalCount
    end

    local tempIndex = self.lastIndex
    local tempMJ = nil

    self.InitShowLai_c = coroutine.start(function ()  
        if not IsNil(self.mjSelectObj) and isAnim then                 
            for i=1, dun do                                               
                tempMJ = self.compMjItemMgr.mjItemList[tempIndex]  
                if tempMJ ~= nil then
                    self.mjSelectObj.transform.position = tempMJ.transform.position
                    if i==1 then
                        self.mjSelectObj.transform.rotation = tempMJ.transform.rotation
                    end
                    coroutine.wait(0.2) 
                end
                tempIndex = tempIndex + 2
                if tempIndex > self.config.MahjongTotalCount then
                    tempIndex = tempIndex - self.config.MahjongTotalCount
                end
            end

            if not IsNil(self.mjSelectObj) then
                self.mjSelectObj.transform.position = Vector3.zero
            end

        end

        local mj = self.compMjItemMgr.mjItemList[laiIndex]
        mj:SetMesh(cardValue)
        mj:Show(true,isAnim)

        if callback~=nil then
            callback()
        end
    end)
    
end

--[[--
 * @Description: 摸牌  
 ]]
function comp_mjTable:SendCard( viewSeat,paiValue )
    local mj
    if (self.sendIndex == 0) then
        self.sendIndex = self.config.MahjongTotalCount
    end

    --TODO 需要处理取到已经被摸走的牌

    mj = self:GetMJItem(self.sendIndex)
    if mj.paiValue ~= nil or mj.mjObj.activeSelf == false then
        self.sendIndex = self.sendIndex - 1
        mj = self:GetMJItem(self.sendIndex, true)
    end
    -- logError("sendIndex", self.sendIndex)

    self.sendIndex = self.sendIndex -1
    mj:SetMesh(paiValue)
    self.compPlayerMgr:GetPlayer(viewSeat):AddHandCard(mj,false)
end

 --[[--
 * @Description: 得到一个牌子  
 ]]
function comp_mjTable:GetMJItem(index, notRefreshCardNum)
    local mj = self.compMjItemMgr.mjItemList[index]
    if not notRefreshCardNum then
        roomdata_center.leftCard = roomdata_center.leftCard -1
        mahjong_ui.SetLeftCard( roomdata_center.leftCard )
    end
    return mj
end

--[[--
 * @Description: 恢复完整牌墙  
 ]]
function comp_mjTable:ReShowWall()
    local x,y,z,index = 0,0,0,1
    for i=1,self.config.MahjongDunCount,1 do
        x= (i-1)*mahjongConst.MahjongOffset_x
        for j=1,2,1 do
            y = (j-1)*mahjongConst.MahjongOffset_y
            for k=1,4,1 do
                local mj = self.compMjItemMgr.mjItemList[(k-1) * self.config.MahjongDunCount * 2 + index]
                mj:SetParent(self.mjWallPoints[k], false)
                mj.transform.localPosition = Vector3(x, y, 0)
                mj:Show(false)
                mj:SetState(MahjongItemState.inWall)
            end
            index = index + 1
        end
    end
end

--[[--
 * @Description: 恢复牌墙  
 ]]
function comp_mjTable:ResetWall(dun,viewSeat)
    local x,y,z,index = 0,0,0,1
    for i=1,self.config.MahjongDunCount,1 do
        for j=1,2,1 do
            for k=1,4,1 do
                local mj = self.compMjItemMgr.mjItemList[(k-1) * self.config.MahjongDunCount * 2 + index]
                mj:Show(false)
                mj:SetState(MahjongItemState.inWall)
            end
            index = index + 1
        end
    end

    self.sendIndex = dun * 2 + (viewSeat-1) * self.config.MahjongDunCount * 2 --发牌位置
    self.lastIndex = self.sendIndex + 2

    Trace("-----------------ResetWall------------self.sendIndex "..tostring(self.sendIndex).." self.lastIndex "..tostring(self.lastIndex))
end

 --[[--
 * @Description: 得到一组牌子，重连用  
 ]]
function comp_mjTable:GetResetCards( count )
    local list = {}
    for i=1,count do
        if (self.sendIndex <= 0) then
            self.sendIndex = self.config.MahjongTotalCount
        end
        local mj = self:GetMJItem(self.sendIndex)
        table.insert(list,mj)
        self.sendIndex = self.sendIndex -1
    end
    return list
end


--local time_callback_leftTime = nil -- 在剩余多少时间时回调

--[[--
 * @Description: 设置定时器  
 ]]
function comp_mjTable:SetTime(time,isAlarm,alarmTime,fun,funLeftTime)
    if self.time_timer~=nil then
        self.time_timer:Stop()
        self.time_timer = nil
    end
    self.time_count = math.floor(time)

    self.time_isAlarm = isAlarm or false
    self.time_alarmTime = alarmTime or 0

    if fun~=nil then
        self.time_count = self.time_count - funLeftTime
        self.time_callback = fun
        --time_callback_leftTime = funLeftTime
    end

    self.time_timer = Timer.New(slot(self.UpdateTime, self), 1, self.time_count+1)
    self.time_timer:Start()  
end

  --[[--
 * @Description: 更新时间  
 ]]
function comp_mjTable:UpdateTime()
    if self.time_count <= 0 and self.time_callback~=nil then
        self.time_callback()
        self:StopTime(false)
    end

    if self.time_count >= 0 then
        if self.tiem_isAlarm and self.time_count < self.time_alarmTime then
            ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("timeup_alarm", true))
        end

        local leftNum = math.floor(self.time_count/10)
        local rightNum = self.time_count-leftNum*10
        for i,v in ipairs(self.timeLeft_trans) do
            v.gameObject:SetActive(false)
        end
        for i,v in ipairs(self.timeRight_trans) do
            v.gameObject:SetActive(false)
        end
        self.timeLeft_trans[leftNum+1].gameObject:SetActive(true)
        self.timeRight_trans[rightNum+1].gameObject:SetActive(true)
        self.time_count = self.time_count - 1
    end
end

 --[[--
 * @Description: 停止定时器  
 ]]
function comp_mjTable:StopTime(isHide)
    isHide = isHide or true
    if isHide then
        for i,v in ipairs(self.timeLeft_trans) do
            v.gameObject:SetActive(false)
        end
        for i,v in ipairs(self.timeRight_trans) do
            v.gameObject:SetActive(false)
        end
    end
    if self.time_timer~=nil then
        self.time_timer:Stop()
        self.time_timer = nil
    end
    self.time_count = 0
    self.time_isAlarm = false
    self.time_alarmTime = 0
    self.time_callback = nil
end

--[[--
 * @Description: 更换桌布  
 ]]
function comp_mjTable:ChangeDeskCloth()
    local clothNum = hall_data.GetPlayerPrefs("desk")
    if clothNum~= "1" and clothNum~= "2" and clothNum~= "3" then
        return
    end
    local matName = "zhuozi_0"..clothNum..""
    local mat = newNormalObjSync(mahjong_path_mgr.GetMaterialPath(matName), typeof(UnityEngine.Material))
    local meshRenderer = self.tableModelObj:GetComponent(typeof(UnityEngine.MeshRenderer))
    meshRenderer.sharedMaterial = mat
end

function comp_mjTable:StopAllCoroutine()
    --coroutine.stop(InitDice_c)
    coroutine.stop(self.SendAllHandCard_c)
    coroutine.stop(self.InitShowLai_c)
    for i = 1, #self.Wall_C_List do
        coroutine.stop(self.Wall_C_List[i])
    end
    self.Wall_C_List = {}
    --InitDice_c = nil
    self.InitShowLai_c = nil
    self.SendAllHandCard_c = nil
end

function comp_mjTable:Uninitialize()
	mode_comp_base.Uninitialize(self)
    self:StopAllCoroutine()
    self.compMjItemMgr = nil 
    self.compPlayerMgr = nil
    self:StopTime()
end

return comp_mjTable