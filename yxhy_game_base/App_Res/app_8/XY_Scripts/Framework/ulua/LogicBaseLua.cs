/********************************************************************
	created:	2015/06/09  14:12
	file base:	LogicBaseLua
	file ext:	cs
	author:		shine
	
	purpose:	用来作为挂接lua脚本到GameObject的载体
                流程如下：
 *              (1) 本身记录了lua层的logicLuaObjMgr和对应要挂载的xxxx.lua
 *              (2) 此脚本执行Start的时候，会调用logicLuaObjMgr进行具体xxxx.lua对象的创建，并且调用xxxx.lua对象的Start
 *              (3) 后续的所有函数调用，比如Update，OnTriggerEnter等函数，都是先调用logicLuaObjMgr对应的函数，传递好GameObject和其他参数
                    然后再由logicLuaObjMgr.lua来根据字典进行分发调用
 * 
 *               目前只包含了Start,Update, OnTriggerEnter,OnTriggerStay, OnTriggerExit这5个，后续如果有需求可以继续添加其他函数
 *               需要注意lua层的logicLuaObjMgr也要对应增加函数
*********************************************************************/
using UnityEngine;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System;
using Framework;

public class LogicBaseLua : MonoBehaviour
{    
    private LuaState luaState = null;

    [SerializeField]
    public string fullLuaFileName;
    [SerializeField]
    public int ID = 0;

    [SerializeField]
    public bool isOldUnique = false;

    private string m_luaFileName;

    // lua functions
    //private LuaFunction m_awakeFunc;
    //private LuaFunction m_startFunc;
    //private LuaFunction m_updateFunc;
    private LuaFunction m_onTriggerEnterFunc;
    private LuaFunction m_onTriggerStayFunc;
    private LuaFunction m_onTriggerExitFunc;

    private LuaFunction m_onCollisionEnterFunc;
    private LuaFunction m_onCollisionStayFunc;
    private LuaFunction m_onCollisionExitFunc;

    private LuaFunction m_onFingerHoverFunc;//手势识别，划过手势识别
    private LuaFunction m_onFingerSwipeFunc;
    private LuaFunction m_onFingerUpFunc;
    private LuaFunction m_onFingerDownFunc;
    private LuaFunction m_onFingerTapFunc;

    //private LuaFunction m_onDestroyFunc;
    //private LuaFunction m_onEnableFunc;
    //private LuaFunction m_onDisableFunc;

    private string m_luaClassName = string.Empty;

    // variables for auto handle depth
    public static LogicBaseLua current = null;
    protected static LinkedList<LogicBaseLua> uiList = new LinkedList<LogicBaseLua>();       // 有深度的UIBase列表（所有UIBase唯一）
    protected static LinkedList<LogicBaseLua> noDepthList = new LinkedList<LogicBaseLua>();  // 无深度的UIBase列表（所有UIBase唯一）
    protected static int maxDepth2D = 1;   // 最大深度（全局公用）

    //public bool beKeepDepth = false;  // 是否保持深度（这个估计是固定面板，深度不会有变化）
    public bool beKeepDepthValue = false;

    protected bool beClose = false;          // 是否已经关闭 
    protected UIPanel[] panels = null;     // 存放包含的所有UIPanel
    private const int delta = 10;          // 递增量
    protected Transform myTrans = null;   // 自身的Transform
    protected UIPanel panel = null;       // 自身的UIPanel

    private bool hasLogicBaseLuaParent = false;
    public bool HasLogicBaseLuaParent
    {
        set { hasLogicBaseLuaParent = value; }
        get { return hasLogicBaseLuaParent; }
    }

    protected LuaTable self = null;
    private LuaFunction update = null;
    private LuaFunction lateUpdate = null;
    private LuaFunction fixedUpdate = null;
    private bool beStart = false;
    //private BoxCollider[] boxColliders = null;
    //private Dictionary<BoxCollider, bool> boxColliderStateDict = new Dictionary<BoxCollider, bool>();
    private bool isFastHide = false;
    public bool IsFastHide
    {
        get { return isFastHide; }
    }

    public void RefreshPanelDepth()
    {
        RemoveFromList();
        InitDepth();
    }

