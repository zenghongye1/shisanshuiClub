require "extern"
local ChildCoroutine = class("ChildCoroutine")
function ChildCoroutine:ctor()
end
function ChildCoroutine:SetSelf(co)
    self.co = co
end
function ChildCoroutine:OnProcess()
    for i = 1, 10 do
        print( "i " .. i )
print("yield")
        coroutine.yield()
    end

end

local child = ChildCoroutine.new()
co = coroutine .create(handler(child, ChildCoroutine.OnProcess))
while true do
child:SetSelf(co)
print("resume")
coroutine.resume(co)
if coroutine.status(co) == "dead" then
    break
end

end
