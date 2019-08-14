--[[--
 * @Description: 大厅UI控制
 * @Author:      shine
 * @FileName:    hall_ui_ctrl.lua
 * @DateTime:    2017-05-19 14:32:55
 ]]

hall_ui_ctrl = {}
local this = hall_ui_ctrl

local firstLogin = true
local loadDataCor = nil 

function this.Init()
    -- body
end

function this.UInit()
  if loadDataCor ~= nil then
    coroutine.stop(loadDataCor)
    loadDataCor = nil
  end    
end

--[[--
 * @Description: 加载完场景做的第一件事
 ]]
function this.HandleLevelLoadComplete()
  Trace("gs_mgr.state_main_hall-------------------------------")
    gs_mgr.ChangeState(gs_mgr.state_main_hall)
    map_controller.SetIsLoadingMap(false)

    --查询游戏重连状态
    if firstLogin then
        loadDataCor = coroutine.start(function ()
            this.OnGetClientConfig(data_center.GetClientConfData())
        end)
        firstLogin = false

        require "logic/gvoice_sys/gvoice_sys"
        if(not gvoice_sys.GetIsInit()) then
          gvoice_sys.GVoiceInit()   --语音服务初始化
          --gvoice_engine = gvoice_sys.GetEngine()
        end
    end    
end

function this.OnGetClientConfig(data)
  --等获取游戏配置列表后再查询状态   
    if data ~= nil then      
      local tmp = data["gameinfo"]["roomgame"]
      local gidTbl = {}
      for i,v in ipairs(tmp) do
        realUrl= data["mjupdateurl"]..v["grule"]
        if PlayerPrefs.HasKey("jsonversion") and PlayerPrefs.GetInt("jsonversion") == tonumber(data["jsonversion"]) 
          and FileReader.IsFileExists(Application.persistentDataPath.."/"..v["grule"]) then 
          --return
        else
          PlayerPrefs.SetInt("jsonversion", tonumber(data["jsonversion"]))
          Trace(realUrl.."realUrl")
          --request_config["gid"]=gid
          Trace("拉取json文件")
          NetWorkManage.Instance:HttpDownTextAsset(realUrl, function(code, msg)
          end, Application.persistentDataPath.."/games/gamerule")
        end

        table.insert(gidTbl, tonumber(v["gid"]))
      end
      local ssround=data.gameinfo.roomgame[1].addtional 
      --local fzround=data.gameinfo.roomgame[2].addtional 
      --local fz=room_data.GetRoundInfo()
      local sss=room_data.GetSssRoundInfo()
      --this.ReadRoundInfo(fzround,fz)
      this.ReadRoundInfo(ssround,sss)
      player_data.SetGidTbl(gidTbl)
    end
  
    local paraData = {}
    paraData._gids = player_data.GetGidTbl() 

    join_room_ctrl.QueryState() 
end


function this.ReadRoundInfo(data,Roundinfo) 
   local roundInfo=Roundinfo
   for i=1,#data  do
     --打课模式
     if data[i].round == "0" then
       roundInfo[tonumber(data[i].pnum)]=data[i].cost
     else
       if data[i].pnum == "0" then
         for _,v in pairs(roundInfo) do
           v[tostring(data[i].round)]=data[i].cost 
         end
       else
          roundInfo[tostring(data[i].pnum)][tostring(data[i].round)]=data[i].cost 
       end
     end 
   end 
end 