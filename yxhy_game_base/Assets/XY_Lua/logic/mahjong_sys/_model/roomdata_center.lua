--[[--
 * @Description: 房间数据缓存中心
 * @Author:      ShushingWong
 * @FileName:    roomdata_center.lua
 * @DateTime:    2017-06-19 15:24:43
 ]]
require "logic/shisangshui_sys/card_data_manage"
local MidJoinData = require "logic/mahjong_sys/_model/MidJoinData"
roomdata_center = {}

local this = roomdata_center
this.isShowGive=true--是否亮四打一
this.chairid = 0--房间id
this.rid = 0    --rid
this.gid = 0    --gid
this.roomnumber = 0--房号
-- 几人桌
this.maxplayernum = 0 --最大人数
this.maxSupportPlayer = 0	--牌桌支持的最大人数
this.gamesetting = nil
this.timersetting = nil
this.ownerId = 0

this.gameRuleStr = "" --游戏规则串

-- 中途加入状态
this.midJoinState = false
this.midJoinViewSeatMap = {}

-- 当前局数
this.nCurrJu = 0
-- 总局数
this.nJuNum = 0
this.nMoneyMode = 0

--庄位置
this.zhuang_viewSeat = 0

this.ownerLogicSeat = 0

this.totalCard = 136

this.leftCard = 136

-- 单局游戏是否开始
this.isStart = false

-- 是否已经开始出牌
this.beginSendCard = false

-- 花牌
this.playerFlowerCards = {}

-- 出哪张排后可以听
this.hintInfoMap = nil
-- 听牌 和 胡的番数
this.currentTingInfo = nil
this.sindex=nil --亮四打一打哪张
-- 是否是听得状态
this.isTing = false
-- 自己上一次出的牌 用于自动出牌的交验
this.selfOutCard = 0

-- askplay当前不能出的牌（不是非报听不能出牌）
this.curFilterCards = {}

this.isSelfVote = false

-- 是否已经开始一局
this.isRoundStart = false

-- 是否打课
this.bSupportKe = nil

-- 打课模式 结束标志
this.keEnd = false

-- 当前出牌玩家
this.currentPlayViewSeat = 0

this.mjMap = {}

this.tingVersion = 0

-- 大结算数据
this.totalRewardData = nil
this.needShowTotalReward = false

-- 客户端主动听牌类型
this.tingType = 0
this.tingPlayerSign = {}

--是否解散
this.isDissolution = false

--  是否正在重连
this.isReconnecting = false
--  是否已经开始打牌
this.isPlaying = false

--胡牌提示用附带参数
this.checkWinParam = {}

this.dice = nil
-- 扣牌选择缓存
this.kouCardList = nil
--边钻砸
this.hasBZZ = 0
this.nbzz = 0
this.isNeedOutCard = false
--  承德是否明提
this.bSupportMT = nil

-- 中途加入相关缓存数据  
this.midJoinData = MidJoinData:create()


function this.IsPlayerTing(viewSeat)
  local logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(viewSeat)
  if this.tingPlayerSign[logicSeat] then
    return true
  else
    return false
  end
end

-- 牌数据中心
function this.AddMj(value, num)
  num = num or 1
  if this.mjMap[value] == nil then
      this.mjMap[value] = num
  else
      this.mjMap[value] = this.mjMap[value] + num
      if this.mjMap[value] > 4 then
        --logError("this.mjMap[value] > 4", value)
        this.mjMap[value] = 4
      end
  end
end

function this.GetLeftMjCount(value)
  local count = this.mjMap[value]
  if count == nil then
    count = 0
  end
  local res = 4 - count
  if res < 0 then
    res = 0
  end
  return res
end

  -- "stTingCards": {
  --     {
  --       "give": 21,   --出哪张牌
  --       "flag": 0,    --0普通胡 1任意胡
  --       "win":{-- 和牌信息
  --         {"nCard":21, "nFan":10, "nLeft":2},
  --         {"nCard":22, "nFan":10, "nLeft":2},
  --         ... ---这里可以有多个
  --       }
  --     },
  --     {},
  --     .... ---这里可以有多个
  --   }

-- 特殊牌  金 混
this.specialCard = {}

