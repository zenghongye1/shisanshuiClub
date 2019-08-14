/********************************************************************
	created:	2015/05/15  14:44
	file base:	ProjectConfigUtility
	file ext:	cs
	author:		shine

	purpose:	项目设置工具类
*********************************************************************/

using System.IO;
using XYHY;
using LuaInterface;
using UnityEngine;

public static class ProjectConfigUtility
{
    public static readonly string ConfigFileName = "ProjectConfig";
    public static readonly string ConfigFilePostfix= "bytes";

    public static ProjectConfigInfo GetProjectConfig()
    {
        byte[] configBytes = LoadConfigFile("LocalConfig/" + ConfigFileName,
                                                ConfigFilePostfix);

        if (configBytes == null)
        {
            return null;
        }

        string configStr = System.Text.Encoding.UTF8.GetString(configBytes);

        ProjectConfigInfo configInfo =
            LitJson.JsonMapper.ToObject<ProjectConfigInfo>(configStr);
        
        return configInfo;
    }

    /// <summary>
    /// 加载配置文件
    /// </summary>
    /// <param name="resPath">Resources目录相对路径</param>
    /// <param name="fileSuffix">文件后缀名</param>
    /// <returns>文件的bytes</returns>
    private static byte[] LoadConfigFile(string resPath, string fileSuffix)

    {
        byte[] bytes = null;
        TextAsset ta = null;

        if (XyhyGlobal.IsLoadAssetBundle)
        {
            string fileUrl = string.Format("{0}{1}.{2}", BundleConfig.Instance.BundlesPathForPersist, resPath, fileSuffix);
            if (File.Exists(fileUrl))
            {
                bytes = File.ReadAllBytes(fileUrl);
            }
            else
            {
                ta = Resources.Load<TextAsset>(resPath);
                if (ta != null)
                {
                    bytes = ta.bytes;
                }
            }
        }
        else
        {
            ta = Resources.Load<TextAsset>(resPath);
            if (ta != null)
            {
                bytes = ta.bytes;
            }
        }

        if (bytes == null)
        {
            Debugger.LogError("can find config:" + resPath);
        }

        return bytes;
    }
}
