
chessItem_Enum = {
	Mahjong = "Mahjong",
	Poker = "Poker", 
	PokerTable = "PokerTable"
}

local chess_item_factory = class("chess_item_factory")

chess_item_factory_instance = nil

function chess_item_factory:ctor()
end

function chess_item_factory:Instance()
	if chess_item_factory_instance == nil then
		chess_item_factory_instance = require("logic.shisangshui_sys.Utils.chess_item_factory"):create()
	end
	return chess_item_factory_instance
end

function chess_item_factory:GetChessItem(itemType)
	local itemObj = nil
	if tostring(itemType) == tostring(chessItem_Enum.Mahjong) then
	elseif tostring(itemType) == tostring(chessItem_Enum.Poker) then
		itemObj = require("logic.shisangshui_sys.models.card_poker"):create()
	else if tostring(itemType) == tostring(chessItem_Enum.PokerTable) then
		itemObj = require("logic.shisangshui_sys.models.table_poker"):create()
	end
	return itemObj
end
