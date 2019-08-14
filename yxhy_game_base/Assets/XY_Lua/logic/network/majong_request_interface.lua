require "logic/network/majong_request_protocol"
require "logic/network/messagedefine"


majong_request_interface = {}
local this = majong_request_interface

--请求进入游戏
function this.EnterGameReq(gameData)
   local userInfo =  data_center.GetLoginUserInfo()
   local session_key = userInfo.sessionkey
    
    local srvName = ""
    local srvID = nil

    local version = YX_APIManage.Instance:getHuTipsVersion()

    if gameData._dst ~= nil then
      srvName = gameData._dst._svr_t
      srvID = gameData._dst._svr_id
    else
      srvName = gameData._svr_t 
      srvID = gameData._svr_id

      if srvName == nil or srvID == nil then
        srvName = "chess"
        srvID = 1
      end
    end

    local urlStr = string.format(global_define.gamewsurl, srvName, srvID, data_center.GetLoginUserInfo().uid, session_key)
    SocketManager:createSocket("game", urlStr, srvName, tonumber(srvID), gameData._dst)

    SocketManager:onGameOpenCallBack(function ()
      Trace("onGameOpenCallBack-------- EnterGameReq")
      local pkgBuffer = majong_request_protocol.EnterGameReq(gameData, version)
      network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL, pkgBuffer)
    end)
end

-- 请求准备游戏
function this.ReadyGameReq(_tableId, _seat)
    local pkgBuffer = majong_request_protocol.ReadyGame(messagedefine.chessPath,_tableId, _seat);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer));
   network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

-- 请求开始
function this.ApplyForReq(nChair, bStatus)
    local pkgBuffer = majong_request_protocol.ApplyForGame(nChair, bStatus);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer));
   network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--进入大厅查询游戏状态(重连)
function this.QueryGameStateReq(paraData)
    local pkgBuffer = majong_request_protocol.QueryGameState(messagedefine.onlinePath, paraData);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL, pkgBuffer)
end

--下跑
function this.XiaPaoReq(beishu,tableID,seat)
     local pkgBuffer = majong_request_protocol.requestXiaPao(messagedefine.chessPath,beishu,tableID,seat);
       Trace("pkgBuffer==================================="..tostring(pkgBuffer));
   network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--买自摸
function this.BuySelfdrawReq(buyselfdraw,tableID,seat)
     local pkgBuffer = majong_request_protocol.requestBuySelfdraw(messagedefine.chessPath,buyselfdraw,tableID,seat);
       Trace("pkgBuffer==================================="..tostring(pkgBuffer));
   network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--出牌
function this.OutCardReq(playPara,tableID,seat)
    local pkgBuffer = majong_request_protocol.requestOutCard(messagedefine.chessPath,playPara,tableID,seat);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--糊牌
function this.HuPaiReq(cardValue,tableID,seat)
    local pkgBuffer = majong_request_protocol.requestHu(messagedefine.chessPath,cardValue,tableID,seat);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--听牌
function this.TingReq()
    local pkgBuffer = majong_request_protocol.requestTing();
      Trace("pkgBuffer==================================="..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--抢听
function this.QiangTingReq(cardValue)
    local pkgBuffer = majong_request_protocol.requestQiangTing(cardValue);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--碰牌
function this.TripletReq(cardtbl,tableID,seat,nbzz)
   local pkgBuffer = majong_request_protocol.requestTriplet(messagedefine.chessPath,cardtbl,tableID,seat,nbzz);
     Trace("pkgBuffer==================================="..tostring(pkgBuffer))
   network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--杠牌
function this.QuadrupletReq(cardtbl,tableID,seat,nbzz)
    local pkgBuffer = majong_request_protocol.requestQuadruplet(messagedefine.chessPath,cardtbl,tableID,seat,nbzz);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer))
   network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--吃牌
function this.CollectReq(cardCollect,tableID,seat)
    local pkgBuffer = majong_request_protocol.requestCollect(messagedefine.chessPath,cardCollect,tableID,seat);
    Trace("pkgBuffer==================================="..tostring(pkgBuffer))
   network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--亮喜儿牌
function this.LiangXiErReq(cardLiangXiEr,tableID,seat)
    local pkgBuffer = majong_request_protocol.requestLiangXiEr(messagedefine.chessPath,cardLiangXiEr,tableID,seat);
    Trace("pkgBuffer==================================="..tostring(pkgBuffer))
   network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--过（放弃）
function this.GiveUp(tableID,seat)
    local pkgBuffer = majong_request_protocol.requestGiveUp(messagedefine.chessPath,tableID,seat);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--重新进入游戏
function this.reEnterGameReq(gameID,gameRule, tingVersion)
    local pkgBuffer = majong_request_protocol.reEnterGame(messagedefine.chessPath,gameID,gameRule, tingVersion);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer));
   network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--申请退出，请求合局
function  this.VoteDrawReq(flag, tableID,seat)
    local pkgBuffer = majong_request_protocol.requestVoteDraw(messagedefine.chessPath,flag, tableID,seat);
    -- logError("pkgBuffer==================================="..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--玩家退出
function this.LeaveReq(tableID,seat)
     local pkgBuffer = majong_request_protocol.requestLeave(messagedefine.chessPath, tableID, seat);
       Trace("pkgBuffer==================================="..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

function this.Dissolution( gid, tableid, seat)
    local pkgBuffer = majong_request_protocol.requestDissolution(messagedefine.chessPath, gid, tableid, seat);
       Trace("pkgBuffer==================================="..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--聊天
function this.ChatReq(contenttype,content,tableID,seat,geivewho)
    local pkgBuffer = majong_request_protocol.requestChat(messagedefine.chessPath,contenttype,content,tableID,seat,geivewho);
    Trace("pkgBuffer==================================="..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--心跳
function this.HeartBeatReq(session)
     local pkgBuffer = majong_request_protocol.HeartBeat(messagedefine.chessPath, session);
      Trace("pkgBuffer==================================="..tostring(pkgBuffer));
     network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL, pkgBuffer)
end