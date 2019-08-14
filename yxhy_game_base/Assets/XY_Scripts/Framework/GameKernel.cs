using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using NS_DataCenter;
using LuaInterface;
using cs;
using XYHY;
using XYHY.ABSystem;
#if UNITY_5
using UnityEngine.SceneManagement;
#endif

namespace Framework
{
    public interface IInitializeable
    {
        void Initialize();
        void UnInitialize();
    }

    public interface IUpdateable
    {
        void Update();
    }

    public interface ILateUpdateable
    {
        void LateUpdate();
    }

    public interface IFixedUpdateable
    {
        void FixedUpdate();
    }

    public sealed class GameKernel : LuaClient
    {
        const string GameKernelGOName = "GameKernel";
        private bool beQuit = false;
        //ConsoleMgr cmd = null;
        const string loadingSceneName = "xyhy_loading";
        private bool hasLoadLua = false;

        [NoToLuaAttribute]
        public event Action UpdateEvent = delegate { };
        [NoToLuaAttribute]
        public event Action LateUpdateEvent = delegate { };
        [NoToLuaAttribute]
        public event Action FixedUpdateEvent = delegate { };

        IList<IInitializeable> _orderedInitializeableList = new List<IInitializeable>();
        IList<IUpdateable> _orderedUpdateableList = new List<IUpdateable>();
        IList<ILateUpdateable> _orderedLateUpdateableList = new List<ILateUpdateable>();
        IList<IFixedUpdateable> _orderedFixedUpdateableList = new List<IFixedUpdateable>();
        ServiceContainer _serviceContainer = new ServiceContainer();

        List<Type> _inializeablesOrder = new List<Type>()
        {
            //typeof(),
            //typeof(IDebugConsole),		// make debug console the first one!
        };

        List<Type> _updateablesOrder = new List<Type>()
        {
            //typeof(),
        };

        List<Type> _lateupdateablesOrder = new List<Type>()
        {
            // typeof(),
        };

        List<Type> _fixedupdateablesOrder = new List<Type>()
        {
            // typeof(),
        };

        void CreateServiceForVisionUpdate()
        {
            IServiceLocator binder = _serviceContainer;
            //cmd = ConsoleMgr.Instance;
            
            binder.BindService<IResourceMgr>(new ResourceMgr());
        }

        void CreateServiceForInitData()
        {
            IServiceLocator binder = _serviceContainer;
            //cmd = ConsoleMgr.Instance;

            //binder.BindService<IDataCenter>(new DataCenter());
            binder.BindService<IResourceMgr>(new ResourceMgr());
        }

        void ClearCache()
        {

        }

        void CreateAllService()
        {
            IServiceLocator binder = _serviceContainer;
            //cmd = ConsoleMgr.Instance;

            binder.BindService<IDataCenter>(new DataCenter());
            binder.BindService<IResourceMgr>(new ResourceMgr());
            //binder.BindService<InputDetermine>(new InputDetermine());            
            //binder.BindService<AudioSys>(AudioSys.Instance);
            binder.BindService<LuaNotifier>(LuaNotifier.Instance);
            ClearCache();
        }

        new void Awake()
        {
            Instance = this;
        }

        protected override LuaFileUtils InitLoader()
        {
            return new LuaResLoader();
        }

        protected override void LoadLuaFiles()
        {
#if UNITY_EDITOR            
            luaState.AddSearchPath(Application.dataPath + "/XY_Lua");
#endif
            OnLoadFinished();
            hasLoadLua = true;
        }

        public static T Get<T>() where T : class
        {
            if (_instance == null)
                return null;
            return _instance._serviceContainer.GetService<T>();
        }

        public static Coroutine StartMonoCoroutine(IEnumerator routine)
        {
            if (_instance)
            {
                return _instance.StartCoroutine(routine);
            }
            return null;
        }

        public static void StopMonoCoroutine(Coroutine routine)
        {
            if (_instance)
            {
                _instance.StopCoroutine(routine);
            }
        }

        void DoCreateForVisionUpdate()
        {
            CreateServiceForVisionUpdate();

            SortServiceInOrder<IInitializeable>(_inializeablesOrder, ref _orderedInitializeableList);

            // initialized
            for (int i = 0; i < _orderedInitializeableList.Count; ++i)
            {
                _orderedInitializeableList[i].Initialize();
            }
        }

