/********************************************************************
	created:	2016/06/18  15:57
	file base:	ResourceMgr
	file ext:	cs
	author:		shine
	purpose:	提供加载资源的相应接口
*********************************************************************/

using Framework;
using NS_DataCenter;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;
using System.IO;
using XYHY.ABSystem;

namespace XYHY
{
    public class ResourceMgr : IResourceMgr, IInitializeable
    {
#if UNITY_EDITOR
        private const string RES_PATH_EDITOR = "Assets/Res_XYHY/";
#endif

        public void Initialize()
        {

        }

        public void UnInitialize()
        {
            //卸载所有非永生的资源
            //UnloadNormalResources();
        }

        public Texture2D LoadTextureSync(string path)
        {
            Object obj = LoadNormalObjSync(new AssetBundleParams(path, typeof(Texture2D)));
            if (obj != null)
            {
                return obj as Texture2D;
            }
            return null;
        }

        public Texture2D LoadImmortalTextureSync(string path)
        {
            Object obj = LoadResidentMemoryObjSync(new AssetBundleParams(path, typeof(Texture2D)));
            if (obj != null)
            {
                return obj as Texture2D;
            }
            return null;
        }

        public UIAtlas LoadAtlasSync(string path)
        {
            Object obj = LoadNormalObjSync(new AssetBundleParams(path, typeof(GameObject)));
            if (obj != null)
            {
                GameObject go = obj as GameObject;
                if (go != null)
                {
                    return go.GetComponent<UIAtlas>();
                }
                return null;
            }
            return null;
        }


        /// <summary>
        /// 同步方式加载资源
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public Object LoadNormalObjSync(AssetBundleParams abParams)
        {
            Object retObj = null;

            //#if UNITY_EDITOR && (!(AB_WINDOW && UNITY_STANDALONE))
#if UNITY_EDITOR && (!(AB_WINDOW && UNITY_STANDALONE)) && !AB_MODE
            if (abParams.assetInMemoryType == AssetInMemoryType.buildin)
            {
                retObj = LoadFromResource(abParams.path);
            }
            else
            {
                retObj = LoadInEditor(abParams.path, abParams.type);
            }
#else
            if (abParams.assetInMemoryType == AssetInMemoryType.buildin)
            {
                retObj = LoadFromResource(abParams.path);
            }
            else
            {
                retObj = LoadFromAssetBundle(abParams.path);
            }
#endif

            if (retObj == null)
            {
                Debugger.LogError(string.Format("该资源不存在，路径:{0}，类型:{1}", abParams.path, abParams.type));
            }

            return retObj;
        }

        public Object LoadSceneResidentMemoryObjSync(AssetBundleParams abParams)
        {
            Object retObj = null;
            abParams.assetInMemoryType = AssetInMemoryType.TempResident;

#if UNITY_EDITOR
            retObj = LoadInEditor(abParams.path, abParams.type);
#else
            retObj = LoadFromResource(abParams.path);
#endif

            if (retObj == null)
            {
                Debugger.LogWarning(string.Format("该资源不存在，路径:{0}，类型:{1}", abParams.path, abParams.type));
            }

            return retObj;
        }

        //同步加载需常驻内存的资源
        public Object LoadResidentMemoryObjSync(AssetBundleParams abParams)
        {
            Object retObj = null;
            abParams.assetInMemoryType = AssetInMemoryType.Resident;

#if UNITY_EDITOR
            retObj = LoadInEditor(abParams.path, abParams.type);
#else
            retObj = LoadFromAssetBundle(abParams.path);
#endif

            if (retObj == null)
            {
                Debugger.LogWarning(string.Format("该资源不存在，路径:{0}，类型:{1}", abParams.path, abParams.type));
            }

            return retObj;
        }

        public bool LoadNormalObjAsync(AssetBundleParams abParams)
        {
            if (string.IsNullOrEmpty(abParams.path))
            {
                return false;
            }

            //先返回null  （TO DO）
            return false;
        }


        //异步加载需常驻内存的资源
        public Object LoadResidentMemoryObjAsync(AssetBundleParams abParams)
        {
            abParams.assetInMemoryType = AssetInMemoryType.Resident;

            //先返回null  （TO DO）
            return null;
        }

