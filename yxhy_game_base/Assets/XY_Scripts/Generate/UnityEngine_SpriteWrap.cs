﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_SpriteWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.Sprite), typeof(UnityEngine.Object));
		L.RegFunction("Create", Create);
		L.RegFunction("OverrideGeometry", OverrideGeometry);
		L.RegFunction("New", _CreateUnityEngine_Sprite);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("bounds", get_bounds, null);
		L.RegVar("rect", get_rect, null);
		L.RegVar("pixelsPerUnit", get_pixelsPerUnit, null);
		L.RegVar("texture", get_texture, null);
		L.RegVar("associatedAlphaSplitTexture", get_associatedAlphaSplitTexture, null);
		L.RegVar("textureRect", get_textureRect, null);
		L.RegVar("textureRectOffset", get_textureRectOffset, null);
		L.RegVar("packed", get_packed, null);
		L.RegVar("packingMode", get_packingMode, null);
		L.RegVar("packingRotation", get_packingRotation, null);
		L.RegVar("pivot", get_pivot, null);
		L.RegVar("border", get_border, null);
		L.RegVar("vertices", get_vertices, null);
		L.RegVar("triangles", get_triangles, null);
		L.RegVar("uv", get_uv, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_Sprite(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.Sprite obj = new UnityEngine.Sprite();
				ToLua.Push(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.Sprite.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Create(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Texture2D), typeof(UnityEngine.Rect), typeof(UnityEngine.Vector2)))
			{
				UnityEngine.Texture2D arg0 = (UnityEngine.Texture2D)ToLua.ToObject(L, 1);
				UnityEngine.Rect arg1 = (UnityEngine.Rect)ToLua.ToObject(L, 2);
				UnityEngine.Vector2 arg2 = ToLua.ToVector2(L, 3);
				UnityEngine.Sprite o = UnityEngine.Sprite.Create(arg0, arg1, arg2);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 4 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Texture2D), typeof(UnityEngine.Rect), typeof(UnityEngine.Vector2), typeof(float)))
			{
				UnityEngine.Texture2D arg0 = (UnityEngine.Texture2D)ToLua.ToObject(L, 1);
				UnityEngine.Rect arg1 = (UnityEngine.Rect)ToLua.ToObject(L, 2);
				UnityEngine.Vector2 arg2 = ToLua.ToVector2(L, 3);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 4);
				UnityEngine.Sprite o = UnityEngine.Sprite.Create(arg0, arg1, arg2, arg3);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 5 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Texture2D), typeof(UnityEngine.Rect), typeof(UnityEngine.Vector2), typeof(float), typeof(uint)))
			{
				UnityEngine.Texture2D arg0 = (UnityEngine.Texture2D)ToLua.ToObject(L, 1);
				UnityEngine.Rect arg1 = (UnityEngine.Rect)ToLua.ToObject(L, 2);
				UnityEngine.Vector2 arg2 = ToLua.ToVector2(L, 3);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 4);
				uint arg4 = (uint)LuaDLL.lua_tonumber(L, 5);
				UnityEngine.Sprite o = UnityEngine.Sprite.Create(arg0, arg1, arg2, arg3, arg4);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 6 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Texture2D), typeof(UnityEngine.Rect), typeof(UnityEngine.Vector2), typeof(float), typeof(uint), typeof(UnityEngine.SpriteMeshType)))
			{
				UnityEngine.Texture2D arg0 = (UnityEngine.Texture2D)ToLua.ToObject(L, 1);
				UnityEngine.Rect arg1 = (UnityEngine.Rect)ToLua.ToObject(L, 2);
				UnityEngine.Vector2 arg2 = ToLua.ToVector2(L, 3);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 4);
				uint arg4 = (uint)LuaDLL.lua_tonumber(L, 5);
				UnityEngine.SpriteMeshType arg5 = (UnityEngine.SpriteMeshType)ToLua.ToObject(L, 6);
				UnityEngine.Sprite o = UnityEngine.Sprite.Create(arg0, arg1, arg2, arg3, arg4, arg5);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 7 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Texture2D), typeof(UnityEngine.Rect), typeof(UnityEngine.Vector2), typeof(float), typeof(uint), typeof(UnityEngine.SpriteMeshType), typeof(UnityEngine.Vector4)))
			{
				UnityEngine.Texture2D arg0 = (UnityEngine.Texture2D)ToLua.ToObject(L, 1);
				UnityEngine.Rect arg1 = (UnityEngine.Rect)ToLua.ToObject(L, 2);
				UnityEngine.Vector2 arg2 = ToLua.ToVector2(L, 3);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 4);
				uint arg4 = (uint)LuaDLL.lua_tonumber(L, 5);
				UnityEngine.SpriteMeshType arg5 = (UnityEngine.SpriteMeshType)ToLua.ToObject(L, 6);
				UnityEngine.Vector4 arg6 = ToLua.ToVector4(L, 7);
				UnityEngine.Sprite o = UnityEngine.Sprite.Create(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
				ToLua.Push(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Sprite.Create");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OverrideGeometry(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)ToLua.CheckObject(L, 1, typeof(UnityEngine.Sprite));
			UnityEngine.Vector2[] arg0 = ToLua.CheckObjectArray<UnityEngine.Vector2>(L, 2);
			ushort[] arg1 = ToLua.CheckNumberArray<ushort>(L, 3);
			obj.OverrideGeometry(arg0, arg1);
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
	static int get_bounds(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Bounds ret = obj.bounds;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index bounds on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rect(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Rect ret = obj.rect;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index rect on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pixelsPerUnit(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			float ret = obj.pixelsPerUnit;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pixelsPerUnit on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_texture(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Texture2D ret = obj.texture;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index texture on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_associatedAlphaSplitTexture(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Texture2D ret = obj.associatedAlphaSplitTexture;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index associatedAlphaSplitTexture on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_textureRect(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Rect ret = obj.textureRect;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index textureRect on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_textureRectOffset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Vector2 ret = obj.textureRectOffset;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index textureRectOffset on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_packed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			bool ret = obj.packed;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index packed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_packingMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.SpritePackingMode ret = obj.packingMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index packingMode on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_packingRotation(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.SpritePackingRotation ret = obj.packingRotation;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index packingRotation on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pivot(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Vector2 ret = obj.pivot;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pivot on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_border(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Vector4 ret = obj.border;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index border on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_vertices(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Vector2[] ret = obj.vertices;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index vertices on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_triangles(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			ushort[] ret = obj.triangles;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index triangles on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_uv(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Sprite obj = (UnityEngine.Sprite)o;
			UnityEngine.Vector2[] ret = obj.uv;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index uv on a nil value" : e.Message);
		}
	}
}

