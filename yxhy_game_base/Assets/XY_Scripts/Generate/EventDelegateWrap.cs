﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class EventDelegateWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(EventDelegate), typeof(System.Object));
		L.RegFunction("Equals", Equals);
		L.RegFunction("GetHashCode", GetHashCode);
		L.RegFunction("Set", Set);
		L.RegFunction("Execute", Execute);
		L.RegFunction("Clear", Clear);
		L.RegFunction("ToString", ToString);
		L.RegFunction("IsValid", IsValid);
		L.RegFunction("Add", Add);
		L.RegFunction("Remove", Remove);
		L.RegFunction("New", _CreateEventDelegate);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("oneShot", get_oneShot, set_oneShot);
		L.RegVar("target", get_target, set_target);
		L.RegVar("methodName", get_methodName, set_methodName);
		L.RegVar("parameters", get_parameters, null);
		L.RegVar("isValid", get_isValid, null);
		L.RegVar("isEnabled", get_isEnabled, null);
		L.RegFunction("Callback", EventDelegate_Callback);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateEventDelegate(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				EventDelegate obj = new EventDelegate();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(EventDelegate.Callback)))
			{
				EventDelegate.Callback arg0 = null;
				LuaTypes funcType1 = LuaDLL.lua_type(L, 1);

				if (funcType1 != LuaTypes.LUA_TFUNCTION)
				{
					 arg0 = (EventDelegate.Callback)ToLua.CheckObject(L, 1, typeof(EventDelegate.Callback));
				}
				else
				{
					LuaFunction func = ToLua.ToLuaFunction(L, 1);
					arg0 = DelegateFactory.CreateDelegate(typeof(EventDelegate.Callback), func) as EventDelegate.Callback;
				}

				EventDelegate obj = new EventDelegate(arg0);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.MonoBehaviour), typeof(string)))
			{
				UnityEngine.MonoBehaviour arg0 = (UnityEngine.MonoBehaviour)ToLua.CheckUnityObject(L, 1, typeof(UnityEngine.MonoBehaviour));
				string arg1 = ToLua.CheckString(L, 2);
				EventDelegate obj = new EventDelegate(arg0, arg1);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: EventDelegate.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Equals(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			EventDelegate obj = (EventDelegate)ToLua.CheckObject(L, 1, typeof(EventDelegate));
			object arg0 = ToLua.ToVarObject(L, 2);
			bool o = obj != null ? obj.Equals(arg0) : arg0 == null;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetHashCode(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			EventDelegate obj = (EventDelegate)ToLua.CheckObject(L, 1, typeof(EventDelegate));
			int o = obj.GetHashCode();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Set(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(System.Collections.Generic.List<EventDelegate>), typeof(EventDelegate)))
			{
				System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.ToObject(L, 1);
				EventDelegate arg1 = (EventDelegate)ToLua.ToObject(L, 2);
				EventDelegate.Set(arg0, arg1);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(System.Collections.Generic.List<EventDelegate>), typeof(EventDelegate.Callback)))
			{
				System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.ToObject(L, 1);
				EventDelegate.Callback arg1 = null;
				LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

				if (funcType2 != LuaTypes.LUA_TFUNCTION)
				{
					 arg1 = (EventDelegate.Callback)ToLua.ToObject(L, 2);
				}
				else
				{
					LuaFunction func = ToLua.ToLuaFunction(L, 2);
					arg1 = DelegateFactory.CreateDelegate(typeof(EventDelegate.Callback), func) as EventDelegate.Callback;
				}

				EventDelegate o = EventDelegate.Set(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(EventDelegate), typeof(UnityEngine.MonoBehaviour), typeof(string)))
			{
				EventDelegate obj = (EventDelegate)ToLua.ToObject(L, 1);
				UnityEngine.MonoBehaviour arg0 = (UnityEngine.MonoBehaviour)ToLua.ToObject(L, 2);
				string arg1 = ToLua.ToString(L, 3);
				obj.Set(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: EventDelegate.Set");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Execute(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(System.Collections.Generic.List<EventDelegate>)))
			{
				System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.ToObject(L, 1);
				EventDelegate.Execute(arg0);
				return 0;
			}
			else if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(EventDelegate)))
			{
				EventDelegate obj = (EventDelegate)ToLua.ToObject(L, 1);
				bool o = obj.Execute();
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: EventDelegate.Execute");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clear(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			EventDelegate obj = (EventDelegate)ToLua.CheckObject(L, 1, typeof(EventDelegate));
			obj.Clear();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ToString(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			EventDelegate obj = (EventDelegate)ToLua.CheckObject(L, 1, typeof(EventDelegate));
			string o = obj.ToString();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsValid(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.CheckObject(L, 1, typeof(System.Collections.Generic.List<EventDelegate>));
			bool o = EventDelegate.IsValid(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Add(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(System.Collections.Generic.List<EventDelegate>), typeof(EventDelegate)))
			{
				System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.ToObject(L, 1);
				EventDelegate arg1 = (EventDelegate)ToLua.ToObject(L, 2);
				EventDelegate.Add(arg0, arg1);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(System.Collections.Generic.List<EventDelegate>), typeof(EventDelegate.Callback)))
			{
				System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.ToObject(L, 1);
				EventDelegate.Callback arg1 = null;
				LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

				if (funcType2 != LuaTypes.LUA_TFUNCTION)
				{
					 arg1 = (EventDelegate.Callback)ToLua.ToObject(L, 2);
				}
				else
				{
					LuaFunction func = ToLua.ToLuaFunction(L, 2);
					arg1 = DelegateFactory.CreateDelegate(typeof(EventDelegate.Callback), func) as EventDelegate.Callback;
				}

				EventDelegate o = EventDelegate.Add(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(System.Collections.Generic.List<EventDelegate>), typeof(EventDelegate), typeof(bool)))
			{
				System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.ToObject(L, 1);
				EventDelegate arg1 = (EventDelegate)ToLua.ToObject(L, 2);
				bool arg2 = LuaDLL.lua_toboolean(L, 3);
				EventDelegate.Add(arg0, arg1, arg2);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(System.Collections.Generic.List<EventDelegate>), typeof(EventDelegate.Callback), typeof(bool)))
			{
				System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.ToObject(L, 1);
				EventDelegate.Callback arg1 = null;
				LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

				if (funcType2 != LuaTypes.LUA_TFUNCTION)
				{
					 arg1 = (EventDelegate.Callback)ToLua.ToObject(L, 2);
				}
				else
				{
					LuaFunction func = ToLua.ToLuaFunction(L, 2);
					arg1 = DelegateFactory.CreateDelegate(typeof(EventDelegate.Callback), func) as EventDelegate.Callback;
				}

				bool arg2 = LuaDLL.lua_toboolean(L, 3);
				EventDelegate o = EventDelegate.Add(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: EventDelegate.Add");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Remove(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(System.Collections.Generic.List<EventDelegate>), typeof(EventDelegate)))
			{
				System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.ToObject(L, 1);
				EventDelegate arg1 = (EventDelegate)ToLua.ToObject(L, 2);
				bool o = EventDelegate.Remove(arg0, arg1);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(System.Collections.Generic.List<EventDelegate>), typeof(EventDelegate.Callback)))
			{
				System.Collections.Generic.List<EventDelegate> arg0 = (System.Collections.Generic.List<EventDelegate>)ToLua.ToObject(L, 1);
				EventDelegate.Callback arg1 = null;
				LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

				if (funcType2 != LuaTypes.LUA_TFUNCTION)
				{
					 arg1 = (EventDelegate.Callback)ToLua.ToObject(L, 2);
				}
				else
				{
					LuaFunction func = ToLua.ToLuaFunction(L, 2);
					arg1 = DelegateFactory.CreateDelegate(typeof(EventDelegate.Callback), func) as EventDelegate.Callback;
				}

				bool o = EventDelegate.Remove(arg0, arg1);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: EventDelegate.Remove");
			}
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

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_oneShot(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			EventDelegate obj = (EventDelegate)o;
			bool ret = obj.oneShot;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index oneShot on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_target(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			EventDelegate obj = (EventDelegate)o;
			UnityEngine.MonoBehaviour ret = obj.target;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index target on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_methodName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			EventDelegate obj = (EventDelegate)o;
			string ret = obj.methodName;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index methodName on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_parameters(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			EventDelegate obj = (EventDelegate)o;
			EventDelegate.Parameter[] ret = obj.parameters;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index parameters on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isValid(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			EventDelegate obj = (EventDelegate)o;
			bool ret = obj.isValid;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isValid on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isEnabled(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			EventDelegate obj = (EventDelegate)o;
			bool ret = obj.isEnabled;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isEnabled on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_oneShot(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			EventDelegate obj = (EventDelegate)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.oneShot = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index oneShot on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_target(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			EventDelegate obj = (EventDelegate)o;
			UnityEngine.MonoBehaviour arg0 = (UnityEngine.MonoBehaviour)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.MonoBehaviour));
			obj.target = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index target on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_methodName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			EventDelegate obj = (EventDelegate)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.methodName = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index methodName on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EventDelegate_Callback(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(EventDelegate.Callback), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

