/*******************************************************************************
*Author         :  xuemin.lin
*Description    :  游戏里面有一些需要宏定义的字符串都写在这里。可以统一管理
*Other          :  none
*Modify Record  :  none
*******************************************************************************/

using UnityEngine;
using System.Collections;

public class GameDefine
{
    #region 服务器协字段定义
    public static readonly string   s_Events = "_events";
    public static readonly string   s_Cmd = "_cmd";
    public static readonly string   s_sn = "_sn";
    public static readonly string   s_HeartBeat = "heart_beat";
    public static readonly string   s_SyncTable = "sync_table";
    public static readonly string   s_SplitString = "http_req@@@@";
    public static readonly string   s_onlineStr = "online";
    public static readonly string   s_svrt = "_svr_t";
    public static readonly string   s_chessStr = "chess";
    public static readonly string   s_LobbyKey = "online/1";
    public static readonly string   s_roomKey = "chess/1";
    public static readonly int      s_ArrayIndex = 0;
    #endregion

    public static readonly uint     s_MaxReconnectTimes = 3;
    public static readonly float     s_HeartBeatTimeOut = 3;
}
