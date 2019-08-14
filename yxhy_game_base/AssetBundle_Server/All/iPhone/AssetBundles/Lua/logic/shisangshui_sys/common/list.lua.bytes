local setmetatable = setmetatable
local list = list or {}
local mt = { __index = list }
list.m_entry = {}
function list.new()
    local s = setmetatable( {}, mt)
    return s
end

function list:PushBack(v)
    table.insert(self.m_entry , v)
end
function list:PopFront()
    if table.nums(self.m_entry) == 0 then
        return nil
    end
    local v = self.m_entry[1]
    table.remove( self.m_entry, 1)
    return v
end
function list:PopBack()
    if table.nums(self.m_entry) == 0 then
        return nil
    end
    local index = # self.m_entry
    local v = self.m_entry[index]
     table.remove( self.m_entry, index)
     return v
end
function list:Size()
    return table.nums( self.m_entry)
end
function list:Clear()
     self.m_entry = {}
 end
return list