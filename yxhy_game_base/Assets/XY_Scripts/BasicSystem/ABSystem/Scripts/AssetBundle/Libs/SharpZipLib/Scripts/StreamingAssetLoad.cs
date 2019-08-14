using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
using System.IO;
using ICSharpCode.SharpZipLib.Zip;
using ICSharpCode.SharpZipLib.Core;

public class StreamingAssetLoad
{
#if UNITY_ANDROID
    static AssetZip ApkFile = null;
#endif

    public static void Init()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        if (ApkFile == null)
        {
            ApkFile = new AssetZip();
            ApkFile.Init(ResourcesPath.dataPath);
        }
#endif
    }

    public static void Release()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        if (ApkFile != null)
        {
            ApkFile.Release();
            ApkFile = null;

            GC.Collect();
        }
#endif
    }

    public static bool GetFile(string file, out string dstfile, out int offset)
    {
#if UNITY_EDITOR || UNITY_IPHONE || UNITY_STANDALONE
        dstfile = ResourcesPath.streamingAssetsPath + file;
        if (!File.Exists(dstfile))
        {
            dstfile = string.Empty;
            offset = 0;
            Debug.LogError(string.Format("StreamingAssetLoad.GetFile({0}) not exist!", dstfile));
            return false;
        }

        offset = 0;
        return true;
#elif UNITY_ANDROID // 安卓平台的，数据存储在apk包当中
        Init();
        ZipFile.PartialInputStream stream = ApkFile.FindFileStream("assets/" + file) as ZipFile.PartialInputStream;
        if (stream == null)
        {
            dstfile = string.Empty;
            offset = 0;
            return false;
        }
        else
        {
            dstfile = ResourcesPath.dataPath;
            offset = (int)stream.StartPos;
            return true;
        }
#endif
    }

    public static Stream GetFile(string file)
    {
#if UNITY_EDITOR || UNITY_IPHONE || UNITY_STANDALONE
        string fullfile = ResourcesPath.streamingAssetsPath + file;
        if (!File.Exists(fullfile))
        {
            return null;
        }

        try
        {
            return File.Open(fullfile, FileMode.Open, FileAccess.Read, FileShare.Read);
        }
        catch (Exception ex)
        {
            Debug.LogException(ex);
            return null;
        }
#elif UNITY_ANDROID // 安卓平台的，数据存储在apk包当中
        Init();
        return ApkFile.FindFileStream("assets/" + file);
#endif
    }

    public static void EachAllFile(System.Action<string> fun)
    {
#if UNITY_EDITOR || UNITY_IPHONE || UNITY_STANDALONE
        string fullfile = ResourcesPath.streamingAssetsPath;
        FileSystemScanner scanner = new FileSystemScanner("", "");
        scanner.ProcessFile =
            (object sender, ScanEventArgs e) =>
            {
                fun(e.Name.Substring(fullfile.Length).Replace('\\', '/'));
            };

        scanner.Scan(fullfile, true);

#elif UNITY_ANDROID // 安卓平台的，数据存储在apk包当中
        Init();
        ApkFile.EachAllFile(
            (string file) => 
            {
                if (file.StartsWith("assets/"))
                    fun(file.Substring(7));
            });
#endif
    }
}
