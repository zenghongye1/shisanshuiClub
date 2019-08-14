local LibBase = import(".lib_base")
local LibMult = class("LibMult", LibBase)

function LibMult:ctor()
    self.m_stMult = {}
    for i=1,PLAYER_NUMBER do
        self.m_stMult[i] = -1
    end
end

function LibMult:CreateInit(strSlotName)
    return true
end

function LibMult:OnGameStart()
    for i=1,PLAYER_NUMBER do
        self.m_stMult[i] = -1
    end
end

function LibMult:IsAllMult() 
    local nBanker = GDealer:GetBanker()
    for i=1,PLAYER_NUMBER do
        if i ~= nBanker then
            --LOG_DEBUG("GET player %d Mult value:%d\n", i, self.m_stMult[i] )
            if self.m_stMult[i] == -1 then
                return false
            end
        end
    end
    return true
end

function LibMult:IsPlayerMult(nChairID)
    return self.m_stMult[nChairID] ~= -1 
end

function LibMult:GetPlayerMult(nChairID)
    --if not GGameCfg.GameSetting.bSupportWaterBanker then
        if self.m_stMult[nChairID] == -1 then
           return 0
        end
   -- else
    --    return self.m_stMult[nChairID]
   -- end
    return 0
end

function LibMult:ProcessPlayerMult(nChair, Radio)
    if  self.m_stMult[nChair] ~= -1 then
        --LOG_DEBUG("player is Mult miss:%d\n", self.m_stMult[nChair] )
        return -1
    end
    --LOG_DEBUG("SET player %d Mult value:%d\n", nChair, Radio )
    self.m_stMult[nChair] = Radio
    return 0
end

return LibMult