using UnityEngine;
using NS_DataCenter;
using System.Collections.Generic;
using XYHY.ABSystem;

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
        public bool showSplashAnimation = false; //是否显示开机动画

        public bool useLog = true;

        AssetBundleManager abManager = null;

        public List<string> depFileNameLst = new List<string>();


        public static GameAppInstaller Instance
        {
            get
            {
                return _instance;
            }
        }

        void Awake()
        {
            _instance = this;
            
            NetWorkManage.testAccount = testAccount;
            NetWorkManage.Instance.EServerUrlType = _serverUrlType;
            NetWorkManage.Instance.Init();

            LuaHelper.isAppleVerify = isAppleVerify;
            LuaHelper.openGuestMode = openGuestMode;

            abManager = AssetBundleManager.Instance;
            abManager.Init(depFileNameLst, delegate
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
                BuglyAgent.InitWithAppId ("fa367c7db7");
#elif UNITY_ANDROID
                //QQ_APIManage.Instance.loadSoLib();
                BuglyAgent.InitWithAppId("d5389d0e62");

#endif
                // 如果你确认已在对应的iOS工程或Android工程中初始化SDK，那么在脚本中只需启动C#异常捕获上报功能即可
                BuglyAgent.EnableExceptionHandler();
                BuglyAgent.ConfigAutoReportLogLevel(LogLevel);
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
                UnGfx.SetResolution(720, false);
#endif
            }

            
            m_bInitialized = true;

            /*Logger logger = new Logger();
            logger.Start();
            CVarTable.Start();
            ConsoleMgr cmd = new ConsoleMgr();
            logger.cmd = cmd; */

#if UNITY_ANDROID || UNITY_IPHONE || UNITY_IOS
            channel = "xyhy";
            //version = VersionInfoData.CurrentVersionInfo.VersionNum;
            user = SystemInfo.deviceUniqueIdentifier;
#endif
#if UNITY_ANDROID && !UNITY_EDITOR
            //if(!VersionInfoData.CurrentVersionInfo.IsReleaseVer)
            //{
            //    LuaInterface.Debugger.Log("Init U3DAutomationBehaviour");
            //    gameObject.AddComponent<WeTest.U3DAutomation.U3DAutomationBehaviour>();
            //}         
#endif

            //设定语言
            Localization.language = "Chinese";
            
            GameSetting gameSetting = new GameSetting();
            gameSetting.InitSetting();
            gameSetting = null;

            /*for (int i = 0; i < 3; i++)
            {
                yield return new WaitForEndOfFrame();
            }*/

            //隐藏Android虚拟按钮
            //HideAndroidButtons.Init();
            
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