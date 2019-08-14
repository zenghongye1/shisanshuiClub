using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

public class Packager {
    public static string platform = string.Empty;
    static List<string> paths = new List<string>();
    static List<string> files = new List<string>();

    ///-----------------------------------------------------------
    static string[] exts = { ".txt", ".xml", ".lua", ".assetbundle", ".json" };
    static bool CanCopy(string ext) {   //能不能复制
        foreach (string e in exts) {
            if (ext.Equals(e)) return true;
        }
        return false;
    }

    /// <summary>
    /// 载入素材
    /// </summary>
    static UnityEngine.Object LoadAsset(string file) {
        if (file.EndsWith(".lua")) file += ".txt";
        return AssetDatabase.LoadMainAssetAtPath("Assets/Builds/" + file);
    }

    /// <summary>
    /// 生成绑定素材
    /// </summary>
    //[MenuItem("Game/Copy Lua And Config Files")]
    public static void BuildAssetResource() {
        GenVersionNO();

        HandleLuaFile();
        HandleLocalConfigFiles("LocalConfig");
        HandleLocalConfigFiles("ProtobufDataConfig");
        AssetDatabase.Refresh();
        GenerateFileCopyList();
    }

    /// <summary>
    /// 处理Lua文件
    /// </summary>
    static void HandleLuaFile() {
        string resPath = (Application.dataPath + "/Resources").ToLower();
        string luaPath = resPath + "/XY_Lua/";

        //----------复制Lua文件----------------
        if (Directory.Exists(luaPath)) {
            Directory.Delete(luaPath, true);
        }
        Directory.CreateDirectory(luaPath);

        paths.Clear(); files.Clear();
        string luaDataPath = Application.dataPath + "/XY_Lua/".ToLower();
        Recursive(luaDataPath);
        foreach (string f in files) {
            if (f.EndsWith(".meta")) continue;
            string newfile = f.Replace(luaDataPath, "");
            string newpath = luaPath + newfile;
            newpath = newpath.Replace(".lua", ".txt");
            string path = Path.GetDirectoryName(newpath);
            if (!Directory.Exists(path)) Directory.CreateDirectory(path);
            File.Copy(f, newpath, true);
        }
        AssetDatabase.Refresh();
    }

    static void GenVersionNO()
    {
        string luaDataPath = Application.dataPath + "/XY_Lua/".ToLower();
        string verTextPath = Application.dataPath + "/version.txt";
        string batVerPath = Application.dataPath + "/GetSshineInfo.bat";
        if (File.Exists(verTextPath))
        {
            File.Delete(verTextPath);
            while (File.Exists(verTextPath))
            {
            }
        }

        Process.Start(batVerPath);
        while (!File.Exists(verTextPath)) {
        }
        System.Threading.Thread.Sleep(3000);

        string verStr = File.ReadAllText(verTextPath);
        if (verStr == "")
        {
            return;
        }
        int nBegin = verStr.IndexOf("Revision:");
        if (nBegin == -1)
        {
            return;
        }

        int nEnd = verStr.IndexOf("\r\n", nBegin);
        string sshineVer = "\"" + verStr.Substring(nBegin + 9, nEnd-nBegin-9);

        nBegin = verStr.IndexOf("Last Changed Date: ");
        nEnd = verStr.IndexOf(" +0800", nBegin);
        sshineVer += "\\n" + verStr.Substring(nBegin, nEnd - nBegin) + "\"";

        string luaVerPath = luaDataPath + "logic/sshine_version.lua";
        if (File.Exists(luaVerPath))
        {
            File.Delete(luaVerPath);
            System.Threading.Thread.Sleep(1000);
        }
        File.WriteAllText(luaVerPath, "CurSshineVer=" + sshineVer, Encoding.UTF8);

        while (!File.Exists(luaVerPath))
        {
        }
        System.Threading.Thread.Sleep(2000);
    }
    /// <summary>
    /// 处理本地配置文件
    /// </summary>
    static void HandleLocalConfigFiles(string folderPath)
    {
        string srcPrefix = Application.dataPath + "/Resources/";
        string dstPrefix = Application.dataPath + "/StreamingAssets/";

        string oldLocalConfigPath = srcPrefix + folderPath;
        string newlocalConfigPath = dstPrefix + folderPath;

        if (Directory.Exists(newlocalConfigPath))
        {
            Directory.Delete(newlocalConfigPath, true);
        }

        Directory.CreateDirectory(newlocalConfigPath);

        List<string> configFiles = new List<string>();
        DirectoryInfo directory = new DirectoryInfo(oldLocalConfigPath);
        FileInfo[] dirs = directory.GetFiles("*.*", SearchOption.AllDirectories);

        foreach (FileInfo info in dirs)
        {
            string fullname = info.FullName.Replace('\\', '/');
            if (fullname.Contains(".meta"))
            {
                continue;
            }

            configFiles.Add(fullname);
        }

        foreach (string f in configFiles)
        {
            string newfile = f.Replace(oldLocalConfigPath, "");
            string newpath = newlocalConfigPath + newfile;
            string path = Path.GetDirectoryName(newpath);
            if (!Directory.Exists(path)) Directory.CreateDirectory(path);
            File.Copy(f, newpath, true);
        }

        AssetDatabase.Refresh();
    }