function this.SetSpecialCard(card)
  if type(card) == "number" then
    table.insert(this.specialCard,card)
  elseif type(card) == "table" then
    for _,v in pairs(card) do
      if not IsTblIncludeValue(v,this.specialCard) then
        table.insert(this.specialCard,v)
      else
        logError("debug")
      end
    end
  else
    logError("错误的类型",type(card))
  end
  --this.specialCard = card
end

-- 返回 结果 如果需要可以添加是哪张特殊牌
function this.CheckIsSpecialCard(card)
  local res = false
  for _,v in ipairs(this.specialCard) do
    if v == card then
      res = true
      break
    end
  end
  return res , ""
end

function this.GetSpecialCard()
  return this.specialCard
end

-- givecard 做key
function this.SetHintInfoMap(tbl)
  this.hintInfoMap = {}
  local tingCards = tbl._para.stTingCards
  if tingCards == nil then
    tingCards= tbl._para.tingInfo
    if tingCards == nil then
        return
    elseif #tingCards>0 then
        this.hintInfoMap={}
        this.hintInfoMap[tingCards["give"]]={tingCards.flag, tingCards.win}
    end
  else
      this.hintInfoMap={}
      for i = 1, #tingCards do
        this.hintInfoMap[tingCards[i]["give"]] = {tingCards[i].flag, tingCards[i].win}
      end
  end
end


-- 出牌后 检测打的牌 是否可以听
function this.CheckTingWhenGiveCard(giveCard)
	--河北代码备份
    --[[if this.tingType == 0 then
        this.isTing = false
        this.currentTingInfo = nil
    end
    if this.isTing and this.currentTingInfo and giveCard ~= -1 then
        return
    end ]]
  if this.hintInfoMap == nil then
    this.isTing = false
    return
  end
  if this.tingType==0 then
     if this.hintInfoMap[giveCard] == nil or giveCard == -1 then
        this.isTing = false
        this.currentTingInfo = nil
        this.hintInfoMap = nil
     else --roomdata_center.gamesetting.bSupportTing ~= true then
        this.isTing = true
        this.currentTingInfo = this.hintInfoMap[giveCard]
        this.hintInfoMap = nil
      -- else
      --   this.isTing = false
      --   this.currentTingInfo = this.hintInfoMap[giveCard]
      --   this.hintInfoMap = nil
      end
  else
       if this.tingType>0 then
         this.isTing=true
       else
        this.isTing=false
       end
       if this.hintInfoMap[giveCard]~=nil then
           this.currentTingInfo=this.hintInfoMap[giveCard]
       else
           for k,v  in pairs(this.hintInfoMap) do
              if v~=nil then
                  this.currentTingInfo = v
                  break
              end
           end
       end
  end
end

-- 检测出完这张牌后 是否可以听牌
function this.CheckCardTing(value)
  if roomdata_center.currentPlayViewSeat == 1 then
    return this.hintInfoMap ~= nil and this.hintInfoMap[value] ~= nil
  end
  return false
end

function  this.GetTingInfo(paiValue)
    return this.hintInfoMap and this.hintInfoMap[paiValue]
end

function this.CheckWindCard()
  local hasWind = false
  if this.cardPoolType ~= nil then
    for i,v in ipairs(this.cardPoolType) do
      if v == "wind" then
        hasWind = true
        break
      end
    end
  end
  Trace("hasWind--------------------------"..tostring(hasWind))
  return hasWind
end


