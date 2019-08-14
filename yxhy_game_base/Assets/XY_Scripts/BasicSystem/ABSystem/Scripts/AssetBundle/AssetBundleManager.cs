#if !AB_MODE && UNITY_EDITOR
#else
#define _AB_MODE_
#endif

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace XYHY.ABSystem
{
    public enum LoadState
    {
        State_None = 0,
        State_Loading = 1,
        State_Error = 2,
        State_Complete = 3
    }

    public class AssetBundleManager : MonoBehaviour
    {
        static AssetBundleManager _instance;
        static public AssetBundleManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = (new GameObject("AssetBundleManager")).AddComponent<AssetBundleManager>();
                    GameObject.DontDestroyOnLoad(_instance.gameObject);
                }
                return _instance;
            }
        }

        public static string NAME = "AssetBundleManager";
        public static bool enableLog = false;

        public delegate void LoadAssetCompleteHandler(AssetBundleInfo info);
        public delegate void LoaderCompleteHandler(AssetBundleLoader info);
        public delegate void LoadProgressHandler(AssetBundleLoadProgress progress);

        /// <summary>
        /// 同时最大的加载数
        /// </summary>
        private const int MAX_REQUEST = 100;
        /// <summary>
        /// 可再次申请的加载数
        /// </summary>
        private int _requestRemain = MAX_REQUEST;
        /// <summary>
        /// 当前申请要加载的队列
        /// </summary>
        private List<AssetBundleLoader> _requestQueue = new List<AssetBundleLoader>();

        /// <summary>
        /// 加载队列
        /// </summary>
        private List<AssetBundleLoader> _currentLoadQueue = new List<AssetBundleLoader>();
        /// <summary>
        /// 未完成的
        /// </summary>
        private HashSet<AssetBundleLoader> _nonCompleteLoaderSet = new HashSet<AssetBundleLoader>();
        /// <summary>
        /// 此时加载的所有Loader记录，(用于在全加载完成之后设置 minLifeTime)
        /// </summary>
        private HashSet<AssetBundleLoader> _thisTimeLoaderSet = new HashSet<AssetBundleLoader>();
        /// <summary>
        /// 已加载完成的缓存列表
        /// </summary>
        private Dictionary<string, AssetBundleInfo> _loadedAssetBundle = new Dictionary<string, AssetBundleInfo>();
        /// <summary>
        /// 已创建的所有Loader列表(包括加载完成和未完成的)
        /// </summary>
        private Dictionary<string, AssetBundleLoader> _loaderCache = new Dictionary<string, AssetBundleLoader>();
        /// <summary>
        /// 当前是否还在加载，如果加载，则暂时不回收
        /// </summary>
        private bool _isCurrentLoading;

        private AssetBundleLoadProgress _progress = new AssetBundleLoadProgress();
        /// <summary>
        /// 进度
        /// </summary>
        public LoadProgressHandler onProgress;

        public AssetBundlePathResolver pathResolver;

        private AssetBundleDataReader _depInfoReader;

        private AssetBundleDataReader _gameDepInfoReader;


        public Action _initCallback;


        public AssetBundleManager()
        {
            _instance = this;
            pathResolver = new AssetBundlePathResolver();
        }

        public AssetBundleDataReader depInfoReader { get { return _depInfoReader; } }

        public AssetBundleDataReader gameDepInfoReader { get { return _gameDepInfoReader; } }

        protected void Awake()
        {
            _instance = this;
            pathResolver = new AssetBundlePathResolver();            
            //InvokeRepeating("CheckUnusedBundle", 0, 5);
        }

        void Update()
        {
            if (_isCurrentLoading)
            {
                CheckNewLoaders();
                CheckQueue();
            }
        }

        public void CheckAndCleanDepCache(string fileName)
        {
            var streamVerInfo = FileUtils.GetStreamAssetVer(fileName);
            var persistentVerInfo = FileUtils.GetPersistentAssetVer(fileName);
         
            bool needDelete = false;

            // 如果不存在 则强制删除
            if(persistentVerInfo == null || streamVerInfo == null)
            {
                needDelete = true;
            }
            else
            {
                Version persistentVer = new Version(persistentVerInfo.VersionNum);
                Version streamingVer = new Version(streamVerInfo.VersionNum);
                if (persistentVer == null || streamingVer == null)
                {
                    needDelete = true;
                }
                else
                {
                    // 只判断第一位和第二位
                    if(streamingVer.Major > persistentVer.Major || streamingVer.Minor > persistentVer.Minor)
                    {
                        needDelete = true;
                    }
                }
            }

            if(needDelete)
            {
                if(Directory.Exists(pathResolver.BundleCacheDir))
                {
                    Directory.Delete(pathResolver.BundleCacheDir, true);
                    LuaInterface.Debugger.Log("Delete " + pathResolver.BundleCacheDir);
                }
                if (Directory.Exists(AssetBundlePathResolver.instance.BundlesPathForPersistent))
                    Directory.CreateDirectory(AssetBundlePathResolver.instance.BundlesPathForPersistent);
                //File.Copy()
                NetWorkManage.Instance.CreateFile(AssetBundlePathResolver.instance.BundlesPathForPersistent, fileName, LitJson.JsonMapper.ToJson(streamVerInfo));
            }

        }

        public void Init(List<string> depFileNameLst,string verFileName, Action callback)
        {
            _initCallback = callback;
#if (!AB_WINDOW) && UNITY_STANDALONE
#if UNITY_EDITOR
            this.InitComplete();
#endif
#else
            CheckAndCleanDepCache(verFileName);
    #if _AB_MODE_
            if (depFileNameLst.Count > 0)
            {
                this.StartCoroutine(LoadDepInfo(depFileNameLst[0]));
            }
            else
            {
                Debug.LogError("commDepFileName not exist!");
                return;
            }

            //根据需要加载
            if (depFileNameLst.Count > 1)
            {
                for(int i=1; i< depFileNameLst.Count; i++)
                {
                    this.StartCoroutine(SubLoadDepInfo(depFileNameLst[i]));
                }
            }
    #else
            this.InitComplete();
    #endif
#endif
        }

        public void Init(Stream depStream, Action callback)
        {
            if (depStream.Length > 4)
            {
                BinaryReader br = new BinaryReader(depStream);
                if (br.ReadChar() == 'A' && br.ReadChar() == 'B' && br.ReadChar() == 'D')
                {
                    if (_depInfoReader == null)
                    {
                        if (br.ReadChar() == 'T')
                        {
                            _depInfoReader = new AssetBundleDataReader();
                        }
                        else
                        {
                            _depInfoReader = new AssetBundleDataBinaryReader();
                        }                            
                    }

                    depStream.Position = 0;
                    _depInfoReader.Read(depStream);
                }
            }

            depStream.Close();

            if (callback != null)
                callback();
        }


        public void InitGame(Stream depStream, Action callback)
        {
            if (depStream.Length > 4)
            {
                BinaryReader br = new BinaryReader(depStream);
                if (br.ReadChar() == 'A' && br.ReadChar() == 'B' && br.ReadChar() == 'D')
                {
                    if (_gameDepInfoReader == null)
                    {
                        if (br.ReadChar() == 'T')
                        {
                            _gameDepInfoReader = new AssetBundleDataReader();
                        }
                        else
                        {
                            _gameDepInfoReader = new AssetBundleDataBinaryReader();
                        }
                    }

                    depStream.Position = 0;
                    _gameDepInfoReader.Read(depStream);
                }
            }

            depStream.Close();

            if (callback != null)
                callback();
        }

        public IEnumerator LoadGameDepInfo(string gameDepFileName, Action callback)
        {
            string depFile = string.Format("{0}/{1}", pathResolver.BundleCacheDir, gameDepFileName);
            //编辑器模式下测试AB_MODE，直接读取
#if UNITY_EDITOR && !AB_MODE
            depFile = pathResolver.GetBundleSourceFile(gameDepFileName, false);
#endif

            if (File.Exists(depFile))
            {
                FileStream fs = new FileStream(depFile, FileMode.Open, FileAccess.Read);
                InitGame(fs, callback);
                fs.Close();
            }
            else
            {
                string srcURL = pathResolver.GetBundleSourceFile(gameDepFileName);
                WWW w = new WWW(srcURL);
                yield return w;

                if (w.error == null)
                {
                    InitGame(new MemoryStream(w.bytes), callback);
                    //File.WriteAllBytes(depFile, w.bytes);
                }
                else
                {
                    if (callback != null)
                    {
                        callback();
                    }
                    //Debug.LogError(string.Format("{0} not exist!", depFile));
                }
            }
        }


        void InitComplete()
        {
            if (_initCallback != null)
                _initCallback();
            _initCallback = null;
        }

        public IEnumerator LoadDepInfo(string depFileName)
        {
            string depFile = string.Format("{0}/{1}", pathResolver.BundleCacheDir, depFileName);
            //编辑器模式下测试AB_MODE，直接读取
#if UNITY_EDITOR && !AB_MODE
            depFile = pathResolver.GetBundleSourceFile(depFileName, false);
#endif
            if (File.Exists(depFile))
            {
                FileStream fs = new FileStream(depFile, FileMode.Open, FileAccess.Read);
                Init(fs, null);
                fs.Close();
            }
            else
            {
                string srcURL = pathResolver.GetBundleSourceFile(depFileName);
                WWW w = new WWW(srcURL);
                yield return w;

                if (w.error == null)
                {                    
                    Init(new MemoryStream(w.bytes), null);
                    //File.Copy(srcURL, depFile);
                    //File.WriteAllBytes(depFile, w.bytes);
                }
                else
                {
                    Debug.LogError(string.Format("{0} not exist!", depFile));
                }
            }
            this.InitComplete();
        }

        public IEnumerator SubLoadDepInfo(string dependFileName, Action callback = null)
        {
            string depFile = string.Format("{0}/{1}", pathResolver.BundleCacheDir, dependFileName);
            //编辑器模式下测试AB_MODE，直接读取
#if UNITY_EDITOR && !AB_MODE
            depFile = pathResolver.GetBundleSourceFile(dependFileName, false);
#endif

            if (File.Exists(depFile))
            {
                //FileStream fs = new FileStream(depFile, FileMode.Open, FileAccess.Read);
                //Init(fs, callback);
                //fs.Close();
                LoadRemoteDepInfoDirectly(dependFileName, callback);
            }
            else
            {
                string srcURL = pathResolver.GetBundleSourceFile(dependFileName);
                WWW w = new WWW(srcURL);
                yield return w;

                if (w.error == null)
                {
                    Init(new MemoryStream(w.bytes), callback);
                    //File.WriteAllBytes(depFile, w.bytes);
                }
                else
                {
                    if (callback != null)
                        callback();
                }
            }
        }


        //直接加载已下载的依赖
        public bool LoadRemoteDepInfoDirectly(string depFileName, Action callback)
        {
            string depFile = string.Format("{0}/{1}", pathResolver.BundleCacheDir, depFileName);
            if (File.Exists(depFile))
            {
                FileStream fs = new FileStream(depFile, FileMode.Open, FileAccess.Read);
                Init(fs, callback);
                fs.Close();
                return true;
            }
            return false;
        }





        void OnDestroy()
        {
            this.RemoveAll();
        }

        /// <summary>
        /// 通过ShortName获取FullName
        /// </summary>
        /// <param name="shortFileName"></param>
        /// <returns></returns>
        public string GetAssetBundleFullName(string shortFileName)
        {
            return _depInfoReader.GetFullName(shortFileName);
        }

        /// <summary>
        /// 用默认优先级为0的值加载
        /// </summary>
        /// <param name="path">路径</param>
        /// <param name="handler">回调</param>
        /// <returns></returns>
        public AssetBundleLoader Load(string path, LoadAssetCompleteHandler handler = null)
        {
            return Load(path, 0, handler);
        }

        /// <summary>
        /// 通过一个路径加载ab
        /// </summary>
        /// <param name="path">路径</param>
        /// <param name="prority">优先级</param>
        /// <param name="handler">回调</param>
        /// <returns></returns>
        public AssetBundleLoader Load(string path, int prority, LoadAssetCompleteHandler handler = null)
        {
#if _AB_MODE_
            AssetBundleLoader loader = this.CreateLoader(HashUtil.Get(path.ToLower()) + ".ab", path);
#else
            AssetBundleLoader loader = this.CreateLoader(path);
#endif
            loader.prority = prority;
            loader.onComplete += handler;

            _isCurrentLoading = true;
            _nonCompleteLoaderSet.Add(loader);
            _thisTimeLoaderSet.Add(loader);

            return loader;
        }

        internal AssetBundleLoader CreateLoader(string abFileName, string oriName = null)
        {
            AssetBundleLoader loader = null;

            if (_loaderCache.ContainsKey(abFileName))
            {
                loader = _loaderCache[abFileName];
            }
            else
            {
#if _AB_MODE_
                AssetBundleData data = _depInfoReader.GetAssetBundleInfo(abFileName);
                if (data == null && oriName != null)
                {
                    data = _depInfoReader.GetAssetBundleInfoByShortName(oriName.ToLower());
                }
                if (data == null)
                {
                    Debug.LogError(oriName + "    " + abFileName);
                    MissAssetBundleLoader missLoader = new MissAssetBundleLoader();
                    missLoader.bundleManager = this;
                    return missLoader;
                }

                loader = this.CreateLoader();
                loader.bundleManager = this;
                loader.bundleData = data;
                loader.bundleName = data.belongName + "/" + data.fullName;
//#if UNITY_IOS || UNITY_IPHONE || UNITY_STAND
//                string secondDirName = data.debugName.Split('/')[2].ToLower();
//#elif UNITY_ANDROID || (AB_WINDOW && UNITY_STANDALONE)
//                string secondDirName = data.debugName.Split('\\')[2].ToLower();
//#else
//                string secondDirName = "";
//#endif
                //loader.bundleName = secondDirName+ "/" + data.fullName;
#else
                loader = this.CreateLoader();
                loader.bundleManager = this;
                loader.bundleName = abFileName;
#endif
                _loaderCache[abFileName] = loader;
            }

            return loader;
        }

        protected virtual AssetBundleLoader CreateLoader()
        {
#if UNITY_EDITOR  && !AB_MODE
            return new EditorModeAssetBundleLoader();
#elif UNITY_IOS
            return new IOSAssetBundleLoader();
#elif UNITY_ANDROID
            return new MobileAssetBundleLoader();
#else
            return new MobileAssetBundleLoader();
#endif
        }

        void CheckNewLoaders()
        {
            if (_nonCompleteLoaderSet.Count > 0)
            {
                List<AssetBundleLoader> loaders = ListPool<AssetBundleLoader>.Get();
                loaders.AddRange(_nonCompleteLoaderSet);
                _nonCompleteLoaderSet.Clear();

                var e = loaders.GetEnumerator();
                while (e.MoveNext())
                {
                    _currentLoadQueue.Add(e.Current);
                }

                _progress = new AssetBundleLoadProgress();
                _progress.total = _currentLoadQueue.Count;

                e = loaders.GetEnumerator();
                while (e.MoveNext())
                {
                    e.Current.Start();
                }
                ListPool<AssetBundleLoader>.Release(loaders);
            }
        }
        
        public void RemoveAll()
        {
            this.StopAllCoroutines();

            _currentLoadQueue.Clear();
            _requestQueue.Clear();
            foreach (AssetBundleInfo abi in _loadedAssetBundle.Values)
            {
                abi.Dispose();
            }
            _loadedAssetBundle.Clear();
            _loaderCache.Clear();
        }

        public AssetBundleInfo GetBundleInfo(string key)
        {
            key = key.ToLower();
#if _AB_MODE_
            string preKey = key.Split('/')[0];
            key = preKey + HashUtil.Get(key) + ".ab";             
#endif
            var e = _loadedAssetBundle.GetEnumerator();
            while (e.MoveNext())
            {
                AssetBundleInfo abi = e.Current.Value;
                if (abi.bundleName == key)
                    return abi;
            }
            return null;
        }

        /// <summary>
        /// 请求加载Bundle，这里统一分配加载时机，防止加载太卡
        /// </summary>
        /// <param name="loader"></param>
        internal void Enqueue(AssetBundleLoader loader)
        {
            if (_requestRemain < 0)
                _requestRemain = 0;
            _requestQueue.Add(loader);
        }

        void CheckQueue()
        {
            if (_requestRemain > 0 && _requestQueue.Count > 0)
                _requestQueue.Sort();

            while (_requestRemain > 0 && _requestQueue.Count > 0)
            {
                AssetBundleLoader loader = _requestQueue[0];
                _requestQueue.RemoveAt(0);
                LoadBundle(loader);
            }
        }

        void LoadBundle(AssetBundleLoader loader)
        {
            if (!loader.isComplete)
            {
                loader.LoadBundle();
                _requestRemain--;
            }
        }

        internal void LoadError(AssetBundleLoader loader)
        {
            Debug.LogWarning("Cant load AB : " + loader.bundleName, this);
            LoadComplete(loader);
        }

        internal void LoadComplete(AssetBundleLoader loader)
        {
            _requestRemain++;
            _currentLoadQueue.Remove(loader);

            if (onProgress != null)
            {
                _progress.loader = loader;
                _progress.complete = _progress.total - _currentLoadQueue.Count;
                onProgress(_progress);
            }

            //all complete
            if (_currentLoadQueue.Count == 0 && _nonCompleteLoaderSet.Count == 0)
            {
                _isCurrentLoading = false;

                var e = _thisTimeLoaderSet.GetEnumerator();
                while (e.MoveNext())
                {
                    AssetBundleLoader cur = e.Current;
                    if (cur.bundleInfo != null)
                        cur.bundleInfo.ResetLifeTime();
                }
                _thisTimeLoaderSet.Clear();
            }
        }

        internal AssetBundleInfo CreateBundleInfo(AssetBundleLoader loader, AssetBundleInfo abi = null, AssetBundle assetBundle = null)
        {
            if (abi == null)
                abi = new AssetBundleInfo();
            abi.bundleName = loader.bundleName.ToLower();
            abi.bundle = assetBundle;
            abi.data = loader.bundleData;

            _loadedAssetBundle[abi.bundleName] = abi;
            return abi;
        }

        internal void RemoveBundleInfo(AssetBundleInfo abi)
        {
            abi.Dispose();
            _loadedAssetBundle.Remove(abi.bundleName);
        }

        /// <summary>
        /// 当前是否在加载状态
        /// </summary>
        public bool isCurrentLoading { get { return _isCurrentLoading; } }

		void CheckUnusedBundle()
		{
			this.UnloadUnusedBundle();
		}

        /// <summary>
        /// 卸载不用的
        /// </summary>
        public void UnloadUnusedBundle(bool force = false)
        {
            if (_isCurrentLoading == false || force)
            {
                List<string> keys = ListPool<string>.Get();
                keys.AddRange(_loadedAssetBundle.Keys);

                bool hasUnusedBundle = false;
                //一次最多卸载的个数，防止卸载过多太卡
                int unloadLimit = 20;
                int unloadCount = 0;

                do
                {
                    hasUnusedBundle = false;
                    for (int i = 0; i < keys.Count && !_isCurrentLoading && unloadCount < unloadLimit; i++)
                    {
                        if (_isCurrentLoading && !force)
                            break;

                        string key = keys[i];
                        AssetBundleInfo abi = _loadedAssetBundle[key];
                        if (abi.isUnused)
                        {
                            hasUnusedBundle = true;
                            unloadCount++;

                            this.RemoveBundleInfo(abi);

                            keys.RemoveAt(i);
                            i--;
                        }
                    }
                } while (hasUnusedBundle && !_isCurrentLoading && unloadCount < unloadLimit);

                ListPool<string>.Release(keys);
#if UNITY_EDITOR
                if (unloadCount > 0 && enableLog)
                {
                    Debug.Log("===>> Unload Count: " + unloadCount);
                }
#endif
            }
        }

        public void RemoveBundle(string key)
        {
            AssetBundleInfo abi = this.GetBundleInfo(key);
            if (abi != null)
            {
                this.RemoveBundleInfo(abi);
            }
        }

        public AssetBundleInfo LoadSync(string path)
        {
#if _AB_MODE_
            AssetBundleLoader loader = this.CreateLoader(HashUtil.Get(path.ToLower()) + ".ab", path);
#else
            AssetBundleLoader loader = this.CreateLoader(path);
#endif
            

            if (loader != null)
            {
                loader.Start(true);
            }

            return loader.bundleInfo;
        }
    }
}
