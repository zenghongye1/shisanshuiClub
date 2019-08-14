using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace XYHY.ABSystem
{
    public enum TargetPlatform
    {
        None = 0,
        Win = 5,
        iPhone = 9,
        Android = 13
    }

    /// <summary>
    /// AB 打包及运行时路径解决器
    /// </summary>
    public class AssetBundlePathResolver
    {
        public static AssetBundlePathResolver instance;

        public AssetBundlePathResolver()
        {
            instance = this;
        }


        public static Version version = new Version(0, 1, 0);
        public static Dictionary<string, Version> dicVersion = new Dictionary<string, Version>();


        //打包平台
        public TargetPlatform BundlePlatform
        {
            get
            {
                TargetPlatform tp = TargetPlatform.Win;
#if UNITY_EDITOR
                switch (UnityEditor.EditorUserBuildSettings.activeBuildTarget)
                {
                    case UnityEditor.BuildTarget.StandaloneOSXIntel64:
                    case UnityEditor.BuildTarget.StandaloneWindows:
                        tp = TargetPlatform.Win;
                        break;
                    case UnityEditor.BuildTarget.iOS:
                        tp = TargetPlatform.iPhone;
                        break;
                    case UnityEditor.BuildTarget.Android:
                        tp = TargetPlatform.Android;
                        break;
                }
#else
#if UNITY_STANDALONE
                        tp = TargetPlatform.Win;
#elif UNITY_IPHONE
                        tp = TargetPlatform.iPhone;
#elif UNITY_ANDROID
                        tp = TargetPlatform.Android;
#endif
#endif
                return tp;
            }
        }

        private string bundlePlatformStr = null;
        public string BundlePlatformStr
        {
            get
            {
                if (string.IsNullOrEmpty(bundlePlatformStr))
                {
                    bundlePlatformStr = BundlePlatform.ToString();
                }
                return bundlePlatformStr;
            }
        }

        /// <summary>
        /// AB 保存的路径相对于 Assets/StreamingAssets 的名字
        /// </summary>
        public virtual string BundleSaveDirName { get { return "AssetBundles"; } }

        //版本文件存放文件名
        public virtual string VerCommSaveFile { get { return "ver_app4.txt"; } }
        public virtual string VerGame11SaveFile { get { return "ver_game11.txt"; } }
        public virtual string VerGame18SaveFile { get { return "ver_game18.txt"; } }


#if UNITY_EDITOR
        /// <summary>
        /// AB 保存的路径
        /// </summary>
        public string BundleSavePath { get { return "Assets/StreamingAssets/" + BundlePlatformStr + "/" + BundleSaveDirName; } }
        /// <summary>
        /// AB打包的原文件HashCode要保存到的路径，下次可供增量打包
        /// </summary>
        public virtual string HashCacheSaveFile { get { return "Assets/AssetBundles/"; } }   //cache.txt
        /// <summary>
        /// 在编辑器模型下将 abName 转为 Assets/... 路径
        /// 这样就可以不用打包直接用了
        /// </summary>
        /// <param name="abName"></param>
        /// <returns></returns>
        public virtual string GetEditorModePath(string abName)
        {
            //将 Assets.AA.BB.prefab 转为 Assets/AA/BB.prefab
            abName = abName.Replace(".", "/");
            int last = abName.LastIndexOf("/");

            if (last == -1)
                return abName;

            string path = string.Format("{0}.{1}", abName.Substring(0, last), abName.Substring(last + 1));
            return path;
        }

        //外部包路径（该资源应上传到服务器，等待客户端下载）
        public string BundlesPathForServer
        {
            get
            {
                return string.Format("{0}/../AssetBundle_Server/{1}/", Application.dataPath, bundlePlatformStr);
            }
        }

        //全部ab导出路径
        public string BundlesAllExportPath
        {
            get
            {
                return string.Format("{0}/../AssetBundle_Server/All/{1}/", Application.dataPath, bundlePlatformStr);
            }
        }

        //全部ab导出路径
        public string BundlesGameExportPath
        {
            get
            {
                return string.Format("{0}/../AssetBundle_Server/Gid/{1}/", Application.dataPath, bundlePlatformStr);
            }
        }

        public string DependenceCahcePath
        {
            get
            {
                return Application.dataPath + "/AssetBundles/" + bundlePlatformStr + "/";
            }
        }

        //热更ab导出资源
        public string BundlesHotUpdateExportPath
        {
            get
            {
                return string.Format("{0}/../AssetBundle_Server/HotUpdate/{1}/", Application.dataPath, bundlePlatformStr);
            }
        }


        public string GetBundlesHotUpdateExportPath(string ver)
        {
            return string.Format("{0}/../AssetBundle_Server/HotUpdate/{1}/{2}/AssetBundles/", Application.dataPath,ver, bundlePlatformStr);
        }

        public string BundleSaveFullPath
        {
            get
            {
                return string.Format("{0}/StreamingAssets/{1}/", Application.dataPath, bundlePlatformStr);
            }
        }

        public string LuaBytesPath
        {
            get
            {
                return string.Format("{0}/Resources/Lua", Application.dataPath);
            }
        }

        public string ProtobufDataPath
        {
            get
            {
                return string.Format("{0}/Resources/ProtobufDataConfig", Application.dataPath);
            }
        }

#endif

        /// <summary>
        /// 获取 AB 源文件路径（打包进安装包的）
        /// </summary>
        /// <param name="path"></param>
        /// <param name="forWWW"></param>
        /// <returns></returns>
        public virtual string GetBundleSourceFile(string path, bool forWWW = true)
        {
            string filePath = null;
#if UNITY_EDITOR            
            if (forWWW)                
                filePath = string.Format("file://{0}/StreamingAssets/{1}/{2}", Application.dataPath, BundlePlatformStr + "/" + BundleSaveDirName, path);
            else
                filePath = string.Format("{0}/StreamingAssets/{1}/{2}", Application.dataPath, BundlePlatformStr + "/" + BundleSaveDirName, path);
#elif UNITY_ANDROID
            //filePath = string.Format("{0}/{1}/{2}", Application.streamingAssetsPath, BundlePlatformStr + "/" + BundleSaveDirName, path);    //jar:file://{0}!/assets/{1}/{2}
            //filePath = Path.Combine(Application.streamingAssetsPath, BundlePlatformStr + "/" + BundleSaveDirName + path);                
            if (forWWW)
                filePath = string.Format("{0}/{1}/{2}/{3}", Application.streamingAssetsPath, BundlePlatformStr, BundleSaveDirName, path);                
            else
                filePath = string.Format("{0}!assets/{1}/{2}/{3}", Application.dataPath, BundlePlatformStr, BundleSaveDirName, path);                                 
#elif UNITY_IOS
            if (forWWW)
                filePath = string.Format("file://{0}/Raw/{1}/{2}/{3}", Application.dataPath, BundlePlatformStr, BundleSaveDirName, path);
            else
                filePath = string.Format("{0}/Raw/{1}/{2}/{3}", Application.dataPath, BundlePlatformStr, BundleSaveDirName, path);
#else
            throw new System.NotImplementedException();
#endif
            //Debug.Log("filePath=======================" + filePath);
            return filePath;
        }

        /// <summary>
        /// AB 依赖信息文件名
        /// </summary>
        public virtual string DependCommFileName { get { return "dep_app3.all"; } }
        public virtual string DependGame11FileName { get { return "dep_game11.all"; } }
        public virtual string DependGame18FileName { get { return "dep_game18.all"; } }


        DirectoryInfo cacheDir;

        /// <summary>
        /// 用于缓存AB的目录，要求可写
        /// </summary>
        public virtual string BundleCacheDir
        {
            get
            {
                if (cacheDir == null)
                {
#if UNITY_EDITOR && false
                    string dir = string.Format("{0}/{1}/{2}", Application.streamingAssetsPath, BundlePlatformStr, BundleSaveDirName);
#else
					string dir = string.Format("{0}/{1}/{2}", Application.persistentDataPath, BundlePlatformStr, BundleSaveDirName);
#endif
                    cacheDir = new DirectoryInfo(dir);
                    if (!cacheDir.Exists)
                        cacheDir.Create();
                }
                return cacheDir.FullName;
            }
        }

        string streamingAssetPath = null;
        public virtual string StreamingAssetPath
        {
            get
            {                
                if (string.IsNullOrEmpty(streamingAssetPath))
                {
                    streamingAssetPath = Application.streamingAssetsPath;
                    /*
                    #if UNITY_EDITOR || UNITY_STANDALONE
                        streamingAssetPath = Application.streamingAssetsPath;
                    #elif UNITY_IPHONE
                        streamingAssetPath = "file://" + Application.dataPath + "/Raw/";
                    #elif UNITY_ANDROID
                        streamingAssetPath = "jar:file://" + Application.dataPath + "!/assets/";
                    #endif
                    */
                }

                return streamingAssetPath;
            }
        }

        public virtual string PersistentDataPath
        {
            get
            {
                return Application.persistentDataPath;
            }
        }

        //存放在streamingAssetsPath下的资源包的路径
        public string BundlesPathForStreaming
        {
            get
            {
                return string.Format("{0}/{1}/{2}/", Application.streamingAssetsPath, BundlePlatformStr, BundleSaveDirName);
            }
        }

        //存放在streamingAssetsPath下的资源包的路径
        public string BundlesPathForPersistent
        {
            get
            {
                return string.Format("{0}/{1}/{2}/", Application.persistentDataPath, BundlePlatformStr, BundleSaveDirName);
            }
        }

        public string GetBundleUrlForSyncLoad(string bundleName)
        {
            string path = PersistentDataPath;
            string fileUrl;

            fileUrl = string.Format("{0}/{1}/{2}", path, BundlePlatformStr, bundleName);

            //获取资源包在persistentDataPath目录下的url
            if (File.Exists(fileUrl))
            {
                return fileUrl;
            }
            //获取资源包在StreamingAssets目录下的url
            else
            {
                path = StreamingAssetPath;

                fileUrl = string.Format("{0}/{1}/{2}/{3}", path, BundleSaveDirName, BundlePlatformStr, bundleName);

                return fileUrl;
            }
        }
    }
}