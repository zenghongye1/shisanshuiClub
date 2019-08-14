using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using Framework;
using NS_DataCenter;

public partial class UISys : MonoBehaviour, IUIComponentContainer
{
    public static UISys Instance
    {
        get { return m_View; }
    }

    // 界面释放方式
    public enum EnmUIDestroyType
    {
        ENMUIDT_WITHSCENE = 0,  // 随着场景释放而释放
        ENMUIDT_FREEDESTROY     // 自由方式，不随场景释放而释放，自己控制      
    }
    partial void InitPrefabTable();

    void OnDestroy()
    {
        m_UITable.Clear();
        m_View = null;        
    }

    static UISys m_View = null;

    Dictionary<string, UIComponentBase> m_UITable = new Dictionary<string, UIComponentBase>();
    private Dictionary<string, GameObject> m_LuaUITable = new Dictionary<string, GameObject>();

    public Camera m_UICamera;
    public UICamera m_UICameraComp;
    private int m_originalCullingMask = 32;
    public void SetUIComponent<T>(T Comp) where T : UIComponent<T>
    {
        m_UITable[typeof(T).ToString()] = Comp;
    }

    void Awake()
    {
        m_View = this;
        cachedGo = gameObject;
        InitPrefabTable();
        //记录下原始值
        if (m_UICamera != null)
        {
            m_originalCullingMask = m_UICamera.cullingMask;
            m_UICameraComp = m_UICamera.GetComponent<UICamera>();
        }
    }

    /// <summary>
    /// 根据名字来创建UI（遗留机制类型）
    /// </summary>
    /// <param name="uiname"></param>
    public UIComponentBase CreateUIByName(string uiname)
    {
        if (m_UITable[uiname] == null)
        {
            UIComponentBase.CreateInstanceByName(uiname);
        }

        //Debug.Log("Create:" + uiname);
        if (!m_UITable[uiname].gameObject.activeInHierarchy)
        {
            SetVisableByUIName(uiname, true);
        }
        
        return m_UITable[uiname];
    }

    /// <summary>
    /// 用来创建lua控制的面板
    /// </summary>
    /// <param name="name">面板名字，也是prefab，lua脚本的名字</param>
    //public void CreateLuaUIPanel(string name, string luaScriptName = "")
    //{
    //    Debugger.Log("CreatePanel::>> " + name);
    //    IResourceMgr resourceMgr = GameKernel.Get<IResourceMgr>();
    //    string fullName = "Prefabs/UI/" + name;
    //    //resourceMgr.LoadResourceAsync(fullName, OnLuaPanelLoaded);
    //    UnityEngine.Object obj = resourceMgr.LoadResourceSync(fullName);
    //    OnLuaPanelLoaded(fullName, luaScriptName, obj, LOADSTATUS.LOAD_SUCCESS);
    //}

    /// <summary>
    /// 用于异步加载完UI prefab之后的回调函数
    /// </summary>
    /// <param name="url"></param>
    /// <param name="obj"></param>
    /// <param name="result"></param>
    //private void OnLuaPanelLoaded(string url, string luaScriptName, UnityEngine.Object obj, LOADSTATUS result)
    //{
    //    Debug.Log("OnLuaPanelLoaded, url is: " + url);
    //    StartCreateLuaPanel(obj, url, luaScriptName);
    //}

    /// <summary>
    /// 创建面板,这里根据名字约定进行bundle的载入以及相应lua控制脚本的唤起
    /// 比如,名字为promptPanel的lua脚本,对应了一个叫promptPanel的prefab,并且会创建一个名字为
    /// promptPanel的GameObject, 然后这个GameObject会addComponent一个BaseLua的组件
    /// 这个组件在start的时候会调用对应的一个lua函数:promptPanel.Start，这样就将
    /// lua那边的脚本驱动起来了
    /// </summary>
    //private void StartCreateLuaPanel(UnityEngine.Object resObj, string name, string luaScriptName)
    //{
    //    string tmpName = name.Substring(name.LastIndexOf('/') + 1);

    //    GameObject obj = CreateObjectByPrefab(resObj as GameObject, tmpName);
    //    BaseLua baseLua = obj.AddComponent<BaseLua>();
    //    baseLua.OnInit(null, null, luaScriptName);

    //    Debug.Log("StartCreatePanel------>>>>" + name);
    //    m_LuaUITable[tmpName] = obj;
    //}

    /// <summary>
    /// 根据prefab来创建Object,目前也是用于ulua方式的UI
    /// </summary>
    /// <param name="prefab"></param>
    /// <param name="name"></param>
    /// <returns></returns>
    private GameObject CreateObjectByPrefab(GameObject prefab, string name)
    {
        GameObject go = Instantiate(prefab) as GameObject;
        go.name = name;
        go.layer = LayerMask.NameToLayer("UI");
        go.transform.parent = transform;
        go.transform.localScale = Vector3.one;
        go.transform.localPosition = Vector3.zero;

        return go;
    }

    /// <summary>
    /// 用于ulua方式的UI，销毁指定名字的luaPanel
    /// </summary>
    /// <param name="name"></param>
    public void DestroyLuaPanel(string name)
    {
        if (m_LuaUITable.ContainsKey(name) && null != m_LuaUITable[name])
        {
            Destroy(m_LuaUITable[name]);
        }
    }

