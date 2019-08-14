--
-- create by xuemin.lin
--
local stack = class("Stack")

function stack:ctor()
    self.stack_table = {}
end

function stack:Push(element)
    local size = self:Size()
    self.stack_table[size + 1] = element
end

function stack:Pop()
    local size = self:Size()
    if self:IsEmpty() then
        Trace("Error: Stack is empty!")
        return
    end
    return table.remove(self.stack_table,size)
end

function stack:Top()
    local size = self:Size()
    if self:IsEmpty() then
        Trace("Error: Stack is empty!")
        return
    end
    return self.stack_table[size]
end

function stack:IsEmpty()
    local size = self:Size()
    if size == 0 then
        return true
    end
    return false
end

function stack:Size()
    return table.nums(self.stack_table) or 0
end

function stack:Clear()
    -- body
    self.stack_table = nil
    self.stack_table = {}
end

function stack:PrintElement()
    local size = self:Size()

    if self:IsEmpty() then
        Trace("Error: Stack is empty!")
        return
    end

    local str = "{"..self.stack_table[size]
    size = size - 1
    while size > 0 do
        str = str..", "..self.stack_table[size]
        size = size - 1
    end
    str = str.."}"
    print(str)
end


return stack