    /// <summary>
    /// 生成文件列表，用于在首次运行时，从streamAssetsPath拷贝到PersistentPath
    /// </summary>
    static void GenerateFileCopyList()
    {
        string streamAssetPath = Application.dataPath + "/StreamingAssets";

        string newFilePath = streamAssetPath + "/files.txt";
        if (File.Exists(newFilePath)) File.Delete(newFilePath);

        DirectoryInfo directory = new DirectoryInfo(streamAssetPath);
        FileInfo[] dirs = directory.GetFiles("*.*", SearchOption.AllDirectories);
        List<string> fileList = new List<string>();

        foreach (FileInfo info in dirs)
        {
            bool isIgnoreFile = false;
            foreach (string ignoreInfo in IGNORE_FOLDERS)
            {
                if (info.FullName.Contains(ignoreInfo))
                {
                    isIgnoreFile = true;
                }
            }

            foreach (string ignoreSuffix in IGNORE_FILE_SUFFIX_ARR)
            {
                if (info.FullName.Contains(ignoreSuffix))
                {
                    isIgnoreFile = true;
                }
            }

            if (isIgnoreFile)
            {
                continue;
            }

            string fullname = info.FullName.Replace('\\', '/');
            fileList.Add(fullname);
        }


        FileStream fs = new FileStream(newFilePath, FileMode.CreateNew);
        StreamWriter sw = new StreamWriter(fs);
        for (int i = 0; i < fileList.Count; i++)
        {
            string file = fileList[i];
            string md5 = Util.md5file(file);
            string value = file.Replace(streamAssetPath, string.Empty);
            if (value.StartsWith("/"))
            {
                value = value.Remove(0,1);
            }
            
            sw.WriteLine(value + "|" + md5);
        }
        sw.Close(); fs.Close();

    }

    /// <summary>
    /// 数据目录
    /// </summary>
    static string AppDataPath {
        get { return Application.dataPath.ToLower(); }
    }

    /// <summary>
    /// 遍历目录及其子目录
    /// </summary>
    static void Recursive(string path) {
        string[] names = Directory.GetFiles(path);
        string[] dirs = Directory.GetDirectories(path);
        foreach (string filename in names) {
            string ext = Path.GetExtension(filename);
            if (ext.Equals(".meta")) continue;
            files.Add(filename.Replace('\\', '/'));
        }
        foreach (string dir in dirs) {
            paths.Add(dir.Replace('\\', '/'));
            Recursive(dir);
        }
    }

    static string[] IGNORE_FOLDERS = { "FMODE", };
    static string[] IGNORE_FILE_SUFFIX_ARR = new string[]{
		".meta",
		".cs",
		".cg",
		".js",
		".shader",
        ".mp4"
	};
}