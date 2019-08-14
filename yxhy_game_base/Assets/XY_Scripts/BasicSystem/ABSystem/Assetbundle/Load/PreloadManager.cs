using UnityEngine;
using System.Collections;
using Framework;
using XYHY;
using NS_DataCenter;
using System.Collections.Generic;
using LuaInterface;


public class PreloadManager
{
    private static PreloadManager instance = new PreloadManager();
    public static PreloadManager Instance
    {
        get
        {
            return instance;
        }
    }

    PreloadResult preloadAsyncAssetsResult;
    //预加载普通资源
    public void PreloadAsyncAssets(uint sceneId, ref PreloadResult preloadResult)
    {
        //初始化系统
        preloadAsyncAssetsResult = preloadResult;

        IResBinData iResBinData = GameKernel.GetDataCenter().GetResBinData();

        //预加载及预热资源
        List<string> preLoadObjList = null;   
        List<string> PreloadAndPrehotObjList = null;
        
        if (preLoadObjList != null && preLoadObjList.Count > 0)
        {
            preloadAsyncAssetsResult.TotalCount += preLoadObjList.Count;
        }
        if (PreloadAndPrehotObjList != null && PreloadAndPrehotObjList.Count > 0)
        {
            preloadAsyncAssetsResult.TotalCount += PreloadAndPrehotObjList.Count;
        }

        if (preloadAsyncAssetsResult.TotalCount > 0)
        {
            IResourceMgr resMgr = GameKernel.Get<IResourceMgr>();
            /*if (preLoadObjList != null)
            {
                foreach (string item in preLoadObjList)
                {
                    AssetBundleParams abp =
                        AssetBundleParamFactory.Create(item);
                    resMgr.LoadSceneResidentMemoryObjAsync(abp, preloadObjCallBack);
                }
            }
            if (PreloadAndPrehotObjList != null)
            {
                foreach (string item in PreloadAndPrehotObjList)
                {
                    AssetBundleParams abp = AssetBundleParamFactory.Create(item);
                    abp.IsPreloadMainAsset = true;

                    ResLogger.Log("Prelaod " + abp.path + " " + abp.type);

                    resMgr.LoadSceneResidentMemoryObjAsync(abp, preloadObjCallBack);
                }
            }

            for (int i = 0; i < diffPreloads.Count; i++)
            {
                if (!string.IsNullOrEmpty(diffPreloads[i]))
                {
                    AssetBundleParams abp = AssetBundleParamFactory.Create(diffPreloads[i]);
                    abp.IsPreloadMainAsset = true;

                    ResLogger.Log("Diff Prelaod " + abp.path + " " + abp.type);

                    resMgr.LoadResidentMemoryObjAsync(abp, preloadObjCallBack);
                }
            }*/
        }
        else
        {
            preloadAsyncAssetsResult = null;
        }
    }
    
    //先不处理
    /*private void preloadObjCallBack(AssetBundleInfo info)
    {
        preloadAsyncAssetsResult.Index++;
        preloadAsyncAssetsResult.PreloadPercent = 1.0f * preloadAsyncAssetsResult.Index / preloadAsyncAssetsResult.TotalCount;
        if (info!=null)
            this.preloadAsyncAssetsResult.name = info.bundleName;
    }*/


    PreloadResult preloadSyncAndAsyncAssetsResult;
    public void PreloadSyncAndAsyncAssets(uint sceneId, ref PreloadResult preloadResult)
    {
        preloadSyncAndAsyncAssetsResult = preloadResult;
        IResBinData iResBinData = GameKernel.GetDataCenter().GetResBinData();

        //预加载场景资源
    }

    PreloadResult preloadSceneResult;
    //场景资源预加载
    public void PreloadSceneAsset(string sceneName, ref PreloadResult preloadResult)
    {
        this.preloadSceneResult = preloadResult;

        //获取预加载的场景数据(现在木有，先不处理)
        List<string> preLoadGOList = null;

        if (preLoadGOList != null && preLoadGOList.Count > 0)
        {
            this.preloadSceneResult.TotalCount += preLoadGOList.Count;
        }

        if (this.preloadSceneResult.TotalCount > 0)
        {
            //资源加载并生成相应预设
            if (preLoadGOList != null)
            {
                IResourceMgr resMgr = GameKernel.Get<IResourceMgr>();
                foreach (string item in preLoadGOList)
                {
                    AssetBundleParams abp = new AssetBundleParams(item, typeof(GameObject));
                    resMgr.LoadNormalObjAsync(abp);
                }
            }
        }
        else
        {
            this.preloadSceneResult = null;
        }
    }
    
    /*private void preloadGOCallBack(AssetBundleInfo info)
    {
        if (info != null)
        {
            if (info.mainObject != null)
            {
                GameObject go = GameObject.Instantiate(info.mainObject) as GameObject;
                go.name = info.mainObject.name;
                StaticBatchingUtility.Combine(go);
                if (go != null)
                    this.preloadSceneResult.name = go.name;
            }
        }

        this.preloadSceneResult.Index++;
        this.preloadSceneResult.PreloadPercent = 1.0f * this.preloadSceneResult.Index / this.preloadSceneResult.TotalCount;
    }*/
}
