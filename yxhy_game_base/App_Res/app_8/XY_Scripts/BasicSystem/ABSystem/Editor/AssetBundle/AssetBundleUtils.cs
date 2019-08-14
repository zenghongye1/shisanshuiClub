using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;
using System.Linq;

namespace XYHY.ABSystem
{
    class AssetCacheInfo
    {
        /// <summary>
        /// 源文件的hash，比较变化
        /// </summary>
        public string fileHash;
        /// <summary>
        /// 源文件meta文件的hash，部分类型的素材需要结合这个来判断变化
        /// 如：Texture
        /// </summary>
        public string metaHash;
        /// <summary>
        /// 上次打好的AB的CRC值，用于增量判断
        /// </summary>
        public string bundleCrc;
        /// <summary>
        /// 所依赖的那些文件
        /// </summary>
        public string[] depNames;
    }

    class AssetBundleUtils
    {
        public static AssetBundlePathResolver pathResolver;
        public static DirectoryInfo AssetDir = new DirectoryInfo(Application.dataPath);
        public static string AssetPath = AssetDir.FullName;
        public static DirectoryInfo ProjectDir = AssetDir.Parent;
        public static string ProjectPath = ProjectDir.FullName;

        static Dictionary<int, AssetTarget> _object2target;       
        static Dictionary<string, AssetTarget> _assetPath2target;
        static Dictionary<string, string> _fileHashCache;
        static Dictionary<string, AssetCacheInfo> _fileHashOld;

        static Dictionary<int, AssetTarget> _confAndLua2target;
        static Dictionary<string, AssetTarget> _confAndLuaPath2target;

        public static void Init()
        {
            _object2target = new Dictionary<int, AssetTarget>();
            _assetPath2target = new Dictionary<string, AssetTarget>();
            _fileHashCache = new Dictionary<string, string>();
            _fileHashOld = new Dictionary<string, AssetCacheInfo>();

            _confAndLua2target = new Dictionary<int, AssetTarget>();
            _confAndLuaPath2target = new Dictionary<string, AssetTarget>();

            //LoadVersionInfo();            

            LoadCache();            
        }

        public static void ClearCache()
        {
            _object2target = null;
            _assetPath2target = null;
            _fileHashCache = null;
            _fileHashOld = null;

            _confAndLua2target = null;
            _confAndLuaPath2target = null;
        }

        public static void LoadVersionInfo()
        {
            VersionInfo verInfo = FileUtils.GetGameVerNo(AssetBundlePathResolver.instance.VerCommSaveFile);
            if (verInfo != null)
            {
                AssetBundlePathResolver.version = new Version(verInfo.VersionNum);
            }            
        }

        public static void LoadCache()
        {
            for(int i=0; i< AssetBundleBuildPanel.verConfLst.Count; i++)
            {
                string cacheTxtFilePath = pathResolver.HashCacheSaveFile + AssetBundleBuildPanel.verConfLst[i];
                if (File.Exists(cacheTxtFilePath))
                {
                    string value = File.ReadAllText(cacheTxtFilePath);
                    StringReader sr = new StringReader(value);

                    //版本比较
                    string vString = sr.ReadLine();
                    bool wrongVer = false;
                    try
                    {
                        Version ver = new Version(vString);
                        wrongVer = ver.Minor < AssetBundlePathResolver.dicVersion[AssetBundleBuildPanel.verConfLst[i].fileName].Minor || 
                            ver.Major < AssetBundlePathResolver.dicVersion[AssetBundleBuildPanel.verConfLst[i].fileName].Major;                            //AssetBundlePathResolver.version.Minor || ver.Major < AssetBundlePathResolver.version.Major;
                    }
                    catch (Exception) { wrongVer = true; }

                    if (wrongVer)
                        return;

                    //读取缓存的信息
                    while (true)
                    {
                        string path = sr.ReadLine();
                        if (path == null)
                            break;

                        AssetCacheInfo cache = new AssetCacheInfo();
                        cache.fileHash = sr.ReadLine();
                        cache.metaHash = sr.ReadLine();
                        cache.bundleCrc = sr.ReadLine();
                        int depsCount = Convert.ToInt32(sr.ReadLine());
                        cache.depNames = new string[depsCount];
                        for (int j = 0; j < depsCount; j++)
                        {
                            cache.depNames[j] = sr.ReadLine();
                        }

                        _fileHashOld[path] = cache;
                    }
                }
            }
        }

