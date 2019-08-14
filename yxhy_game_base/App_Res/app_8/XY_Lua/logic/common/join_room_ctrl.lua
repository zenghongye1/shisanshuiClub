--[[--
 * @Description: 加入房间逻辑处理
 * @Author:      shine
 * @FileName:    join_room_ctrl.lua
 * @DateTime:    2017-07-20 17:31:19
 ]]

require"logic/hall_sys/openroom/room_data"

join_room_ctrl = {}
local this = join_room_ctrl


function this.ReEnterRoomByQuery(_dsts)
    --重弹窗口处理
    message_box.ShowGoldBox(GetDictString(6022), {function ()
            message_box.Close()
        end, function ()
            local tbl = {_dst = _dsts[1]}
            Trace("reEnterData---------------------------------------"..GetTblData(tbl))
            this.EnterGameHandle(tbl)
            message_box.Close()
        end}, {"quxiao","queding"},{"button_03","button_02"})
end


--[[--
 * @Description: 加入房间处理  
 ]]
function this.JoinRoomByRno(rno)
    --Trace("JoinRoomByRno start--------------------------------------")
    http_request_interface.getRoomByRno(rno, function (str)
        --waiting_ui.Hide()
        local s = string.gsub(str, "\\/", "/")
        local dataTbl = ParseJsonStr(s)

        if dataTbl ~= nil then

            --根据_dsts来确定是否重连，如果有就重连，木有就不重连
            if dataTbl._dsts ~= nil and #dataTbl._dsts > 0 then               
                this.ReEnterRoomByQuery(dataTbl._dsts)            
            else
                if tonumber(dataTbl.ret)~=0 then
                    waiting_ui.Hide()
                    if tonumber(dataTbl.ret) == 100 then
                        fast_tip.Show(GetDictString(6001))
                    elseif tonumber(dataTbl.ret) == 101 then
                        fast_tip.Show(GetDictString(6004)) 
                    end
                    return
                end

                if dataTbl.data.gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
                    shisangshui_room_ui.EnterGameReq(dataTbl)
                else
                    fuzhoumj_room_ui.EnterGameReq(dataTbl)
                end
            end
        end        
    end)   
end

function this.CreateRoomHandler(dataTbl)
    waiting_ui.Hide()
    local content = "房间开设成功！房号："..tostring(dataTbl.data.rno).."\n请确认你是否参与对局？"
    message_box.ShowGoldBox(content, 
         {function() 
            if dataTbl.data.gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then 
                invite_sys.inviteFriend(dataTbl.data.rno, "十三水", tostring(room_data.GetShareString()))
            else
                invite_sys.inviteFriend(dataTbl.data.rno, "福州麻将", roomdata_center.gameRuleStr)
            end
            --message_box.Close()             
        end, 
        function()
            if dataTbl.data.gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
                shisangshui_room_ui.EnterGameReq(dataTbl)
            else
                fuzhoumj_room_ui.EnterGameReq(dataTbl)
            end            
            message_box.Close() 
        end}, 
        {"fonts_28", "fonts_29"}, {"button_03","button_02"})      
end


function this.CreateRoom(data)
    http_request_interface.createRoom(data, function (str)
        --waiting_ui.Hide()
        local s = string.gsub(str, "\\/", "/")
        local dataTbl = ParseJsonStr(s)
        Trace(str)
        if dataTbl ~= nil then

            --根据_dsts来确定是否重连，如果有就重连，木有就不重连
            if dataTbl._dsts ~= nil and #dataTbl._dsts > 0 then               
                this.ReEnterRoomByQuery(dataTbl._dsts)            
            else
                if tonumber(dataTbl.ret)~=0 then
                    waiting_ui.Hide()
                    if tonumber(dataTbl.ret) == 100 then
                        fast_tip.Show(GetDictString(6001))
                    elseif tonumber(dataTbl.ret) == 101 then
                        fast_tip.Show(GetDictString(6004))
                    elseif tonumber(dataTbl.ret)==102 then
                        message_box.ShowGoldBox(GetDictString(6046),{function()message_box.Close() end, function() message_box.Close()
                        hall_ui.shop()end},{"quxiao","queding"},{"button_03","button_02"})
                    end
                    return
                end
        
                if dataTbl.nextaction == 0 then
                    this.CreateRoomHandler(dataTbl)
                elseif dataTbl.nextaction == 1 then
                    if dataTbl.data.gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
                        shisangshui_room_ui.EnterGameReq(dataTbl)
                    else
                        fuzhoumj_room_ui.EnterGameReq(dataTbl)
                    end                      
                end                
            end
        end        
    end)     
end


--[[--
 * @Description: 查询状态（进入游戏时候调用）  
 ]]
function this.QueryState(callback)
  http_request_interface.QueryStatus({}, function (str)
     local s=string.gsub(str,"\\/","/")
     Trace("QueryState--------------------------------"..tostring(s))
     local t=ParseJsonStr(s)   
     if t._dsts ~= nil and #t._dsts > 0 then     
        local tbl = {_dst = t._dsts[1]}
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
    mahjong_play_sys.EnterGameReq(data)
    player_data.SetReconnectEpara(data) 
end