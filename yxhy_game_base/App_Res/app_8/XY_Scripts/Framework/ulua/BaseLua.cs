//using UnityEngine;
//using LuaInterface;
//using System.Collections;
//using System.Collections.Generic;
//using System;
//using Framework;

//public class BaseLua : MonoBehaviour {
//    //private string data = null;
//    //private bool initialize = false;
//    private LuaScriptMgr umgr = null;
//    private AssetBundle bundle = null;
//    //private Hashtable buttons = new Hashtable();

//    private string luaScriptName = "";
//    public string LuaScriptName
//    {
//        set{luaScriptName = value;}
//        get { return luaScriptName; }
//    }

//    /// <summary>
//    /// Lua管理器
//    /// </summary>
//    protected LuaScriptMgr uluaMgr {
//        get
//        {
//            if (umgr == null)
//            {
//                umgr = GameKernel.Get<ILuaScriptMgr>() as LuaScriptMgr;
//            }
//            return umgr;
//        }
//    }

//    /// <summary>
//    /// 初始化面板
//    /// </summary>
//    public void OnInit(AssetBundle bundle, string text, string luaScriptName)
//    {
//        LuaScriptName = luaScriptName;

//        //this.data = text;   //初始化附加参数
//        this.bundle = bundle; //初始化
//        Debug.Log("OnInit---->>>" + name + " text:>" + text);

//        LuaState l = uluaMgr.lua;

//        string luaGlobalTableName = transform.name;
//        if (luaScriptName != "")
//        {
//            luaGlobalTableName = luaScriptName;
//        }
//        l[luaGlobalTableName + ".transform"] = transform;
//        l[luaGlobalTableName + ".gameObject"] = gameObject;

//        CallMethod("Awake");
//    }

//    protected void Start() {
//        CallMethod("Start");
//    }

//    /// <summary>
//    /// 获取一个GameObject资源
//    /// </summary>
//    /// <param name="name"></param>
//    public GameObject GetGameObject(string name) {
//        if (bundle == null) return null;
//        return Util.LoadAsset(bundle, name);
//    }

//    private string GetValidLuaScriptName()
//    {
//        if (luaScriptName == "")
//        {
//            string clearCloneName = name.Replace("(Clone)", "");
//            return clearCloneName;
//        }
//        else
//        {

//            return luaScriptName;
//        }
//    }

//    //-----------------------------------------------
//    /// <summary>
//    /// 执行Lua方法-无参数
//    /// </summary>
//    protected object[] CallMethod(string func) {
//        if (uluaMgr == null) return null;
//        string funcName = GetValidLuaScriptName() + "." + func;
//        return uluaMgr.CallLuaFunction(funcName);
//    }

//    /// <summary>
//    /// 执行Lua方法
//    /// </summary>
//    protected object[] CallMethod(string func, GameObject go) {
//        if (uluaMgr == null) return null;
//        string funcName = GetValidLuaScriptName() + "." + func;
//        return uluaMgr.CallLuaFunction(funcName, go);
//    }

//    //-----------------------------------------------------------------
//    protected void OnDestroy() {
//        if (bundle) {
//            bundle.Unload(true);
//            bundle = null;  //销毁素材
//        }
//        CallMethod("Destroy");

//        umgr = null; 
//        Debug.Log("~" + name + " was destroy!");

//        if (uluaMgr == null)
//        {
//            return;
//        }
//        LuaState l = uluaMgr.lua;
//        string luaGlobalTableName = transform.name;
//        if (luaScriptName != "")
//        {
//            luaGlobalTableName = luaScriptName;
//        }

//        l[luaGlobalTableName + ".transform"] = null;
//        l[luaGlobalTableName + ".gameObject"] = null;
//    }
//}