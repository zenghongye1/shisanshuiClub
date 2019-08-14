﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class TrieFilterWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(TrieFilter), typeof(TrieNode));
		L.RegFunction("GetInstance", GetInstance);
		L.RegFunction("AddKey", AddKey);
		L.RegFunction("HasBadWord", HasBadWord);
		L.RegFunction("FindOne", FindOne);
		L.RegFunction("FindAll", FindAll);
		L.RegFunction("Replace", Replace);
		L.RegFunction("New", _CreateTrieFilter);
		L.RegFunction("__tostring", Lua_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateTrieFilter(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				TrieFilter obj = new TrieFilter();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: TrieFilter.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetInstance(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			TrieFilter o = TrieFilter.GetInstance();
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddKey(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TrieFilter obj = (TrieFilter)ToLua.CheckObject(L, 1, typeof(TrieFilter));
			string arg0 = ToLua.CheckString(L, 2);
			obj.AddKey(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HasBadWord(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TrieFilter obj = (TrieFilter)ToLua.CheckObject(L, 1, typeof(TrieFilter));
			string arg0 = ToLua.CheckString(L, 2);
			bool o = obj.HasBadWord(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FindOne(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TrieFilter obj = (TrieFilter)ToLua.CheckObject(L, 1, typeof(TrieFilter));
			string arg0 = ToLua.CheckString(L, 2);
			string o = obj.FindOne(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FindAll(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TrieFilter obj = (TrieFilter)ToLua.CheckObject(L, 1, typeof(TrieFilter));
			string arg0 = ToLua.CheckString(L, 2);
			System.Collections.Generic.List<string> o = obj.FindAll(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Replace(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TrieFilter obj = (TrieFilter)ToLua.CheckObject(L, 1, typeof(TrieFilter));
			string arg0 = ToLua.CheckString(L, 2);
			string o = obj.Replace(arg0);
			LuaDLL.lua_pushstring(L, o);
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

