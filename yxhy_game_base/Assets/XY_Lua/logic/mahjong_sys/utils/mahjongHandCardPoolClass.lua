local mahjong_opercard_view = require "logic/mahjong_sys/ui_mahjong/reward/mahjong_opercard_view"
local mahjong_handcard_view = require "logic/mahjong_sys/ui_mahjong/reward/mahjong_handcard_view"
local handCardPoolClass = class("handCardPoolClass")

function handCardPoolClass:ctor(oper_go,card_go)
	self.operItemList_EX = oper_go
	self.cardItemList_EX = card_go

	self.opercardPoolList = {}
end

function handCardPoolClass:GetOperCard()
  local opercard = nil
  if 0 == #self.opercardPoolList then
    local go = newobject(self.operItemList_EX)
    opercard = mahjong_opercard_view:create(go)
    return opercard
  else
    while(#self.opercardPoolList > 0)
    do
      if not IsNil(self.opercardPoolList[#self.opercardPoolList].gameObject) then
        return table.remove(self.opercardPoolList)
      else
        table.remove(self.opercardPoolList)
      end
    end
    return self:GetOperCard()
  end
end

function handCardPoolClass:RecycleOperCard(item)
  if not IsNil(item.gameObject) then
    table.insert(self.opercardPoolList,item)
    item:SetActive(false)
  end
end

function handCardPoolClass:GetHandCard()
  local go = newobject(self.cardItemList_EX)
  local handcard = mahjong_handcard_view:create(go)
  return handcard
end

return handCardPoolClass