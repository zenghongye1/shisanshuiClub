using UnityEngine;
using System.Collections;
using System;
using System.IO;
using XYHY;
using UnityEngine.SceneManagement;

namespace SceneSystem
{
    public class LoadingSceneProcess : SceneProcessBase
    {
        private const string LOADING_SCENE_NAME = "xyhy_loading";

        /// 记录上次开启的协程
        /// </summary>
        private Coroutine mLoadSceneResCor = null;
        private WWW www = null;

        public override void Start()
        {
            if (mLoadSceneResCor != null)
            {
                Framework.GameKernel.StopMonoCoroutine(mLoadSceneResCor);
                mLoadSceneResCor = null;
            }
            mLoadSceneResCor = Framework.GameKernel.StartMonoCoroutine(IELoadScene());
        }

        public override void Stop()
        {
            if (mLoadSceneResCor != null)
            {
                Framework.GameKernel.StopMonoCoroutine(mLoadSceneResCor);
                if (www != null)
                {
                    www.Dispose();
                    www = null;
                }

                mLoadSceneResCor = null;
            }
        }

        private IEnumerator IELoadScene()
        {
            if (XyhyGlobal.IsLoadAssetBundle)
            {
                System.Text.StringBuilder fileUrlsb = LuaInterface.StringBuilderCache.Acquire();
                fileUrlsb.Append(BundleConfig.Instance.PersistentDataPath);
                fileUrlsb.Append("/");
                fileUrlsb.Append(BundleConfig.Instance.BundlePlatformStr);
                fileUrlsb.Append("/");
                fileUrlsb.Append("Levels");
                fileUrlsb.Append("/");
                fileUrlsb.Append(LOADING_SCENE_NAME);

                string fileUrl = LuaInterface.StringBuilderCache.GetStringAndRelease(fileUrlsb);
                //获取资源包在persistentDataPath目录下的url
                if (File.Exists(fileUrl))
                {
                    www = new WWW("file:///" + fileUrl);
                    yield return www;
                    if (www.error != null)
                    {
                        Debug.LogError("--SceneResourcesMgr LoadScene-->" + www.error);
                    }

                    AssetBundle ab = www.assetBundle;
                    www.Dispose();
                    www = null;
                    OnLevelWasLoaded();
                    ab.Unload(false);
                }
                else
                {
                    OnLevelWasLoaded();
                }
            }
            else
            {
                OnLevelWasLoaded();
            }

            yield return new WaitForEndOfFrame();
        }

        void OnLevelWasLoaded()
        {
            Framework.GameKernel.GetResourceMgr().UnloadAllNormalResources();
            //Application.LoadLevel(LOADING_SCENE_NAME);
            SceneManager.LoadScene(LOADING_SCENE_NAME);
            Complete();
        }
    }
}