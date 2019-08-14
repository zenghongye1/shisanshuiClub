local LibBase = import(".lib_base")
local LibCardDeal = class("LibCardDeal", LibBase)

function LibCardDeal:ctor()
end

function LibCardDeal:CreateInit(strSlotName)
    return true
end

function LibCardDeal:OnGameStart()
end

--洗牌
function LibCardDeal:DoDeal(cards)
    if type(cards) ~= "table" then
        return {}
    end
    if #cards == 0 then
        return {}
    end
    local newCards = clone(cards)
    local maxCardLen = #newCards
    math.randomseed(os.time())
    local z = (math.random(0, 1317) % 20 + 17) * (math.random(0,1317) % 20 + 17)
    local swapChar = 0
    while z > 0 do
        local i = math.random(0,1317) % maxCardLen +1
        local j = math.random(0,1317) % maxCardLen + 1
        swapChar = newCards[i]
        newCards[i] = newCards[j]
        newCards[j] = swapChar
        z = z - 1
    end
    return newCards
end


return LibCardDeal