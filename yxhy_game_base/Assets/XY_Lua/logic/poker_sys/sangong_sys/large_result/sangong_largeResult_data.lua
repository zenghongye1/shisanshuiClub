local base = require("logic/mahjong_sys/data/mahjong_data_class/bigSettlement_ui_data")
local sangong_largeResult_data = class("sangong_largeResult_data",base)

function sangong_largeResult_data:ctor(data)
	base.ctor(self)
	self.result = {}
	self:ProcessData(data)
end

function sangong_largeResult_data:ProcessData(data)
	--重写
	local result = data
	local players = {}
	self.result["rno"] = data["rno"]
	self.result["curr_ju"] = data["curr_ju"]
	self.result["ju_num"] = data["ju_num"]

	for k,v in pairs(result["user_list"]) do
		local player = {
			userData = {
				name = "",
				uid = "",
				headurl = "",
				imagetype = 0,
			},
			all_score = 0, -- 总分
			tList = {}, -- {"胜利:" = "1次",...}
		}
		local number = player_seat_mgr.GetLogicSeatByStr(k)
		local userData = room_usersdata_center.GetTempUserByLogicSeat(tonumber(number))
		player["userData"]["uid"] = v		--uid存入totallInfo表
		player["userData"]["name"] = userData.name				--name存入totallInfo表
		player["userData"]["headurl"] = userData.headurl
		player["userData"]["imagetype"] = 2
		player["all_score"] = result["totallInfo"][k]["score"]
		if result["totallInfo"][k]["winfo"] then
			player["tList"] = {
				[1] = {[1] = "通杀:",[2] = tostring(result["totallInfo"][k]["winfo"]["nAllWinNums"]).."次"},
				[2] = {[1] = "通赔:",[2] = tostring(result["totallInfo"][k]["winfo"]["nAllLooseNums"]).."次"},
				[3] = {[1] = "三公:",[2] = tostring(result["totallInfo"][k]["winfo"]["nSGNums"]).."次"},
				[4] = {[1] = "胜利:",[2] = tostring(result["totallInfo"][k]["winfo"]["nWinNums"]).."次"},
			}
		else
			player["tList"] = {
				[1] = {[1] = "通杀:",[2] = tostring(result["totallInfo"][k]["nums"][1]).."次"},
				[2] = {[1] = "通赔:",[2] = tostring(result["totallInfo"][k]["nums"][2]).."次"},
				[3] = {[1] = "三公:",[2] = tostring(result["totallInfo"][k]["nums"][3]).."次"},
				[4] = {[1] = "胜利:",[2] = tostring(result["totallInfo"][k]["nums"][4]).."次"},
			}
		end
		table.insert(players,player)
	end
	self.result["owner_uid"] = result["owner_uid"]
	self.result["players"] = players
	--logError(GetTblData(self.result))
end

return sangong_largeResult_data