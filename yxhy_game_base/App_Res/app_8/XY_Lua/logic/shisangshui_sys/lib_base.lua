
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
        LOG_ERROR("CheckSlot Failed.\n")
        return nil
    end
    return slot
end
function LibBase:CheckSlot(slot, stFuntionNames)
    for _,funcName in ipairs(stFuntionNames) do
        if type(slot[funcName]) ~= 'function' then
            local name = slot.name or ""
            LOG_ERROR("CheckSlot Failed. slot name:%s require:%s\n", name, funcName)
            return -1
        end
    end
    return 0
end

return LibBase



--[[ 
local LibBase = {}

-- [ [ 
local mt = { __index = LibBase }

function LibBase.new()
    local self = setmetatable({}, mt)
    return self
end
  ]  ]

function LibBase.CreateInit(strSlotName)
    return true
end
function LibBase.OnGameStart()
    return true
end

function LibBase.LoadSlot(strSlotName, stFuntionNamesCheck)
    local slot = import(strSlotName)
    local iRetCode =  self:CheckSlot(slot, stFuntionNamesCheck)  
    if iRetCode ~= 0 then
        LOG_ERROR("CheckSlot Failed.\n")
        return nil
    end
    return slot
end
function LibBase.CheckSlot(slot, stFuntionNames)
    for _,funcName in ipairs(stFuntionNames) do
        if type(slot[funcName]) ~= 'function' then
            local name = slot.name or ""
            LOG_ERROR("CheckSlot Failed. slot name:%s require:%s\n", name, funcName)
            return -1
        end
    end
    return 0
end


return LibBase

]]
