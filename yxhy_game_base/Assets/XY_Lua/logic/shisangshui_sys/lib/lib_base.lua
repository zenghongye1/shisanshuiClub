local LibBase = class("LibBase")

function LibBase:ctor()
end
function LibBase:CreateInit(strSlotName)
    return true
end
function LibBase:OnGameStart()
    
end
function LibBase:LoadSlot(strSlotName, stFuntionNamesCheck)
    local slot = import(strSlotName)
    local iRetCode =  self:CheckSlot(slot, stFuntionNamesCheck)  
    if iRetCode ~= 0 then
        return nil
    end
    return slot
end
function LibBase:CheckSlot(slot, stFuntionNames)
    for _,funcName in ipairs(stFuntionNames) do
        if type(slot[funcName]) ~= 'function' then
            local name = slot.name or ""
            return -1
        end
    end
    return 0
end

return LibBase