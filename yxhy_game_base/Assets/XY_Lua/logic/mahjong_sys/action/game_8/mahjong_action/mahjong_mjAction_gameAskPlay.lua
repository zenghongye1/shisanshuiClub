-- 初始化特殊玩法设置
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_mjAction_gameAskPlay = class("mahjong_mjAction_gameAskPlay", base)

function mahjong_mjAction_gameAskPlay:Execute(tbl)
    local viewSeat = self.gvblFun(tbl._src)
    local time = roomdata_center.timersetting.giveTimeOut
    if viewSeat == 1 then
        self.compTable:SetTime(time,true,3,{3,8},function ()
            self.compPlayerMgr.selfPlayer:StartShakeTimer()
        end)
    else
        self.compTable:SetTime(time)
    end

    roomdata_center.currentPlayViewSeat = viewSeat

    self.compPlayerMgr.selfPlayer:SetDisableCardShow(self.cfg.showTingDisableCard)
    local handcard=self.compPlayerMgr.selfPlayer.handCardList
    if mahjong_anim_state_control.GetCurrentStateName() ~= MahjongGameAnimState.none then
        mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.none)
    end 
    
    if viewSeat == 1 then
        local filterCards = tbl._para
        if self.cfg.tingNotChange then
            if #filterCards == #self.compPlayerMgr.selfPlayer.handCardList then
                table.remove(filterCards)
            end
        end
        roomdata_center.curFilterCards = filterCards
        self.compPlayerMgr.selfPlayer:SetCanOut(true, filterCards)  
    end

    self.compTable:SetCurLightDir(viewSeat)

    if viewSeat ~= 1 then
        self.compPlayerMgr.selfPlayer:HideTingInHand()
    else
        mahjong_client_ting_mgr:ClientCheckHuTips()
    end

    local isShowG=tbl._para.bShowGive
    if isShowG~=nil then  
        roomdata_center.isShowGive=isShowG
        if viewSeat==1 and roomdata_center.tingType==0 then 
            self.compPlayerMgr.selfPlayer:Resetfourcardstate(isShowG) 
        end  
        if isShowG==false and viewSeat==1 then
            if handcard[#handcard]~=nil then
               handcard[#handcard]:SetDisable(true)   
            end  
        end       
    end 
end

return mahjong_mjAction_gameAskPlay