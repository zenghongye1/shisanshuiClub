local reward_player_item_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_player_item_view"
local reward_title_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_title_view"
local mahjongHandCardPoolClass = require "logic/mahjong_sys/utils/mahjongHandCardPoolClass"

local base = require("logic.framework.ui.uibase.ui_window")
local mahjong_small_reward_ui = class("mahjong_small_reward_ui",base)

function mahjong_small_reward_ui:ctor()
  base.ctor(self)  
  self.itemList = {}
  self.data = nil
end

function mahjong_small_reward_ui:OnInit()
  base.OnInit(self)
  self.titleView = reward_title_view:create(child(self.transform, "reward_panel/Panel_Top/titleView").gameObject)
  self.btnGo = child(self.transform, "reward_panel/Panel_Bottom/button").gameObject
  addClickCallbackSelf(self.btnGo, self.OnBtnClick, self)
  self.btnPicGo = child(self.transform, "reward_panel/Panel_Bottom/buttonPic").gameObject
  addClickCallbackSelf(self.btnPicGo, self.OnBtnPicClick, self)
  
  local operItemList_EX = child(self.transform, "reward_panel/Panel_Middle/infoList/operItemList").gameObject
  local cardItemList_EX = child(self.transform, "reward_panel/Panel_Middle/infoList/cardItemList").gameObject
  self.handCardPool = mahjongHandCardPoolClass:create(operItemList_EX,cardItemList_EX)

  self.roomNum_label = subComponentGet(self.transform, "reward_panel/Panel_Bottom/room","UILabel")
  self.gameName_label = subComponentGet(self.transform, "reward_panel/Panel_Bottom/gameName","UILabel")
  self.date_label = subComponentGet(self.transform, "reward_panel/Panel_Bottom/date","UILabel")
end

function mahjong_small_reward_ui:OnOpen(data)
  base.OnOpen(self,data)
  if self.data then
    if self.data.type~=data.type then
      self:HidePlayers()
      self.data = data
      self:CreatePlayers()
    else
      self.data = data
    end
  else
    self.data = data
    self:CreatePlayers()
  end

  self:InitView()
  self:SetRewards()
end

function mahjong_small_reward_ui:close()
  ui_sound_mgr.PlayCloseClick()
  UI_Manager:Instance():CloseUiForms("mahjong_small_reward_ui")
  self:Clear()
end

function mahjong_small_reward_ui:PlayOpenAmination()
end

function mahjong_small_reward_ui:HidePlayers()
  for i,v in ipairs(self.itemList) do
    v:SetActive(false)
  end
  self.itemList = {}
end

function mahjong_small_reward_ui:CreatePlayers()
  local player_type = self.data.type
  local path = data_center.GetResMJCommPath().."/ui/reward/playerInfoItem"
  local playerInfoItem = newNormalObjSync(path..tostring(player_type),typeof(GameObject))
  local p = child(self.transform, "reward_panel/Panel_Middle/infoList")
  for i=1,4 do
    local obj
    obj = newobject(playerInfoItem)
    obj.name = "playerInfoItem"..i
    obj.transform:SetParent(p)
    obj.transform.localScale = Vector3.one
    obj.transform.localPosition = Vector3(0,-123*(i-1),0)
    local item = reward_player_item_view:create(obj)
    table.insert(self.itemList, item)
  end
end

function mahjong_small_reward_ui:InitView()
  self.roomNum_label.text = self:GetRoomNum()
  self.gameName_label.text = self:GetGameName()
  self.date_label.text = self:GetGameTime()
  
end

function mahjong_small_reward_ui:OnBtnClick()
  if roomdata_center.totalRewardData then
      Notifier.dispatchCmd(cmdName.GAME_SOCKET_LUMP_SUM)
      self:close()
  else
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_ready"))
    mahjong_play_sys.ReadyGameReq()
  end
end

function mahjong_small_reward_ui:OnBtnPicClick()
  screenshotHelper.ShotToPhoto(function ()
    UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10090))
  end)
end


function mahjong_small_reward_ui:SetRewards()
  self:SetTitleView(self.data)
  local tbl = self.data.playersInfo
  local firstSeat = self.data.winViewSeat[1]
  local specialCardType = self.data.specialCardType
  local specialCardValues = self.data.specialCardValues
  if #tbl == 0 then
    return
  end
  -- 胡牌人是第一个，否则庄在第一个
  if not self.data.isHuang then
    self.itemList[1]:SetInfo(tbl[firstSeat],true, firstSeat,specialCardValues,specialCardType,self)
    self.itemList[1]:ShowWin(true) 
  else
    for i = 1, #tbl do
      if tbl[i].isBanker then
        firstSeat = i
        break
      end
    end
    self.itemList[1]:SetInfo(tbl[firstSeat],false, firstSeat,specialCardValues,specialCardType,self)
    self.itemList[1]:ShowWin(false)
  end
  
  local itemIndex = 2
  for i=1,#tbl-1 do
    local seat = firstSeat + i
    if seat > #tbl then
      seat = seat - #tbl
    end
    local isWin = false
    if #self.data.winViewSeat>1 then
      for i,v in ipairs(self.data.winViewSeat) do
        if seat == v then
          isWin = true
          break
        end
      end
    end
    self.itemList[itemIndex]:ShowWin(isWin)
    self.itemList[itemIndex]:SetInfo(tbl[seat],isWin, seat,specialCardValues,specialCardType,self)
    itemIndex = itemIndex + 1
  end

  for i = roomdata_center.MaxPlayer() + 1, 4 do
    self.itemList[i]:SetActive(false)
  end

end

-- 添加胡牌类型枚举？
function mahjong_small_reward_ui:SetTitleView(data)
  self.titleView:SetResult(data)
end

function mahjong_small_reward_ui:GetOperCard()
  return self.handCardPool:GetOperCard()
end

function mahjong_small_reward_ui:RecycleOperCard(item)
  self.handCardPool:RecycleOperCard(item)
end

function mahjong_small_reward_ui:GetHandCard()
  return self.handCardPool:GetHandCard()
end

function mahjong_small_reward_ui:GetRoomNum()
  local str = "房号:  "..roomdata_center.roomnumber
  local round = roomdata_center.nCurrJu.."/"..roomdata_center.nJuNum.."局"
  if roomdata_center.bSupportKe then
    round = "打课"
  end
  str = str.." ("..round..")"
  return str
end

function mahjong_small_reward_ui:GetGameTime()
  return os.date("%Y-%m-%d  %H:%M:%S",os.time())
end

function mahjong_small_reward_ui:GetGameName()
  return GameUtil.GetGameName(roomdata_center.gid)
end

function mahjong_small_reward_ui:Clear()
  for _,v in ipairs(self.itemList) do
    v:Clear()
  end
end

return mahjong_small_reward_ui