        void DoCreateForInitData()
        {
            CreateServiceForInitData();

            SortServiceInOrder<IInitializeable>(_inializeablesOrder, ref _orderedInitializeableList);

            // initialized
            for (int i = 0; i < _orderedInitializeableList.Count; ++i)
            {
                _orderedInitializeableList[i].Initialize();
            }
        }

        void DoCreate()
        {
            CreateAllService();

            SortServiceInOrder<IInitializeable>(_inializeablesOrder, ref _orderedInitializeableList);
            SortServiceInOrder<IUpdateable>(_updateablesOrder, ref _orderedUpdateableList);
            SortServiceInOrder<ILateUpdateable>(_lateupdateablesOrder, ref _orderedLateUpdateableList);
            SortServiceInOrder<IFixedUpdateable>(_fixedupdateablesOrder, ref _orderedFixedUpdateableList);

            // initialized
            for (int i = 0; i < _orderedInitializeableList.Count; ++i)
            {
                _orderedInitializeableList[i].Initialize();
            }

            RegisterEvent();
            base.Init();
        }

        void DoBegin()
        {
            base.StartGame();
        }

        void RegisterEvent()
        {
            Messenger.AddListener<string>(MSG_DEFINE.MSG_SCENE_LOAD_COMPLETE, OnLevelRealWasLoaded);
        }

        void UnRegisterEvent()
        {
            Messenger.RemoveListener<string>(MSG_DEFINE.MSG_SCENE_LOAD_COMPLETE, OnLevelRealWasLoaded);
        }

        new protected void OnSceneLoaded(Scene scene, LoadSceneMode mode)
        {

        }

        private void OnLevelRealWasLoaded(string levelName)
        {
            if (levelName == loadingSceneName)
            {
                return;
            }

            if (levelLoaded != null)
            {
                levelLoaded.BeginPCall();
                levelLoaded.PCall();
                levelLoaded.EndPCall();
            }
        }

        void DoShutdown()
        {
            UnRegisterEvent();
            Yielders.ClearWaitForSeconds();

            mDataCenter = null;

            for (int i = _orderedInitializeableList.Count - 1; i >= 0; --i)
            {
                try
                {
                    _orderedInitializeableList[i].UnInitialize();
                }
                catch (System.Exception ex)
                {
                    //开发期间先让它直接报错
                    // not re-throw here, as we want later service get UnInitialized
                    Debugger.LogError(String.Format("Error when UnInitialize service {0}: {1}",
                        _orderedInitializeableList[i], ex.ToString()));
                }
            }

            _orderedInitializeableList = null;
            _orderedUpdateableList = null;
            _orderedLateUpdateableList = null;
            _orderedFixedUpdateableList = null;

            _serviceContainer = null;

            GameObject go = GameObject.Find(GameKernelGOName);
            if (go)
            {
                GameObject.Destroy(go);
            }
        }

        void OnApplicationPause(bool paused) 
        {
            if (! paused && Screen.height > 720) 
            {
                //  UnGfx.SetResolution(720, false);
                UnGfx.SetResolution(720,true);
            }
        }

        new void OnApplicationQuit()
        {
            if (!beQuit)
            {
                Debugger.Log("Begin quit");

                //talkingdata end
                //TalkingDataGA.OnEnd();

                beQuit = true;
                //LogicBaseLua.DestroyAll();
                //cmd.Destroy();
                //cmd = null;
                //Logger.Instance.cmd = null;
                //CVarTable.Destroy();
                base.Destroy();
                //Logger.Instance.Destroy();
                Debugger.Log("quit over");
            }
        }

        void Update()
        {
            //cmd.Update();
            if (_orderedUpdateableList != null)
            {
                for (int i = 0; i < _orderedUpdateableList.Count; ++i)
                {
                    _orderedUpdateableList[i].Update();
                }
            }

            Messenger.Update();             // msg process
            GlobalTimer.Instance.Update();  // timer process
            UpdateEvent();

            if (Input.GetKeyDown(KeyCode.Escape))
            {
                if (hasLoadLua)
                {
                    LuaFunction func = LuaClient.GetMainState().GetFunction("exit_ui.Show");
                    if (func != null)
                    {
                        func.BeginPCall();
                        func.PCall();
                        func.EndPCall();
                        func = null;
                    }
                }
            }          
        }

        void LateUpdate()
        {
            for (int i = 0; i < _orderedLateUpdateableList.Count; ++i)
            {
                _orderedLateUpdateableList[i].LateUpdate();
            }

            LateUpdateEvent();
        }

        void FixedUpdate()
        {
            for (int i = 0; i < _orderedFixedUpdateableList.Count; ++i)
            {
                _orderedFixedUpdateableList[i].FixedUpdate();
            }

            FixedUpdateEvent();
        }

