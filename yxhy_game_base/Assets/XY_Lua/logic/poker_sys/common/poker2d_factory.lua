poker2d_factory = {}
local this = poker2d_factory


local normalPokerRes = "normalPoker2D"
local ghostPokerRes = "ghostPoker2D"

local pokerColor = {
	Diamond = 1,
	Club = 2,
	Heart = 3,
	Spade = 4,
}

local pokerColorSprite = {
	[pokerColor.Diamond] = "Diamond",
	[pokerColor.Club] = "Club",
	[pokerColor.Heart] = "Heart",
	[pokerColor.Spade] = "Spade",
}

local pokerNumProSpriteStr = {
	[pokerColor.Diamond] = "r_",
	[pokerColor.Club] = "b_",
	[pokerColor.Heart] = "r_",
	[pokerColor.Spade] = "b_",
}

local ghostValue = {
	[1] = 79,
	[2] = 95,
	[3] = 111,	--花牌
}

local ghostColorSprite = {
	[ghostValue[1]] = "joker02",
	[ghostValue[2]] = "joker01",
	[ghostValue[3]] = "joker01",
}

local ghostNumSprite = {
	[ghostValue[1]] = "joker02-1",
	[ghostValue[2]] = "joker01-1",
	[ghostValue[3]] = "joker02-1",
}

function this.GetPoker(serCardValue)
	local serCardValue = tonumber(serCardValue)
	if not this.CheckPokerValid(serCardValue) then
		logError("牌值错误:"..tostring(serCardValue))
		return
	end
	local obj = nil
	if this.CheckIsGhost(serCardValue) then
		obj = this.DealGhostPoker(serCardValue)
	else
		obj = this.DealNormalPoker(serCardValue)
	end
	obj.name = serCardValue
	return obj
end

function this.DealNormalPoker(serCardValue)
	local num,color = this.GetPokerValue(serCardValue)
	if num < 2 or num > 14 or color < 1 or color > 4 then
		return
	end
	local obj = newNormalUI(data_center.GetResPokerCommPath().."/card/"..normalPokerRes)
	componentGet(child(obj.transform,"num"),"UISprite").spriteName = pokerNumProSpriteStr[color]..num
	componentGet(child(obj.transform,"color1"),"UISprite").spriteName = pokerColorSprite[color]
	componentGet(child(obj.transform,"color2"),"UISprite").spriteName = pokerColorSprite[color]
	return obj
end

function this.DealGhostPoker(serCardValue)
	local obj = newNormalUI(data_center.GetResPokerCommPath().."/card/"..ghostPokerRes)
	componentGet(child(obj.transform,"num"),"UISprite").spriteName = ghostNumSprite[serCardValue]
	componentGet(child(obj.transform,"color1"),"UISprite").spriteName = ghostColorSprite[serCardValue]
	return obj
end

function this.CheckPokerValid(serCardValue)
	if this.CheckIsGhost(serCardValue) then
		return true
	else
		local num,color = this.GetPokerValue(serCardValue)
		if num < 2 or num > 14 or color < 1 or color > 4 then
			return false
		else
			return true
		end
	end
end

function this.CheckIsGhost(serCardValue)
	if serCardValue == ghostValue[1] or serCardValue == ghostValue[2] or serCardValue == ghostValue[3] then
		return true
	end
end

function this.GetPokerValue(serCardValue)
	local num = serCardValue % 16
	local color = math.floor(serCardValue / 16) + 1
	return num,color
end

------------外部用---------------
function this.SetPokerStyle(serCardValue,obj)
	local serCardValue = tonumber(serCardValue)
	if not this.CheckPokerValid(serCardValue) then
		logError("牌值错误:"..tostring(serCardValue))
		return
	end
	if not IsNil(obj) then
		local num,color = this.GetPokerValue(serCardValue)
		componentGet(child(obj.transform,"num"),"UISprite").spriteName = pokerNumProSpriteStr[color]..num
		componentGet(child(obj.transform,"color1"),"UISprite").spriteName = pokerColorSprite[color]
		componentGet(child(obj.transform,"color2"),"UISprite").spriteName = pokerColorSprite[color]
	end
end

return poker2d_factory