    // 初始化
    protected virtual void InitDepth()
    {
        if (!hasLogicBaseLuaParent)
        {
            myTrans = transform;
            panel = gameObject.GetComponent<UIPanel>();
            panels = gameObject.GetComponentsInChildren<UIPanel>(true);

            if (panels.Length > 0)
            {
                // 如果不保持深度，则将包含的所有子panel加入到
                if (!beKeepDepthValue)
                {
                    // 将所有的panel进行排序（包括自己），从低往高，深度越高越靠前，lamda表达式
                    Array.Sort<UIPanel>(panels, (p1, p2) => { return p1.depth - p2.depth; });

                    // 加入到list
                    AddToList();
                }
                else
                {
                    noDepthList.AddLast(this);
                }

                //foreach (UIPanel _panel in panels)
                //{
                //    if (_panel.renderQueue == UIPanel.RenderQueue.StartAt)
                //    {
                //        _panel.startingRenderQueue = 2500 + _panel.depth;
                //    }
                //}
            }
        }
    }

    public virtual void InitPanelRenderQueue()
    {
        if (panels == null)
        {
            panels = gameObject.GetComponentsInChildren<UIPanel>(true);
        }
        foreach (UIPanel panel in panels)
        {
            if (panel.renderQueue != UIPanel.RenderQueue.StartAt)
            {
                panel.renderQueue = UIPanel.RenderQueue.StartAt;
            }
            panel.startingRenderQueue = 3000 + panel.depth;
        }
    }


    private void InitLuaFuncHandlers()
    {
        //m_awakeFunc = luaState.GetFunction(m_luaClassName + ".Awake", false);
        //m_startFunc = luaState.GetFunction(m_luaClassName + ".Start", false);
        //m_updateFunc = luaState.GetFunction(m_luaClassName + ".Update", false);
        m_onTriggerEnterFunc = luaState.GetFunction(m_luaClassName + ".OnTriggerEnter", false);
        m_onTriggerStayFunc = luaState.GetFunction(m_luaClassName + ".OnTriggerStay", false);
        m_onTriggerExitFunc = luaState.GetFunction(m_luaClassName + ".OnTriggerExit", false);
        //m_onDestroyFunc = luaState.GetFunction(m_luaClassName + ".OnDestroy", false);
        //m_onEnableFunc = luaState.GetFunction(m_luaClassName + ".OnEnable", false);
        //m_onDisableFunc = luaState.GetFunction(m_luaClassName + ".OnDisable", false);

        m_onCollisionEnterFunc = luaState.GetFunction(m_luaClassName + ".OnCollisionEnter", false);
        m_onCollisionStayFunc = luaState.GetFunction(m_luaClassName + ".OnCollisionStay", false);
        m_onCollisionExitFunc = luaState.GetFunction(m_luaClassName + ".OnCollisionExit", false);
        m_onFingerHoverFunc = luaState.GetFunction(m_luaClassName + ".OnFingerHover", false);
        m_onFingerSwipeFunc = luaState.GetFunction(m_luaClassName + ".OnSwipe", false);
        m_onFingerUpFunc = luaState.GetFunction(m_luaClassName + ".OnFingerUp", false);
        m_onFingerDownFunc = luaState.GetFunction(m_luaClassName + ".OnFingerDown", false);
        m_onFingerTapFunc = luaState.GetFunction(m_luaClassName + ".OnTap", false);
    }
    private void UninitSingleLuaFuncHandler(LuaFunction luaFunc)
    {
        if (luaFunc != null)
        {
            luaFunc.Dispose();
            luaFunc = null;
        }
    }
    private void UninitLuaFuncHandlers()
    {
        UninitSingleLuaFuncHandler(m_onTriggerEnterFunc);
        UninitSingleLuaFuncHandler(m_onTriggerStayFunc);
        UninitSingleLuaFuncHandler(m_onTriggerExitFunc);

        UninitSingleLuaFuncHandler(m_onCollisionEnterFunc);
        UninitSingleLuaFuncHandler(m_onCollisionStayFunc);
        UninitSingleLuaFuncHandler(m_onCollisionExitFunc);
        UninitSingleLuaFuncHandler(m_onFingerHoverFunc);
    }

    void CallLuaFunction(string name)
    {
        if (luaState == null)
            return;
        LuaFunction func = luaState.GetFunction(name, false);

        if (func != null) 
        {
            func.BeginPCall();
            func.Push(self);
            func.PCall();
            func.EndPCall();
            func.Dispose();
            func = null;
        }
    }

    protected void Awake()
    {
        luaState = LuaClient.GetMainState();
        RefreshLuaSetting();       
    }

