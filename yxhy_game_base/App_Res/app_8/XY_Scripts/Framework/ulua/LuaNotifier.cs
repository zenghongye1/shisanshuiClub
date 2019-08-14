/********************************************************************
	created:	2015/06/09  14:12
	file base:	LuaNotifier
	file ext:	cs
	author:		shine
	
	purpose:	实现lua notifier c#层调用
*********************************************************************/
using UnityEngine;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System;
using Framework;

public class LuaNotifier : ILuaNotifier , IInitializeable 
{
    static ILuaNotifier m_Instance;
    static public ILuaNotifier Instance
    {
        get 
        {
            if (m_Instance == null)
            {
                m_Instance = new LuaNotifier();
            }
            return m_Instance;
        }
    }
            
    private LuaFunction m_dispatchCmd;

    public void Initialize()
    {
        if (LuaClient.GetMainState() != null)
        {
            m_dispatchCmd = LuaClient.GetMainState().GetFunction("Notifier.dispatchCmdForCSharp");
        }
    }

    public void UnInitialize()
    {
        m_dispatchCmd = null;
        m_Instance = null;
    }

    /// <summary>
    /// 发送消息到lua函数（string类型不适用）
    public void dispatchCmd(string cmdID, System.Object para1 = null, System.Object para2 = null, System.Object para3 = null, System.Object para4 = null)
    {
#if UNITY_PROFILER
        Profiler.BeginSample("LuaNotifier.dispatchCmd()");
#endif
        if (m_dispatchCmd == null && LuaClient.Instance!=null && LuaClient.GetMainState() != null)
        {
            m_dispatchCmd = LuaClient.GetMainState().GetFunction("Notifier.dispatchCmdForCSharp");
        }

        if (m_dispatchCmd != null)
        {
            m_dispatchCmd.BeginPCall();
            m_dispatchCmd.Push(cmdID);
            m_dispatchCmd.Push(para1);
            m_dispatchCmd.Push(para2);
            m_dispatchCmd.Push(para3);
            m_dispatchCmd.Push(para4);
            m_dispatchCmd.PCall();
            m_dispatchCmd.EndPCall();
        }
#if UNITY_PROFILER
        Profiler.EndSample();
#endif
    }
}