-- 开局是设置一次
function this.SetPlayerFlowersCards(viewSeat, cards)
  if this.playerFlowerCards[viewSeat] == nil then
    this.playerFlowerCards[viewSeat] = cards
  else
    for i = 1, #cards do
      table.insert(this.playerFlowerCards[viewSeat], cards[i])
    end
  end
  Notifier.dispatchCmd(cmdName.MSG_UPDATE_PLAYER_HUA_CARD, {viewSeat, #this.playerFlowerCards[viewSeat]})
end

function this.GetAllFlowerCardsCount()
  local tab = {}
  for i = 1, this.MaxPlayer() do
    local logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(i)
    local count = 0
    if this.playerFlowerCards[i] ~= nil then
      count = #this.playerFlowerCards[i]
    end
    tab[logicSeat] = count
  end
  for i = this.MaxPlayer() + 1, 4 do
    tab[i] = 0
  end
  return tab
end

function this.AddFlowerCard(viewSeat, card)
  table.insert(this.playerFlowerCards[viewSeat], card)
  Notifier.dispatchCmd(cmdName.MSG_UPDATE_PLAYER_HUA_CARD, {viewSeat, #this.playerFlowerCards[viewSeat]})
end

function this.AddFlowerCardToZhuang(card)
  if this.playerFlowerCards[this.zhuang_viewSeat] == nil then
    this.playerFlowerCards[this.zhuang_viewSeat] = {}
  end
  table.insert(this.playerFlowerCards[this.zhuang_viewSeat], card)
  Notifier.dispatchCmd(cmdName.MSG_UPDATE_PLAYER_HUA_CARD, {this.zhuang_viewSeat, #this.playerFlowerCards[this.zhuang_viewSeat]})
end

function this.GetFlowerCards(viewSeat)
  return this.playerFlowerCards[viewSeat] or {}
end

function this.GetspecialFlowers(viewSeat)
  if this.dice == nil then
    return {}
  end
  local dirString = {41,42,43,44,45,46,47,48}

  local bankerViewSeat = this.zhuang_viewSeat
  local bankerIndex = player_seat_mgr.ViewSeatToIndex(bankerViewSeat)
  local dir = bankerIndex + this.dice[1] + this.dice[2] -1
    dir = dir % 4
    if dir == 0 then
        dir = 4
    end

    local offset = player_seat_mgr.ViewSeatToIndex(viewSeat) - dir
    if offset < 0 then
      offset = offset + 4
    end

  return {dirString[offset + 1],dirString[offset + 5]}
end

-- 更新房间剩余牌数
function this.UpdateRoomCard(delta)
  if this.leftCard + delta < 0 then
    return
  end
  this.SetRoomLeftCard(this.leftCard + delta)
end

--设置房间剩余牌数
function this.SetRoomLeftCard(num)
  this.leftCard = num
  Notifier.dispatchCmd(cmdName.MSG_UPDATE_ROOM_LEFT_CARD, num)
end


--[[--
 * @Description:
  {"_cmd":"game_cfg","_para":{"CardPoolType":["char","bamboo","ball","wind","fabai"],
                              "GameSetting":{"bCounterLian":false,"bSupportCollect":false,"bSupportDealerAdd":true,"bSupportGangCi":false,"bSupportGangFlowAdd":true,"bSupportGangPao":true,"bSupportGunWin":true,"bSupportHiddenQuadruplet":true,"bSupportHun":true,"bSupportQuadruplet":true,"bSupportSevenDoubleAdd":true,"bSupportTing":false,"bSupportTriplet":true,"bSupportTriplet2Quadruplet":true,"bSupportWind":true,"bSupportXiaPao":true,"bTingCanPlayOther":true,"nTimeOutCountToAuto":-1},
                              "TimerSetting":{"AutoPlayTimeOut":2,"TimeOutLimit":-1,"XiaPaoTimeOut":10,"blockTimeOut":10,"giveTimeOut":15,"readyTimeOut":10},
                              "chairID":4,
                              "nCurrJu":1,
                              "nJuNum":2,
                              "nMoneyMode":11,
                              "nPlayerNum":4,
                              "rno":0},
           "_src":"p4",
           "_st":"nti"}
]]
function this.SetRoomCfgInfo(cfgData)

  this.chairid = cfgData["_para"].chairID
  if cfgData["_para"].rno then
    this.roomnumber = cfgData["_para"].rno
  end
  this.maxplayernum = cfgData["_para"].nPlayerNum
  this.gamesetting = cfgData["_para"].GameSetting
  this.gt_cfg = cfgData["_para"].gt_cfg
  if this.gamesetting.costtype == nil and this.gt_cfg and this.gt_cfg.cfg and this.gt_cfg.cfg.costtype then
    this.gamesetting.costtype = this.gt_cfg.cfg.costtype
  end
  this.nCurrJu = cfgData["_para"].nCurrJu

  this.nJuNum = cfgData["_para"].nJuNum
  this.nMoneyMode = cfgData["_para"].nMoneyMode

  this.ownerId = cfgData["_para"].owner_uid


  this.timersetting = cfgData["_para"].TimerSetting
  if cfgData["_para"].rid then
    this.rid = cfgData["_para"].rid
  end

  if cfgData["_para"].gid or cfgData["_para"]._gid then
    this.gid = cfgData["_para"].gid or cfgData["_para"]._gid
  end

  this.cardPoolType = cfgData["_para"].CardPoolType

  if this.gamesetting.bSupportKe ~= nil then
    this.bSupportKe = this.gamesetting.bSupportKe
  end 


  if this.gamesetting.bSupportMT ~= nil then
    this.bSupportMT = this.gamesetting.bSupportMT
  end

  if cfgData["_para"]["gt_cfg"]["cid"] then
	this.roomCid = cfgData["_para"]["gt_cfg"]["cid"]	---当前房间俱乐部cid
  end

  this.checkWinParam = cfgData["_para"].checkWinParam or {} --胡牌提示用附带参数

  this.RoomDataInit()
end

function this.AddGameSetting(str,data)
	this.gamesetting[str] = data
end

function this.RoomDataInit()
  this.ownerLogicSeat = 0
  this.keEnd = false
end

function this.IsOwner()
	local mySelfUid =  data_center.GetLoginUserInfo().uid
	return tonumber(this.ownerId) == tonumber(mySelfUid)
end


function this.SetCurPlayerMaxCount(num)
  this.maxplayernum = num
end

function this.GetCurPlayerMaxCount()
  return this.maxplayernum
end

this.MaxPlayer = function()
  return this.GetCurPlayerMaxCount()
end

function this.SetBanker( bankerViewSeat )
  this.zhuang_viewSeat = bankerViewSeat
end

--[[--
 * @Description: 获取庄家座位的号码，两人时为1,3
 ]]
function this.GetBankerViewSeat()
  if this.maxplayernum == 4 then
    return this.zhuang_viewSeat
  elseif this.maxplayernum == 3 then
    local myLogicSeat = player_seat_mgr.GetMyLogicSeat()
    if myLogicSeat == 1 then
      return this.zhuang_viewSeat
    elseif myLogicSeat == 2 then
      if this.zhuang_viewSeat == 3 then
        return 4
      else
        return this.zhuang_viewSeat
      end
    elseif myLogicSeat == 3 then
      if this.zhuang_viewSeat == 2 then
        return 3
      elseif this.zhuang_viewSeat == 3 then
        return 4
      else
        return this.zhuang_viewSeat
      end
    end
  elseif this.maxplayernum == 2 then
    if this.zhuang_viewSeat == 2 then
      return 3
    else
      return this.zhuang_viewSeat
    end
  end
end

function this.SetSubRoundNum(num)
  this.nCurrJu = num
end

function this.GetSubRoundNum(  )
  return this.nCurrJu
end

function this.SetAllRoundNum( num )
  this.nJuNum = num
end

function this.GetAllRoundNum(  )
  return this.nJuNum
end

-- 清楚临时数据
function this.ClearData()
  this.mjMap = {}
  this.playerFlowerCards = {}
  this.hintInfoMap = nil
  this.currentTingInfo = nil
  this.isTing = false
  this.curFilterCards = {}
  this.specialCard = {}
  this.hasVoted = false
  this.beginSendCard = false
  this.isStart = false
  this.selfOutCard = 0
  this.isSelfVote = false
  this.currentPlayViewSeat = 0
  this.tingType = 0
  this.tingPlayerSign = {}
  this.isDissolution=false
  this.kouCardList = nil
  this.sindex=nil
  this.dice = nil
  --边钻砸
  this.hasBZZ = 0
  this.nbzz = 0
  this.isNeedOutCard = false

  this.maxSupportPlayer = 0

  this.midJoinData:Clear()
end

function this.UnInitAllData()
    this.isRoundStart = false
    this.nCurrJu = 0
    this.bSupportKe = nil
    this.totalRewardData = nil
    this.needShowTotalReward = false
      --  承德是否明提
    this.bSupportMT = nil
end

function this.OnSyncTable()
  this.mjMap = {}
  this.playerFlowerCards = {}
  this.specialCard = {}
  this.selfOutCard = 0
  this.tingType = 0
  this.kouCardList = nil
  this.tingPlayerSign = {}
end

function this.GetTotalCard()
  local num = 0
  local hasWind = this.CheckWindCard()
  if not hasWind then
    num = this.totalCard - 28
  else
    num = this.totalCard
  end
  return num
end

---设置玩法桌子支持的最大人数
function this.SetMaxSupportPlayer(pnum)
	this.maxSupportPlayer = pnum
end