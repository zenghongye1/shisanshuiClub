--[[--
 * @Description: 加入房间逻辑处理
 * @Author:      shine
 * @FileName:    join_room_ctrl.lua
 * @DateTime:    2017-07-20 17:31:19
 ]]

require "logic/hall_sys/openroom/room_data"
require "logic/poker_sys/common/network/poker_play_sys"

join_room_ctrl = {}
local this = join_room_ctrl


function this.ReEnterRoomByQuery(_dst)
    --重弹窗口处理
     MessageBox.ShowYesNoBox(LanguageMgr.GetWord(6022),
        function() 
            local tbl = {_dst = _dst}
            this.EnterGameHandle(tbl)
        end)
end


--[[--
 * @Description: 加入房间处理  
 ]]
function this.JoinRoomByRno(rno)
    --Trace("JoinRoomByRno start--------------------------------------")
    -- http_request_interface.getRoomByRno(rno, function (str)
    --     --waiting_ui.Hide()
    --     local s = string.gsub(str, "\\/", "/")
    --     local dataTbl = ParseJsonStr(s)
    --     if dataTbl ~= nil then
    --         Trace("JoinRoom:-----------------"..GetTblData(dataTbl))
    --         if tonumber(dataTbl.ret)~=0 then
    --             model_manager:GetModel("ClubModel"):CheckMsgRet(dataTbl)
    --             return
    --         else
    --             --根据_dsts来确定是否重连，如果有就重连，木有就不重连
    --             if dataTbl._dsts ~= nil and #dataTbl._dsts > 0 then  
    --              --重连必须重以_dsts里面的_gid为准。目前暂时只取第一个，其它忽略
    --                 data_center.SetCurGameID(dataTbl._dsts[1]._gid)
    --                 this.ReEnterRoomByQuery(dataTbl._dsts)            
    --             else
    --                 data_center.SetCurGameID(dataTbl.data.gid)
    --                 this.EnterType(dataTbl)
    --             end     
    --         end 
    --     end
    -- end)  

    this.GetRoomByRno(rno, function(dataTbl)  
        Trace("JoinRoom:-----------------"..GetTblData(roomInfo))
           --根据_dsts来确定是否重连，如果有就重连，木有就不重连
        if dataTbl._dst ~= nil and dataTbl._dst._gid ~= nil then  
         --重连必须重以_dsts里面的_gid为准。目前暂时只取第一个，其它忽略
            data_center.SetCurGameID(dataTbl._dst._gid)
            this.ReEnterRoomByQuery(dataTbl._dst)            
        else
            data_center.SetCurGameID(dataTbl.roominfo.gid)
            this.EnterType(dataTbl)
        end     
    end, true)


end

function this.CreateRoomHandler(dataTbl)
    Trace("CreateRoomHandler-----------"..GetTblData(dataTbl))
    -- waiting_ui.Hide()
    UI_Manager:Instance():CloseUiForms("waiting_ui")
    if game_scene.getCurSceneType() ~= scene_type.HALL then
        return
    end
    
    --TER0327-label
    local content = "房间开设成功！房号："..tostring(dataTbl.roominfo.rno).."\n请确认是否立即进入房间？"
    local inviteInfo = MessageBox.GetBtnInfo("邀请好友", "button_05", function() this.OnInvite(dataTbl) end)
    local enterGameInfo = MessageBox.GetBtnInfo("进入房间","button_03", function() this.JoinRoomByRno(dataTbl.roominfo.rno) MessageBox:Hide() end)

    --苹果审核隐藏界面
    if G_isAppleVerifyInvite then
        MessageBox.Show(content, {enterGameInfo},nil,false)
        return
    end

    MessageBox.Show(content, {enterGameInfo,inviteInfo},nil,false)
end

function this.OnInvite(dataTbl)
    report_sys.EventUpload(25)
	invite_sys.inviteToRoom(dataTbl.roominfo.rno,GameUtil.GetGameName(dataTbl.roominfo.gid),ShareStrUtil.GetRoomShareStr(dataTbl.roominfo.gid, dataTbl.roominfo,nil,true),dataTbl.roominfo.cid)
end

