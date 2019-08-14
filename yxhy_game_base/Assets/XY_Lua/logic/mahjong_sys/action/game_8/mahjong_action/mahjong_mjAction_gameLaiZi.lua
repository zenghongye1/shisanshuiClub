local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_mjAction_gameLaiZi = class("mahjong_mjAction_gameLaiZi", base)


local InitShowLaiAnim_c = nil


function mahjong_mjAction_gameLaiZi:Execute(tbl)
    Trace("mahjong_mjAction_gameLaiZi-------------------"..GetTblData(tbl))
    roomdata_center.SetSpecialCard(tbl["_para"]["laizi"][1])
    local cardValue = tbl._para.cards[1]
    local dun = math.ceil(tbl._para.sits[1]/2)
    self.compTable:ShowLai(dun, cardValue, true, function(mj)    
        self:ShowLaiAnim(mj, function ()
            self.compPlayerMgr.selfPlayer:ShowSpecialInHand()
            self.compPlayerMgr:AllSortHandCard() 
            mahjong_ui:ShowSpecialCard(tbl["_para"]["laizi"][1],1,self.cfg.specialCardSpriteName)
            Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_GAME_LAIZI)
        end)
    end )
end


function mahjong_mjAction_gameLaiZi:ShowLaiAnim(mj, callback)
    InitShowLaiAnim_c = coroutine.start(function ()  
        if (mj ~= nil) then            
            -- 混飞到屏幕中间
            local mjEx =  self.compMjItemMgr.exMj            
            local mjLaiziEx =  self.compMjItemMgr.exLaiziMj
            mjEx:SetActive(true)
            mjLaiziEx:SetActive(true)
            coroutine.wait(0.5)

            mj:Clone(mjEx)

            self.compTable:MoveMjTo3DCenter(mjEx, 0.3)
            coroutine.wait(0.35)
            self.compTable:MoveMjTo2DCenter(mjEx, 0, Vector3(-0.2, 0, 0))

            -- 显示癞子
            mjLaiziEx:Set2DLayer()
            mjEx:Clone(mjLaiziEx)
            local specialCard = roomdata_center.GetSpecialCard()
            if specialCard~= nil and #specialCard > 0 then
                mjLaiziEx:SetMesh(specialCard[1])    
            end            
            mjLaiziEx:SetSpecialCard(true)
            mjLaiziEx:SetParent(nil) 
            local pos = mjLaiziEx.transform.localPosition
            pos = pos + Vector3(0, -0.01, 0)
            -- 在翻牌后面
            mjLaiziEx.transform.localPosition = pos
            mjLaiziEx.transform.localScale = Vector3.one
            coroutine.wait(0.1) 
            local toPos = pos + Vector3(0.42, 0.01, 0)
            mjLaiziEx:DOLocalMove(toPos, 0.6)
            
            coroutine.wait(1.6)
            mjLaiziEx.transform.localPosition = pos+Vector3(-0.21, 0, 0)
            --mjEx:Hide()  
            self.compTable:DoHideToPoint({mjEx}, mahjong_ui:GetHunHidePos(), 0, nil, true)
            self.compTable:DoHideToPoint({mjLaiziEx}, mahjong_ui:GetHunHidePos(), 0.2, nil, true)
            coroutine.wait(0.2)            
        end
        if callback ~= nil then
            callback()
        end
    end)    
end

return mahjong_mjAction_gameLaiZi

    