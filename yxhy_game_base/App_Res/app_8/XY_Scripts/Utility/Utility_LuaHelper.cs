using System;
using UnityEngine;
using LuaInterface;

public class Utility_LuaHelper
{
    static public void CallParaLuaFunc(LuaFunction luaFunc)
    {
        if (luaFunc != null)
        {
            luaFunc.Call();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, uint para1)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, bool para1)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, bool para1, float para2)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.Push(para2);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, uint para1, uint para2)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.Push(para2);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, uint para1, LuaInteger64 para2, LuaInteger64 para3)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.PushInt64(para2);
            luaFunc.PushInt64(para3);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, string para1, Vector3 para2, int fontIndex = 1, bool bPlayer = false, int offset = 0)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.Push(para2);
            luaFunc.Push(fontIndex);
            luaFunc.Push(bPlayer);
            luaFunc.Push(offset);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, string para1, float para2, string para3, float para4, string para5, float para6)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.Push(para2);
            luaFunc.Push(para3);
            luaFunc.Push(para4);
            luaFunc.Push(para5);
            luaFunc.Push(para6);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, string para1, string para2, string para3)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.Push(para2);
            luaFunc.Push(para3);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, string para1, string para2, string para3,string para4,bool selfSDK=false)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.Push(para2);
            luaFunc.Push(para3);
            luaFunc.Push(para4);
            luaFunc.Push(selfSDK);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    static public void CallParaLuaFunc(LuaFunction luaFunc, string para1)
    {
        if (luaFunc != null)
        {
            luaFunc.BeginPCall();
            luaFunc.Push(para1);
            luaFunc.PCall();
            luaFunc.EndPCall();
        }
    }

    //static public void CallParaLuaFunc(LuaFunction luaFunc, params object[] parmaArray)
    //{
    //    if (luaFunc != null)
    //    {
    //        if (null != parmaArray && parmaArray.Length > 0)
    //        {
    //            luaFunc.BeginPCall();
    //            for (int i = 0; i < parmaArray.Length; i++)
    //            {
    //                luaFunc.Push(parmaArray[i]);
    //            }
    //            luaFunc.PCall();
    //            luaFunc.EndPCall();
    //        }
    //        else
    //        {
    //            luaFunc.Call();
    //        }
    //    }
    //}
}