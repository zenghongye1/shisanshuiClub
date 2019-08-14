
using System.Collections;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.ComponentModel;
using System;
using System.Threading;
using UnityEngine;
using LuaInterface;
using TingInfo;
using System.IO;

public class YX_APIManage : Singleton<YX_APIManage>
{
    private static AndroidInterface androidInterface;    
    const int SYSTEM_UI_FLAG_IMMERSIVE_STICKY = 4096;    
    const int SYSTEM_UI_FLAG_HIDE_NAVIGATION = 2;
    const int SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION = 512;
    const int SYSTEM_UI_FLAG_FULLSCREEN = 4;
    const int SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN = 1024;

    AndroidJavaObject decorView;
    AndroidJavaObject activity;
    huTips huCount;
    string strBattery;

    public void Awake()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface = new AndroidInterface();
        if(androidInterface != null)
            Debug.Log("androidInterface aleard Create");
        //print("**********HideAndroidButtons.Awake()**********");
        AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        activity = jc.GetStatic<AndroidJavaObject>("currentActivity");
        AndroidJavaObject window = activity.Call<AndroidJavaObject>("getWindow");
        decorView = window.Call<AndroidJavaObject>("getDecorView");

        TurnImmersiveModeOn();
#endif
        huCount = new huTips();
    }

    public delegate void DelegateNetHallCallBack();
    public DelegateNetHallCallBack delegateNetHallCallBack;
    public void setHallTimer(DelegateNetHallCallBack delegateNet)
    {
        delegateNetHallCallBack = delegateNet;
    }
    public delegate void DelegateNetGameCallBack();
    public DelegateNetGameCallBack delegateNetGameCallBack;
    public void setGameTimer(DelegateNetGameCallBack delegateNet)
    {
        delegateNetGameCallBack = delegateNet;
    }

    //检测网络状态，如果网络状态有变动则做相应的处理
    private NetworkReachability m_currentReachability;
    public NetworkReachability CurrentReachability
    {
        get { return m_currentReachability; }
        set
        {
            if (m_currentReachability != value)
            {
                m_currentReachability = value;
                switch (m_currentReachability)
                {
                    case NetworkReachability.NotReachable:
                        break;
                    case NetworkReachability.ReachableViaCarrierDataNetwork:
                        break;
                    case NetworkReachability.ReachableViaLocalAreaNetwork:
                        break;
                }
            }
        }
    }

    private void Start()
    {
        CurrentReachability = Application.internetReachability;
    }

    public void Update()
    {
        if (delegateNetHallCallBack != null)
        {
            delegateNetHallCallBack();
        }
        if (delegateNetGameCallBack != null)
        {
            delegateNetGameCallBack();
        }

        //检查网络状态
        if (CurrentReachability != Application.internetReachability)
        {
            CurrentReachability = Application.internetReachability;
            CheckNetState(CurrentReachability);
        }

        if(needCallback)
        {
            needCallback = false;
            if (tingCallback != null)
            {
                tingCallback(tingCount, tingVersion);
                tingCallback = null;
                tingCount = -1;
                tingVersion = -1;
                tingCallback = null;
            }
        }
    }

    void CheckNetState(NetworkReachability netState)
    {
        //Debug.Log("NetworkReachability-------------------------------");
        if (LuaClient.Instance == null)
            return;
        if (LuaClient.GetMainState() == null)
            return;
        LuaFunction func = LuaClient.GetMainState().GetFunction("network_mgr.NetworkReachability");
        if (func != null)
        {
            func.BeginPCall();
            func.Push((int)netState);
            func.PCall();
            func.EndPCall();
            func = null;
        }
    }

    private void OnApplicationPause(bool isPause)
    {
        if (LuaClient.GetMainState() == null) return;
        if (isPause)
        {
            LuaFunction func = LuaClient.GetMainState().GetFunction("network_mgr.AppPauseNotify");
            if (func == null)
                return;
            func.BeginPCall();
            func.Push(1);
            func.PCall();
            func.EndPCall();
            func = null;
        }
        else
        {
            LuaFunction func = LuaClient.GetMainState().GetFunction("network_mgr.AppPauseNotify");
            if (func == null)
                return;
            func.BeginPCall();
            func.Push(0);
            func.PCall();
            func.EndPCall();
            func = null;
        }
    }

    //获取地理坐标回调
    public void getLocationDataCallBack(string jsonData)
    {
        if (GetLocationData != null)
        {
            GetLocationData(jsonData);
        }
    }

    private void OnApplicationFocus(bool focus)
    {

#if UNITY_ANDROID && !UNITY_EDITOR
        //print("**********HideAndroidButtons.OnApplicationFocus()**********");
        if (focus)
        {
          
      //    UnGfx.SetResolution(720, false);
        
          TurnImmersiveModeOn();
          UnGfx.SetResolution(720, true);
        }
#endif
    }

    public delegate void BatteryCallBack(string persion);
    public BatteryCallBack batteryCallBack;


    //SDK初始化
    public void InitPlugins(bool isTest)
    {
#if UNITY_IOS && !UNITY_EDITOR
			IOSInterface.Init("appid",isTest, this.gameObject.name);
#elif UNITY_ANDROID && !UNITY_EDITOR
			androidInterface.InitPlugins(isTest, this.gameObject.name);
#endif
    }

    public delegate void DelegateCheckWXInstall(string msg);
    public DelegateCheckWXInstall delegateWXInstallResp;
    public void CheckWXInstall(DelegateCheckWXInstall resp)
    {
        delegateWXInstallResp = resp;
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.CheckWXInstall();
#elif UNITY_IOS && !UNITY_EDITOR
		IOSInterface.CheckWXInstall();
#endif
    }

    public void onCheckWXInstallCallBack(string msg)
    {
        if (delegateWXInstallResp != null)
        {
            delegateWXInstallResp(msg);
        }
    }

    /// <summary>
    /// 微信登录
    /// </summary>
    ///
    public delegate void DelegateLoginResp(string msg);
    public DelegateLoginResp delegateLoginResp;
    public Action<string> GetLocationData;
    //  private Action<string> ActionLoginResp;
    public void WeiXinLogin(DelegateLoginResp resp)
    {
        delegateLoginResp = resp;
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.WeiXinLogin();
#elif UNITY_IOS && !UNITY_EDITOR
		IOSInterface.WeiXinLogin();
#endif
    }


    public delegate void DelegateShareResp(string msg);
    public DelegateShareResp delegateShareResp;

    /// <summary>
    /// 
    /// </summary>
    /// <param name="shareType">0微信好友，1朋友圈，2微信收藏</param>
    /// <param name="type">1文本，2图片，3声音，4视频，5网页</param>
    ///
    public void WeiXinShare(int shareType,int type, string title, string filePath, string url, string description, DelegateShareResp callback)
    {
        delegateShareResp = callback;
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.WeiXinShare(shareType, type, title, filePath, url, description);
#elif UNITY_IOS && !UNITY_EDITOR
		IOSInterface.WeiXinShare(shareType, type, title, filePath, url, description);
#endif
    }

    public void onWeiXinShareCallBack(string msg)
    {
        //Debug.Log("onWeiXinShareCallBack" + msg);
        if (delegateShareResp != null)
        {
            delegateShareResp(msg);
            delegateShareResp = null;
        }
    }

    public void QQLogin(DelegateLoginResp resp)
    {
        delegateLoginResp = resp;
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.QQLogin();
#elif UNITY_IOS && !UNITY_EDITOR
		IOSInterface.TencentQQLogin();
#endif
    }

    public delegate void DelegateCheckQQInstall(string msg);
    public DelegateCheckQQInstall delegateQQInstallResp;
    public void CheckQQInstall(DelegateCheckQQInstall resp)
    {
        delegateQQInstallResp = resp;
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.CheckQQInstall();
#elif UNITY_IOS && !UNITY_EDITOR
        IOSInterface.CheckQQInstall();
#endif
    }

    public void onCheckQQInstallCallBack(string msg)
    {
        if (delegateQQInstallResp != null)
        {
            delegateQQInstallResp(msg);
        }
    }
    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="shareType">0QQ好友，1空间</param>
    /// <param name="type">1文本，2图片，3声音，4视频，5网页</param>
    public void QQShare(int shareType,int type, string title, string imgPath, string url, string description, DelegateShareResp callback)
    {
        delegateShareResp = callback;
#if UNITY_ANDROID && !UNITY_EDITOR
        if (type == 5)
        {
            if (shareType == 0)
                androidInterface.QQSharRiceText(title, description, url, imgPath);
            else
                androidInterface.QQShareToQQZone(title, description, url, imgPath);
        }
        else if (type == 2)
            androidInterface.QQShareImg(imgPath, null);
#elif UNITY_IOS && !UNITY_EDITOR
		if (type == 5)
        {
            if (shareType == 0)
				IOSInterface.TencentQQSharRiceText(title, description, url, imgPath);
            else
				IOSInterface.TencentQQShareToQQZone(title, description, url, imgPath);
        }
        else if (type == 2)
				IOSInterface.TencentQQShareImg(imgPath, null);
#endif
    }


    public void YX_IsEnableBattery(bool isEnable)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.GetBattery(isEnable);