    /// <summary>
    /// 根据名字来销毁UI（遗留机制所用）
    /// </summary>
    /// <param name="uiname"></param>
    public void DestroyUIByName(string uiname)
    {
        if (m_UITable[uiname] != null)
        {
            SetVisableByUIName(uiname,false);
            UIComponentBase.DestroyInstanceByName(uiname);
            //LuaInterface.Debugger.Log("Destroy:" + uiname);
            m_UITable[uiname] = null;
        }
    }
    protected static Dictionary<XY_UILayer.Layer, string> mCurPanelNameList = new Dictionary<XY_UILayer.Layer, string>();
    protected static Dictionary<XY_UILayer.Layer, Queue<string>> mPanelToCreateList = new Dictionary<XY_UILayer.Layer, Queue<string>>();
    
    public void SetVisableByUIName(string uiname, bool bShow)
    { 
        UIComponentBase uiPanel = m_UITable[uiname];
        if (uiPanel != null)
        {
            XY_UILayer.Layer uiLayer = uiPanel.GetUILayer();

            // 主面版直接处理
            if (uiLayer == XY_UILayer.Layer.MainBarLayer)
            {
                uiPanel.Visable(bShow);
                return;
            }

            // 其它面板层保存起来
            if (mCurPanelNameList.ContainsKey(uiLayer) == false)
            {
                mCurPanelNameList[uiLayer] = null;
                mPanelToCreateList[uiLayer] = new Queue<string>();
            }

            // 先处理当前面板
            string uiNameOld = mCurPanelNameList[uiLayer];
            uiPanel.Visable(bShow);

            // 以下是互斥逻辑
            if (bShow == true)
            {
                if (uiname != uiNameOld)
                {
                    // 将同级的其它面板隐藏起来（互斥）
                    if (uiNameOld != null && uiNameOld.Length > 0)
                    {
                        UIComponentBase.DestroyInstanceByName(uiNameOld);
                        Queue<string> hidePanels = mPanelToCreateList[uiLayer];
                        hidePanels.Enqueue(uiNameOld);
                    }

                    // 更改当前显示的面板
                    mCurPanelNameList[uiLayer] = uiname;
                }
            }
            else
            {
                //从同层的面板中，找到上个显示的，并显示
                if (uiname != uiNameOld)
                {
                    uiPanel.Visable(bShow);
                    // 控制不了控件的销毁与创建时序，暂时用这种方案  
                    Queue<string> hidePanels = mPanelToCreateList[uiLayer];
                    if (hidePanels.Contains(uiname))
                    {
                        Debug.Log("----hidePanels.Contains(uiPanel)---------");
                        Queue<string> tmp = new Queue<string>();
                        for (int i = 0; i < hidePanels.Count; ++i)
                        {
                            string tmpName = hidePanels.Dequeue();
                            if (tmpName == uiname)
                            {
                                break;
                            }
                            tmp.Enqueue(tmpName);
                        }

                        for (int i = 0; i < tmp.Count; ++i)
                        {
                            hidePanels.Enqueue(tmp.Dequeue());
                        }
                    }
                }
                else
                {
                    if (uiNameOld != null && uiNameOld.Length > 0)
                    {
                        mCurPanelNameList[uiLayer] = null;
                        Queue<string> hidePanels = mPanelToCreateList[uiLayer];
                        if (hidePanels != null && hidePanels.Count > 0)
                        {
                            mCurPanelNameList[uiLayer] = hidePanels.Dequeue();
                            CreateUIByName(uiNameOld);
                        }
                    }
                    else
                    {
                        mCurPanelNameList[uiLayer] = null;
                    }
                }
            }
        }
    }

    public void ChangeUICameraCullingMask(int newMask)
    {
        if (m_UICamera != null)
        {
            m_UICamera.cullingMask = newMask;
        }
    }

    public void RecoveryUICameraCullingMask()
    {
        ChangeUICameraCullingMask(m_originalCullingMask);
    }

    public void BlockTouch()
    {
        //UICamera cameraComp = m_UICamera.GetComponent<UICamera>();
        m_UICameraComp.useMouse = false;
        m_UICameraComp.useTouch = false;
    }

    public void ActiveTouch()
    {
        //UICamera cameraComp = m_UICamera.GetComponent<UICamera>();
        m_UICameraComp.useMouse = true;
        m_UICameraComp.useTouch = true;
    }

    private int disableUICamTimes = 0;

    public void EnableUICamera()
    {
        disableUICamTimes--;
        //Debug.LogWarning("EnableUICamera");
        if (disableUICamTimes == 0)
        {
            //UICamera cameraComp = m_UICamera.GetComponent<UICamera>();
            m_UICameraComp.enabled = true;
        }
    }

    public void DisableUICamera()
    {
        disableUICamTimes++;
        //Debug.LogWarning("DisableUICamera");
        //UICamera cameraComp = m_UICamera.GetComponent<UICamera>();
        m_UICameraComp.enabled = false;
    }

    GameObject cachedGo;
}