        /// <summary>
        /// 加载配置文件
        /// </summary>
        /// <param name="resPath">Resources目录相对路径</param>
        /// <param name="fileSuffix">文件后缀名</param>
        /// <returns>文件的bytes</returns>
        public byte[] LoadConfigFile(string resPath, string fileSuffix)
        {
            byte[] bytes = null;
            TextAsset ta = null;

            if (XyhyGlobal.IsLoadAssetBundle)
            {
                string fileUrl = string.Format("{0}{1}/{2}.{3}", BundleConfig.Instance.BundlesPathForPersist, BundleConfig.Instance.AssetBundleDirectory, resPath, fileSuffix);
                if (File.Exists(fileUrl))
                {
                    bytes = File.ReadAllBytes(fileUrl);
                }
                else
                {
                    ta = Resources.Load<TextAsset>(resPath);
                    if (ta != null)
                    {
                        bytes = ta.bytes;
                    }
                }
            }
            else
            {
                ta = Resources.Load<TextAsset>(resPath);
                if (ta != null)
                {
                    bytes = ta.bytes;
                }
            }

            if (bytes == null)
            {
                Debugger.LogError("can find skill config:" + resPath);
            }

            return bytes;
        }


        private string getBundleName(string path, System.Type type)
        {
            if (!string.IsNullOrEmpty(path) && type != null)
            {
                string[] fileTypeArray = type.ToString().Split('.');

                System.Text.StringBuilder sb = LuaInterface.StringBuilderCache.Acquire();  //new System.Text.StringBuilder();
                sb.Append(path);
                sb.Append(".");
                sb.Append(fileTypeArray[fileTypeArray.Length - 1]);
                sb.Replace(" ", "_");
                sb.Replace("/", ".");

                return LuaInterface.StringBuilderCache.GetStringAndRelease(sb);  //path.Replace("/", ".");
            }
            return string.Empty;
        }

        public bool UnloadResource(string path, System.Type type)
        {
            AssetBundleInfo abInfo = AssetBundleManager.Instance.GetBundleInfo(path);
            if (abInfo != null)
            {
                abInfo.Dispose();
                return true;
            }

            return false;
        }

        public bool UnloadImmortalResource(string path, System.Type type)
        {
            //string bundleName = getBundleName(path, type);

            //待补充
            return false;
        }

        //清理加载资源时使用的资源文件，标注Immortal的资源暂不销毁
        public void UnloadAllNormalResources()
        {
            //待补充
        }


        //卸载上一次的场景资源
        public void UnloadLastSceneAsset(string sceneName, UILabel labelCtrl = null)
        {

        }


        public static Object LoadInEditor(string path, System.Type type)
        {
#if UNITY_EDITOR
            string fileName = Path.GetFileName(path);
            string rootPath = Path.GetDirectoryName(path);
            string[] tpath = { string.Format("{0}{1}", RES_PATH_EDITOR, rootPath) };
            if (!Directory.Exists(tpath[0]))
            {
                return null;
            }
            string[] guids = UnityEditor.AssetDatabase.FindAssets(fileName, tpath);

            if (guids != null && guids.Length > 0)
            {
                for (int i = 0; i < guids.Length; ++i)
                {
                    string fpath = UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i]);
                    Object obj = UnityEditor.AssetDatabase.LoadAssetAtPath(fpath, type);
                    if (obj != null)
                        return obj;
                }
            }
#endif
            return null;
        }



        public static Object LoadFromResource(string path)
        {
            Object obj = Resources.Load(path);
            return obj;
        }

        public static Object LoadFromAssetBundle(string path)
        {
            AssetBundleInfo abInfo = AssetBundleManager.Instance.LoadSync(path);

            if (abInfo == null)
            {
                Debugger.LogError(string.Format("该资源不存在，路径:{0}", path));
                return null;
            }
            return abInfo.mainObject;
        }

        public static void LoadGameDep(string depName, System.Action callback)
        {
            AssetBundleManager.Instance.StartCoroutine(AssetBundleManager.Instance.SubLoadDepInfo(depName, callback));
        }
    }
}