#elif UNITY_IOS && !UNITY_EDITOR
#endif
    }

    public void YX_GetPhoneStreng()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.GetPhoneStreng();
#elif UNITY_IOS && !UNITY_EDITOR
     
#endif
    }

    public void locationStart(Action<string> cb)
    {
        GetLocationData = cb;
#if UNITY_ANDROID && !UNITY_EDITOR
                androidInterface.locationStart();
#elif UNITY_IOS && !UNITY_EDITOR
            IOSInterface.locationStart();
#endif
    }

    public void locationStop()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
            androidInterface.locationStop();
#elif UNITY_IOS && !UNITY_EDITOR
        IOSInterface.locationStop();
#endif
    }

    public double getLocationDistance(double latitudeA, double longitudeA, double latitudeB, double longitudeB)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        return   androidInterface.getLocationDistance(latitudeA,longitudeA,latitudeB,longitudeB);
#elif UNITY_IOS && !UNITY_EDITOR
         return   IOSInterface.getLocationDistance(latitudeA,longitudeA,latitudeB,longitudeB);
#endif
        return 0.0;
    }

    public void onPluginsInitFinsh(string msg)
    {
        //Debug.Log("收到回调啦啦啦");
        //string dataPath = Application.dataPath;
        //Debug.Log("Application.dataPath -------" + dataPath);
    }

    public void onWeiXinLoginCallBack(string msg)
    {
        //Debug.Log("LoginCallBack:" + msg);
        if (delegateLoginResp != null)
        {
            delegateLoginResp(msg);
            delegateLoginResp = null;
        }
    }

    public void onQQLoginCallBack(string msg)
    {
        Debug.Log("onQQLoginCallBack" + msg);
        if (delegateLoginResp != null)
        {
            delegateLoginResp(msg);
            delegateLoginResp = null;
        }
    }

    public void onQQShareCallBack(string msg)
    {
        Debug.Log("onQQShareCallBack" + msg);
        if (delegateShareResp != null)
        {
            delegateShareResp(msg);
            delegateShareResp = null;
        }
    }

    public delegate void onCopyCall(string msg);
    public onCopyCall oncopyCallback;
    public void onCopyCallBack(string msg)
    { 
        if (oncopyCallback != null)
            oncopyCallback(msg);
    }
    public void onCopy(string msg, onCopyCall delegateCallback)
    {
        oncopyCallback = delegateCallback; 
#if UNITY_ANDROID && !UNITY_EDITOR
        string callbackname="";
        androidInterface.onCopy(msg);
#elif UNITY_IOS && !UNITY_EDITOR
		IOSInterface.CopyToClipboard(msg);
#endif
    }

    public delegate void getCopyCall(string msg);
    public getCopyCall getcopyCallback;
    public void getCopyCallBack(string msg)
    {
        //Debug.Log("getCopyCallback----------------"+ msg);
        msg = msg.Replace("\\", "\\\\");
        if (getcopyCallback != null)
            getcopyCallback(msg);
    }
    public void getCopy(getCopyCall delegateCallback)
    {
        getcopyCallback = delegateCallback;
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.getCopyText();
#elif UNITY_IOS && !UNITY_EDITOR
		IOSInterface.GetCopyText();
#endif
    }

    //PushBegin
    // public delegate void PushUIDCallBack(string msg);
    // public PushUIDCallBack pushUIDCBack;
    // public void onPushUIDCallBack(string msg)
    // { 
    //     if (pushUIDCBack != null)
    //         pushUIDCBack(msg);
    // }
    // public void onPushUID(string msg, PushUIDCallBack delegateCallback)
    // {
    //     pushUIDCBack = delegateCallback;
    public void onPushUID(string msg)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.setPushUID(msg);
