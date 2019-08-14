using System.Collections.Generic;
using UnityEngine;

namespace XYHY.ABSystem
{
    public class AssetBundleBuildConfig : ScriptableObject
    {
        public enum Format
        {
            Text,
            Bin
        }

        public string versionNum = "1.0.0";

        public Format depInfoFileFormat = Format.Bin;

        public List<AssetBundleFilter> filters = new List<AssetBundleFilter>();

        public List<AssetBundleDepVersion> depVersionLst = new List<AssetBundleDepVersion>();
    }

    public enum FilterType
    {
        Asset,
        ConfAndLua,
    }

    [System.Serializable]
    public class AssetBundleFilter
    {
        public FilterType filterType = FilterType.Asset;

        public bool valid = true;
        public string path = string.Empty;
        public string filter = "*.prefab";
        public string[] filterArray = { "*.prefab" };
    }

    [System.Serializable]
    public class AssetBundleDepVersion
    {
        public string versionFileName = "*.txt";
        public string depFileName = "*.";
    }
}