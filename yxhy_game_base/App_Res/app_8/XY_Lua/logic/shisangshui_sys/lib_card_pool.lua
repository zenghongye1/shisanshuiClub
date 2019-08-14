local LibBase = import(".lib_base")
local LibCardPool = class("LibCardPool", LibBase)

function LibCardPool:ctor()
end
function LibCardPool:CreateInit(strSlotName)
    return true
end
function LibCardPool:OnGameStart() 
end

function LibCardPool:GetCardSet(bSupportGhostCard, nSupportAddColor)
    local cards = Array.Clone(GStars_Normal_Cards)
    --加鬼牌
    if bSupportGhostCard then
        for _, v in ipairs(GStars_Ghost_Cards) do
            table.insert(cards, v)
        end

    end
    --加一色 二色
    if nSupportAddColor == 1 then
        for _, v in ipairs(GStars_One_Color) do
            table.insert(cards, v)
        end
    elseif nSupportAddColor == 2 then
        for _, v in ipairs(GStars_Two_Color) do
            table.insert(cards, v)
        end
    end

    return cards
end

return LibCardPool