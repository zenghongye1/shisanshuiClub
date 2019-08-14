local mahjongHelper = {}

function mahjongHelper:GetMJHandCard(cards,win_card,specialCardValues,replaceSpecialCardValue)
  local handCards = {}
  for i=1,#cards do
    table.insert(handCards,cards[i])
  end

    table.sort(handCards)
    -- 白板代替金
    if replaceSpecialCardValue and specialCardValues then
	    for j=1,#handCards do
	      if handCards[j] == replaceSpecialCardValue then
	          local index = j-1
	          while index > 0 and handCards[index] > specialCardValues[1] do 
	              local temp = handCards[index]
	              handCards[index] = handCards[index+1]
	              handCards[index+1] = temp
	              index = index -1
	          end
	      end
	    end
	end
    --金前置
    for j=1,#handCards do
      if self:CheckIsSpecialCard(handCards[j],specialCardValues) then
          local index = j-1
          while index > 0 and not self:CheckIsSpecialCard(handCards[index],specialCardValues) do 
              local temp = handCards[index]
              handCards[index] = handCards[index+1]
              handCards[index+1] = temp
              index = index -1
          end
      end
    end
    if win_card then
      table.insert(handCards,win_card)
    end
  return handCards
end

function mahjongHelper:CheckIsSpecialCard(card,specialCards)
  local res = false
  for _,v in ipairs(specialCards or {}) do
    if v == card then
      res = true
      break
    end
  end
  return res
end

function mahjongHelper:GetOperValueList( combineTile,specialCardValues,replaceSpecialCardValue)
  local list = {}
  for i,operData in ipairs(combineTile) do
    local valueList = {}
    if operData.ucFlag == 16 then
    	if specialCardValues then
	  		local cardValue1 = self:GetReplaceCard(operData.card,specialCardValues,replaceSpecialCardValue)
	        local cardValue2 = self:GetReplaceCard(cardValue1 + 1,specialCardValues,replaceSpecialCardValue)
	        local cardValue3 = self:GetReplaceCard(cardValue1 + 2,specialCardValues,replaceSpecialCardValue)
	          table.insert(valueList,operData.card)
	          table.insert(valueList,cardValue2)
	          table.insert(valueList,cardValue3)
	    else
	    	    table.insert(valueList,operData.card)
	          table.insert(valueList,operData.card + 1)
	          table.insert(valueList,operData.card + 2)
	     end
    elseif operData.ucFlag == 17 then
          table.insert(valueList,operData.card)
          table.insert(valueList,operData.card)
          table.insert(valueList,operData.card)
    elseif operData.ucFlag == 18 then
          table.insert(valueList,operData.card)
          table.insert(valueList,operData.card)
          table.insert(valueList,operData.card)
          table.insert(valueList,operData.card)
    elseif operData.ucFlag == 19 then
          table.insert(valueList,0)
          table.insert(valueList,0)
          table.insert(valueList,0)
          table.insert(valueList,operData.card)
    elseif operData.ucFlag == 20 then
          table.insert(valueList,operData.card)
          table.insert(valueList,operData.card)
          table.insert(valueList,operData.card)
          table.insert(valueList,operData.card)
    elseif operData.ucFlag == 9 then
          table.insert(valueList,35)
          table.insert(valueList,36)
          table.insert(valueList,37)
    else
        logError("not define operData.ucFlag",operData.ucFlag)
    end
    table.insert(list,valueList)
  end
  return list
end

function mahjongHelper:GetReplaceCard(card,specialCardValues,replaceSpecialCardValue)
    if card == replaceSpecialCardValue and card ~= 0 then
        return specialCardValues[1] or card
    elseif card == specialCardValues[1] and replaceSpecialCardValue ~= 0 then
        return replaceSpecialCardValue
    else
        return card
    end
end

return mahjongHelper