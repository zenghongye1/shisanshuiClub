using UnityEngine;
using System.Collections;
using System;
using System.IO;
using XYHY;
using UnityEngine.SceneManagement;

namespace SceneSystem
{
    public class LevelsLoadProcess : SceneProcessBase
    {
        /// 记录上次开启的协程
        /// </summary>
        private Coroutine mLoadSceneResCor = null;
        private Coroutine mLoadSceneCor = null;
        private WWW www = null;

        public override void Start()
        {
            if (mLoadSceneResCor != null)
            {
                Framework.GameKernel.StopMonoCoroutine(mLoadSceneResCor);
                mLoadSceneResCor = null;
            }

            if (mLoadSceneCor != null)
            {
                Framework.GameKernel.StopMonoCoroutine(mLoadSceneCor);
                mLoadSceneCor = null;
            }

            mLoadSceneResCor = Framework.GameKernel.StartMonoCoroutine(IELoadSceneRes());
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

            if (mLoadSceneCor != null)
            {
                Framework.GameKernel.StopMonoCoroutine(mLoadSceneCor);
                mLoadSceneCor = null;
            }
        }

        private IEnumerator IELoadSceneRes()
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
                fileUrlsb.Append(SceneMgr.Instance.CurrentScene);

                string fileUrl = LuaInterface.StringBuilderCache.GetStringAndRelease(fileUrlsb);
                //获取资源包在persistentDataPath目录下的url
                if (File.Exists(fileUrl))
                {
//                    www = new WWW("file:///" + fileUrl);
//                    yield return www;
//                    if (www.error != null)
//                    {
//                        Debug.LogError("--SceneResourcesMgr LoadScene-->" + www.error);
//                    }
//
//                    AssetBundle ab = www.assetBundle;
//                    www.Dispose();
//                    www = null;
//                    OnLevelWasLoaded();
//                    ab.Unload(false);

                    string path = "file:///" + fileUrl;

                    AssetBundleCreateRequest request =
                        AssetBundle.LoadFromFileAsync(path);

                    yield return request;

                    OnLevelWasLoaded();

                    AssetBundle ab = request.assetBundle;

                    if (ab != null)
                    {
                        ab.Unload(false);
                    }
                    else
                    {
                        LuaInterface.Debugger.LogWarning("Async加载场景错误：" + path);
                    }

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
            mLoadSceneCor = Framework.GameKernel.StartMonoCoroutine(IELoadScene());
        }

        private IEnumerator IELoadScene()
        {
            AsyncOperation op = SceneManager.LoadSceneAsync(SceneMgr.Instance.CurrentScene);
            while (!op.isDone)
            {
                //toProgress = (int)(sceneLoadPercent * op.progress);
                //while (displayProgress < toProgress)
                //{
                //    displayProgress += processSpeed;
                //    setLoadingPercentage(displayProgress, op);
                //    yield return null;
                //}
                //Messenger.BroadcastAsync<int>(MSG_DEFINE.MSG_LOADING_PROCESS_CHANGE, (int)(op.progress * 20));
                yield return new WaitForEndOfFrame();
            }

            Complete();
        }
    }
}