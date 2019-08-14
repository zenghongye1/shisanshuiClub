 --[[--
  * @Description: 网络消息分发机制管理
  * 1>. 服务器消息不阻塞，将服务器消息放入消息队列
  * 2>. 客户端分发中心注册模块消息处理完事件，如果队列中还有消息，
        接着派发下一条给对应模块，这里可通过注册消息事件处理
  * 3>. 增加模块消息最长处理时间，如果超过该时间段则强制派发下一条消息指令(模块那边需强制同步)
  * @Author:      shine
  * @FileName:    msg_dispatch_mgr.lua
  * @DateTime:    2017-05-20 14:16:41
  ]]

require "logic/mahjong_sys/_model/roomdata_center"
require "logic/mahjong_sys/_model/player_data"
require "logic/shisangshui_sys/shisangshui_play_sys"
require "logic/mahjong_sys/mahjong_play_sys"
require "logic/voteQuit/vote_quit_ui"

msg_dispatch_mgr = {}
local  this = msg_dispatch_mgr


local msgqueue = {}
local mapEvent = {}
local eventNum = 0
local curEvent = nil

local isEnter = false
local isSend = false

local curSysTime = nil


--1代表第一个游戏的数据
local msgEventTable = require "logic/framework/msgEventTable"

--[[--
 * @Description: 初始化消息事件  
 ]]
function this.Init()
  --注册消息处理回调事件
  Notifier.regist(cmdName.MSG_HANDLE_DONE, this.OnMsgHandleDone)
	UpdateBeat:Add(this.Update)
end

function this.UnInit()
  UpdateBeat:Remove(this.Update)
  Notifier.remove(cmdName.MSG_HANDLE_DONE, this.OnMsgHandleDone)
end

function this.HandleRecvData(cmdId, msg)
  Trace("收到服务端协议cmdId======================================="..GetTblData(msg))

  if msg._st ~=nil and msg._st == "err" then
    this.HandleSTError(cmdId, msg)
    Trace("-------------!!!!!!!!!!!!!----------" .. GetTblData(msg))
  elseif cmdId == "query_state" then
    this.HandleQueryStateMsg(msg)
  elseif cmdId == "session" then
    this.HandleSessionMsg(msg)
  elseif cmdId == "game_cfg" then  
    this.SetRoomCfgData(msg)
  elseif cmdId == "table_limit" then
    --game_scene.DestroyCurSence()    
    --game_scene.gotoHall()
  elseif cmdId == "leave" then
    this.LeaveEventHandler(msg)
  elseif cmdId == "dissolution" then  -- 解散房间
    this.DissolutionHandler(msg)
  elseif cmdId == "error" then
    this.ErrorEventHandler(msg)
  elseif cmdId=="pushmsg" then
    this.UpdataInfoHandle(msg)
  elseif cmdId=="chat" then
    this.OnPlayerChat(msg)
  else
    msg.time = os.clock()
    this.AddMsgToQueue(cmdId, msg)
  end
end

function this.HandleSTError(cmdId, msg)
  waiting_ui.Hide()
  if cmdId == "enter" then
    if msg._para._errno ~= nil then
      if tonumber(msg._para._errno) == 2009 then
        fast_tip.Show(GetDictString(6004))
      elseif tonumber(msg._para._errno) == 2003 then
        fast_tip.Show(GetDictString(2003))
      elseif msg._para._errno == 2001 then
        --[[message_box.ShowGoldBox(GetDictString(2001), nil, 1, {
        function ()
          if game_scene.getCurSceneType() ~= scene_type.HALL then
            game_scene.DestroyCurSence() 
            game_scene.gotoHall()               
          end
          message_box.Close()             
        end}, {"fonts_01"})           ]]
        if game_scene.getCurSceneType() ~= scene_type.HALL then
          game_scene.DestroyCurSence() 
          game_scene.gotoHall()               
        end
      end
    end  
  elseif cmdId == "vote_draw" then
    if msg._para._errno ~= nil then
		local errno= msg._para._errno
	if tonumber(errno) == 5001 then
			--请求次数太过多
			fast_tip.Show("解散功能时间冷却中，请稍后再试.")
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_VOTE_DRAW)
			return
		elseif tonumber(errno) == 5002 then
			fast_tip.Show("等待牌局结束后，房间将会解散.")
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_VOTE_DRAW)
			return
		elseif tonumber(errno) == 5003 then
			fast_tip.Show("投票正在进行中，请稍后再试.")
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_VOTE_DRAW)
			return
		end
    end
  end
end