    public void RefreshLuaSetting()
    {
        try
        {
            if (fullLuaFileName == null)
            {
                return;
            }

            current = this;
            fullLuaFileName = fullLuaFileName.Replace('\\', '/');
            m_luaFileName = fullLuaFileName.Substring(fullLuaFileName.LastIndexOf('/') + 1);
            luaState.Require(fullLuaFileName);

            LogicBaseLua[] baseLuas = gameObject.GetComponentsInChildren<LogicBaseLua>(true);
            for (int i = 0; i < baseLuas.Length; ++i)
            {
                if (baseLuas[i].gameObject == this.gameObject)
                {
                    continue;
                }
                baseLuas[i].HasLogicBaseLuaParent = true;
            }

            m_luaClassName = m_luaFileName;
            self = luaState.GetTable(m_luaClassName);
            update = self.RawGetLuaFunction("Update");
            lateUpdate = self.RawGetLuaFunction("LateUpdate");
            fixedUpdate = self.RawGetLuaFunction("FixedUpdate");

            InitLuaFuncHandlers();

            // 对于只有一个实例的情况
            if (!isOldUnique)
            {
                LuaFunction func = self.RawGetLuaFunction("New");

                if (func == null)
                {
                    throw new LuaException(m_luaClassName + " does not have a New function, GameObject is" + gameObject.name);
                }

                func.BeginPCall();
                func.PCall();
                self.Dispose();
                self = func.CheckLuaTable();
                func.EndPCall();
                func.Dispose();
                func = null;
            }

            LuaFunction addLuaObjectFunc = luaState.GetFunction("logicLuaObjMgr.AddLuaUIObject");
            addLuaObjectFunc.BeginPCall();
            addLuaObjectFunc.Push(gameObject);
            addLuaObjectFunc.Push(self);
            addLuaObjectFunc.PCall();
            addLuaObjectFunc.EndPCall();
            addLuaObjectFunc.Dispose();
            addLuaObjectFunc = null;

            self.name = m_luaClassName;
            self["gameObject"] = gameObject;
            self["transform"] = transform;
            self["ID"] = ID;
            CallLuaFunction(m_luaClassName + ".Awake");
        }
        catch (Exception e)
        {
            luaState.ToLuaException(e);
        }
    }

    /// <summary>
    /// 调用logicLuaObjMgr.lua中的createLuaObject，并紧接着调用Lua层的Start
    /// </summary>
    protected void Start()
    {
        InitDepth();        
        CallLuaFunction(m_luaClassName + ".Start");
        AddUpdate();      
        beStart = true;
    }

    protected void OnEnable()
    {
        if (beStart)
        {
            AddUpdate();
        }
        CallLuaFunction(m_luaClassName + ".OnEnable");
    }

    protected void OnDisable()
    {
        RemoveUpdate();
        //CallLuaFunction(m_luaClassName + ".OnDisable");
    }

    void AddUpdate()
    {
        if(LuaClient.Instance == null)
        {
            return;
        }
        LuaLooper loop = LuaClient.Instance.GetLooper();

        if (update != null)
        {
            loop.UpdateEvent.Add(update, self);
        }

        if (lateUpdate != null)
        {
            loop.LateUpdateEvent.Add(lateUpdate, self);
        }

        if (fixedUpdate != null)
        {
            loop.FixedUpdateEvent.Add(fixedUpdate, self);
        }
    }

    void RemoveUpdate()
    {
        LuaClient inst = LuaClient.Instance;

        if (inst)
        {
            LuaLooper loop = inst.GetLooper();
            loop.UpdateEvent.Remove(update, self);
            loop.LateUpdateEvent.Remove(lateUpdate, self);
            loop.FixedUpdateEvent.Remove(fixedUpdate, self);
        }
    }

    /// <summary>
    /// OnTriggerEnter
    /// </summary>
    /// <param name="collider"></param>
    protected void OnTriggerEnter(Collider collider)
    {        
        if (m_onTriggerEnterFunc != null)
        {
            m_onTriggerEnterFunc.BeginPCall();
            m_onTriggerEnterFunc.Push(self);
            m_onTriggerEnterFunc.Push(collider);
            m_onTriggerEnterFunc.PCall();
            m_onTriggerEnterFunc.EndPCall();
        }        
    }

