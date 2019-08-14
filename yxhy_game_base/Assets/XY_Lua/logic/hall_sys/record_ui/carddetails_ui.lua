local carddetails_ui_item = require "logic/hall_sys/record_ui/carddetails_ui_item"
local mahjongHandCardPoolClass = require "logic/mahjong_sys/utils/mahjongHandCardPoolClass"

local base = require("logic.framework.ui.uibase.ui_window")
local carddetails_ui = class("carddetails_ui",base)

function carddetails_ui:ctor()
    base.ctor(self)
    self.datatable = nil
    self.itemList = {}
end

function carddetails_ui:OnInit()
  base.OnInit(self)
  self:FindChild()
end

function carddetails_ui:OnOpen(datatable,m)
    base.OnOpen(self,datatable)
    self.datatable = datatable

    FrameTimer.New(
      function() 
        self:InitInfo(m)
      end,1,1
    ):Start()
    
end

function carddetails_ui:PlayOpenAmination()
end
function carddetails_ui:OnRefreshDepth()
  local uiEffect = child(self.gameObject.transform, "cardetails_panel/Panel_Top/Title/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

function carddetails_ui:close()
  ui_sound_mgr.PlayCloseClick()
  UI_Manager:Instance():CloseUiForms("carddetails_ui")
end

function carddetails_ui:FindChild()
    self.btn_close=child(self.transform,"cardetails_panel/Panel_Top/Sprite")
    if self.btn_close~=nil then
        addClickCallbackSelf(self.btn_close.gameObject,self.close,self)
    end 

    self.scrollView_comp = subComponentGet(self.transform,"cardetails_panel/Panel_Middle/sv_all","UIScrollView") 
    self.grid_rank=child(self.transform,"cardetails_panel/Panel_Middle/sv_all/grid_rank") 
    -- self.time_label = subComponentGet(self.transform,"cardetails_panel/Panel_Middle/lab_data","UILabel") 
    self.gameName_label = subComponentGet(self.transform,"cardetails_panel/Panel_Middle/gameName","UILabel") 
    self.roomNum = subComponentGet(self.transform,"cardetails_panel/Panel_Middle/room","UILabel")

    local operItemList_EX = child(self.transform, "cardetails_panel/Panel_Middle/infoList/operItemList").gameObject
    local cardItemList_EX = child(self.transform, "cardetails_panel/Panel_Middle/infoList/cardItemList").gameObject

    self.handCardPool = mahjongHandCardPoolClass:create(operItemList_EX,cardItemList_EX)
end


function carddetails_ui:SetRoomNum(index)
   if self.datatable.rno~=nil then
      local str = "房号:  "..self.datatable.rno
      local round = index.."/"..self.datatable.accountc.ju_num.."局"
      if self.datatable.cfg.bsupportke and self.datatable.cfg.bsupportke == 1 then
        round = "打课"
      end
      str = str.." ("..round..")"
      self.roomNum.text=str
   end
end

function carddetails_ui:SetName()
  local str = ""
   if self.datatable.gid~=nil then
    str = str..GameUtil.GetGameName(self.datatable.gid).." "
   end
    if self.datatable.ctime~=nil then
      str = str..os.date("%Y/%m/%d %H:%M",self.datatable.ctime)
   end
   self.gameName_label.text = str
end

-- function carddetails_ui:SetTime()
--    if self.datatable.ctime~=nil then
--       self.time_label.text=os.date("%Y/%m/%d %H:%M",self.datatable.ctime)
--    end
-- end

function carddetails_ui:GetOperCard()
   return self.handCardPool:GetOperCard()
end

function carddetails_ui:RecycleOperCard(item)
  self.handCardPool:RecycleOperCard(item)
end

function carddetails_ui:GetHandCard()
  return self.handCardPool:GetHandCard()
end

function carddetails_ui:InitInfo(index) 
	Trace("战绩流水数据:"..GetTblData(self.datatable))
   if self.datatable==nil then
      return
   end
   if self.datatable.clog==nil or table.getCount(self.datatable.clog)==0 then
        return
   end 
   if self.datatable.rank_id  ==nil then
       return
   end

   self:SetRoomNum(index)
   self:SetName()
   -- self:SetTime()
   local key=self.datatable.rank_id  
   for i=#key+1,#self.itemList do
     self.itemList[i]:SetActive(false)
   end
   for i=1, table.getCount(key) do        
      local item=self.itemList[i] --child(self.grid_rank, "item_"..i)
      if item==nil then
            local old_item=child(self.transform, "cardetails_panel/Panel_Middle/sv_all/playerInfoItem")
            item_go=NGUITools.AddChild(self.grid_rank.gameObject,old_item.gameObject)
            item_go.transform.localScale={x=1,y=1,z=1}
            item_go.name="item_"..i
            item = carddetails_ui_item:create(item_go.gameObject)
            item.mainUI = self
            table.insert(self.itemList,item)
      end    
      item:SetActive(true)
	    item:ResetItemView()
      item:SetScore(self.datatable.clog[index]["rewards"][tonumber(string.sub(key[i], 2))].all_score)

      item:SetHeadInfo(self.datatable.accountc.rewards[key[i]])
      
      local rewards=self.datatable.clog[index]["rewards"]
      if rewards then
  	    local iBanker = tonumber(self.datatable.clog[index]["banker"]) or 0
        --logError(GetTblData(self.datatable))
        local t=rewards[tonumber(string.sub(key[i], 2))]
  	    local mj_type=child(self.transform, "cardetails_panel/Panel_Middle/mj_type")
  	    mj_type.gameObject:SetActive(false)
        if tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_SHISHANSHUI or tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_PINGTAN_SSS 
		  or tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_PUXIAN_SSS or tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_ShuiZhuang_SSS
		  or tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_DuoGui_SSS or tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_BaRen_SSS 
		  or tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_ChunSe_SSS then
            item:ShowSSS(t)
            local banker=child(item.transform, "headView/zhuangIcon")
            if banker then
                banker.gameObject:SetActive(("p"..iBanker) ==key[i])
            end 
		elseif tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_NIUNIU or tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_SANGONG then 
			----牛牛三公走一块
            item:ShowNiuNiu(t,self.datatable.gid) 
            local banker=child(item.transform, "headView/zhuangIcon")
            if banker then
                banker.gameObject:SetActive(("p"..iBanker) ==key[i])
            end 
        elseif tonumber(self.datatable.gid)==ENUM_GAME_TYPE.TYPE_YINGSANZHANG then 
            ----赢三张
            item:ShowYingSanZhang(t,self.datatable.gid) 
            local banker=child(item.transform, "headView/zhuangIcon")
            if banker then
                banker.gameObject:SetActive(("p"..iBanker) ==key[i])
            end
        else   
            local banker=child(item.transform, "headView/zhuangIcon")
            if banker then
              banker.gameObject:SetActive(("p"..iBanker) ==key[i])
            end 
            local gid = self.datatable.gid
            local laizi=self.datatable.clog[index].laizicards
            local score = self.datatable.clog[index].win_type or ""
            local rewards = self.datatable.clog[index]["rewards"]
            local scoreItem
            local isPao
            local specialCardType = config_mgr.getConfig("cfg_mahjongconfig",GameUtil.GetResId(gid)).specialCardSpriteName
            if rewards then
              local reward = rewards[tonumber(string.sub(key[i], 2))]
              local game_id = GameUtil.GetResId(gid)
              local rewardClass = require("logic/mahjong_sys/action/game_"..game_id.."/ui_action/mahjong_action_small_reward_"..game_id)
              local win_type = reward.win_type
              local win_viewSeat,viewSeat = {},0
              if win_type~="" and reward.win_info and reward.win_info.nFanDetailInfo then
                win_viewSeat = {}
              end
              local mode = config_mgr.getConfig("cfg_mahjongconfig",GameUtil.GetResId(gid)).mode
              if mode == 1 then
                scoreItem = rewardClass:GetScoreItem(reward,win_type,win_viewSeat,viewSeat)
              else
                scoreItem = nil -- rewardClass:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
              end
              isPao = reward.nJiePao == 1
            end

            if mj_type then
              mj_type.gameObject:SetActive(true)
              local fanTypeLabel = subComponentGet(mj_type, "fanTypeLabel", "UILabel")
              fanTypeLabel.text = self:GetMjFanType({{[score] = 1}},GameUtil.GetResId(gid))
            end
            if tonumber(gid)==ENUM_GAME_TYPE.TYPE_XIAMEN_MJ or 
              tonumber(gid)==ENUM_GAME_TYPE.TYPE_ZHANGZHOU_MJ or
              tonumber(gid)==ENUM_GAME_TYPE.TYPE_LONGYAN_MJ or
              tonumber(gid)==ENUM_GAME_TYPE.TYPE_NINGDE_MJ or
              tonumber(gid)==ENUM_GAME_TYPE.TYPE_DAXI_MJ then
              item:ShowMJ(t,scoreItem,laizi,37,isPao,specialCardType)
            else
              item:ShowMJ(t,scoreItem,laizi,nil,isPao,specialCardType)
            end
        end   
      end
   end
   componentGet(self.grid_rank.gameObject,"UIGrid"):Reposition()   
   self.scrollView_comp:ResetPosition()
end 

function carddetails_ui:GetMjFanType(score,gid)
  local fanTypeStr = ""
  if score then
    local fanTypeTbl = {}
    local cfgHutypeName = config_mgr.getConfig("cfg_mahjongconfig",gid)
    local config = config_mgr.getConfigs(cfgHutypeName.huTypeTable)
    local artConfig = config_mgr.getConfigs("cfg_artconfig")
    for _,fanTypeName in ipairs(score) do
      for _,data in pairs(config) do
        if data.serverName and fanTypeName[data.serverName] ~= nil and fanTypeName[data.serverName] > 0 then
            local artId = data.artId
            local artIdByGameId = data.artIdByGameId
            if artIdByGameId and artIdByGameId[gid] then
              artId = artIdByGameId[gid]
            end
            local artData = artConfig[artId]
            if artData and artData.chineseName then
              table.insert(fanTypeTbl,artData.chineseName)
            end
          break
        end
      end
    end
    for i=1,#fanTypeTbl do
      fanTypeStr = fanTypeStr..fanTypeTbl[i]
      if i~=#fanTypeTbl then
        fanTypeStr = fanTypeStr.."、"
      end
    end
  end
  return fanTypeStr
end


return carddetails_ui
