/********************************************************************
	created:	2017/05/15  11:49
	file base:	ProjectConfigInfo
	file ext:	cs
	author:		shine

	purpose:    项目设置信息
*********************************************************************/

using UnityEngine;
using System.Collections;

namespace XYHY
{
    /// <summary>
    /// 项目设置信息
    /// </summary>
    public class ProjectConfigInfo
    {
        /// <summary>
        /// 游戏版本校验地址
        /// </summary>
        public string VersionCheckUrl;

        /// <summary>
        /// 游戏服务器IP地址
        /// </summary>
        public string GameServerIp;

        /// <summary>
        /// 游戏服务器端口
        /// </summary>
        public int GameServerPort;

        /// <summary>
        /// 是否有 debug 日志输出
        /// </summary>
        public bool HasDebugLogOutput;
    }
}


