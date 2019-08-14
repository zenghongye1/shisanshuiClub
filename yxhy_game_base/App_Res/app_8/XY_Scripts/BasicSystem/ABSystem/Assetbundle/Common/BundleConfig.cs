/********************************************************************
	created:	2015/12/20  15:44
	file base:	BundleConfig
	file ext:	cs
	author:		shine	
	purpose:	资源包配置
*********************************************************************/

using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;

namespace XYHY
{
    public enum TargetPlatform
    {
        None = 0,
        Win = 5,
        iPhone = 9,
        Android = 13
    }


    public class BundleConfig
    {
        private static readonly object flag = new object();
        private BundleConfig() { }
        private static BundleConfig instance;

        public static BundleConfig Instance
        {
            get
            {
                if (instance == null)
                {
                    lock (flag)
                    {
                        if (instance == null)
                        {
                            instance = new BundleConfig();
                        }
                    }
                }

                return instance;
            }
        }
        
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

        //资源包存放目录名
        public string AssetBundleDirectory { get { return "AssetBundles"; } }

        private string persistentDataPath = null;
        public string PersistentDataPath
        {
            get
            {
                if (string.IsNullOrEmpty(persistentDataPath))
                {
                    persistentDataPath = Application.persistentDataPath;
                }
                return persistentDataPath;
            }
        }
        
        //资源包存放路径persistentPath
        private string bundlesPathForPersist = null;
        public string BundlesPathForPersist
        {
            get
            {
                if (string.IsNullOrEmpty(bundlesPathForPersist))
                {
                    bundlesPathForPersist = PersistentDataPath + "/" + BundlePlatformStr + "/";
                }
                return bundlesPathForPersist;
            }
        }
        
        //资源依赖关系表文件名
        public string DependFileName = "Depend.bytes";
        
        //版本文件存放文件名
        public string VersionFileName = "version.bytes";

        //渠道号存放文件名
        public string ChannelFileName = "channel.bytes";

        //资源包的后缀
        public string BundleSuffix = ".ab";
        
        public string GetBundleUrlForAsyncLoad(string bundleName)
        {
            string path = PersistentDataPath;
            string fileUrl;
            fileUrl = string.Format("{0}/{1}/{2}", path, BundlePlatformStr, bundleName);

            if (File.Exists(fileUrl))
            {
                return fileUrl;
            }
            //获取资源包在StreamingAssets目录下的url
            else
            {
                path = StreamingAssetPath;
                
                fileUrl = string.Format("{0}/{1}/{2}/{3}", path, AssetBundleDirectory, BundlePlatformStr, bundleName);

                return fileUrl;
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

                fileUrl = string.Format("{0}/{1}/{2}/{3}", path, AssetBundleDirectory, BundlePlatformStr, bundleName);

                return fileUrl;
            }
        }
        
        //获取各平台下StreamingAsset目录路径
        private string streamingAssetPath = null;
        public string StreamingAssetPath
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
    }
}
