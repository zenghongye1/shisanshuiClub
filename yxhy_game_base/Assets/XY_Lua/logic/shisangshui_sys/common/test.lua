require "debug_e"
require "extern"
local user = require "user"
print(vardump(user.getname()))
user.setname("ttt")
print(vardump(user.getname()))

local user2 = require "user"
print(vardump(user))


other = { foo = 3 }
t1 = setmetatable({}, { __index = other })
t1.foo = 2
t2 = setmetatable({}, { __index = other })
t2.foo = 2
print(vardump(t2.foo))
other.foo = 3
print(vardump(t2.foo))

local Player = require "player"
print(vardump(Player))
Player:Login()
print(Player:GetName())
print(vardump(Player:getname()))
