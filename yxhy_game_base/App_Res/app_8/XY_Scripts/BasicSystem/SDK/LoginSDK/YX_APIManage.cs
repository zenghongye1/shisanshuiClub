
using System.Collections;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.ComponentModel;
using System;
using System.Threading;
using UnityEngine;
using LuaInterface;
using TingInfo;

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
    public void setHallTimer(DelegateNetHallCallBack delegateNet) {
        delegateNetHallCallBack = delegateNet;
    }
    public delegate void DelegateNetGameCallBack();
    public DelegateNetGameCallBack delegateNetGameCallBack;
    public void setGameTimer(DelegateNetGameCallBack delegateNet) {
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
        if (delegateNetHallCallBack != null) {
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

    private void OnApplicationFocus(bool focus)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        //print("**********HideAndroidButtons.OnApplicationFocus()**********");
        if (focus)
        {
            TurnImmersiveModeOn();
            UnGfx.SetResolution(720, false);
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
    public void CheckWXInstall(DelegateCheckWXInstall resp) {
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
   

    /// <summary>
    /// 
    /// </summary>
    /// <param name="shareType">0微信好友，1朋友圈，2微信收藏</param>
    /// <param name="type">1文本，2图片，3声音，4视频，5网页</param>
    ///
    public void WeiXinShare(int shareType, int type, string title, string filePath, string url, string description)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.WeiXinShare(shareType, type, title,filePath,url,description);
#elif UNITY_IOS && !UNITY_EDITOR
		IOSInterface.WeiXinShare(shareType, type, title,filePath,url,description);
#endif
    }
    public void QQLogin(DelegateLoginResp resp)
    {
        delegateLoginResp = resp;
#if UNITY_ANDROID && !UNITY_EDITOR
        androidInterface.QQLogin();
#elif UNITY_IOS && !UNITY_EDITOR
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
   
    public void onPluginsInitFinsh(string msg)
    {
        //Debug.Log("收到回调啦啦啦");
        //string dataPath = Application.dataPath;
        //Debug.Log("Application.dataPath -------" + dataPath);
    }

    public void onWeiXinLoginCallBack(string msg)
    {
        Debug.Log("LoginCallBack:" + msg);
        if (delegateLoginResp != null)
        {
            delegateLoginResp(msg);
            delegateLoginResp = null;
        }

    }

    public void onQQLoginCallBack(string msg)
    {
        //Debug.Log("onQQLoginCallBack" + msg);
        if (delegateLoginResp != null)
        {
            delegateLoginResp(msg);
            delegateLoginResp = null;
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
    public void onPhoneBattery(string msg)
    {
        //Debug.Log("onPhoneBattery" + msg);
        if (batteryCallBack != null)
        {
            batteryCallBack(msg);
        }
    }

    public void onPhoneSignal(string msg)
    {
        //Debug.Log("onPhoneSignal" + msg);
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
    public  string read(string filename)
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

    public void deleteFile(string filename) {

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
        Debug.Log("shake");
#if UNITY_ANDROID || UNITY_IPHONE || UNITY_IOS
        Handheld.Vibrate();
#endif
    }
    public void GetCenterPicture(string mFileName)
    {
        UITexture tx = null;
        StartCoroutine(CaptureByRect(mFileName, tx));

    }
    public IEnumerator CaptureByRect(string mFileName, UITexture tx)
    {
        Rect mRect = new Rect(0, 0, Screen.width, Screen.height);
        //等待渲染线程结束  
        yield return new WaitForEndOfFrame();
        //初始化Texture2D  
        Texture2D mTexture = new Texture2D((int)mRect.width, (int)mRect.height, TextureFormat.RGB24, false);
    //    mTexture.Compress(false);
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
        onfinishtx(tx);
        //如果需要可以返回截图  
        //return mTexture;  
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
    }

    void OnDestroy()
    {
        //print("**********HideAndroidButtons.OnDestroy()**********");
#if UNITY_ANDROID && !UNITY_EDITOR
        decorView.Dispose();
#endif
    }
    public void initHuTips() {
        huCount.initTing();
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
    public void checkTingCount(TingCountCallback callback, int version, string env)
    {
        if(tingThread != null && tingThread.IsAlive)
        {
            Debug.LogError("isRuning");
            return;
        }
        if(isLocked == true)
        {
            Debug.LogError("isLocked");
            return;
        }
        onTingCallback = callback;
        paramList.Clear();
        paramList.Add(version);
        paramList.Add(env);
        paramList.Add(callback);
        tingThread = new Thread(new ParameterizedThreadStart(onTingCount));
        tingThread.Start(paramList);
    }

    public void setTingEnvironment(string env) {
        huCount.setTingEnvironment(env);
    }

    public string getTingInfo() {
        
       return huCount.getTingInfo();
    }

    static object lockObj = new object();
    void onTingCount(object obj)
    {
        lock(lockObj)
        {
            try
            {
                isLocked = true;
                var param = obj as List<object>;
                huCount.setTingEnvironment((string)param[1]);
                int count = huCount.checkTingCount();
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