function this.AddMsgToQueue(cmdId, msg)
  --解析数据(上面已经解析了)
  local msgTable = {}
  msgTable.cmdId = cmdId
  msgTable.msg = msg

  --将解析后的数据加入队列
  table.insert(msgqueue, msgTable)
  Trace("msgqueue================================"..tostring(#msgqueue))
end

--[[--
 * @Description: 移除消息  
 ]]
function this.RemoveMsgFromQueue(msg)
  
end

--[[--
 * @Description: 重置消息队列  
 ]]
function this.ResetMsgQueue(msg)
  isSend = false
  msgqueue = {}
  eventNum = 0
  curEvent = nil
  mapEvent = {}
  --isEnter = false
end

function this.Update()
  if eventNum == 0 then
    --将第一个数据发送出去给注册模块
    if (#msgqueue>0) and (msgqueue[1]~=nil) and (isEnter) and (not isSend) then
      isSend = true
      curEvent = msgEventTable[msgqueue[1].cmdId]

      curSysTime = os.clock()
      msgqueue[1].msg.time = curSysTime - msgqueue[1].msg.time
      Trace("curEvent================================"..tostring(msgqueue[1].cmdId))
      Notifier.dispatchCmd(curEvent, msgqueue[1].msg)
    end
  end
end

function this.RemapMsgToPlayer()
  
end


function this.AddMsgMap(_event)
  if _event == curEvent then
    eventNum = eventNum + 1
    mapEvent[_event] = eventNum
  else
    warning("curEvent havn't handle done, please wait for a moment")
  end
end

--[[--
 * @Description: 消息事件完成后的回调处理
 ]]
function this.OnMsgHandleDone(_event)
  Trace("OnMsgHandleDone-xx----------------------------------"..tostring(_event))
  --这里做一个事件认证
  if _event == curEvent then        
    eventNum = eventNum - 1
    curEvent = nil
  end

  if eventNum <= 0 then
    msgqueue[1] = nil
    table.remove(msgqueue, 1)
    eventNum = 0
    isSend = false        
  end
end

--[[--
 * @Description: 设置进入状态  
 ]]
function this.SetIsEnterState(state)
  isEnter = state
end

--[[--
 * @Description: 处理查询状态后消息处理  
 ]]
function this.HandleQueryStateMsg(msg)
	print("处理查询状态后消息处理")
	if msg._para._dst ~= nil and msg._para._dst.status == "enter" then
		Trace("msg._para._gid-----------------------------"..tostring(msg._para._dst._gid))
		if msg._para._dst._gid == ENUM_GAME_TYPE.TYPE_FUZHOU_MJ then
			player_data.ReSetSessionData(msg._para)
			local t=
			{
				[messagedefine.EField_Session]=msg._para._dst,
				para = --msg._para.para
        {
          _gid = msg._para._dst._gid,
          _glv = msg._para._dst._glv,
          _gsc = msg._para._dst._gsc,
        }
			}    
			player_data.SetReconnectEpara(t.para)

			mahjong_play_sys.EnterGameReq(t)    
		elseif tonumber(msg._para._dst._gid) == tonumber(ENUM_GAME_TYPE.TYPE_SHISHANSHUI) then
			player_data.ReSetSessionData(msg._para)
			player_data.SetReconnectEpara(msg._para.para)   
			if msg._para._dst ~= nil then
				local gamedata = {}				
				local dst = msg._para._dst
				shisangshui_play_sys.EnterGameReq(gamedata, dst)
				Trace("十三水重连")
			end
		end
	elseif hall_data.CheckIsChooseRoomClick() then
		hall_data.SetChooseRoomClick(false)
		Notifier.dispatchCmd(cmdName.MSG_NOT_ENTER_STATE)
  else
    --重连后啥都木有
    game_scene.DestroyCurSence()    
    game_scene.gotoHall()    
	end
end

--[[--
 * @Description: 处理会话消息  
 ]]
function this.HandleSessionMsg(msg)
    msg_dispatch_mgr.ResetMsgQueue()
    waiting_ui.Hide()
    player_data.SetSessionData(msg)   	
    if msg._para._gid == ENUM_GAME_TYPE.TYPE_FUZHOU_MJ then
      mahjong_play_sys.HandlerEnterGame()
    elseif msg._para._gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
	   shisangshui_play_sys.HandlerEnterGame()
    end
end

--[[--
 * @Description: 设置房间配置数据  
 ]]
function this.SetRoomCfgData(msg)
  Trace("msg._para._gid---------------------------"..tostring(msg._para._gid))

  Trace("ENUM_GAME_TYPE.TYPE_SHISHANSHUI---------------------------"..tostring(ENUM_GAME_TYPE.TYPE_SHISHANSHUI))
  if msg._para._gid == ENUM_GAME_TYPE.TYPE_FUZHOU_MJ then
    roomdata_center.SetRoomCfgInfo(msg)  
  elseif msg._para._gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then    
    Trace("msg._para.rno---------------------------"..tostring(msg._para.rno))
    roomdata_center.SetShiSangShuiRoomCfgInfo(msg)
  end
end

--[[--
 * @Description: 解散房间事件处理  
 ]]
function this.DissolutionHandler(msg)
    -- game_scene.DestroyCurSence()    
    -- game_scene.gotoHall()
    if player_seat_mgr.GetMyLogicSeat() ~= 1 then
        message_box.ShowGoldBox(GetDictString(6024),{function ()message_box:Close()end}, {"fonts_01"})
    end
    -- if msg._para._gid == ENUM_GAME_TYPE.TYPE_FUZHOU_MJ then
    --   -- mahjong_play_sys.LeaveReq()  
    -- elseif msg._para._gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
      
    -- end
end

--[[--
 * @Description: 离开事件处理  
 ]]
function this.LeaveEventHandler(msg)
  -- leave 之后 接受不到voteend事件  所以把通知 放到leave中
--[[
  E_LeaveFromClient = 0,
  E_LeaveFromKick = 1,
  E_LeaveForGameEnd = 2, //游戏对局达到本桌上线, 强制清桌
  E_LeaveForVote = 3, //游戏未达到下限,玩家投票提早结束
  E_LeaveForLua=4, //lua请求清桌
  E_MultiLogin = 5, //multilogin
  E_LeaveFromTimeOut_120 = 6,  //玩过一局或以上，但还没到局数上限，开桌超过2个小时， 清桌
  E_LeaveFromTimeOut_30 = 7,  //一局都没玩过，开桌超过30分钟， 清桌
  E_LeaveFromTimeOut_Offline = 8, //所有人都掉线，开桌超过2个小时(这个是设在ChessSvr.ini)， 清桌
  E_LeaveForDissolution = 9, //玩家直接解散桌子
  E_LeaveFromTimeOut_NotReady = 10, //玩家一局没玩过，进来又不举手，则超时默认时间就踢掉
  E_LeaveForMonitorDissolution = 11, //php强制直接解散桌子
]]
  if msg._st == "rsp" then
    --return
  elseif msg._st == "nti" then
    if msg._para.reason ~= nil then
		if msg._para.reason == 3 or msg._para.reason == 4 then
			Trace("中途退出或者牌局到达上限退出")
			vote_quit_ui.Hide()
			message_box.Close(MessageBoxType.vote)
			Notifier.dispatchCmd(cmdName.GAME_SOCKET_LUMP_SUM, nil)
			return
		elseif msg._para.reason == 2 then    
			msg.time = os.clock()
			this.AddMsgToQueue("leave", msg)
			return
		elseif msg._para.reason > 1 and msg._para.reason < 10 then
			if msg._para.reason == 5 then
			  message_box.ShowGoldBox(GetDictString(6026), {function ()message_box.Close()end}, {"fonts_01"})
			end
		else
			msg.time = os.clock()
			this.AddMsgToQueue("leave", msg)
			return        
      end
    end 
  end

  SocketManager:closeSocket("game")
  game_scene.DestroyCurSence()    
  game_scene.gotoHall()
end


--[[--
 * @Description: 错误处理  
 ]]
function this.ErrorEventHandler(msg)
  if msg._para.id == 10005 then
    Notifier.dispatchCmd(cmd_shisanshui.MSG_CARD_XIANGGONG)
  end
end


--[[--
 * @Description: 推送数据处理  
]]

function this.UpdataInfoHandle(msg)
    local tmp = msg._para.msg
    --local t = json.encode(tmp)
    local s=string.gsub(tmp,"\\/","/")
    s=string.sub(s, 1, -1)
    Trace(s)
    if s== nil or s =="" then
      return
    end
    --s= unicode_to_utf8(s)
    Trace(s)
    local t = json.decode(s)
    if t ~= nil then 
      if t["type"] == 10004 then
          http_request_interface.getAccount("",function (str)
              local t=ParseJsonStr(str) 
              local ret = t.ret
              if ret and tonumber(ret) == 0 then
                  local account = t.account
                  local card = account.card 
                  Notifier.dispatchCmd(cmdName.MSG_ROOMCARD_REFRESH,card) 
                  Trace("card"..card)
              end
          end)
      end
      if t["type"] == 10006 then 
         Notifier.dispatchCmd(cmdName.MSG_HASACTIVITY,t.data.hasact)
      end
      if t["type"]==10007 then 
          if tonumber(t.data.appid) ~= global_define.appId then   --验证appid过滤公告
				return
          end 
          if tonumber(t.data.dtype)==tonumber(data_center.GetUserInfoTbl().passport.dtype) or tonumber(t.data.dtype)==0 then  --0全部 1安卓 2IOS
             Trace(t.data.dtype)
             Trace(data_center.GetUserInfoTbl()["xlb"].ptype.."dd")
             if tonumber(t.data.ptype)==tonumber(data_center.GetUserInfoTbl()["xlb"].ptype) or tonumber(t.data.ptype)==0 then --0全部 1代理商 2 普通
                Trace(t.data.ptype) 
                notice_ui.Show(t.data.msg,5)
             end
          end
      end
      if t["type"]==10008 then 
		game_scene.gotoLogin() 
    game_scene.GoToLoginHandle() 
      end
   end
end

--聊天
function this.OnPlayerChat( msg )
  Notifier.dispatchCmd(cmdName.GAME_SOCKET_CHAT,msg)
end

function this.AccountSuspended(msg)
  Notifier.dispatchCmd(cmdName.MSG_FREEZE_USER,msg)
end