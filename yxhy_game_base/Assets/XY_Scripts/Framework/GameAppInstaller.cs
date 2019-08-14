using UnityEngine;
using NS_DataCenter;
using System.Collections.Generic;
using XYHY.ABSystem;
using System.IO;
using LitJson;

namespace Framework
{
    public class GameAppInstaller : MonoBehaviour
    {
        [SerializeField]
        private bool IsOpenBugly = true;//是否开启bugly上报
        [SerializeField]
        private LogSeverity LogLevel = LogSeverity.LogError;//bugly上报等级

        public bool isAppleVerify = false;
        static bool m_bInitialized = false;

        static public GameObject  m_UIRoot = null;
        static private GameAppInstaller _instance;

        public static string channel = null;
        public static string version = null;
        public static string user = null;
        public static long delay = 0;

        public string testAccount = "";
        public ServerUrlType _serverUrlType = ServerUrlType.INTEST_URL;
        public bool openGuestMode = false;
        //public bool showSplashAnimation = false; //是否显示开机动画
        public bool useLog = true;

        AssetBundleManager abManager = null;
        [HideInInspector]
        public List<string> depFileNameLst = new List<string>();
        
        public static string appConfData;
        public static string serverCfgData;


        public static GameAppInstaller Instance
        {
            get
            {
                return _instance;
            }
        }

        void Awake()
        {
            // 暂时先屏蔽   晚点需要删除这个字段
            depFileNameLst = new List<string>(); 
            _instance = this;

            appConfData = FileUtils.GetAppConfData("config/app_config.txt");

            NetWorkManage.testAccount = testAccount;
            NetWorkManage.Instance.EServerUrlType = _serverUrlType;
            NetWorkManage.Instance.Init();

            LuaHelper.isAppleVerify = isAppleVerify;
            LuaHelper.openGuestMode = openGuestMode;
            LuaHelper.serverId = (int)_serverUrlType;
            
            JsonData deJson = JsonMapper.ToObject(appConfData);
            for (int i = 0; i < deJson["depFileNameLst"].Count; i++)
            {
                depFileNameLst.Add(deJson["depFileNameLst"][i].ToString());
            }

            string appVerFileName = deJson["verFileNameLst"][0].ToString();

            abManager = AssetBundleManager.Instance;
            abManager.Init(depFileNameLst, appVerFileName, delegate
            {
#if UNITY_EDITOR
                LuaInterface.Debugger.Log("Depends Load Finished !");
#endif

                //为版本更新创建游戏内核
                GameKernel.CreateForVisionUpdate();
                //CreateUIRoot();

                //需不需播放CG  需要的话得先播放CG之后，再显示更新游戏（待处理）           
                UpdateSys.Instance.ShowUpdateUI();
            });

            if (m_bInitialized)
            {
                Destroy(gameObject);
                return;
            }

            if (useLog)
            {
                LogOutput.Instance.Init();                
            }
            LuaInterface.Debugger.useLog = useLog;

            //初始化SDK环境 ，sdk初始化成功后再开始游戏
            //SDKManager.InitEnv();
            //SDKManager.InitSDK(OnInitSDKResult);
            OnInitSDKResult(true);

            if (IsOpenBugly)
            {
                // 开启SDK的日志打印，发布版本请务必关闭
                BuglyAgent.ConfigDebugMode(true);
                // 注册日志回调，替换使用 'Application.RegisterLogCallback(Application.LogCallback)'注册日志回调的方式：BuglyAgent.RegisterLogCallback (CallbackDelegate.Instance.OnApplicationLogCallbackHandler);
#if UNITY_IPHONE || UNITY_IOS
                if (_serverUrlType == ServerUrlType.RELEASE_URL)
                    BuglyAgent.InitWithAppId("93192a280a");
                else
                    BuglyAgent.InitWithAppId("d1a5c1fb01");
                //BuglyAgent.InitWithAppId ("fa367c7db7");
#elif UNITY_ANDROID
                if (_serverUrlType == ServerUrlType.RELEASE_URL)
                    BuglyAgent.InitWithAppId("d5389d0e62");
                else
                    BuglyAgent.InitWithAppId("765fc4cb28");
                
#endif
                // 如果你确认已在对应的iOS工程或Android工程中初始化SDK，那么在脚本中只需启动C#异常捕获上报功能即可
                BuglyAgent.EnableExceptionHandler();
                BuglyAgent.ConfigAutoReportLogLevel(LogLevel);
                if (PlayerPrefs.HasKey("USER_UID"))
                {
                    string uid = PlayerPrefs.GetString("USER_UID");
                    if (!string.IsNullOrEmpty(uid))
                        BuglyAgent.SetUserId(uid);
                }
            }
        }

        private System.Collections.IEnumerator Init()
        {		
            yield return null;

            if (Screen.height > 720)
            {
#if !UNITY_EDITOR && !UNITY_STANDALONE
                UnGfx.SetResolution(720, true);
#else
                //   UnGfx.SetResolution(720, false);
                UnGfx.SetResolution(720, true);
#endif
            }

            
            m_bInitialized = true;

#if UNITY_ANDROID || UNITY_IPHONE || UNITY_IOS
            channel = "xyhy";
            user = SystemInfo.deviceUniqueIdentifier;
#endif

            //设定语言
            Localization.language = "Chinese";            
            GameSetting gameSetting = new GameSetting();
            gameSetting.InitSetting();
            gameSetting = null;
            
            Destroy(gameObject);
            InitGameStaticClass();
        }

        /// <summary>
        /// 主要为了一些静态类初始化
        /// </summary>
        void InitGameStaticClass()
        {
            
        }

        static public void CreateUIRoot()
        {
            // 确保UIRoot在切换场景后，不会被销毁，并自动转移到下一个场景上
            GameObject uiroot = GameObject.Find("uiroot_xy");
            if (uiroot == null)
            {
                UnityEngine.Object prefab = Resources.Load("RootUIPrefab/uiroot_xy");
                uiroot = GameObject.Instantiate(prefab) as GameObject;
            }
            uiroot.name = "uiroot_xy";
            GameObject.DontDestroyOnLoad(uiroot);
            GameAppInstaller.m_UIRoot = uiroot;
        }


        void OnInitSDKResult(bool ret)
        {
            if (ret)
            {
                LuaInterface.Debugger.Log("初始化SDK成功");
                StartCoroutine(Init());
            }
            else
            {
                LuaInterface.Debugger.Log("初始化SDK失败");
            }
        }
    }
}