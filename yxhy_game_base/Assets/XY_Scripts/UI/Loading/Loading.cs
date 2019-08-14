using UnityEngine;
using System.Collections;
using Framework;
using NS_DataCenter;

public class PreloadResult
{
    public int TotalCount;
    public int Index;
    public float PreloadPercent;
    public string name;
}

public class Loading : UIComponent<Loading>
{
    private const int processSpeed = 3;
    //private AsyncOperation async = null;
    private UILabel tip;
    private UILabel cur_step = null, cur_ab = null;
    private UISlider process;
    //private GameObject thumbGo;
    private UITexture bg;
    //private float step_time = 0.03f;
    private string LOAD_UI_PREFABS = "Prefabs/UI/Loading/loading_ui";

    private Vector3 offset = new Vector3(0, 0, -1000);


    //帧动画形式加载
    private UILabel newTip;
    private UISprite newActionImg;
    private float startTime;
    private float intervalTime = 0.1f;
    private int frameNum;
    private int frameCount = 13;
    private string frameOriginalName = "loading000";

    Coroutine startLoadingCor = null;

    void Awake()
    {
        //startLoadingCor = StartCoroutine(InitLoadUI());
    }

    void Start()
    {
        gameObject.transform.localPosition = offset;//提下z轴，不然可能会被模型遮挡
        //Messenger.AddListener<int>(MSG_DEFINE.MSG_LOADING_PROCESS_CHANGE, OnProcessChange);
    }

    void OnDestroy()
    {
        //Messenger.RemoveListener<int>(MSG_DEFINE.MSG_LOADING_PROCESS_CHANGE, OnProcessChange);
        if (startLoadingCor != null)
        {
            StopCoroutine(startLoadingCor);
            startLoadingCor = null;
        }
    }

    int loadProcess = 0;
    float loadProcessNormalize = 0;
    float loadProcessStepOver = 0.05f;

    void OnProcessChange(int progress)
    {
        loadProcess = progress;
        loadProcessNormalize = 0.01f * loadProcess;
    }

    //void Update()
    //{
        /*if (process != null)
        {
            if (process.value < loadProcessNormalize)
            {
                if (process.value < loadProcessNormalize - loadProcessStepOver)
                    process.value += loadProcessStepOver;
                else
                    process.value = loadProcessNormalize;
            }

            if (process.value > loadProcessNormalize)
            {
                process.value = loadProcessNormalize;
            }
        }*/
        
        
        //帧动画形式加载
        /*if(startTime<intervalTime)
        {
            startTime += Time.deltaTime;
        }
        else
        {
            startTime = 0;
            frameNum++;
            frameNum = frameNum % frameCount;
            newActionImg.spriteName = frameOriginalName + (frameNum + 1);
        }*/
    //}

    IEnumerator InitLoadUI()
    {
        /*XYHY.LuaDestroyBundle ldb = Utility_GameObject.AddMonoBehaviour<XYHY.LuaDestroyBundle>(this.gameObject);
        ldb.BundleName = LOAD_UI_PREFABS;
        ldb.ResType = typeof(GameObject);
        AlwaysToTop();*/

        //scene_config = GameKernel.Get<ILoadSceneSys>().CurSceneConfig();
        //GameObject obj = gameObject.transform.FindChild("tex_bg").gameObject;
        //if (obj != null)
        //{
            /*bg = obj.GetComponent<UITexture>();
            if (bg != null)
            {
                string nextBgName = "bg_loading";
                if (bg.mainTexture == null || (bg.mainTexture != null && !bg.mainTexture.name.Equals(nextBgName)))
                {
                    string lastBgName = null;
                    string str = "UITextures/Loading/" + nextBgName;
                    if (bg.mainTexture != null)
                    {
                        lastBgName = bg.mainTexture.name;
                    }
                    Texture2D tex = GameKernel.GetResourceMgr().LoadImmortalTextureSync(str);
                    if (tex != null)
                    {
                        bg.mainTexture = tex;
                        bg.MarkAsChanged();
                    }

                    if (lastBgName != null && !lastBgName.Equals(nextBgName))
                    {
                        GameKernel.GetResourceMgr().UnloadImmortalResource(string.Format("UITextures/Loading/{0}", lastBgName), typeof(Texture2D));
                    }
                }
            }*/
        //}

        /*obj = gameObject.transform.FindChild("bottom_area/process_bar").gameObject;
        process = obj.GetComponent<UISlider>();
        process.value = 0;

        obj = gameObject.transform.FindChild("bottom_area/lbl_tip").gameObject;
        tip = obj.GetComponent<UILabel>();
        if (tip != null)
        {
            tip.text = "正在加载中，请稍后……";
        }
        else
            obj.SetActive(false);*/


        //obj = gameObject.transform.FindChild("root/tips/lbl_tip").gameObject;
        //newTip = obj.GetComponent<UILabel>();
        //if (newTip != null)
        //    newTip.text = "正在为您加载，即将进入游戏";
        //else
        //    obj.SetActive(false);

        //newActionImg = gameObject.transform.FindChild("root/ani_root/img").GetComponent<UISprite>();
        //newActionImg.gameObject.SetActive(true);

        //GameObject actionRoot = gameObject.transform.FindChild("root").gameObject;
        //actionRoot.gameObject.SetActive(true);
        yield return null;
    }

    public void SetLoadingDesc(string desc)
    {
        if (newTip == null)
        {
            newTip = transform.Find("root/tips/lbl_tip").GetComponent<UILabel>();
        }
        newTip.text = desc;
    }
}
