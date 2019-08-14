/********************************************************************
	created:	2017/05/18  21:03
	file base:	LuaDestroyBundle
	file ext:	cs
	author:		shine
	purpose:	卸掉相关的资源
*********************************************************************/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
namespace XYHY
{
    public class LuaDestroyBundle : MonoBehaviour
    {
        public static Dictionary<string, int> s_dict = new Dictionary<string, int>();
        public string strName;
        public string BundleName
        {
            get 
            { 
                return strName;
            }

            set 
            {
                if (!string.IsNullOrEmpty(value))
                {
                    if (!s_dict.ContainsKey(value))
                    {
                        s_dict[value] = 0;
                    }
                    s_dict[value] += 1;
                    strName = value;
                }
            }
        }
        public System.Type ResType;

        static public void Out() 
        {
            foreach (var item in s_dict)
            {
                Debugger.Log("name:{0},num:{1}",item.Key,item.Value);
            }
        }

        protected void OnDestroy()
        {
            if (BundleName!=null && BundleName.Length > 0)
            {
                if (s_dict.ContainsKey(BundleName))
                {
                    s_dict[BundleName] -= 1;
                }

                XYHY.ResourceMgr o = Framework.GameKernel.GetResourceMgr();
                if (o!=null)
                    o.UnloadResource(BundleName, ResType);
            }
        }

    }
}