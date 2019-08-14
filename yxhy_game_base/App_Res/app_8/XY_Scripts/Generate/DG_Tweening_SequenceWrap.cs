﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;
using DG.Tweening;

public class DG_Tweening_SequenceWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(DG.Tweening.Sequence), typeof(DG.Tweening.Tween));
		L.RegFunction("InsertCallback", InsertCallback);
		L.RegFunction("PrependCallback", PrependCallback);
		L.RegFunction("AppendCallback", AppendCallback);
		L.RegFunction("PrependInterval", PrependInterval);
		L.RegFunction("AppendInterval", AppendInterval);
		L.RegFunction("Insert", Insert);
		L.RegFunction("Join", Join);
		L.RegFunction("Prepend", Prepend);
		L.RegFunction("Append", Append);
		L.RegFunction("__tostring", Lua_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int InsertCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			DG.Tweening.TweenCallback arg1 = null;
			LuaTypes funcType3 = LuaDLL.lua_type(L, 3);

			if (funcType3 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 3, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 3);
				arg1 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Sequence o = obj.InsertCallback(arg0, arg1);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PrependCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Sequence o = obj.PrependCallback(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AppendCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Sequence o = obj.AppendCallback(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PrependInterval(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			DG.Tweening.Sequence o = obj.PrependInterval(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AppendInterval(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			DG.Tweening.Sequence o = obj.AppendInterval(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Insert(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			DG.Tweening.Tween arg1 = (DG.Tweening.Tween)ToLua.CheckObject(L, 3, typeof(DG.Tweening.Tween));
			DG.Tweening.Sequence o = obj.Insert(arg0, arg1);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Join(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.Tween arg0 = (DG.Tweening.Tween)ToLua.CheckObject(L, 2, typeof(DG.Tweening.Tween));
			DG.Tweening.Sequence o = obj.Join(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Prepend(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.Tween arg0 = (DG.Tweening.Tween)ToLua.CheckObject(L, 2, typeof(DG.Tweening.Tween));
			DG.Tweening.Sequence o = obj.Prepend(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Append(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.Tween arg0 = (DG.Tweening.Tween)ToLua.CheckObject(L, 2, typeof(DG.Tweening.Tween));
			DG.Tweening.Sequence o = obj.Append(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Lua_ToString(IntPtr L)
	{
		object obj = ToLua.ToObject(L, 1);

		if (obj != null)
		{
			LuaDLL.lua_pushstring(L, obj.ToString());
		}
		else
		{
			LuaDLL.lua_pushnil(L);
		}

		return 1;
	}
}

