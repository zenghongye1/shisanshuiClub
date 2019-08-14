/*************************************************
author：ricky pu
data：2014.4.12
email:32145628@qq.com
**********************************************/
using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using LuaInterface;
using System;
using gcloud_voice;
using System.Security.Cryptography;
using System.Text;

public static class LuaHelper
{

    public static bool openGuestMode;

    public static bool isAppleVerify;

    //服务器id  预留给lua查询当前server
    public static int serverId;

    public static string password = "yaoxing8901234561234567890123488";
    public static string iv = "yaoxing890123488";

    /// <summary>
    /// getType
    /// </summary>
    /// <param name="classname"></param>
    /// <returns></returns>
    public static System.Type GetType(string classname)
    {
        Assembly assb = Assembly.GetExecutingAssembly();  //.GetExecutingAssembly();
        System.Type t = null;
        t = assb.GetType(classname); ;
        if (t == null)
        {
            t = assb.GetType(classname);
        }
        return t;
    }

    /// <summary>
    /// GetComponentInChildren
    /// </summary>
    public static Component GetComponentInChildren(GameObject obj, string classname)
    {
        System.Type t = GetType(classname);
        Component comp = null;
        if (t != null && obj != null) comp = obj.GetComponentInChildren(t);
        return comp;
    }



    public static string AESDecrypt(string text)
    {
    
        RijndaelManaged rijndaelCipher = new RijndaelManaged();

        rijndaelCipher.Mode = CipherMode.CBC;

        rijndaelCipher.Padding = PaddingMode.PKCS7;

        rijndaelCipher.KeySize = 256;

        rijndaelCipher.BlockSize = 128;

        rijndaelCipher.FeedbackSize = 128;

        byte[] encryptedData = Convert.FromBase64String(text);

        byte[] pwdBytes = System.Text.Encoding.UTF8.GetBytes(password);

        byte[] keyBytes = new byte[32];

        int len = pwdBytes.Length;

        if (len > keyBytes.Length) len = keyBytes.Length;

        System.Array.Copy(pwdBytes, keyBytes, len);

        rijndaelCipher.Key = keyBytes;

        byte[] ivBytes = System.Text.Encoding.UTF8.GetBytes(iv);
        rijndaelCipher.IV = ivBytes;

        ICryptoTransform transform = rijndaelCipher.CreateDecryptor();

        byte[] plainText = transform.TransformFinalBlock(encryptedData, 0, encryptedData.Length);

        return Encoding.UTF8.GetString(plainText);
    }

