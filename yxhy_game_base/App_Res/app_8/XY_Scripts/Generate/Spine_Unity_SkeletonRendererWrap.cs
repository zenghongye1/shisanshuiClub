﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Spine_Unity_SkeletonRendererWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Spine.Unity.SkeletonRenderer), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("Awake", Awake);
		L.RegFunction("Initialize", Initialize);
		L.RegFunction("RefreshRenderQuque", RefreshRenderQuque);
		L.RegFunction("LateUpdate", LateUpdate);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("OnRebuild", get_OnRebuild, set_OnRebuild);
		L.RegVar("skeletonDataAsset", get_skeletonDataAsset, set_skeletonDataAsset);
		L.RegVar("initialSkinName", get_initialSkinName, set_initialSkinName);
		L.RegVar("separatorSlotNames", get_separatorSlotNames, set_separatorSlotNames);
		L.RegVar("separatorSlots", get_separatorSlots, null);
		L.RegVar("zSpacing", get_zSpacing, set_zSpacing);
		L.RegVar("renderMeshes", get_renderMeshes, set_renderMeshes);
		L.RegVar("immutableTriangles", get_immutableTriangles, set_immutableTriangles);
		L.RegVar("pmaVertexColors", get_pmaVertexColors, set_pmaVertexColors);
		L.RegVar("clearStateOnDisable", get_clearStateOnDisable, set_clearStateOnDisable);
		L.RegVar("calculateNormals", get_calculateNormals, set_calculateNormals);
		L.RegVar("calculateTangents", get_calculateTangents, set_calculateTangents);
		L.RegVar("logErrors", get_logErrors, set_logErrors);
		L.RegVar("disableRenderingOnOverride", get_disableRenderingOnOverride, set_disableRenderingOnOverride);
		L.RegVar("valid", get_valid, set_valid);
		L.RegVar("skeleton", get_skeleton, set_skeleton);
		L.RegVar("renderQueue", get_renderQueue, set_renderQueue);
		L.RegVar("SkeletonDataAsset", get_SkeletonDataAsset, null);
		L.RegVar("CustomMaterialOverride", get_CustomMaterialOverride, null);
		L.RegVar("CustomSlotMaterials", get_CustomSlotMaterials, null);
		L.RegVar("Skeleton", get_Skeleton, null);
		L.RegVar("GenerateMeshOverride", get_GenerateMeshOverride, set_GenerateMeshOverride);
		L.RegFunction("SkeletonRendererDelegate", Spine_Unity_SkeletonRenderer_SkeletonRendererDelegate);
		L.RegFunction("InstructionDelegate", Spine_Unity_SkeletonRenderer_InstructionDelegate);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Awake(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)ToLua.CheckObject(L, 1, typeof(Spine.Unity.SkeletonRenderer));
			obj.Awake();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Initialize(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)ToLua.CheckObject(L, 1, typeof(Spine.Unity.SkeletonRenderer));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.Initialize(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RefreshRenderQuque(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)ToLua.CheckObject(L, 1, typeof(Spine.Unity.SkeletonRenderer));
			obj.RefreshRenderQuque();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LateUpdate(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)ToLua.CheckObject(L, 1, typeof(Spine.Unity.SkeletonRenderer));
			obj.LateUpdate();
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
	static int get_OnRebuild(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			Spine.Unity.SkeletonRenderer.SkeletonRendererDelegate ret = obj.OnRebuild;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index OnRebuild on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_skeletonDataAsset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			Spine.Unity.SkeletonDataAsset ret = obj.skeletonDataAsset;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index skeletonDataAsset on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_initialSkinName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			string ret = obj.initialSkinName;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index initialSkinName on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_separatorSlotNames(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			string[] ret = obj.separatorSlotNames;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index separatorSlotNames on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_separatorSlots(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			System.Collections.Generic.List<Spine.Slot> ret = obj.separatorSlots;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index separatorSlots on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_zSpacing(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			float ret = obj.zSpacing;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index zSpacing on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_renderMeshes(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool ret = obj.renderMeshes;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index renderMeshes on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_immutableTriangles(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool ret = obj.immutableTriangles;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index immutableTriangles on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pmaVertexColors(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool ret = obj.pmaVertexColors;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pmaVertexColors on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_clearStateOnDisable(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool ret = obj.clearStateOnDisable;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index clearStateOnDisable on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_calculateNormals(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool ret = obj.calculateNormals;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index calculateNormals on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_calculateTangents(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool ret = obj.calculateTangents;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index calculateTangents on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_logErrors(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool ret = obj.logErrors;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index logErrors on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_disableRenderingOnOverride(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool ret = obj.disableRenderingOnOverride;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index disableRenderingOnOverride on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_valid(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool ret = obj.valid;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index valid on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_skeleton(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			Spine.Skeleton ret = obj.skeleton;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index skeleton on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_renderQueue(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			int ret = obj.renderQueue;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index renderQueue on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_SkeletonDataAsset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			Spine.Unity.SkeletonDataAsset ret = obj.SkeletonDataAsset;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SkeletonDataAsset on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_CustomMaterialOverride(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			System.Collections.Generic.Dictionary<UnityEngine.Material,UnityEngine.Material> ret = obj.CustomMaterialOverride;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index CustomMaterialOverride on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_CustomSlotMaterials(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			System.Collections.Generic.Dictionary<Spine.Slot,UnityEngine.Material> ret = obj.CustomSlotMaterials;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index CustomSlotMaterials on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Skeleton(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			Spine.Skeleton ret = obj.Skeleton;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index Skeleton on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_GenerateMeshOverride(IntPtr L)
	{
		ToLua.Push(L, new EventObject("Spine.Unity.SkeletonRenderer.GenerateMeshOverride"));
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_OnRebuild(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			Spine.Unity.SkeletonRenderer.SkeletonRendererDelegate arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Spine.Unity.SkeletonRenderer.SkeletonRendererDelegate)ToLua.CheckObject(L, 2, typeof(Spine.Unity.SkeletonRenderer.SkeletonRendererDelegate));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Spine.Unity.SkeletonRenderer.SkeletonRendererDelegate), func) as Spine.Unity.SkeletonRenderer.SkeletonRendererDelegate;
			}

			obj.OnRebuild = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index OnRebuild on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_skeletonDataAsset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			Spine.Unity.SkeletonDataAsset arg0 = (Spine.Unity.SkeletonDataAsset)ToLua.CheckUnityObject(L, 2, typeof(Spine.Unity.SkeletonDataAsset));
			obj.skeletonDataAsset = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index skeletonDataAsset on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_initialSkinName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.initialSkinName = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index initialSkinName on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_separatorSlotNames(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			string[] arg0 = ToLua.CheckStringArray(L, 2);
			obj.separatorSlotNames = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index separatorSlotNames on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_zSpacing(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.zSpacing = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index zSpacing on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_renderMeshes(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.renderMeshes = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index renderMeshes on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_immutableTriangles(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.immutableTriangles = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index immutableTriangles on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pmaVertexColors(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.pmaVertexColors = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pmaVertexColors on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_clearStateOnDisable(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.clearStateOnDisable = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index clearStateOnDisable on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_calculateNormals(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.calculateNormals = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index calculateNormals on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_calculateTangents(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.calculateTangents = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index calculateTangents on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_logErrors(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.logErrors = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index logErrors on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_disableRenderingOnOverride(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.disableRenderingOnOverride = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index disableRenderingOnOverride on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_valid(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.valid = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index valid on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_skeleton(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			Spine.Skeleton arg0 = (Spine.Skeleton)ToLua.CheckObject(L, 2, typeof(Spine.Skeleton));
			obj.skeleton = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index skeleton on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_renderQueue(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.renderQueue = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index renderQueue on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_GenerateMeshOverride(IntPtr L)
	{
		try
		{
			Spine.Unity.SkeletonRenderer obj = (Spine.Unity.SkeletonRenderer)ToLua.CheckObject(L, 1, typeof(Spine.Unity.SkeletonRenderer));
			EventObject arg0 = null;

			if (LuaDLL.lua_isuserdata(L, 2) != 0)
			{
				arg0 = (EventObject)ToLua.ToObject(L, 2);
			}
			else
			{
				return LuaDLL.luaL_throw(L, "The event 'Spine.Unity.SkeletonRenderer.GenerateMeshOverride' can only appear on the left hand side of += or -= when used outside of the type 'Spine.Unity.SkeletonRenderer'");
			}

			if (arg0.op == EventOp.Add)
			{
				Spine.Unity.SkeletonRenderer.InstructionDelegate ev = (Spine.Unity.SkeletonRenderer.InstructionDelegate)DelegateFactory.CreateDelegate(typeof(Spine.Unity.SkeletonRenderer.InstructionDelegate), arg0.func);
				obj.GenerateMeshOverride += ev;
			}
			else if (arg0.op == EventOp.Sub)
			{
				Spine.Unity.SkeletonRenderer.InstructionDelegate ev = (Spine.Unity.SkeletonRenderer.InstructionDelegate)LuaMisc.GetEventHandler(obj, typeof(Spine.Unity.SkeletonRenderer), "GenerateMeshOverride");
				Delegate[] ds = ev.GetInvocationList();
				LuaState state = LuaState.Get(L);

				for (int i = 0; i < ds.Length; i++)
				{
					ev = (Spine.Unity.SkeletonRenderer.InstructionDelegate)ds[i];
					LuaDelegate ld = ev.Target as LuaDelegate;

					if (ld != null && ld.func == arg0.func)
					{
						obj.GenerateMeshOverride -= ev;
						state.DelayDispose(ld.func);
						break;
					}
				}

				arg0.func.Dispose();
			}

			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Spine_Unity_SkeletonRenderer_SkeletonRendererDelegate(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Spine.Unity.SkeletonRenderer.SkeletonRendererDelegate), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Spine_Unity_SkeletonRenderer_InstructionDelegate(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Spine.Unity.SkeletonRenderer.InstructionDelegate), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

