--
-- Date: 2014-11-19 15:29:02
--
local stack = class("Stack")

function stack:ctor()
    self.stack_table = {}
end

function stack:push(element)
    local size = self:size()
    self.stack_table[size + 1] = element
end

function stack:pop()
    local size = self:size()
    if self:isEmpty() then
        printError("Error: Stack is empty!")
        return
    end
    return table.remove(self.stack_table,size)
end

function stack:top()
    local size = self:size()
    if self:isEmpty() then
        printError("Error: Stack is empty!")
        return
    end
    return self.stack_table[size]
end

function stack:isEmpty()
    local size = self:size()
    if size == 0 then
        return true
    end
    return false
end

function stack:size()
    return table.nums(self.stack_table) or 0
end

function stack:clear()
    -- body
    self.stack_table = nil
    self.stack_table = {}
end

function stack:printElement()
    local size = self:size()

    if self:isEmpty() then
        printError("Error: Stack is empty!")
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