        void SortServiceInOrder<T>(IList<Type> orderList, ref IList<T> resList) where T : class
        {
            resList.Clear();

            // the service with order specified goes first
            foreach (var t in orderList)
            {
                T thisTypeService = _serviceContainer.GetService(t) as T;
                if (thisTypeService != null)
                {
                    resList.Add(thisTypeService);
                }
                else
                {
                    throw new Exception(String.Format("TypeError in specified service order list: {0} is not of type {1}",
                        t, typeof(T)));
                }
            }

            // then the rest unspecified services
            foreach (var s in _serviceContainer.AllServices)
            {
                T thisTypeService = s as T;
                if (thisTypeService != null && !resList.Contains(thisTypeService))
                {
                    resList.Add(thisTypeService);
                }
            }
        }

        // 外部静态接口
        private static GameKernel _instance = null;

        public static void ShowUpdateUI()
        {
            //Camera.main.enabled = false;
            GameObject.Destroy(GameAppInstaller.m_UIRoot);
            GameAppInstaller.m_UIRoot = null;

            UpdateSys.Instance.StartGame();
        }

        public static void CreateForVisionUpdate()
        {
            Shutdown();

            _instance = (new GameObject(GameKernelGOName)).AddComponent<GameKernel>();
            GameObject.DontDestroyOnLoad(_instance.gameObject);
            _instance.DoCreateForVisionUpdate();
        }

        public static void CreateForInitData()
        {
            Shutdown();

            _instance = (new GameObject(GameKernelGOName)).AddComponent<GameKernel>();
            GameObject.DontDestroyOnLoad(_instance.gameObject);

            _instance.DoCreateForInitData();
        }

        public static void Create()
        {
            Shutdown();

            _instance = (new GameObject(GameKernelGOName)).AddComponent<GameKernel>();
            GameObject.DontDestroyOnLoad(_instance.gameObject);

            _instance.DoCreate();
        }

        public static void Begin()
        {
            if (_instance)
            {
                _instance.DoBegin();
            }
        }

        public static void Shutdown()
        {
            if (_instance)
            {
                _instance.DoShutdown();
                _instance = null;
            }
        }

        static DataCenter mDataCenter = null;
        public static NS_DataCenter.DataCenter GetDataCenter()
        {
            if (_instance == null)
                return null;

            if (mDataCenter == null)
                mDataCenter = _instance._serviceContainer.GetService<NS_DataCenter.IDataCenter>() as NS_DataCenter.DataCenter;

            return mDataCenter;
        }

        public static ResourceMgr GetResourceMgr()
        {
            if (_instance == null)
                return null;
            return _instance._serviceContainer.GetService<IResourceMgr>() as ResourceMgr;
        }

        /*public static InputDetermine GetInputDetermine()
        {
            if (_instance == null)
                return null;
            return _instance._serviceContainer.GetService<InputDetermine>() as InputDetermine;
        }

        static ActorFactory mActorFactory = null;
        public static ActorFactory GetActorFactory()
        {
            if (_instance == null)
                return null;

            if(mActorFactory == null)
                mActorFactory = _instance._serviceContainer.GetService<IActorFactory>() as ActorFactory;

            return mActorFactory;
        }


        public static void SetAppRunMode(bool bSingle)
        {
            RunMode.Instance.SingleMode = bSingle;
        }

        public static HardwareManager GetHardwareMgr()
        {
            if (_instance == null)
                return null;
            return _instance._serviceContainer.GetService<HardwareManager>() as HardwareManager;
        }


        public static bool IsInNetLevel()
        {
            bool ret = GameKernel.IsInMultiPlayerLevel();
            //CSHeroMoveReq moveReq = new CSHeroMoveReq();
            //moveReq.Direct = new Triple();
            //moveReq.Pos = new Triple();
            //NetEngine.Instance.GetGameChnl().SendMsgNoRes((uint)CSCmdType.CS_HERO_MOVE_REQ, moveReq);
            //MemoryStreamPool.MainThreadMsPool.PrintTestLog();
            //MemoryStreamPool.SendThreadMsPool.PrintTestLog();
            //MemoryStreamPool.RecvThreadMsPool.PrintTestLog();
            return ret;
        }
        */


        /// <summary>
        /// 开启cjson功能
        /// </summary>
        protected override void OpenLibs()
        {
            base.OpenLibs();
            OpenCJson();
        }
    }
}