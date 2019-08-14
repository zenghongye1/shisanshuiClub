using UnityEngine;
using System.Collections;
using LuaInterface;
using System;

public class UI_Base : MonoBehaviour
{
    private LuaState luaState = null;

    [SerializeField]
    public string fullLuaFileName;
    private string m_luaFileName;

    [HideInInspector]
    public bool isUpdate = false;
    [HideInInspector]
    public bool isFixedUpdate = false;
    [HideInInspector]
    public bool isLaterUpdate = false;

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
    private string m_luaClassName = string.Empty;
    private string m_logicLuaObjMgr = "logicLuaObjMgr";

    protected LuaTable self = null;
    private LuaFunction update = null;
    private LuaFunction lateUpdate = null;
    private LuaFunction fixedUpdate = null;
    private bool beStart = false;

    public string FullLuaFileName
    {
        get
        {
            return fullLuaFileName;
        }
        set
        {
            fullLuaFileName = value;
            try
            {
                if (fullLuaFileName == null)
                {
                    return;
                }
                fullLuaFileName = fullLuaFileName.Replace('\\', '/');
                m_luaFileName = fullLuaFileName.Substring(fullLuaFileName.LastIndexOf('/') + 1);
                m_luaClassName = m_luaFileName;
            }
            catch (Exception e)
            {
                luaState.ToLuaException(e);
            }

        }
    }
  
    void CallLuaFunction(string MethodName,string LuaScriptName,object otherObj = null)
    {
        if (luaState == null)
            return;
        if (LuaScriptName == null) return;
        LuaFunction func = luaState.GetFunction(MethodName, false);
        if (func != null)
        {
            func.BeginPCall();
       //     func.Push(self);
            func.Push(LuaScriptName);
            if (otherObj != null)
                func.Push(otherObj);
            func.PCall();
            func.EndPCall();
            func.Dispose();
            func = null;
        }
    }

    protected void Awake()
    {
        luaState = LuaClient.GetMainState();
        InitLuaSetting();
    }

    /// <summary>
    /// 调用logicLuaObjMgr.lua中的createLuaObject，并紧接着调用Lua层的Start
    /// </summary>
    protected void Start()
    {
        CallLuaFunction("logicLuaObjMgr" + ".Start",m_luaClassName);
  //      AddUpdate();
  //      beStart = true;
    }

    public void InitLuaSetting()
    {
        try
        {
            if (fullLuaFileName == null)
            {
                return;
            }
            self = luaState.GetTable("logicLuaObjMgr");
            fullLuaFileName = fullLuaFileName.Replace('\\', '/');
            m_luaFileName = fullLuaFileName.Substring(fullLuaFileName.LastIndexOf('/') + 1);
       //     luaState.Require(fullLuaFileName);
            m_luaClassName = m_luaFileName;
            CallLuaFunction(m_logicLuaObjMgr + ".Awake",m_luaClassName);
        }
        catch (Exception e)
        {
            luaState.ToLuaException(e);
        }
    }

    protected void Update()
    {
        if (isUpdate)
            CallLuaFunction(m_logicLuaObjMgr + ".Update", m_luaClassName);
    }

    public void LateUpdate()
    {
        if (isLaterUpdate)
            CallLuaFunction(m_logicLuaObjMgr + ".LateUpdate", m_luaClassName);
    }

    public void FixedUpdate()
    {
        if (isFixedUpdate)
            CallLuaFunction(m_logicLuaObjMgr + ".FixedUpdate", m_luaClassName);
    }
    protected void OnEnable()
    {
        //if (beStart)
        //{
        //    AddUpdate();
        //}
        CallLuaFunction(m_logicLuaObjMgr + ".OnEnable",m_luaClassName);
    }

    protected void OnDisable()
    {
  //      RemoveUpdate();
        CallLuaFunction(m_logicLuaObjMgr + ".OnDisable",m_luaClassName);
    }

    void AddUpdate()
    {
        if (LuaClient.Instance == null)
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
        CallLuaFunction(m_logicLuaObjMgr + ".OnTriggerEnter", m_luaClassName,collider);
    }

    /// <summary>
    /// OnTriggerStay
    /// </summary>
    /// <param name="collider"></param>
    protected void OnTriggerStay(Collider collider)
    {
        CallLuaFunction(m_logicLuaObjMgr + ".OnTriggerStay", m_luaClassName, collider);
    }


    /// <summary>
    /// OnTriggerExit
    /// </summary>
    /// <param name="collider"></param>
    protected void OnTriggerExit(Collider collider)
    {
         CallLuaFunction(m_logicLuaObjMgr + ".OnTriggerExit", m_luaClassName, collider);
    }

    protected void OnCollisionEnter(Collision collision)
    {
         CallLuaFunction(m_logicLuaObjMgr + ".OnCollisionEnter", m_luaClassName, collision);
    }

    protected void OnCollisionStay(Collision collision)
    {
        CallLuaFunction(m_logicLuaObjMgr + ".OnCollisionStay", m_luaClassName, collision);
    }

    protected void OnCollisionExit(Collision collision)
    {
        CallLuaFunction(m_logicLuaObjMgr + ".OnCollisionExit", m_luaClassName, collision);
    }

    //增加手势识别
    void OnFingerHover(FingerHoverEvent e)
    {
        CallLuaFunction(m_logicLuaObjMgr + ".OnFingerHover", m_luaClassName, e);
    }

    void OnSwipe(SwipeGesture gesture)
    {
        string direction = gesture.Direction.ToString();
        GameObject obj = gesture.Selection;
        if (luaState == null)
            return;
        LuaFunction func = luaState.GetFunction(m_logicLuaObjMgr + ".OnSwipe", false);
        if (func != null)
        {
            func.BeginPCall();
            func.Push(self);
            func.Push(m_luaClassName);
            func.Push(direction);
            func.Push(obj);
            func.PCall();
            func.EndPCall();
            func.Dispose();
            func = null;
        }
    }

    void OnDragRecognizer(DragGesture gesture)
    {
        try
        {
            float normalizedTime = 0;
            if (LuaHelper.animationState != null)
            {
                normalizedTime = LuaHelper.animationState.normalizedTime;
            }
            LuaFunction func = luaState.GetFunction(m_logicLuaObjMgr + ".OnDragRecognizer", false);
            if (func != null)
            {
                func.BeginPCall();
                //    func.Push(self);
                func.Push(m_luaClassName);
                func.Push(gesture.DeltaMove);
                func.Push(normalizedTime);
                func.PCall();
                func.EndPCall();
                func.Dispose();
                func = null;
            }
        }catch(Exception e)
        {
        
       }

    }

    void OnFingerUp(FingerUpEvent fingerUp)
    {
        CallLuaFunction(m_logicLuaObjMgr + ".OnFingerUp", m_luaClassName, fingerUp);
    }

    void OnFingerDown(FingerDownEvent e)
    {
        CallLuaFunction(m_logicLuaObjMgr + ".OnFingerDown", m_luaClassName, e);
    }

    void OnTap(TapGesture gesture)
    {
        CallLuaFunction(m_logicLuaObjMgr + ".OnTap", m_luaClassName, gesture);
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
        if (luaState != null)
        {
            CallLuaFunction(m_luaClassName + ".OnDestroy",m_luaClassName);
        }
        ReleaseLuaRes();
    }

    void ReleaseLuaRes()
    {
        SafeRelease(ref update);
        SafeRelease(ref lateUpdate);
        SafeRelease(ref fixedUpdate);
        SafeRelease(ref self);
    }
   
}
