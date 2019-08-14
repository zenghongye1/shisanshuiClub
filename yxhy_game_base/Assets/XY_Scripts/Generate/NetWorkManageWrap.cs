﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class NetWorkManageWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(NetWorkManage), typeof(Singleton<NetWorkManage>));
		L.RegFunction("Init", Init);
		L.RegFunction("LoadLocalCfg", LoadLocalCfg);
		L.RegFunction("ReqServerCfgJson", ReqServerCfgJson);
		L.RegFunction("getReleaseUrl", getReleaseUrl);
		L.RegFunction("SetBaseUrl", SetBaseUrl);
		L.RegFunction("HttpPostRequestWithData", HttpPostRequestWithData);
		L.RegFunction("HttpPOSTRequestV", HttpPOSTRequestV);
		L.RegFunction("HttpPOSTRequest", HttpPOSTRequest);
		L.RegFunction("HttpRequestByMothdType", HttpRequestByMothdType);
		L.RegFunction("HttpDownImage", HttpDownImage);
		L.RegFunction("HttpDownAssetBundle", HttpDownAssetBundle);
		L.RegFunction("HttpDownloadFile", HttpDownloadFile);
		L.RegFunction("HttpDownTextAsset", HttpDownTextAsset);
		L.RegFunction("HttpDownTextAssetByte", HttpDownTextAssetByte);
		L.RegFunction("CreateFile", CreateFile);
		L.RegFunction("GetMacAddress", GetMacAddress);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("testAccount", get_testAccount, set_testAccount);
		L.RegVar("m_physicalAddress", get_m_physicalAddress, set_m_physicalAddress);
		L.RegVar("SwithJosnUrl", get_SwithJosnUrl, set_SwithJosnUrl);
		L.RegVar("SwitchHomeUrl", get_SwitchHomeUrl, set_SwitchHomeUrl);
		L.RegVar("CfgJsonUrl", get_CfgJsonUrl, set_CfgJsonUrl);
		L.RegVar("BaseUrl", get_BaseUrl, set_BaseUrl);
		L.RegVar("GlobalServerUrl", get_GlobalServerUrl, set_GlobalServerUrl);
		L.RegVar("EServerUrlType", get_EServerUrlType, set_EServerUrlType);
		L.RegVar("ServerUrlTypeNum", get_ServerUrlTypeNum, null);
		L.RegVar("WsUrl", get_WsUrl, set_WsUrl);
		L.RegVar("SubPath", get_SubPath, set_SubPath);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Init(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			obj.Init();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadLocalCfg(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			LitJson.JsonData arg0 = (LitJson.JsonData)ToLua.CheckObject(L, 2, typeof(LitJson.JsonData));
			obj.LoadLocalCfg(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReqServerCfgJson(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			obj.ReqServerCfgJson();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int getReleaseUrl(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string o = obj.getReleaseUrl();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetBaseUrl(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			obj.SetBaseUrl(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpPostRequestWithData(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			System.Action<int,string,string> arg2 = null;
			LuaTypes funcType4 = LuaDLL.lua_type(L, 4);

			if (funcType4 != LuaTypes.LUA_TFUNCTION)
			{
				 arg2 = (System.Action<int,string,string>)ToLua.CheckObject(L, 4, typeof(System.Action<int,string,string>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 4);
				arg2 = DelegateFactory.CreateDelegate(typeof(System.Action<int,string,string>), func) as System.Action<int,string,string>;
			}

			obj.HttpPostRequestWithData(arg0, arg1, arg2);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpPOSTRequestV(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			System.Action<int,string,string> arg1 = null;
			LuaTypes funcType3 = LuaDLL.lua_type(L, 3);

			if (funcType3 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (System.Action<int,string,string>)ToLua.CheckObject(L, 3, typeof(System.Action<int,string,string>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 3);
				arg1 = DelegateFactory.CreateDelegate(typeof(System.Action<int,string,string>), func) as System.Action<int,string,string>;
			}

			obj.HttpPOSTRequestV(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpPOSTRequest(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			System.Action<int,string,string> arg1 = null;
			LuaTypes funcType3 = LuaDLL.lua_type(L, 3);

			if (funcType3 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (System.Action<int,string,string>)ToLua.CheckObject(L, 3, typeof(System.Action<int,string,string>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 3);
				arg1 = DelegateFactory.CreateDelegate(typeof(System.Action<int,string,string>), func) as System.Action<int,string,string>;
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
	static int HttpRequestByMothdType(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 6);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			BestHTTP.HTTPMethods arg0 = (BestHTTP.HTTPMethods)ToLua.CheckObject(L, 2, typeof(BestHTTP.HTTPMethods));
			string arg1 = ToLua.CheckString(L, 3);
			bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
			bool arg3 = LuaDLL.luaL_checkboolean(L, 5);
			System.Action<int,string,string> arg4 = null;
			LuaTypes funcType6 = LuaDLL.lua_type(L, 6);

			if (funcType6 != LuaTypes.LUA_TFUNCTION)
			{
				 arg4 = (System.Action<int,string,string>)ToLua.CheckObject(L, 6, typeof(System.Action<int,string,string>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 6);
				arg4 = DelegateFactory.CreateDelegate(typeof(System.Action<int,string,string>), func) as System.Action<int,string,string>;
			}

			obj.HttpRequestByMothdType(arg0, arg1, arg2, arg3, arg4);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpDownImage(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
			int arg2 = (int)LuaDLL.luaL_checknumber(L, 4);
			System.Action<BestHTTP.HTTPRequestStates,UnityEngine.Texture2D> arg3 = null;
			LuaTypes funcType5 = LuaDLL.lua_type(L, 5);

			if (funcType5 != LuaTypes.LUA_TFUNCTION)
			{
				 arg3 = (System.Action<BestHTTP.HTTPRequestStates,UnityEngine.Texture2D>)ToLua.CheckObject(L, 5, typeof(System.Action<BestHTTP.HTTPRequestStates,UnityEngine.Texture2D>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 5);
				arg3 = DelegateFactory.CreateDelegate(typeof(System.Action<BestHTTP.HTTPRequestStates,UnityEngine.Texture2D>), func) as System.Action<BestHTTP.HTTPRequestStates,UnityEngine.Texture2D>;
			}

			obj.HttpDownImage(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpDownAssetBundle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			System.Action<BestHTTP.HTTPRequestStates,UnityEngine.AssetBundle> arg1 = null;
			LuaTypes funcType3 = LuaDLL.lua_type(L, 3);

			if (funcType3 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (System.Action<BestHTTP.HTTPRequestStates,UnityEngine.AssetBundle>)ToLua.CheckObject(L, 3, typeof(System.Action<BestHTTP.HTTPRequestStates,UnityEngine.AssetBundle>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 3);
				arg1 = DelegateFactory.CreateDelegate(typeof(System.Action<BestHTTP.HTTPRequestStates,UnityEngine.AssetBundle>), func) as System.Action<BestHTTP.HTTPRequestStates,UnityEngine.AssetBundle>;
			}

			obj.HttpDownAssetBundle(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpDownloadFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			System.Action<BestHTTP.HTTPRequestStates,string,System.Collections.Generic.List<byte[]>> arg1 = null;
			LuaTypes funcType3 = LuaDLL.lua_type(L, 3);

			if (funcType3 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (System.Action<BestHTTP.HTTPRequestStates,string,System.Collections.Generic.List<byte[]>>)ToLua.CheckObject(L, 3, typeof(System.Action<BestHTTP.HTTPRequestStates,string,System.Collections.Generic.List<byte[]>>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 3);
				arg1 = DelegateFactory.CreateDelegate(typeof(System.Action<BestHTTP.HTTPRequestStates,string,System.Collections.Generic.List<byte[]>>), func) as System.Action<BestHTTP.HTTPRequestStates,string,System.Collections.Generic.List<byte[]>>;
			}

			obj.HttpDownloadFile(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpDownTextAsset(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			System.Action<int,string> arg1 = null;
			LuaTypes funcType3 = LuaDLL.lua_type(L, 3);

			if (funcType3 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (System.Action<int,string>)ToLua.CheckObject(L, 3, typeof(System.Action<int,string>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 3);
				arg1 = DelegateFactory.CreateDelegate(typeof(System.Action<int,string>), func) as System.Action<int,string>;
			}

			string arg2 = ToLua.CheckString(L, 4);
			obj.HttpDownTextAsset(arg0, arg1, arg2);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HttpDownTextAssetByte(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			System.Action<BestHTTP.HTTPRequestStates,byte[]> arg1 = null;
			LuaTypes funcType3 = LuaDLL.lua_type(L, 3);

			if (funcType3 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (System.Action<BestHTTP.HTTPRequestStates,byte[]>)ToLua.CheckObject(L, 3, typeof(System.Action<BestHTTP.HTTPRequestStates,byte[]>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 3);
				arg1 = DelegateFactory.CreateDelegate(typeof(System.Action<BestHTTP.HTTPRequestStates,byte[]>), func) as System.Action<BestHTTP.HTTPRequestStates,byte[]>;
			}

			obj.HttpDownTextAssetByte(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			string arg2 = ToLua.CheckString(L, 4);
			obj.CreateFile(arg0, arg1, arg2);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetMacAddress(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			NetWorkManage obj = (NetWorkManage)ToLua.CheckObject(L, 1, typeof(NetWorkManage));
			string o = obj.GetMacAddress();
			LuaDLL.lua_pushstring(L, o);
			return 1;
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
	static int get_testAccount(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, NetWorkManage.testAccount);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_m_physicalAddress(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string ret = obj.m_physicalAddress;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index m_physicalAddress on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_SwithJosnUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string ret = obj.SwithJosnUrl;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SwithJosnUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_SwitchHomeUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string ret = obj.SwitchHomeUrl;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SwitchHomeUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_CfgJsonUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string ret = obj.CfgJsonUrl;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index CfgJsonUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_BaseUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string ret = obj.BaseUrl;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index BaseUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_GlobalServerUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string ret = obj.GlobalServerUrl;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index GlobalServerUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EServerUrlType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			ServerUrlType ret = obj.EServerUrlType;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index EServerUrlType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ServerUrlTypeNum(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			int ret = obj.ServerUrlTypeNum;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index ServerUrlTypeNum on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_WsUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string ret = obj.WsUrl;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index WsUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_SubPath(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string ret = obj.SubPath;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SubPath on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_testAccount(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 2);
			NetWorkManage.testAccount = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_physicalAddress(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.m_physicalAddress = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index m_physicalAddress on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_SwithJosnUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.SwithJosnUrl = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SwithJosnUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_SwitchHomeUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.SwitchHomeUrl = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SwitchHomeUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_CfgJsonUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.CfgJsonUrl = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index CfgJsonUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_BaseUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.BaseUrl = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index BaseUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_GlobalServerUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.GlobalServerUrl = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index GlobalServerUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EServerUrlType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			ServerUrlType arg0 = (ServerUrlType)ToLua.CheckObject(L, 2, typeof(ServerUrlType));
			obj.EServerUrlType = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index EServerUrlType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_WsUrl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.WsUrl = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index WsUrl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_SubPath(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			NetWorkManage obj = (NetWorkManage)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.SubPath = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SubPath on a nil value" : e.Message);
		}
	}
}

