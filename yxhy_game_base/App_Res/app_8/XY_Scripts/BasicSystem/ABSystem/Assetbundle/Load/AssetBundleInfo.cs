/********************************************************************
	created:	2015/12/20  15:44
	file base:	AssetBundleInfo
	file ext:	cs
	author:		shine	
	purpose:	加载过程中的资源包信息
*********************************************************************/

using System;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

namespace XYHY
{

}

public enum AssetInMemoryType
{
    Normal = 0,
    TempResident = 1,
    Resident = 2,
    buildin = 3,
}

public class AssetBundleParams
{
    public string path;
    public Type type;
    public int uid;
    public bool IsSort = false;
    public Queue<GameObject> parentGoQueue;
    public AssetInMemoryType assetInMemoryType = AssetInMemoryType.Normal;
    public bool IsPreloadMainAsset = false;

    public Queue<Action<GameObject, GameObject>> callbackActQueue;


    public AssetBundleParams(string path, Type type, int assetType = 0)
    {
        this.path = path;
        this.type = type;
        //this.uid = uid;    
        this.assetInMemoryType = (AssetInMemoryType)assetType;
    }
}
