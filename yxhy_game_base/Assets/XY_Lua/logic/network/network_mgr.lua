--[[--
 * @Description: 游戏服务通道lua代理
                 用来进行网络数据接收处理，发包时需要注册收包函数，并可以取消注册
                 network_mgr建立在一个时期内，只能有一条链接存在
 * @Author:      shine
 * @FileName:    network_mgr.lua
 * @DateTime:    2017-05-26 16:53:13
 ]]

require "logic/network/http_request_interface"

network_mgr = {}
local this = network_mgr

this.CMD_LOGIN_HALL = 0
this.CMD_HEARTBEAT = 223344

function this.sendPkgWaitForRsp( cmdID, pkgBuffer )
    -- LogW("sendPkgWaitForRsp------",cmdID,pkgBuffer )
    SocketManager:onGameSendData(pkgBuffer)
end

function this.sendPkgNoWaitForRsp( cmdID, pkgBuffer )
    -- LogW("sendPkgNoWaitForRsp------",cmdID,pkgBuffer )
    SocketManager:onGameSendData(pkgBuffer)
end

--[[--
 * @Description: 切换网络状态  
 ]]
function this.NetworkReachability(netstate)
    Trace("netstate------------------------"..tostring(netstate))
    if netstate == 2 then   --2 代表wifi 
        UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6018))
    elseif netstate == 1 then  --1 代表移动
        UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6019))
    elseif netstate == 0 then  --0 无网络
        UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6044))
    end
    
    SocketManager:reconnect()
end

local durationTime = 0
function this.AppPauseNotify(pause)    
    if pause == 1 then
        durationTime = os.time()
    else
        durationTime = os.time() - durationTime
        --Trace("durationTime2-----------------------"..tostring(os.time()))   
        SocketManager:setLeaveTime(durationTime)
		if game_scene.getCurSceneType() == scene_type.HALL then
			Notifier.dispatchCmd(cmdName.MSG_APP_NOTIFY)  
		end
    end  


end