    /// <summary>
    /// GetComponent
    /// </summary>
    /// <param name="obj"></param>
    /// <param name="classname"></param>
    /// <returns></returns>
    public static Component GetComponent(GameObject obj, string classname)
    {
        if (obj == null) return null;
        return obj.GetComponent(classname);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="obj"></param>
    /// <param name="classname"></param>
    /// <returns></returns>
    public static Component[] GetComponentsInChildren(GameObject obj, string classname)
    {
        System.Type t = GetType(classname);
        if (t != null && obj != null) return obj.transform.GetComponentsInChildren(t);
        return null;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="obj"></param>
    /// <returns></returns>
    public static Transform[] GetAllChild(GameObject obj)
    {
        Transform[] child = null;
        int count = obj.transform.childCount;
        child = new Transform[count];
        for (int i = 0; i < count; i++)
        {
            child[i] = obj.transform.GetChild(i);
        }
        return child;
    }


    public static Action Action(LuaFunction func)
    {
        Action action = () =>
        {
            func.Call();
        };
        return action;
    }

    public static UIScrollView.OnDragNotification ScrollViewVoidDelegate(LuaFunction func)
    {
        UIScrollView.OnDragNotification action = () =>
        {
            func.Call();
        };
        return action;
    }

    public static UIEventListener.VoidDelegate VoidDelegate(LuaFunction func)
    {
        UIEventListener.VoidDelegate action = (go) =>
        {
            func.Call(go);
        };
        return action;
    }
    public static UIWrapContent.OnInitializeItem OnInitializeItemDelegate(LuaFunction func)
    {
        UIWrapContent.OnInitializeItem action = (go, index, realIndex) =>
         {
             func.Call(go, index, realIndex);

         };
        return action;
    }

    public static UIEventListener.VoidDelegate VoidDelegate(LuaFunction func, LuaTable tab)
    {
        UIEventListener.VoidDelegate action = (go) =>
        {
            func.Call(tab, go);
        };
        return action;
    }

    public static UIEventListener.BoolDelegate BoolDelegate(LuaFunction func)
    {
        UIEventListener.BoolDelegate action = (go, state) =>
        {
            func.Call(go, state);
        };
        return action;
    }

    public static UIEventListener.BoolDelegate BoolDelegate(LuaFunction func, LuaTable tab)
    {
        UIEventListener.BoolDelegate action = (go, state) =>
        {
            func.Call(tab, go, state);
        };
        return action;
    }

    public static UIEventListener.FloatDelegate FloatDelegate(LuaFunction func)
    {
        UIEventListener.FloatDelegate action = (go, delta) =>
        {
            func.Call(go, delta);
        };
        return action;
    }

    public static EventDelegate.Callback eventDelegate(LuaFunction func)
    {
        EventDelegate.Callback action = () =>
        {
            func.Call();
        };
        return action;
    }

    public static EventDelegate.Callback eventDelegate(LuaFunction func, LuaTable tab)
    {
        EventDelegate.Callback action = () =>
        {
            func.Call(tab);
        };
        return action;
    }

    public static UICenterOnChild.OnCenterCallback eventCenterDelegate(LuaFunction func)
    {
        UICenterOnChild.OnCenterCallback action = (go) =>
        {
            func.Call(go);
        };
        return action;
    }

    public static UIEventListener.ObjectDelegate ObjectDelegate(LuaFunction func)
    {
        UIEventListener.ObjectDelegate action = (go, state) =>
        {
            func.Call(go, state);
        };
        return action;
    }

    public static UIEventListener.ObjectDelegate ObjectDelegate(LuaFunction func, LuaTable tab)
    {
        UIEventListener.ObjectDelegate action = (go, state) =>
        {
            func.Call(tab, go, state);
        };
        return action;
    }

    public static UIEventListener.VectorDelegate VectorDelegate(LuaFunction func)
    {
        UIEventListener.VectorDelegate action = (go, delta) =>
        {
            func.Call(go, delta);
        };
        return action;
    }
    public static IGCloudVoice.ApplyMessageKeyCompleteHandler MessageKeyCompleteHandler(LuaFunction func)
    {
        IGCloudVoice.ApplyMessageKeyCompleteHandler action = (code) =>
        {
            func.Call(code);
        };
        return action;

    }
    /// <summary>
    /// cjson函数回调
    /// </summary>
    /// <param name="data"></param>
    /// <param name="func"></param>
    public static void OnJsonCallFunc(string data, LuaFunction func)
    {
        Debug.LogWarning("OnJsonCallback data:>>" + data + " lenght:>>" + data.Length);
        if (func != null) func.Call(data);
    }

    public static string GetCSAbility()
    {
        var jsData = new LitJson.JsonData();
        jsData["supportLz"] = 1;
        return jsData.ToJson();
    }



    public static void SetTransformLocalX(Transform tr, float x)
    {
        if (tr == null)
            return;
        var pos = tr.localPosition;
        pos.x = x;
        tr.localPosition = pos;
    }

    public static void SetTransformLocalY(Transform tr, float y)
    {
        if (tr == null)
            return;
        var pos = tr.localPosition;
        pos.y = y;
        tr.localPosition = pos;
    }

    public static void SetTransformLocalZ(Transform tr, float z)
    {
        if (tr == null)
            return;
        var pos = tr.localPosition;
        pos.z = z;
        tr.localPosition = pos;
    }

    public static void SetTransformLocalXY(Transform tr, float x, float y)
    {
        if (tr == null)
            return;
        var pos = tr.localPosition;
        pos.x = x;
        pos.y = y;
        tr.localPosition = pos;
    }

    public static void SetTransformX(Transform tr, float x)
    {
        if (tr == null)
            return;
        var pos = tr.position;
        pos.x = x;
        tr.position = pos;
    }

    public static void SetTransformXZ(Transform tr, float x, float z)
    {
        if (tr == null)
            return;
        var pos = tr.position;
        pos.x = x;
        pos.z = z;
        tr.position = pos;
    }

    public static void SetTransformXYZ(Transform tr, float x, float y, float z)
    {
        if (tr == null)
            return;
        var pos = tr.position;
        pos.x = x;
        pos.y = y;
        pos.z = z;
        tr.position = pos;
    }

    public static void SetTransformLocalEulers(Transform tr, float x, float y, float z)
    {
        if (tr == null)
            return;
        var eulers = tr.localEulerAngles;
        eulers.x = x;
        eulers.y = y;
        eulers.z = z;
        tr.localEulerAngles = eulers;
    }

    public static void AddMatToMeshRenderer(MeshRenderer mr, Material mat1, Material mat2)
    {
        if (mat2 != null)
        {
            Material[] materialArry = new Material[2];
            materialArry[0] = mat1;
            materialArry[1] = mat2;
            mr.sharedMaterials = materialArry;
        }
        else
        {
            Material[] materialArry = new Material[1];
            materialArry[0] = mat1;       
            mr.sharedMaterials = materialArry;
        }
    }

    public static AnimationState animationState;
    public static Animation anim;
    public static void SetCuoPaiSpeed(string animationName,string clipName,float speed)
    {
        if (animationState == null)
        {
            GameObject obj = GameObject.Find("Poker_niu_Anim");
            if (obj != null)
            {
                anim = obj.GetComponent<Animation>();
                if (anim["up"] != null)
                {
                    
                    if (anim.isPlaying == false)
                    {
                   //     anim.Rewind();
                        Debug.Log("重置动画");
                   //     anim[clipName].normalizedTime = 0;
                        anim.Play(animationName);
                    }

                    animationState = anim[clipName];
                    animationState.speed = speed;
                    Debug.Log("动画速度" + animationState.speed);  
                }
            }
        }
        else
        {
            if (anim.isPlaying == false)
            {
                anim.Play(animationName);
            }
            animationState.speed = speed;
        }
    }

    public static void RewindCuoPaiAnimation(string clipName)
    {
        if(anim != null && anim.isPlaying == false)
        {

            anim.Play(clipName);
            anim[clipName].speed = -10;
            Debug.Log("重置动画++++++++");
        }
    }

    public static float GetCuoPaiAnimationNormalizedTime(string clipName)
    {
        float normalizedTime = 0.0f;
        if (anim != null && anim.isPlaying == true)
        {
            normalizedTime = anim[clipName].normalizedTime;
        }
        return normalizedTime;
    }
    public static void SetUISpriteType(UISprite sp,int type)
    {
        if ((type >= 0 && type<=10) && (sp!=null))
         sp.type = (UIBasicSprite.Type)type;
    }


}