        public static void SaveCache()
        {
            for(int i=0; i<AssetBundleBuildPanel.verConfLst.Count; i++)
            {
                StreamWriter sw = new StreamWriter(pathResolver.HashCacheSaveFile + AssetBundleBuildPanel.verConfLst[i].fileName);
                sw.WriteLine(AssetBundleBuildPanel.verConfLst[i].versionNum.ToString());

                foreach (AssetTarget target in _object2target.Values)
                {
#if UNITY_IOS || UNITY_IPHONE
                    string key = "ver_" + target.assetPath.Split('/')[2] + ".txt";
#elif UNITY_ANDROID
                    string key = "ver_" + target.assetPath.Split('\\')[2] + ".txt";
#endif
                    if (key == AssetBundleBuildPanel.verConfLst[i].fileName)
                    {
                        target.WriteCache(sw);
                    }
                    else
                    {
                        if (i == 0)
                        {
                            bool flag = true;
                            for (int j = 0; j < AssetBundleBuildPanel.verConfLst.Count; j++)
                            {
                                if (key == AssetBundleBuildPanel.verConfLst[i].fileName)
                                {
                                    flag = false;
                                    break;
                                }
                            }

                            if (flag)
                            {
                                target.WriteCache(sw);
                            }
                        }
                    }                    
                }

                sw.Flush();
                sw.Close();
            }


            /*StreamWriter sw = new StreamWriter(pathResolver.HashCacheSaveFile);
            sw.WriteLine(AssetBundlePathResolver.version.ToString());
            foreach (AssetTarget target in _object2target.Values)
            {
                target.WriteCache(sw);
            }

            foreach(AssetTarget target in _confAndLua2target.Values)
            {
                target.WriteCache(sw);
            }

            sw.Flush();
            sw.Close();*/
        }

        public static List<AssetTarget> GetAll()
        {
            return new List<AssetTarget>(_object2target.Values);
        }

        public static List<AssetTarget> GetAllConfAndLua()
        {
            return new List<AssetTarget>(_confAndLua2target.Values);
        }

        public static AssetTarget Load(Object o)
        {
            AssetTarget target = null;
            if (o != null)
            {
                int instanceId = o.GetInstanceID();

                if (_object2target.ContainsKey(instanceId))
                {
                    target = _object2target[instanceId];
                }
                else
                {
                    string assetPath = AssetDatabase.GetAssetPath(o);
                    string key = assetPath;
                    //Builtin，内置素材，path为空
                    if (string.IsNullOrEmpty(assetPath))
                        key = string.Format("Builtin______{0}", o.name);
                    else
                        key = string.Format("{0}/{1}", assetPath, instanceId);

                    if (_assetPath2target.ContainsKey(key))
                    {
                        target = _assetPath2target[key];
                    }
                    else
                    {
                        if (assetPath.StartsWith("Resources"))
                        {
                            assetPath = string.Format("{0}/{1}.{2}", assetPath, o.name, o.GetType().Name);
                        }
                        FileInfo file = new FileInfo(Path.Combine(ProjectPath, assetPath));
                        target = new AssetTarget(o, file, assetPath);
                        _object2target[instanceId] = target;
                        _assetPath2target[key] = target;
                    }
                }
            }
            return target;
        }

        public static AssetTarget LoadConfAndLua(FileInfo file, System.Type t = null)
        {
            AssetTarget target = null;
            string fullPath = file.FullName;
            int index = fullPath.IndexOf("Assets");
            if (index != -1)
            {
                string assetPath = fullPath.Substring(index);

                if (_confAndLuaPath2target.ContainsKey(assetPath))
                {
                    target = _confAndLuaPath2target[assetPath];
                }
                else
                {
                    Object o = null;
                    if (t == null)
                        o = AssetDatabase.LoadMainAssetAtPath(assetPath);
                    else
                        o = AssetDatabase.LoadAssetAtPath(assetPath, t);

                    if (o != null)
                    {
                        int instanceId = o.GetInstanceID();
                        target = new AssetTarget(o, file, assetPath);
                        string key = string.Format("{0}/{1}", assetPath, instanceId);
                        _confAndLuaPath2target[key] = target;
                        _confAndLua2target[instanceId] = target;
                    }
                }
            }

            return target;
        }

        public static AssetTarget Load(FileInfo file, System.Type t)
        {
            AssetTarget target = null;
            string fullPath = file.FullName;
            int index = fullPath.IndexOf("Assets");
            if (index != -1)
            {
                string assetPath = fullPath.Substring(index);
                if (_assetPath2target.ContainsKey(assetPath))
                {
                    target = _assetPath2target[assetPath];
                }
                else
                {
                    Object o = null;
                    if (t == null)
                        o = AssetDatabase.LoadMainAssetAtPath(assetPath);
                    else
                        o = AssetDatabase.LoadAssetAtPath(assetPath, t);

                    if (o != null)
                    {
                        int instanceId = o.GetInstanceID();

                        if (_object2target.ContainsKey(instanceId))
                        {
                            target = _object2target[instanceId];
                        }
                        else
                        {
                            target = new AssetTarget(o, file, assetPath);
                            string key = string.Format("{0}/{1}", assetPath, instanceId);
                            _assetPath2target[key] = target;
                            _object2target[instanceId] = target;
                        }
                    }
                }
            }

            return target;
        }