#elif UNITY_IOS && !UNITY_EDITOR
        IOSInterface.setPushUID(msg);
#endif
    }
    //PushEnd

    public void onPhoneBattery(string msg)
    {
        strBattery = msg;

        //Debug.Log("onPhoneBattery" + msg);
        if (batteryCallBack != null)
        {
            batteryCallBack(msg);
        }
    }

    public void setBatteryCallback(BatteryCallBack resp)
    {
        batteryCallBack = resp;

    }
    public void onPhoneSignal(string msg)
    {
        //Debug.Log("onPhoneSignal" + msg);
    }

    // iphoneX适配处理
    public bool isIphoneX()
    {

#if UNITY_IOS && !UNITY_EDITOR
        return IOSInterface.isIphoneX();
#endif
        return false;
    }

    public string GetPhoneBattery()
    {
//        try
//        {
//#if UNITY_ANDROID && !UNITY_EDITOR
//            string CapacityString = System.IO.File.ReadAllText("/sys/class/power_supply/battery/capacity");
//            return CapacityString;
//#else
//            return "100";
//#endif
//        }
//        catch (Exception e)
//        {
//            Debug.Log("Failed to read battery power; " + e.Message);
//        }
//        return "100";

		return strBattery;
    }

    public delegate void DelegateIAppPayResp(string msg);
    public DelegateIAppPayResp delegateIAppPayResp;
    public void startIAppPay(string msg, DelegateIAppPayResp resp)
    {
        delegateIAppPayResp = resp;
        //Debug.Log("YX_APIManager startIAppPay ");
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.startIAppPay(msg);
#endif
    }

    public void onIAppPayCallBack(string msg)
    {
        //Debug.Log("onIAppPayCallBack" + msg);
        if (delegateIAppPayResp != null)
        {
            delegateIAppPayResp(msg);
        }
    }

    //AppleStoreBegin
    public delegate void DelegateInitApplePayResp(string msg);
    public DelegateInitApplePayResp delegateInitApplePayResp;
    public void initApplePay(string _proList, DelegateInitApplePayResp resp)
    {
        delegateInitApplePayResp = resp;
#if UNITY_IOS && !UNITY_EDITOR
        IOSInterface.ApplePayInit(_proList);
#endif
    }
    public void onInitApplePayCallBack(string msg)
    {
        //Debug.Log("onInitApplePayCallBack" + msg);
        if (delegateInitApplePayResp != null)
        {
            delegateInitApplePayResp(msg);
        }
    }
    public delegate void DelegateApplePayResp(string msg);
    public DelegateApplePayResp delegateApplePayResp;
    public void applePay(string _proID, DelegateApplePayResp resp)
    {
        delegateApplePayResp = resp;
        //Debug.Log("YX_APIManager douYouPay");
#if UNITY_IOS && !UNITY_EDITOR
        IOSInterface.ApplePay(_proID);
#endif
    }

    public void onApplePayCallBack(string msg)
    {
        //Debug.Log("onApplePayCallBack" + msg);
        if (delegateApplePayResp != null)
        {
            delegateApplePayResp(msg);
        }
    }
    //AppleStoreEnd

    //DouyouBegin
    public delegate void DelegateDouyouLoginResp(string msg);
    public DelegateDouyouLoginResp delegateDouyouLoginResp;
    public void douYouLogin(string _plaformID, string _openID, DelegateDouyouLoginResp resp)
    {
        delegateDouyouLoginResp = resp;
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.DouYouLogin(_plaformID, _openID);
#endif
    }
    public void onDouYouLoginCallBack(string msg)
    {
        if (delegateDouyouLoginResp != null)
        {
            delegateDouyouLoginResp(msg);
        }
    }

    public delegate void DelegateDouYouPayResp(string msg);
    public DelegateDouYouPayResp delegateDouYouPayResp;
    public void douYouPay(string _money, string _pid, DelegateDouYouPayResp resp)
    {
        delegateDouYouPayResp = resp;
        //Debug.Log("YX_APIManager douYouPay");
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.DouYouPay(_money, _pid); //逗游支付
#endif
    }

    public void onDouYouPayCallBack(string msg)
    {
        //Debug.Log("onDouYouPayCallBack" + msg);
        if (delegateDouYouPayResp != null)
        {
            delegateDouYouPayResp(msg);
        }
    }
    //DouyouEnd

    public string onGetStoragePath()
    {        
        string filepath = "";
#if UNITY_EDITOR
        filepath = Application.persistentDataPath + "/";
#elif UNITY_IPHONE
	    filepath = Application.persistentDataPath+ "/";
#elif UNITY_ANDROID
	    filepath =  Application.persistentDataPath + "/";
#endif

        //Debug.Log("onGetStoragePath ");
        if (filepath != null)
        {
            //Debug.Log("onGetStoragePath filepath " + filepath);
            return filepath;
        }
        return "";
    }

    public string ScreenshotPath
    {
        get
        {
            return onGetStoragePath() + "screenshot/";
        }
    }

    public string read(string filename)
    {
        //Debug.Log(onGetStoragePath() + filename);
        if (System.IO.File.Exists(onGetStoragePath() + filename))
        {
            string filePath = onGetStoragePath() + filename;
            string text= System.IO.File.ReadAllText(filePath);
            //Debug.Log("read  filePath " + filePath + " text= " + text);
            return text;
        }

        return null;
    }

    public void deleteFile(string filename)
    {
        if (System.IO.File.Exists(onGetStoragePath() + filename))
        {
            string filePath = onGetStoragePath() + filename;
            //Debug.Log("deleteFile  filePath " + filePath);
            System.IO.File.Delete(filePath);
        }
    }

    public delegate void onFinishTx(UITexture tx);
    public onFinishTx onfinishtx;
    public void shake()
    {
        //Debug.Log("shake");
#if UNITY_ANDROID || UNITY_IPHONE || UNITY_IOS
        Handheld.Vibrate();
#endif
    }

    public void GetCenterPicture(string mFileName)
    {
        UITexture tx = null;
        StartCoroutine(CaptureByRect(mFileName, tx));
    }

    public void GetCenterPicture(string mFileName, float x, float y, float width, float height)
    {
        UITexture tx = null;
        //float x = 0, y = 0, width = 0, height = 0;
        //GetRectPos(go_pos,out x,out y);
        //GetLength(go2_length,out width,out height);
        StartCoroutine(CaptureByRect(mFileName, tx, x, y, width, height));
    }
    public void GetCenterPicture(string mFileName, Camera ca, float x, float y, float width, float height)
    {
        UITexture tx = null;
        StartCoroutine(CaptureByRect(mFileName, tx, ca, x, y, width, height));
    }

    public IEnumerator CaptureByRect(string mFileName, UITexture tx)
    {
        Rect mRect = new Rect(0, 0, Screen.width, Screen.height);
        //等待渲染线程结束  
        yield return new WaitForEndOfFrame();
        //初始化Texture2D  
        Texture2D mTexture = new Texture2D((int)mRect.width, (int)mRect.height, TextureFormat.RGB24, false);
        //mTexture.Compress(false);
        //读取屏幕像素信息并存储为纹理数据  
        mTexture.ReadPixels(mRect, 0, 0);
        //应用  
        mTexture.Apply(); 

        //将图片信息编码为字节信息  
        byte[] bytes = mTexture.EncodeToJPG(50);
        //保存  
        Debug.Log(ScreenshotPath + mFileName);
        //判断目录是否存在，不存在则会创建目录  
        if (!Directory.Exists(ScreenshotPath))
        {
            Directory.CreateDirectory(ScreenshotPath);
        }
        System.IO.File.WriteAllBytes(ScreenshotPath + mFileName, bytes);
        if (tx != null)
            tx.mainTexture = mTexture;
        onfinishtx(tx);
        //如果需要可以返回截图  
        //return mTexture;  
    }

    public IEnumerator CaptureByRect(string mFileName, UITexture tx, float x, float y, float width, float height)
    {
        Rect mRect = new Rect(x, y, width, height);
        print(Screen.width + ":" + Screen.height);
        //等待渲染线程结束  
        yield return new WaitForEndOfFrame();
        //初始化Texture2D  
        Texture2D mTexture = new Texture2D((int)mRect.width, (int)mRect.height, TextureFormat.RGB24, false);
        //    mTexture.Compress(false);
        RenderTexture.active = null;
        //读取屏幕像素信息并存储为纹理数据  
        mTexture.ReadPixels(mRect, 0, 0);
        //应用  
        mTexture.Apply();
        //将图片信息编码为字节信息  
        byte[] bytes = mTexture.EncodeToJPG(50);
        //保存  
        Debug.Log(YX_APIManage.Instance.onGetStoragePath() + mFileName);
        System.IO.File.WriteAllBytes(YX_APIManage.Instance.onGetStoragePath() + mFileName, bytes);
        if (tx != null)
            tx.mainTexture = mTexture;
        if (onfinishtx != null)
            onfinishtx(tx);
        //如果需要可以返回截图  
        //return mTexture;  
    }

    public IEnumerator CaptureByRect(string mFileName, UITexture tx, Camera rt, float x, float y, float width, float height)
    {
        //Image mImage;  
        RenderTexture rtr = new RenderTexture((int)width, (int)height, 0);
        rt.pixelRect = new Rect(0, 0, Screen.width, Screen.height);
        rt.targetTexture = rtr;
        yield return new WaitForEndOfFrame();
        Texture2D screenShot = new Texture2D((int)width, (int)height, TextureFormat.RGB24, false);
        rt.Render();
        RenderTexture.active = rtr;
        screenShot.ReadPixels(new Rect(x, y, width - 1, height - 1), 0, 0);
        rt.targetTexture = null;
        RenderTexture.active = null;
        //  UnityEngine.Object.Destroy(rt);
        byte[] bytes = screenShot.EncodeToPNG();
        string filename = YX_APIManage.Instance.onGetStoragePath() + mFileName;
        System.IO.File.WriteAllBytes(filename, bytes);

        if (tx != null)
            tx.mainTexture = screenShot;
        if (onfinishtx != null)
            onfinishtx(tx);
        //如果需要可以返回截图  
        //return mTexture;  
    }

    public void SavePicToPhoto(string picName)
    {
        if (Application.platform == RuntimePlatform.Android)
        {
            string destination = "/sdcard/DCIM/FuZhouMJ";
            //判断目录是否存在，不存在则会创建目录  
            if (!Directory.Exists(destination))
            {
                Directory.CreateDirectory(destination);
            }
            string Path_save = destination + "/" + picName;
            string filePath = ScreenshotPath + picName;
            byte[] bytes;
            if (System.IO.File.Exists(filePath))
            {
                bytes = System.IO.File.ReadAllBytes(filePath);
                System.IO.File.WriteAllBytes(Path_save, bytes);
            }            
        }
    }

    void TurnImmersiveModeOn()
    {
        //print("**********HideAndroidButtons.TurnImmersiveModeOn()**********");
        activity.Call("runOnUiThread", new AndroidJavaRunnable(TurnImmersiveModeOnRunable));
    }

    public void TurnImmersiveModeOnRunable()
    {
        //print("**********HideAndroidButtons.TurnImmersiveModeOnRunable()**********");
             decorView.Call("setSystemUiVisibility",  SYSTEM_UI_FLAG_FULLSCREEN | SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | SYSTEM_UI_FLAG_HIDE_NAVIGATION | SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        //       decorView.Call("setSystemUiVisibility", SYSTEM_UI_FLAG_FULLSCREEN  | SYSTEM_UI_FLAG_HIDE_NAVIGATION | SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
    }

    public override void OnDestroy()
    {
        //print("**********HideAndroidButtons.OnDestroy()**********");
        base.OnDestroy();

#if UNITY_ANDROID && !UNITY_EDITOR
        decorView.Dispose();
#endif
    }

    /// <summary>
    /// 初始化听牌参数
    /// </summary>
    /// <param name="style"> 模式，0: --普通模式， 1: --血战模式</param>
    /// <param name="ziMoJiaDi">自摸加底标志</param>
    /// <param name="jiaJiaYou">家家有标志</param>
    public void initHuTips(uint style, byte ziMoJiaDi, byte jiaJiaYou)
    {
//#if !UNITY_EDITOR
//        huCount.initHuPaiLib(style, ziMoJiaDi, jiaJiaYou);
//#endif
        huCount.initHuTipsLib(style, ziMoJiaDi, jiaJiaYou);
    }

    public delegate void TingCountCallback(int count, int version);
    public TingCountCallback onTingCallback;

    public Thread tingThread = null;

    List<object> paramList = new List<object>();

    bool needCallback = false;
    int tingCount = 0;
    int tingVersion = -1;
    bool isLocked;
    TingCountCallback tingCallback;
    public void checkHuTips(TingCountCallback callback, int version, string env)
    {
        if(tingThread != null && tingThread.IsAlive)
        {
            //Debug.LogError("isRuning");
            return;
        }
        if(isLocked == true)
        {
            //Debug.LogError("isLocked");
            return;
        }
        onTingCallback = callback;
        paramList.Clear();
        paramList.Add(version);
        paramList.Add(env);
        paramList.Add(callback);
        tingThread = new Thread(new ParameterizedThreadStart(startCheckHuTips));
        tingThread.Start(paramList);
    }

    //public void setTingEnvironment(string env)
    //{
    //    huCount.setTingEnvironment(env);
    //}

    public string getHuTipsInfo()
    {
        return huCount.getHuTipsInfo();
    }
	
	public int getHuTipsVersion() {
//#if UNITY_EDITOR
//        return 0;
//#endif
        return huCount.getHuTipsVersion();
    }

    static object lockObj = new object();
    void startCheckHuTips(object obj)
    {
        lock(lockObj)
        {
            try
            {
                isLocked = true;
                var param = obj as List<object>;
                huCount.setHuTipsEnvironment((string)param[1]);
                int count = huCount.checkHuTips();
                //Debug.Log("startCheckHuTips() -> checkHuTips() = " + count);
                tingCount = count;
                tingVersion = (int)param[0];
                tingCallback = (TingCountCallback)param[2];
                needCallback = true;
                isLocked = false;
                //if (onTingCallback != null)
                //{
                //    onTingCallback(count, (int)param[0]);
                //    onTingCallback = null;
                //}
            }
            catch(Exception e)
            {
                Debug.LogError(e);
                if (tingCallback != null)
                    tingCallback(-1, 1);
            }           
        }       
    }
}