function this.OnEnterGame(dataTbl)
    -- waiting_ui.Show()
    UI_Manager:Instance():ShowUiForms("waiting_ui")
    report_sys.EventUpload(26)
    this.EnterType(dataTbl)
end


function this.CreateRoom(data)
     UI_Manager:Instance():ShowUiForms("waiting_ui")
    http_request_interface.createRoom(data, function (str)
        --waiting_ui.Hide()
        local s = string.gsub(str, "\\/", "/")
        local dataTbl = ParseJsonStr(s)
        if dataTbl ~= nil then
            Trace("CreateRoom:-----------------"..GetTblData(dataTbl))
            if tonumber(dataTbl.ret)~=0 then
                -- waiting_ui.Hide()
                UI_Manager:Instance():CloseUiForms("waiting_ui")
                model_manager:GetModel("ClubModel"):CheckMsgRet(dataTbl)
                if tonumber(dataTbl.ret)==102 then
                    this.OnNotEnough()
                end
            else            
                
                --根据_dsts来确定是否重连，如果有就重连，木有就不重连
                if dataTbl._dsts ~= nil and #dataTbl._dsts > 0 then   
                     --重连必须重以_dsts里面的_gid为准。目前暂时只取第一个，其它忽略
                    data_center.SetCurGameID(dataTbl._dsts[1]._gid)
                    this.ReEnterRoomByQuery(dataTbl._dsts)            
                else
                    ----水庄十三水玩法直接enter
                    --if dataTbl["data"]["cfg"]["nWaterBanker"] ~= nil and dataTbl["data"]["cfg"]["nWaterBanker"] == 1 then
                    --   this.EnterType(dataTbl)
                    -- else
                        this.CreateRoomHandler(dataTbl)
                    -- end               
                end
            end
            
        end        
    end)     
end

function this.OnNotEnough()
    MessageBox.ShowYesNoBox(LanguageMgr.GetWord(6046), function ()
        UIManager:ShowUiForms("shop_ui")
    end)
end