        public static AssetTarget Load(FileInfo file)
        {
            return Load(file, null);
        }

        public static string ConvertToABName(string assetPath)
        {
            /*string bn = assetPath
                .Replace(AssetPath, "")
                .Replace('\\', '.')
                .Replace('/', '.')
                .Replace(" ", "_")
                .ToLower();*/
            string bn = assetPath
                .Replace(AssetPath, "")
                .Replace('\\', '/')                
                .Replace(" ", "_")
                .ToLower();
            return bn;
        }

        public static string GetFileHash(string path, bool force = false)
        {
            string _hexStr = null;
            if (_fileHashCache.ContainsKey(path) && !force)
            {
                _hexStr = _fileHashCache[path];
            }
            else if (File.Exists(path) == false)
            {
                _hexStr = "FileNotExists";
            }
            else
            {
                FileStream fs = new FileStream(path,
                    FileMode.Open,
                    FileAccess.Read,
                    FileShare.Read);

                _hexStr = HashUtil.Get(fs);
                _fileHashCache[path] = _hexStr;
                fs.Close();
            }
            
            return _hexStr;
        }

        public static AssetCacheInfo GetCacheInfo(string path)
        {
            if (_fileHashOld.ContainsKey(path))
                return _fileHashOld[path];
            return null;
        }


        /// <summary>
        /// 压缩Patch包 (先不压缩)
        /// </summary>
        /// <returns>返回压缩结果，true成功，false失败</returns>
        public static void Convert2Patch()
        {
            //string zipFileName = string.Format("ver_{0}", AssetBundlePathResolver.version.ToString());
            string dir = string.Format("{0}ver_{1}/", AssetBundlePathResolver.instance.BundlesPathForServer, AssetBundlePathResolver.version.ToString());

            foreach (var item in GetAllConfAndLua())
            {
                if (item.FileChangeMode != FileChangeType.None)
                {
                    if (item.assetPath.Contains("Lua")
                        || item.assetPath.Contains("ProtobufDataConfig"))
                    {
                        string fileUrl = item.file.FullName.Replace("\\", "/");
                        fileUrl = fileUrl.Replace(Application.dataPath.Replace("\\", "/"), "");
                        fileUrl = fileUrl.Replace("/Resources/", "");

                        string destUrl = string.Format("{0}{1}", dir, fileUrl);
                        string destDir = Path.GetDirectoryName(destUrl);
                        Directory.CreateDirectory(destDir);
                        if (File.Exists(item.file.FullName))
                        {
                            File.Copy(item.file.FullName, destUrl, true);
                        }
                    }
                }
            }
            
            foreach(var item in GetAll())
            {
                if (item.FileChangeMode != FileChangeType.None)
                {
#if UNITY_IOS || UNITY_IPHONE
                    string fileUrl = item.assetPath.Split('/')[2];                    
#elif UNITY_ANDROID
                    string fileUrl = item.assetPath.Split('\\')[2];                   
#endif                                       
                    string assetBundleName = fileUrl + "/" + HashUtil.Get(item.assetPath.Replace("\\", "/").ToLower()) + ".ab";
                    string destUrl = string.Format("{0}{1}", dir, AssetBundlePathResolver.instance.BundlePlatformStr + "/" + AssetBundlePathResolver.instance.BundleSaveDirName + "/" + assetBundleName);                    
                    //string assetBundleName = fileUrl + "/" + HashUtil.Get(item.assetPath.Replace("\\", "/").ToLower()) + ".ab";

                    string srcUrl = string.Format("{0}/StreamingAssets/{1}/{2}", Application.dataPath, 
                        AssetBundlePathResolver.instance.BundlePlatformStr + "/" + AssetBundlePathResolver.instance.BundleSaveDirName, assetBundleName);

                    string destDir = Path.GetDirectoryName(destUrl);
                    if (!Directory.Exists(destDir))
                    {
                        Directory.CreateDirectory(destDir);
                    }                    
                    if (File.Exists(srcUrl))
                    {
                        File.Copy(srcUrl, destUrl, true);
                    }
                }
            }

            new DirectoryInfo(dir);  
            //DirectoryInfo di = 
            //FileInfo[] fiArray = di.GetFiles("*.*", SearchOption.AllDirectories).ToArray<FileInfo>();
            //ZipHelper.CompressDirectory(dir, fiArray, string.Format("{0}{1}.zip", AssetBundlePathResolver.instance.BundlesPathForServer, zipFileName), 5, false);
        }
    }
}
