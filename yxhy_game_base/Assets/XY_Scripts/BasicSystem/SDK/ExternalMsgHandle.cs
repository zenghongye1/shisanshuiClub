using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LitJson;
using LuaInterface;

/// <summary>
/// 接受安卓或者ios回传给unity的消息，同时也负责和安卓ios发送消息
/// </summary>
public class ExternalMsgHandle : MonoBehaviour
{
    /// <summary>
    /// 此处应与安卓，ios中发送消息的go的名子一样
    /// </summary>
    static string gameObjectName = "SDKObject";

    static Dictionary<string, System.Action<string>> mMsgToCallbacks =new Dictionary<string, System.Action<string>>();

    public static ExternalMsgHandle Instance;

#if UNITY_ANDROID && !UNITY_EDITOR
    static AndroidJavaClass mUPlayerJc;
    static AndroidJavaObject mActivityJo;
#endif
    void Awake()
    {
        if (Instance != null)
            Destroy(Instance);

        Instance = this;
        DontDestroyOnLoad(this);
        gameObject.name = gameObjectName;

#if UNITY_ANDROID && !UNITY_EDITOR
        try
        {
            mUPlayerJc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            mActivityJo = mUPlayerJc.GetStatic<AndroidJavaObject>("currentActivity");
        }
        catch(System.Exception e)
        {
            LuaInterface.Debugger.LogError(e);
        }
#endif
    }
    /// <summary>
    /// 安卓或者ios发送消息的接收方法，注意名子一致
    /// </summary>
    /// <param name="ret"></param>
    public void OnRecMsgFromExternal(string ret)
    {
        JsonData jsonData = JsonMapper.ToObject(ret);
        try
        {
            using (IEnumerator<string> enumerator = jsonData.Keys.GetEnumerator())
            {
                if (enumerator.MoveNext())
                {
                    string func = enumerator.Current;
                    System.Action<string> callback = null;
                    if (mMsgToCallbacks.TryGetValue(func, out callback))
                    {
                        callback(ret);
                    }
                }
            }
        }
        catch(System.Exception e)
        {
            Debugger.LogError(e);
            Debugger.LogError(ret);
        }
    }

    public static void AddMsgCallback(string msg,System.Action<string> fun)
    {
        System.Action<string> tfun = null;
        if(mMsgToCallbacks.TryGetValue(msg,out tfun))
        {
            tfun += fun;
        }
        else
        {
            mMsgToCallbacks.Add(msg,fun);
        }
    }

    public static void RemoveMsgCallback(string msg,System.Action<string> fun)
    {
        System.Action<string> tfun = null;
        if (mMsgToCallbacks.TryGetValue(msg, out tfun))
        {
            tfun -= fun;
        }
    }

    public static void CallExternalFun(string funName,params object [] paras)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        try
        {
            mActivityJo.Call(funName, paras);
        }
        catch(System.Exception e)
        {
            LuaInterface.Debugger.LogError(e);
        }     
#endif
    }

    public static T CallExternalFun<T>(string funName, params object[] paras)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        //try
        //{
        //    T t= mActivityJo.Call<T>(funName, paras);
        //    return t;
        //}
        //catch (System.Exception e)
        //{
        //    LuaInterface.Debugger.LogError(e);
        //}
#endif
        return default(T);
    }
}