    /// <summary>
    /// OnTriggerStay
    /// </summary>
    /// <param name="collider"></param>
    protected void OnTriggerStay(Collider collider)
    {        
        if (m_onTriggerStayFunc != null)
        {
            m_onTriggerStayFunc.BeginPCall();
            m_onTriggerStayFunc.Push(self);
            m_onTriggerStayFunc.Push(collider);
            m_onTriggerStayFunc.PCall();
            m_onTriggerStayFunc.EndPCall();
        }   
    }

    /// <summary>
    /// OnTriggerExit
    /// </summary>
    /// <param name="collider"></param>
    protected void OnTriggerExit(Collider collider)
    {
        if (m_onTriggerExitFunc != null)
        {
            m_onTriggerExitFunc.BeginPCall();
            m_onTriggerExitFunc.Push(self);
            m_onTriggerExitFunc.Push(collider);
            m_onTriggerExitFunc.PCall();
            m_onTriggerExitFunc.EndPCall();
        }          
    }

    protected void OnCollisionEnter(Collision collision)
    {
        if (m_onCollisionEnterFunc != null)
        {
            m_onCollisionEnterFunc.BeginPCall();
            m_onCollisionEnterFunc.Push(self);
            m_onCollisionEnterFunc.Push(collision);
            m_onCollisionEnterFunc.PCall();
            m_onCollisionEnterFunc.EndPCall();
        }
    }

    protected void OnCollisionStay(Collision collision)
    {
        if (m_onCollisionStayFunc != null)
        {
            m_onCollisionStayFunc.BeginPCall();
            m_onCollisionStayFunc.Push(self);
            m_onCollisionStayFunc.Push(collision);
            m_onCollisionStayFunc.PCall();
            m_onCollisionStayFunc.EndPCall();
        }
    }

    protected void OnCollisionExit(Collision collision)
    {
        if (m_onCollisionExitFunc != null)
        {
            m_onCollisionExitFunc.BeginPCall();
            m_onCollisionExitFunc.Push(self);
            m_onCollisionExitFunc.Push(collision);
            m_onCollisionExitFunc.PCall();
            m_onCollisionExitFunc.EndPCall();
        }
    }

    //增加手势识别
    void OnFingerHover(FingerHoverEvent e)
    {
       
        Debug.Log("===============" + e.Selection.name);
        if(m_onFingerHoverFunc != null)
        {
            m_onFingerHoverFunc.BeginPCall();
            m_onFingerHoverFunc.Push(self);
            m_onFingerHoverFunc.Push(e);
            m_onFingerHoverFunc.PCall();
            m_onFingerHoverFunc.EndPCall();


        }
    }

    void OnSwipe(SwipeGesture gesture)
    {
        string str = "方向:" + gesture.Direction + " 速度:" + gesture.Velocity + " 移动距离:" + gesture.Move.magnitude + "";
        string direction = gesture.Direction.ToString();
        GameObject obj = gesture.Selection;
        Debug.Log(str);
        if(m_onFingerSwipeFunc != null)
        {
            m_onFingerSwipeFunc.BeginPCall();
            m_onFingerSwipeFunc.Push(self);
            m_onFingerSwipeFunc.Push(direction);
            m_onFingerSwipeFunc.Push(obj);
            m_onFingerSwipeFunc.PCall();
            m_onFingerSwipeFunc.EndPCall();
        }
    }

    void OnFingerUp(FingerUpEvent fingerUp)
    {
        Debug.Log("手指抬起");
        if (m_onFingerUpFunc != null)
        {
            m_onFingerUpFunc.BeginPCall();
            m_onFingerUpFunc.Push(self);
            m_onFingerUpFunc.Push(fingerUp);
            m_onFingerUpFunc.PCall();
            m_onFingerUpFunc.EndPCall();
        }
    }

    void OnFingerDown(FingerDownEvent e)
    {
        Debug.Log("手指按下");
        if (m_onFingerDownFunc != null)
        {
            m_onFingerDownFunc.BeginPCall();
            m_onFingerDownFunc.Push(self);
            m_onFingerDownFunc.Push(e);
            m_onFingerDownFunc.PCall();
            m_onFingerDownFunc.EndPCall();
        }
    }

    void OnTap(TapGesture gesture)
    {
        Debug.Log("双击事件");
        if(m_onFingerTapFunc != null)
        {
            m_onFingerTapFunc.BeginPCall();
            m_onFingerTapFunc.Push(self);
            m_onFingerTapFunc.Push(gesture);
            m_onFingerTapFunc.PCall();
            m_onFingerTapFunc.EndPCall();
        }
    }


