/********************************************************************
	created:	2015/12/20  15:44
	file base:	BundleResourceMgr
	file ext:	cs
	author:		shine	
	purpose:	加载对象依赖配置文件，管理加载器,用来对所有资源进行统一管理，主要是加载，缓存和释放的策略
*********************************************************************/

using LitJson;
using LuaInterface;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace XYHY
{
    public class BundleResourceMgr
    {
        private static BundleResourceMgr instance;
        private static readonly object lockObj = new object();
        public static BundleResourceMgr Instance
        {
            get
            {
                if (instance == null)
                {
                    lock (lockObj)
                    {
                        if (instance == null)
                        {
                            instance = new BundleResourceMgr();
                        }
                    }
                }

                return instance;
            }
        }


        public void Init(Action callback)
        {

        }
    }
}