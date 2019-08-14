local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_mjAction_gameLaiZi = class("mahjong_mjAction_gameLaiZi", base)


local InitShowLaiAnim_c = nil


function mahjong_mjAction_gameLaiZi:Execute(tbl)
    Trace("mahjong_mjAction_gameLaiZi-------------------"..GetTblData(tbl))
    roomdata_center.SetSpecialCard(tbl["_para"]["laizi"][1])
    local cardValue = tbl._para.cards[1]
    local dun = math.ceil(tbl._para.sits[1]/2)
    self.compTable:ShowLai2(dun, cardValue, true, function(mj)    
        self:ShowLaiAnim(mj,cardValue, function ()
            self.compPlayerMgr.selfPlayer:ShowSpecialInHand()
            self.compPlayerMgr:AllSortHandCard() 
            mahjong_ui:ShowSpecialCard(tbl["_para"]["laizi"][1],1,self.cfg.specialCardSpriteName)
            Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_GAME_LAIZI)
        end)
    end )
end


function mahjong_mjAction_gameLaiZi:ShowLaiAnim(mj,cardValue, callback)    
   -- 混飞到屏幕中间
   local mjEx = self.compMjItemMgr.exMj
   mj:Clone(mjEx) 
   mjEx:SetMesh(cardValue)
   self.compTable:MoveMjTo3DCenter(mjEx, 0.3)
   coroutine.wait(0.3)
   --  播放定次动画
   mjEx:SetActive(false)   -- 3D隐藏
   local trans = mahjong_ui:ShowCiCard(cardValue.."_hand")   -- UI显示
   mahjong_effectMgr:PlayUIEffectById(20019,trans,1.5)
  coroutine.wait(1.5)
  mahjong_ui:HideCiCard()   -- 隐藏UI
  mjEx:SetActive(true)   -- 3D显示
  self.compTable:MoveMjTo2DCenter(mjEx, 0, Vector3(0, 0, 0))
  mjEx:Set2DLayer()
  self.compTable:DoHideToPoint({mjEx}, mahjong_ui:GetHunHidePos(), 0.2, nil, true) 
   coroutine.wait(0.6)
   if callback~=nil then
       callback()
   end 
end

return mahjong_mjAction_gameLaiZi

    