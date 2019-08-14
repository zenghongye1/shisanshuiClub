local mahjong_action_base = class("mahjong_action_base")

function mahjong_action_base:ctor(mode)
    if mode then
    	self.mode = mode
    	self.config = mode.config
        self.cfg = mode.cfg
    	self.compTable = mode:GetComponent("comp_mjTable")
        self.compResMgr = mode:GetComponent("comp_resMgr")
        self.compMjItemMgr = mode:GetComponent("comp_mjItemMgr")
        self.compPlayerMgr = mode:GetComponent("comp_playerMgr")
        self.compDice = mode:GetComponent("comp_dice")

        self.glbvFun = player_seat_mgr.GetLogicSeatNumByViewSeat
        self.gvblFun = player_seat_mgr.GetViewSeatByLogicSeat
        self.gvblnFun = player_seat_mgr.GetViewSeatByLogicSeatNum
        self.gmlsFun = player_seat_mgr.GetMyLogicSeat 
    end
end

function mahjong_action_base:Execute(...)

end

function mahjong_action_base:OnSync(...)
end

function mahjong_action_base:Uninitialize( ... )
end

function mahjong_action_base:AnimSpd()
    if self.mode and self.mode.GetAnimSpeed then
        return self.mode.GetAnimSpeed()
    end
end

return mahjong_action_base