    protected void SafeRelease(ref LuaFunction func)
    {
        if (func != null)
        {
            func.Dispose();
            func = null;
        }

    }

    protected void SafeRelease(ref LuaTable table)
    {
        if (table != null)
        {
            table.Dispose();
            table = null;
        }
    }

    protected void OnDestroy()
    {
        if (beClose == false)
        {
            beClose = true;
            RemoveFromList();            

            if (luaState != null)
            {
                CallLuaFunction(m_luaClassName + ".OnDestroy");
            }

            ReleaseLuaRes();
        }
    }

    void ReleaseLuaRes()
    {        
        SafeRelease(ref update);
        SafeRelease(ref lateUpdate);
        SafeRelease(ref fixedUpdate);
        SafeRelease(ref self);

        UninitLuaFuncHandlers();
    }

    // 加入到深度列表中
    protected virtual void AddToList()
    {
        AddToList(uiList, ref maxDepth2D);
    }

    protected virtual void RemoveFromList()
    {
        if (!hasLogicBaseLuaParent)
        {
            RemoveFromList(uiList, ref maxDepth2D, 1);
        }
    }

    protected void AddToList(LinkedList<LogicBaseLua> list, ref int depth)
    {
        if (beKeepDepthValue)
        {
            return;
        }

        if (list.Count > 0)
        {
#if UNITY_EDITOR
            if (list.Find(this) != null)
            {
                Debugger.LogError("UI {0} already in ui list", name);
                return;
            }
#endif
        }

        depth = SetDepth(depth) + delta;
        list.AddLast(this);
    }

    protected void RemoveFromList(LinkedList<LogicBaseLua> list, ref int depth, int beginDepth)
    {
        if (beKeepDepthValue || list.Count == 0)
        {
            noDepthList.Remove(this);
            return;
        }

        list.Remove(this);
        depth = beginDepth;

        foreach (LogicBaseLua ui in list)
        {
            depth = ui.SetDepth(depth) + delta;
        }
    }


    // 设置深度
    int SetDepth(int value)
    {
        // 得到基线深度，即包括自己和子panel的中的最小深度
        int baseLine = panels[0].depth;
        value -= baseLine;

        for (int i = 0; i < panels.Length; i++)
        {
            panels[i].depth += value;
        }

        return panels[panels.Length - 1].depth;
    }

    static public void DestroyAll()
    {
        foreach (LogicBaseLua ui in uiList)
        {
            GameObject go = ui.gameObject;
            ui.beClose = true;
            ui.ReleaseLuaRes();
            GameObject.Destroy(go);
        }

        foreach (LogicBaseLua ui in noDepthList)
        {
            GameObject go = ui.gameObject;
            ui.beClose = true;
            ui.ReleaseLuaRes();
            GameObject.Destroy(go);
        }

        uiList.Clear();
        noDepthList.Clear();
    }

    UIEffect[] uieffArray = null;
    MeshRenderer[] mrArray = null;
    public void FastHide()
    {
        isFastHide = true;
        if (panels != null)
        {
            for (int i = 0; i < panels.Length; ++i)
            {
                if (panels[i].affectByParentShowHide)
                {
                    panels[i].Hide();
                }
            }
        }

        mrArray = this.transform.GetComponentsInChildren<MeshRenderer>();
        for(int i = 0; i<mrArray.Length; i++)
        {
            mrArray[i].enabled = false;
        }

        uieffArray = this.transform.GetComponentsInChildren<UIEffect>();
        for (int i = 0; i < uieffArray.Length; i++)
        {
            uieffArray[i].gameObject.SetActive(false);
        }
    }

    public void FastShow()
    {
        isFastHide = false;
        if (panels != null)
        {
            for (int i = 0; i < panels.Length; ++i)
            {
                if (panels[i].affectByParentShowHide)
                {
                    panels[i].Show();
                }          
            }
        }

        //MeshRenderer[] mrArray = this.transform.GetComponentsInChildren<MeshRenderer>();
        if(mrArray != null)
        {
            for (int i = 0; i < mrArray.Length; i++)
            {
                mrArray[i].enabled = true;
            }
        }

        //UIEffect[] uieffArray = this.transform.GetComponentsInChildren<UIEffect>();
        if (uieffArray != null)
        {
            for (int i = 0; i < uieffArray.Length; i++)
            {
                uieffArray[i].gameObject.SetActive(true);
            }
        }
    }



}