function this.CreateClubRoom(data)
    UI_Manager:Instance():ShowUiForms("waiting_ui")
    --http_request_interface.createClubRoom(data, function (str)
    local param = {}
    param.param = data
    HttpProxy.SendRoomRequest(HttpCmdName.ClubCreateClubRoom, param, function(dataTbl)
        --waiting_ui.Hide()
        -- local s = string.gsub(str, "\\/", "/")
        -- local dataTbl = ParseJsonStr(s)
        if dataTbl ~= nil then
            Trace("CreateClubRoom:-----------------"..GetTblData(dataTbl))
            -- if tonumber(dataTbl.ret)~=0 then
            --     UI_Manager:Instance():CloseUiForms("waiting_ui")
            --     model_manager:GetModel("ClubModel"):CheckMsgRet(dataTbl)
            -- else            
                --设置当前的gameid
			data_center.SetCurGameID(dataTbl["roominfo"]["gid"])
			--根据_dsts来确定是否重连，如果有就重连，木有就不重连
			if dataTbl._dst ~= nil and dataTbl._dst._gid ~= nil then  
				 --重连必须重以_dsts里面的_gid为准。目前暂时只取第一个，其它忽略
				data_center.SetCurGameID(dataTbl._dst._gid)
				this.ReEnterRoomByQuery(dataTbl._dst)            
			else
				----十三水水庄玩法直接enter
				--if dataTbl["roominfo"]["gid"] ~= nil and dataTbl["roominfo"]["gid"] == ENUM_GAME_TYPE.TYPE_ShuiZhuang_SSS then
				--	this.JoinRoomByRno(dataTbl.roominfo.rno)
				--else
					this.CreateRoomHandler(dataTbl)
				--end                 
			end
        end        
    end)     
end


--[[--
 * @Description: 查询状态（进入游戏时候调用）  
 ]]
function this.QueryState(callback)
  HttpProxy.SendUserRequest(HttpCmdName.QueryStatus, nil, function(data) 
    local dst = data._dst
    if dst and dst._gid then     
      local tbl = {_dst = dst}
      --设置当前的gameid
      Trace("_dsts[1]._gid===================="..tostring(dst._gid))
      data_center.SetCurGameID(dst._gid)
      this.EnterGameHandle(tbl)
    else
      if callback ~= nil then
          callback()
      end
    end
    end)
end


--[[--
 * @Description: 进入游戏处理  
 ]]
function this.EnterGameHandle(data)
    local gid = data._dst._gid
    this.CheckDownGame(gid, function()
        mahjong_play_sys.EnterGameReq(data)
        player_data.SetReconnectEpara(data) 
    end)
end


function this.EnterType(dataTbl)
    this.CheckDownGame(dataTbl.roominfo.gid, function()  
        if GameUtil.CheckGameIdIsMahjong(dataTbl.roominfo.gid) then
            majong_request_interface.EnterGameReq(dataTbl.roominfo)
		else
			Trace("进入扑克房间")
			poker_play_sys.EnterGameReq(dataTbl.roominfo)
        end                              
    end)
end

function this.ShowDownLoadTip(gid, size)
    local gameName = GameUtil.GetGameName(gid)
    MessageBox.ShowYesNoBox("您尚未安装" .. gameName .. "，是否立即加载？", 
        function (size) 
            NS_VersionUpdate.AssetUpdateManager.Instance:RealDownGameAsset() 
        end, nil)
end



function this.GetRoomByRno(roomNum, callback, showwaiting, noTips, errorHandler)
    local param = {}
    local sendCfg = {}
    sendCfg.showWaiting = showwaiting
    sendCfg.noTips = noTips
    sendCfg.errorHandler = errorHandler
    param.rno = roomNum
    HttpProxy.SendRoomRequest(HttpCmdName.GetRoomByRno, param,
        function(roominfo, error)
            if callback ~= nil then
                callback(roominfo)
            end
        end, nil, sendCfg)
end



function this.CheckDownGame(gid, callback)
    if not GameUtil.CheckNeedDown(gid) then
        callback()
        return
    end
    local resId = GameUtil.GetResId(gid)
    local verInfo = FileUtils.GetGameVerNo("ver_game_" .. resId .. ".txt")
    local depName = "dep_game_" .. resId .. ".all"
    local verNum = verInfo and verInfo.VersionNum or "0"
    local uid = nil
    if (PlayerPrefs.HasKey("USER_UID")) then
        uid = PlayerPrefs.GetString("USER_UID");
    end

    print("请求版本号先去掉")
    callback()
    --请求版本号先去掉
    -- GameKernel.GetResourceMgr().LoadGameDep(depName, function() 
    --     http_request_interface.GetVersionUp(verNum, 
    --         function(str)
    --             local s = string.gsub(str, "\\/", "/")
    --             Trace("CheckDownGame---------------"..str)
    --             local dataTab = ParseJsonStr(s)
    --             if dataTab ~= nil and dataTab.ret == 0 then
    --                 if dataTab.updateInfo ~= nil and dataTab.updateInfo.hotUpdate ~= nil then
    --                     local isNeed = dataTab.updateInfo.hotUpdate.isNeed or false
    --                     if isNeed then
    --                         local url = dataTab.updateInfo.hotUpdate.url
    --                         NS_VersionUpdate.AssetUpdateManager.Instance:StartDownloadGame(url, resId,function() 
    --                             if callback  then
    --                                 callback()
    --                             end
    --                         end, function(size) this.ShowDownLoadTip(gid, size) end )
                            
    --                     else
    --                         if(callback ~= nil) then
    --                             callback()
    --                         end
    --                     end
    --                 end
    --             end
    --         end
    --     , gid)
        end)


 --    if this.assetUpdateMgr == nil then
 --        this.assetUpdateMgr = GameObject.Find("uiroot_xy/Camera/version_update_ui(Clone)"):GetComponent(typeof(NS_VersionUpdate.AssetUpdateManager))
 --        if this.assetUpdateMgr == nil then
 --            return
 --        end
 --    end
 --            logError("1236")
 --    this.assetUpdateMgr:EnterGameHotHander(global_define.appConfig.appId, tostring(gid), "0", "",function ()
 --        logError("1235")
 --        if(callback ~= nil) then
 --            callback()
 --        end

    --  -- GameKernel.GetResourceMgr().LoadGameDep("dep_game_" .. gid .. ".all", callback)
    -- end)
end

