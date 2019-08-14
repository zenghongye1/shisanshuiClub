using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

// 资源路径
public static class ResourcesPath
{
    static ResourcesPath()
    {
        dataPath = Application.dataPath;

        streamingAssetsPath =
#if UNITY_EDITOR
            dataPath + "/StreamingAssets/";
#else
            Application.streamingAssetsPath + "/";
#endif
    }

    static public readonly string dataPath;

    static public readonly string streamingAssetsPath;
}