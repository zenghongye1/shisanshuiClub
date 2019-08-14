using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

/// <summary>
/// BundleLoader用于进行资源的加载，版本的控制
/// </summary>
public class XyhyGlobal
{
    /// <summary>
    /// 获取当前版本是发布版，还是开发版
    /// RELEASE_VER为发布版，否则就为研发版
    /// </summary>
    /// <returns>如果是发布版返回true，否则返回false</returns>
    public static bool IsReleaseVersion
    {
        get
        {
            #if RELEASE_VER
                return true;
            #else
                return false;
            #endif
        }
    }

    //是否是加载资源包
    public static bool IsLoadAssetBundle
    {
        get
        {
#if UNITY_EDITOR && !AB_MODE
            return false;
#else
            return true;
#endif
        }
    }
}
