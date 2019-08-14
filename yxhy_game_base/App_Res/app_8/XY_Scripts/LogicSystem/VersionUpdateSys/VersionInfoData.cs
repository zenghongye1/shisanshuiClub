using UnityEngine;
using System.Collections;
using Framework;
using XYHY;
using NS_VersionUpdate;

public class VersionInfoData
{
    private static VersionInfo mVerInfo = null;
    public static VersionInfo CurrentVersionInfo
    {
        get
        {
            if (mVerInfo == null)
            {
                mVerInfo = FileUtils.GetCurrentVerNo();
            }
            return mVerInfo;
        }
        set
        {
            mVerInfo = value;
            if (mVerInfo != null)
            {
                //测试用，后续可以放到第三方log平台显示
                Debug.Log("GameAppInstaller.channel=" + GameAppInstaller.channel + " mVerInfo.VersionNum=" + mVerInfo.VersionNum + " GameAppInstaller.user=" + GameAppInstaller.user);
            }
        }
    }
    
    private static VersionUpdateType curVersionUpdateType = VersionUpdateType.NoNeedUpdate;
    public static VersionUpdateType CurVersionUpdateType
    {
        get
        {
            return curVersionUpdateType;
        }
        set
        {
            curVersionUpdateType = value;
        }
    }
}
