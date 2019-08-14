using System;
using System.Collections.Generic;
using XYHY.ABSystem;
using System.IO;
using System.Text;

public class DownloadFileChecker
{
    static string _savePath = AssetBundlePathResolver.instance.BundlesPathForPersistent + "downTemp.txt";

    static Dictionary<string, string> _downloadedFileMap = new Dictionary<string, string>();

    static FileStream _fs;
    static StreamWriter _sw;
    //暂时不按照game的版本号检查， game分包下载不支持断点续传 版本号已ver_app_4为准
    //@TODO  1. 每一个game对应一个独立的downloadFileChecker   2. 分包game也添加断点续传 
    public static void InitDownFileInfo(string nowVersion)
    {
        bool needWriteVersion = true;
        if (File.Exists(_savePath))
        {
            needWriteVersion = LoadFileAndCheckVersion(nowVersion);
        }

        InitStreams(needWriteVersion, nowVersion);
    }

    public static bool CheckKeyHasDownLoad(string key, string crc)
    {
        return _downloadedFileMap.ContainsKey(key) && _downloadedFileMap[key] == crc;
    }

    // 单个文件下载完成时 调用
    public static void DownFileFinish(string key, string crc)
    {
        if (_downloadedFileMap.ContainsKey(key))
            _downloadedFileMap[key] = crc;
        else
            _downloadedFileMap.Add(key, crc);
        if(_sw != null)
        {
            _sw.WriteLine(EncodeLine(key, crc));
            _sw.Flush();
        }
     
    }

    // 热更完成后 删除临时文件
    public static void CloseAndClearDownFileChecker()
    {
        Close();
        if (File.Exists(_savePath))
            File.Delete(_savePath);
    }

    public static void Close()
    {
        if (_sw != null)
        {
            _sw.Close();
            _sw = null;
        }
        if (_fs != null)
        {
            _fs.Close();
            _fs = null;
        }
    }

    public static void InitStreams(bool needWriteVersion, string nowVer)
    {
        if (!Directory.Exists(AssetBundlePathResolver.instance.BundlesPathForPersistent))
            Directory.CreateDirectory(AssetBundlePathResolver.instance.BundlesPathForPersistent);
        _fs = File.Open(_savePath, FileMode.Append, FileAccess.Write, FileShare.ReadWrite);
        _sw = new StreamWriter(_fs);
        if(needWriteVersion)
        {
            _sw.WriteLine(nowVer);
        }
    }

    static bool LoadFileAndCheckVersion(string nowVersion)
    {
        if (!File.Exists(_savePath))
            return true;
        var lines = File.ReadAllLines(_savePath);
        if (lines == null || lines.Length == 0)
            return true;
        string versionNumber = lines[0];
        // 检测版本号是否相同 不相同在直接删除源文件
        if(!CheckVersion(versionNumber, nowVersion))
        {
            File.Delete(_savePath);
            _downloadedFileMap.Clear();
            return true;
        }

        for (int i = 1; i < lines.Length; i++)
        {
            DecodeLine(lines[i]);
        }
        return false;
    }

    static bool CheckVersion(string fileVersion, string nowVersion)
    {
        var fileVer = new Version(fileVersion);
        var nowVer = new Version(nowVersion);
        return fileVer.Equals(nowVer);
    }


    static void DecodeLine(string line)
    {
        var contents = line.Split('\t');
        if (contents.Length != 2)
            return;
        contents[0] = contents[0].Replace("\\", "/");
        if (!_downloadedFileMap.ContainsKey(contents[0]))
        {
            _downloadedFileMap.Add(contents[0], contents[1]);
        }
        else
        {
            _downloadedFileMap[contents[0]] = contents[1];
        }
    }

    static string EncodeLine(string key, string crc)
    {
        return string.Format("{0}\t{1}", key, crc);
    }

}
