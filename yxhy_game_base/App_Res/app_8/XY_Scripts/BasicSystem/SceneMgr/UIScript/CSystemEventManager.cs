/********************************************************************
	created:	2017.6.7
	file base:	
	file ext:	cs
	author:		xuemin.lin	
	purpose:	
*********************************************************************/
using System;
using UnityEngine;
using System.Collections.Generic;

//现在我们一般支持的T是UnityEngine.Object和System.Object
public delegate void CSysEventCallback<T>(T arg1);
//如果是System.Object的子类的用CSystemEventManager
//统一的事件监听规则是CSystemEventManager.AddListener(ESystemEventType, OnEventChanged)添加监听事件;
//统一的事件监听规则是CSystemEventManager.RemoveListener(ESystemEventType, OnEventChanged)删除监听的事件;
//统一的事件监听规则是CSystemEventManager.Invoke(ESystemEventType, (System.Object)speed)触发监听的事件;

//如果是UnityEngine.Object的子类的用CSystemEventManager<UnityEngine.Object>
//统一的事件监听规则是通过CSystemEventManager<UnityEngine.Object>.AddListener(ESystemEventType, OnEventChanged)添加监听事件;
//统一的事件监听规则是通过CSystemEventManager<UnityEngine.Object>.RemoveListener(ESystemEventType, OnEventChanged)删除监听的事件;
//统一的事件监听规则是通过CSystemEventManager<UnityEngine.Object>.Invoke(ESystemEventType, (UnityEngine.Object)gameObject)触发监听的事件;
static public class CSystemEventManager
{
    //TODO: CHANGE Delegate to list<Action<T>> to make it registerable
	private static Dictionary<ESystemEventType, Delegate> mEventTable = new Dictionary<ESystemEventType, Delegate>();

    public static void AddListener(ESystemEventType enEventType, CSysEventCallback<System.Object> kHandler)
    {
        lock (mEventTable)
        { 
            if (!mEventTable.ContainsKey(enEventType))
            {
                mEventTable.Add(enEventType, null);
            }

            mEventTable[enEventType] = (CSysEventCallback<System.Object>)mEventTable[enEventType] + kHandler;
		}
    }

    public static void RemoveListener(ESystemEventType enEventType, CSysEventCallback<System.Object> kHandler)
    { 
        lock(mEventTable)
        {
            if (mEventTable.ContainsKey(enEventType))
            {
                mEventTable[enEventType] = (CSysEventCallback<System.Object>)mEventTable[enEventType] - kHandler;

                if (mEventTable[enEventType] == null)
                {
                    mEventTable.Remove(enEventType);
                }
            }
        }
    }

    public static void Invoke(ESystemEventType enEventType, System.Object arg1)
    {
        try
        {
            Delegate kDelegate;
            if (mEventTable.TryGetValue(enEventType, out kDelegate))
            {
                CSysEventCallback<System.Object> kHandler = (CSysEventCallback<System.Object>)kDelegate;

                if (kHandler != null)
                {
                    kHandler(arg1);
                }
            }
        }
        catch (Exception ex)
        {
         
        }
    }

    public static void UnInit()
    {
        mEventTable.Clear();
    }
}
