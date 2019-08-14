﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class NS_VersionUpdate_AssetUpdateManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(NS_VersionUpdate.AssetUpdateManager), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("HttpPOSTRequest", HttpPOSTRequest);
		L.RegFunction("SkipAssetUpdate", SkipAssetUpdate);
		L.RegFunction("EnterGameHotHander", EnterGameHotHander);
		L.RegFunction("StartDownloadGame", StartDownloadGame);
		L.RegFunction("RealDownGameAsset", RealDownGameAsset);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("Instance", get_Instance, set_Instance);
		L.RegVar("commPanel", get_commPanel, set_commPanel);
		L.RegVar("verFileNameLst", get_verFileNameLst, set_verFileNameLst);
		L.RegVar("urlFilePath", get_urlFilePath, set_urlFilePath);
		L.RegVar("isUsingAboard", get_isUsingAboard, set_isUsingAboard);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpPOSTRequest(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)ToLua.CheckObject(L, 1, typeof(NS_VersionUpdate.AssetUpdateManager));
			string arg0 = ToLua.CheckString(L, 2);
			System.Action<string,int,string> arg1 = null;
			LuaTypes funcType3 = LuaDLL.lua_type(L, 3);

			if (funcType3 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (System.Action<string,int,string>)ToLua.CheckObject(L, 3, typeof(System.Action<string,int,string>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 3);
				arg1 = DelegateFactory.CreateDelegate(typeof(System.Action<string,int,string>), func) as System.Action<string,int,string>;
			}

			obj.HttpPOSTRequest(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SkipAssetUpdate(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)ToLua.CheckObject(L, 1, typeof(NS_VersionUpdate.AssetUpdateManager));
			obj.SkipAssetUpdate();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnterGameHotHander(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 6);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)ToLua.CheckObject(L, 1, typeof(NS_VersionUpdate.AssetUpdateManager));
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			string arg2 = ToLua.CheckString(L, 4);
			string arg3 = ToLua.CheckString(L, 5);
			System.Action arg4 = null;
			LuaTypes funcType6 = LuaDLL.lua_type(L, 6);

			if (funcType6 != LuaTypes.LUA_TFUNCTION)
			{
				 arg4 = (System.Action)ToLua.CheckObject(L, 6, typeof(System.Action));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 6);
				arg4 = DelegateFactory.CreateDelegate(typeof(System.Action), func) as System.Action;
			}

			obj.EnterGameHotHander(arg0, arg1, arg2, arg3, arg4);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StartDownloadGame(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)ToLua.CheckObject(L, 1, typeof(NS_VersionUpdate.AssetUpdateManager));
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			System.Action arg2 = null;
			LuaTypes funcType4 = LuaDLL.lua_type(L, 4);

			if (funcType4 != LuaTypes.LUA_TFUNCTION)
			{
				 arg2 = (System.Action)ToLua.CheckObject(L, 4, typeof(System.Action));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 4);
				arg2 = DelegateFactory.CreateDelegate(typeof(System.Action), func) as System.Action;
			}

			System.Action<long> arg3 = null;
			LuaTypes funcType5 = LuaDLL.lua_type(L, 5);

			if (funcType5 != LuaTypes.LUA_TFUNCTION)
			{
				 arg3 = (System.Action<long>)ToLua.CheckObject(L, 5, typeof(System.Action<long>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 5);
				arg3 = DelegateFactory.CreateDelegate(typeof(System.Action<long>), func) as System.Action<long>;
			}

			obj.StartDownloadGame(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RealDownGameAsset(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)ToLua.CheckObject(L, 1, typeof(NS_VersionUpdate.AssetUpdateManager));
			obj.RealDownGameAsset();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
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

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Instance(IntPtr L)
	{
		try
		{
			ToLua.Push(L, NS_VersionUpdate.AssetUpdateManager.Instance);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_commPanel(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)o;
			UnityEngine.GameObject ret = obj.commPanel;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index commPanel on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_verFileNameLst(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)o;
			System.Collections.Generic.List<string> ret = obj.verFileNameLst;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index verFileNameLst on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_urlFilePath(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)o;
			string ret = obj.urlFilePath;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index urlFilePath on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isUsingAboard(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)o;
			bool ret = obj.isUsingAboard;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isUsingAboard on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Instance(IntPtr L)
	{
		try
		{
			NS_VersionUpdate.AssetUpdateManager arg0 = (NS_VersionUpdate.AssetUpdateManager)ToLua.CheckUnityObject(L, 2, typeof(NS_VersionUpdate.AssetUpdateManager));
			NS_VersionUpdate.AssetUpdateManager.Instance = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_commPanel(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)o;
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.GameObject));
			obj.commPanel = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index commPanel on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_verFileNameLst(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)o;
			System.Collections.Generic.List<string> arg0 = (System.Collections.Generic.List<string>)ToLua.CheckObject(L, 2, typeof(System.Collections.Generic.List<string>));
			obj.verFileNameLst = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index verFileNameLst on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_urlFilePath(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.urlFilePath = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index urlFilePath on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isUsingAboard(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NS_VersionUpdate.AssetUpdateManager obj = (NS_VersionUpdate.AssetUpdateManager)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.isUsingAboard = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isUsingAboard on a nil value" : e.Message);
		}
	}
}

