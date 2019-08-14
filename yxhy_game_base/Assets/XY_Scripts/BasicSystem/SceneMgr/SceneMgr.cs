using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using SceneSystem;
using Framework;
using cs;
using dataconfig;

public class SceneMgr
{
    private static SceneMgr instance = new SceneMgr();

    private List<SceneProcessBase> processList = new List<SceneProcessBase>();
    LoadingSceneProcess mLoadingSceneProcess = new LoadingSceneProcess();
    ShowLoadingUIProcess mShowLoadingUIProcess = new ShowLoadingUIProcess();
    LevelsLoadProcess mLevelsLoadProcess = new LevelsLoadProcess();
    //AssetPreloadProcess mAssetPreloadProcess = new AssetPreloadProcess();

    /// <summary>
    ///以后从构造函数扩展加载scene进程 
    /// </summary>
    public SceneMgr(){ }

    public static SceneMgr Instance
    {
        get
        {
            return instance;
        }
    }

    SceneProcessBase curProcess = null;

    bool mIsLoading = false;
    uint mSceneId = 0;
    public uint SceneId
    {
        get { return mSceneId; }
    }

    string mLastSceneName = "登录";
    public string LastSceneName
    {
        get { return mLastSceneName; }
    }

    string mCurrentSceneName = "";
    public string CurrentSceneName
    {
        get { return mCurrentSceneName; }
    }

    string mCurrentScene = "";
    public string CurrentScene
    {
        get { return mCurrentScene; }
    }

    SceneConfig mSceneConfig = null;
    public SceneConfig SceneConfig
    {
        get { return mSceneConfig; }
    }


    uint mTaskNeedPreloadSceneId = 0;
    public uint TaskNeedPreloadSceneId
    {
        get { return mTaskNeedPreloadSceneId; }
    }

    public void LoadScene(uint fromSceneId, uint sceneId, bool showLoading = true, uint taskPreloadSceneId = 0, string loadingTips = "")
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        //Network.NetChnlDebug.Instance.Debug();
       // Network.NetChnlDebug.Instance.Clear();
#endif
        //Messenger.Broadcast<uint>(MSG_DEFINE.MSG_SCENE_LOAD_START, sceneId);
        if (mIsLoading == true)
        {
            StopCurrent();
        }

        mIsLoading = true;
        mSceneId = sceneId;
        mTaskNeedPreloadSceneId = taskPreloadSceneId;

        //如果有需要，可以加载场景相关配置（TO DO）
        mSceneConfig = GameKernel.GetDataCenter().GetResBinData().GetSceneConfByID(sceneId);
        mCurrentSceneName = mSceneConfig.name;

        if (mSceneConfig != null)
        {
            mCurrentScene = mSceneConfig.sceneName;
        }

        ConnectProcess(showLoading,loadingTips);
        StartProcess();    //数据齐全 开始进程
    }

    /// <summary>
    /// isShowLoading  应该用策略模式，现在暂时没有要求
    /// </summary>
    void ConnectProcess(bool isShowLoading, string loadingTips = "")
    {
        if (isShowLoading)
        {
            processList.Add(mLoadingSceneProcess);
            mShowLoadingUIProcess.mTips = loadingTips;
            processList.Add(mShowLoadingUIProcess);
            processList.Add(mLevelsLoadProcess);
            //processList.Add(mAssetPreloadProcess);
        }
        else
        {
            processList.Add(mLevelsLoadProcess);
        }
    }

    private void StopCurrent()
    {
        processList.Clear();
        if (curProcess != null)
        {
            curProcess.Stop();
            mIsLoading = false;
        }
    }

    void StartProcess()
    {
        NextProcess();
    }

    public void NextProcess()
    {
        if (processList.Count > 0)
        {
            curProcess = processList[0];
            processList.RemoveAt(0);

            curProcess.Start();
        }
        else
        {
            FinishLoad();
        }
    }

    private void FinishLoad()
    {        
        Messenger.BroadcastAsync<string>(MSG_DEFINE.MSG_SCENE_LOAD_COMPLETE, CurrentSceneName);
        mIsLoading = false;
        InitSceneComplete();
        //Framework.GameKernel.StartMonoCoroutine(InitSceneComplete());
    }

    //这里有点闪屏，可以考虑等下个场景ui好了后再删除，但消息需从lua那边调用过来，先放着
    void InitSceneComplete()
    {
        UISys.Instance.DestroyUIByName(typeof(Loading).ToString());      
    }
}
