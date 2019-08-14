using UnityEngine;
using System.Collections;
using System;

namespace SceneSystem
{
    public class AssetPreloadProcess : SceneProcessBase
    {
        private Coroutine mLoadSceneCor = null;
        public override void Start()
        {
            Messenger.BroadcastAsync(MSG_DEFINE.MSG_SCENE_LOAD_PRE);
            StartCoroutine();
        }
        public override void Stop()
        {
            if (mLoadSceneCor != null)
            {
                Framework.GameKernel.StopMonoCoroutine(mLoadSceneCor);
                mLoadSceneCor = null;
            }
        }

        void StartCoroutine()
        {
            mLoadSceneCor = Framework.GameKernel.StartMonoCoroutine(StartLoadingCor());
        }
        private IEnumerator StartLoadingCor()
        {
            XYHY.IResourceMgr resMgr = Framework.GameKernel.GetResourceMgr();
            int displayProgress = 0;
            int toProgress = 0;
            int sceneLoadPercent = 20;
            int processSpeed = 4;
            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreLoad);
            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreloadScene);

            int sceneAssetLoadPercent = 30;
            PreloadResult preloadSceneResult = new PreloadResult();
            PreloadManager.Instance.PreloadSceneAsset(SceneMgr.Instance.CurrentScene, ref preloadSceneResult);
            if (preloadSceneResult != null && preloadSceneResult.TotalCount > 0)
            {
                while (true)
                {
                    toProgress = (int)(preloadSceneResult.PreloadPercent * sceneLoadPercent);
                    while (displayProgress < toProgress)
                    {
                        displayProgress += processSpeed;
                        setLoadingPercentage(displayProgress);
                        yield return new WaitForEndOfFrame();
                    }
                    if (preloadSceneResult.PreloadPercent >= 1 && toProgress == sceneLoadPercent)
                    {
                        break;
                    }
                    yield return null;
                }
            }
            preloadSceneResult = null;

            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreloadScene,false);

            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreUnloadScn);
            //卸载场景物件
            resMgr.UnloadLastSceneAsset(SceneMgr.Instance.CurrentScene);
            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreUnloadScn, false);

            //预加载异步资源
            PreloadResult preloadAsyncAssetResult = new PreloadResult();
            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreloadAsset);

            PreloadManager.Instance.PreloadAsyncAssets(SceneMgr.Instance.SceneId, ref preloadAsyncAssetResult);
            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreloadAsset,false);

            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreLoadAssetAsy);

            if (preloadAsyncAssetResult != null && preloadAsyncAssetResult.TotalCount > 0)
            {
                while (true)
                {
                    toProgress = sceneLoadPercent + (int)(preloadAsyncAssetResult.PreloadPercent * sceneAssetLoadPercent);

                    while (displayProgress < toProgress)
                    {
                        displayProgress += processSpeed;
                        setLoadingPercentage(displayProgress);
                        yield return new WaitForEndOfFrame();
                    }
                    if (preloadAsyncAssetResult.PreloadPercent >= 1 && toProgress == (sceneLoadPercent + sceneAssetLoadPercent))
                    {
                        preloadAsyncAssetResult = null;
                        break;
                    }
                    yield return null;
                }
            }
            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreLoadAssetAsy,false);

            //预加载同时有同步和异步的资源
            PreloadResult preloadSyncAndAsyncAssetsResult = new PreloadResult();
            PreloadManager.Instance.PreloadSyncAndAsyncAssets(SceneMgr.Instance.SceneId, ref preloadSyncAndAsyncAssetsResult);

            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreLoadSycAndAsy);
            if (preloadSyncAndAsyncAssetsResult != null && preloadSyncAndAsyncAssetsResult.TotalCount > 0)
            {
                while (true)
                {
                    toProgress = sceneLoadPercent + sceneAssetLoadPercent + (int)(preloadSyncAndAsyncAssetsResult.PreloadPercent * (100 - sceneLoadPercent - sceneAssetLoadPercent));

                    while (displayProgress < toProgress)
                    {
                        displayProgress += processSpeed;
                        setLoadingPercentage(displayProgress);
                        yield return new WaitForEndOfFrame();
                    }
                    if (preloadSyncAndAsyncAssetsResult.PreloadPercent >= 1 && toProgress == 100)
                    {
                        preloadSyncAndAsyncAssetsResult = null;
                        break;
                    }
                    yield return null;
                }
            }
            TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreLoadSycAndAsy,false);
            
            toProgress = 100;
            while (displayProgress < toProgress)
            {
                displayProgress += processSpeed;
                setLoadingPercentage(displayProgress);
                yield return null;
            }
        }

        private void setLoadingPercentage(int progress)
        {
            Messenger.BroadcastAsync<int>(MSG_DEFINE.MSG_LOADING_PROCESS_CHANGE, progress);

            if (progress >= 100)
            {
                progress = 100;
                Complete();
                TimeCostLog.Instance.WriteLog(SceneMgr.Instance.SceneId, eTimeCost.ePreLoad, false);         
            }
        }
    }
}
