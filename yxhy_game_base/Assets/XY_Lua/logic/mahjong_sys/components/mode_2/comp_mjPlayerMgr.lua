local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjPlayerMgr = class ("comp_mjPlayerMgr", mode_comp_base)

function  comp_mjPlayerMgr:ctor(playerPath)
	playerPath = playerPath or "logic/mahjong_sys/components/mode_2/comp_mjPlayer"
	self.name = "comp_playerMgr"

    self.comp_player_class = require(playerPath)
    self.comp_selfPlayer_class = require("logic/mahjong_sys/components/mode_2/comp_mjSelfPlayer")

    self.playerList = {}--玩家组件列表
    self.selfPlayer = nil

    self.highLightCache = {}
end

function comp_mjPlayerMgr:Initialize()
	mode_comp_base.Initialize(self)
	self:InitPlayer()
end

--[[--
 * @Description: 初始化玩家组件  
 ]]
function comp_mjPlayerMgr:InitPlayer()
    local playersPoint = GameObject.New("Players")

    for i=1,roomdata_center.MaxPlayer(),1 do
        local player = nil
        if i == 1 then
            player = self.comp_selfPlayer_class:create()
            self.selfPlayer = player
        else
            player = self.comp_player_class:create()
        end
        
        player.index = i
        player.mode = self.mode
        player.playerObj.transform:SetParent(playersPoint.transform, false)

        if roomdata_center.MaxPlayer() == 2 and i == 2 then
            player.index = 3
        end

        if roomdata_center.MaxPlayer() == 3 then 
            player.index = self:GetPlayerIndexForThreePlayer(i)
        end

        self:SetPlayerPos(player)

        player.playerObj.name = "Player"..i
        player.viewSeat = i
        player:Init()
        table.insert(self.playerList,player)
    end
end

--[[--
 * @Description: 设置玩家位置  
 ]]
function comp_mjPlayerMgr:SetPlayerPos(player)
    if player.index == 3 then
        player.playerObj.transform.localPosition = Vector3(0,0, -0.12)
    end
    player.playerObj.transform.localEulerAngles = Vector3(0, -90 * (player.index - 1), 0)
end

--[[--
 * @Description: 获取三人时玩家位置  
 ]]
function comp_mjPlayerMgr:GetPlayerIndexForThreePlayer(iterator)
    local myLogicSeat = player_seat_mgr.GetMyLogicSeat()
    if myLogicSeat == 1 then
      return iterator
    elseif myLogicSeat == 2 then
      if iterator == 3 then
        return 4
      else
        return iterator
      end
    elseif myLogicSeat == 3 then
      if iterator == 2 then
        return 3
      elseif iterator == 3 then
        return 4
      else
        return iterator
      end
    end
end

--[[--
 * @Description: 获取玩家组件  
 ]]
function comp_mjPlayerMgr:GetPlayer(index)
    return self.playerList[index]
end


function comp_mjPlayerMgr:HideHuaInTable()
    for i = 1,#self.playerList,1 do
        self.playerList[i]:DoHideFlowerCards()
    end
end

--[[--
 * @Description: 所有玩家手牌排序  
 ]]
function comp_mjPlayerMgr:AllSortHandCard()
    for i=1,#self.playerList do
        self.playerList[i]:SortHandCard(false)
    end
end

--[[--
 * @Description: 重置玩家，游戏开始前  
 ]]
function comp_mjPlayerMgr:ResetPlayer()
    for i = 1,#self.playerList,1 do
        self.playerList[i]:Init()
    end
end

--[[--
 * @Description: 设置相同牌高亮  
 ]]
function comp_mjPlayerMgr:SetHighLight(value)
    self:HideHighLight()
    for i = 1,#self.playerList,1 do
        local t = self.playerList[i]:GetSameValueItem(value)
        for i=1,#t do
            table.insert(self.highLightCache,t[i])
        end
    end
    for i=1,#self.highLightCache do
        self.highLightCache[i]:SetHighLight(true)
    end
end


--[[--
 * @Description: 隐藏高亮  
 ]]
function comp_mjPlayerMgr:HideHighLight()
    for i=1,#self.highLightCache do
        self.highLightCache[i]:SetHighLight(false)
    end
    self.highLightCache = {}
end


function comp_mjPlayerMgr:Uninitialize()
	mode_comp_base.Uninitialize(self)
    for i = 1,#self.playerList,1 do
        self.playerList[i]:Uninitialize()
    end
end

return comp_mjPlayerMgr