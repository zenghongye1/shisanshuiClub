using System.IO;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
using System.Collections.Generic;
using LitJson;

namespace XYHY.ABSystem
{
    public class VerConf
    {
        public string fileName = "";
        public string versionNum = "";
        public string fullDir = "";
        public string id = "";
        public string depFileName = "";
        public bool m_IsSelect = true;
        public bool isApp = false;
        //是否随包
        public bool isInPackage = false;

        public string GetDirName()
        {
            return Path.GetFileName(fullDir);
        }
    }

    public class AssetBundleBuildPanel : EditorWindow
    {
        //是否打资源包至StreamingAssets目录下
        public static bool BuildABsToStreamingAssets = true;

        //public static string versionNum = "1.0.0";

        //public static Dictionary<string, string> dicVersion = new Dictionary<string, string>();
        public static string appid = "1";

        public static List<VerConf> verConfLst = new List<VerConf>();

        public readonly string ResRootDir = "/Res_XYHY";

        AssetBundlePathResolver pathResolver = new AssetBundlePathResolver();

        [MenuItem("ABSystem/Builder Panel")]
        static void Open()
        {
            GetWindow<AssetBundleBuildPanel>("ABSystem", true);
        }

        [MenuItem("ABSystem/Builde AssetBundles")]
        public static void BuildAssetBundles()
        {
            AssetBundleBuildConfig config = LoadAssetAtPath<AssetBundleBuildConfig>(savePath);

            if (config == null)
                return;

#if UNITY_5
			ABBuilder builder = new AssetBundleBuilder5x(new AssetBundlePathResolver());
#else
			ABBuilder builder = new AssetBundleBuilder4x(new AssetBundlePathResolver());
#endif
            builder.SetDataWriter(config.depInfoFileFormat == AssetBundleBuildConfig.Format.Text ? new AssetBundleDataWriter() : new AssetBundleDataBinaryWriter());

            builder.Begin();

            for (int i = 0; i < config.filters.Count; i++)
            {
                AssetBundleFilter f = config.filters[i];
                if (f.valid)
                {
                    builder.AddRootTargets(new DirectoryInfo(f.path), f.filterType, f.filterArray);
                }
                //if (f.valid)
                //    builder.AddRootTargets(new DirectoryInfo(f.path), new string[] { f.filter });
            }            
            
            builder.Export();
            builder.End();
        }

        public static void BuildSingleAssetBundlePath(string path)
        {
            AssetBundleBuildConfig config = LoadAssetAtPath<AssetBundleBuildConfig>(savePath);

            if (config == null)
                return;

#if UNITY_5
            ABBuilder builder = new AssetBundleBuilder5x(new AssetBundlePathResolver());
#else
			ABBuilder builder = new AssetBundleBuilder4x(new AssetBundlePathResolver());
#endif
            builder.SetDataWriter(config.depInfoFileFormat == AssetBundleBuildConfig.Format.Text ? new AssetBundleDataWriter() : new AssetBundleDataBinaryWriter());

            builder.Begin();

            string fileName = Path.GetFileName(path);

            bool isApp = fileName.Contains("app");

            for (int i = 0; i < config.filters.Count; i++)
            {
                AssetBundleFilter f = config.filters[i];
                if (f.valid)
                {
                    builder.AddRootTargets(new DirectoryInfo(path), FilterType.Asset, f.filterArray);

                    // app 添加lua和config 打包
                    if (isApp && f.filterType == FilterType.ConfAndLua)
                    {
                        builder.AddRootTargets(new DirectoryInfo(f.path), f.filterType, f.filterArray);
                    }
                }
                //if (f.valid)
                //    builder.AddRootTargets(new DirectoryInfo(f.path), new string[] { f.filter });
            }

            builder.Export();
            builder.End();
        }



        static T LoadAssetAtPath<T>(string path) where T:Object
		{
#if UNITY_5
			return AssetDatabase.LoadAssetAtPath<T>(savePath);
#else
			return (T)AssetDatabase.LoadAssetAtPath(savePath, typeof(T));
#endif
		}

        const string savePath = "Assets/XY_Scripts/BasicSystem/ABSystem/config.asset";

        private AssetBundleBuildConfig _config;
        private ReorderableList _list;
        private Vector2 _scrollPosition = Vector2.zero;

        
        private ReorderableList _verList;

        AssetBundleBuildPanel()
        {

        }

        void OnVerLstElementGUI(Rect rect, int index, bool isactive, bool isfocused)
        {
            const float GAP = 5;
            VerConf verConf = verConfLst[index];

            rect.y++;
            Rect r = rect;
            r.width = 150;
            r.height = 18;            
            verConf.fileName = GUI.TextField(r, verConf.fileName);

            r.xMin = r.xMax + GAP;
            r.xMax = rect.xMax - r.xMin - GAP - 60;
            verConf.versionNum = GUI.TextField(r, verConf.versionNum);

            r.xMin = r.xMax + GAP;
            r.xMax = r.xMin + 20;
            verConf.m_IsSelect = GUI.Toggle(r, verConf.m_IsSelect, "");

            r.xMin = r.xMax + GAP;
            r.xMax = r.xMin + 80;
            if(GUI.Button(r, "build"))
            {
                BuildSingleAssetBundlePath(verConf.fullDir);
            }
        }

        void OnListElementGUI(Rect rect, int index, bool isactive, bool isfocused)
        {
            const float GAP = 5;

            AssetBundleFilter filter = _config.filters[index];
            rect.y++;

            Rect r = rect;
            r.width = 16;
            r.height = 18;
            filter.valid = GUI.Toggle(r, filter.valid, GUIContent.none);

            r.xMin = r.xMax + GAP;
            r.xMax = rect.xMax - 400;
            GUI.enabled = false;
            filter.path = GUI.TextField(r, filter.path);
            GUI.enabled = true;

            r.xMin = r.xMax + GAP;
            r.width = 50;
            if (GUI.Button(r, "Select"))
            {
                var path = SelectFolder();
                if (path != null)
                    filter.path = path;
            }

            for(int i= 0; i<filter.filterArray.Length; i++)
            {
                r.xMin = r.xMax + GAP;
                r.xMax = r.xMin + 50;
                filter.filterArray[i] = GUI.TextField(r, filter.filterArray[i]);
            }
            
            r.xMin = r.xMax + GAP;
            r.width = 50;
            if (GUI.Button(r, "+"))
            {            
                ArrayUtility.Add(ref filter.filterArray, "");
            }
            r.xMin = r.xMax + GAP;
            r.width = 50;
            if (GUI.Button(r, "-"))
            {              
                ArrayUtility.RemoveAt(ref filter.filterArray, filter.filterArray.Length - 1);
            }
        }

        string SelectFolder()
        {
            string dataPath = Application.dataPath;
            string selectedPath = EditorUtility.OpenFolderPanel("Path", dataPath, "");
            if (!string.IsNullOrEmpty(selectedPath))
            {
                if (selectedPath.StartsWith(dataPath))
                {
                    return "Assets/" + selectedPath.Substring(dataPath.Length + 1);
                }
                else
                {
                    ShowNotification(new GUIContent("不能在Assets目录之外!"));
                }
            }
            return null;
        }

        void OnVerLstHeaderGUI(Rect rect)
        {
            EditorGUI.LabelField(rect, "Version Edit");
        }

        void OnListHeaderGUI(Rect rect)
        {
            EditorGUI.LabelField(rect, "Asset Filter");
        }

        void InitConfig()
        {
            _config = LoadAssetAtPath<AssetBundleBuildConfig>(savePath);
            if (_config == null)
            {
                _config = new AssetBundleBuildConfig();
            }
        }
      

        void InitVerListDrawer()
        {
            _verList = new ReorderableList(verConfLst, typeof(VerConf));
            _verList.drawElementCallback = OnVerLstElementGUI;
            _verList.drawHeaderCallback = OnVerLstHeaderGUI;
            _verList.draggable = true;
            _verList.elementHeight = 22;
            _verList.onAddCallback = (list) => verLstAdd();
        }

        void InitFilterListDrawer()
        {
            _list = new ReorderableList(_config.filters, typeof(AssetBundleFilter));
            _list.drawElementCallback = OnListElementGUI;
            _list.drawHeaderCallback = OnListHeaderGUI;
            _list.draggable = true;
            _list.elementHeight = 22;
            //_list.onAddCallback = (list) => Add();
        }

        void verLstAdd()
        {
            //VerConf verConf = new VerConf();
            //verConfLst.Add(verConf);
        }

        void Add()
        {
            string path = SelectFolder();
            if (!string.IsNullOrEmpty(path))
            {
                var filter = new AssetBundleFilter();
                filter.path = path;
                _config.filters.Add(filter);
            }
        }

        void InitVerConfs()
        {
            string appcfg = FileUtils.GetAppConfData("config/app_config.txt");
            JsonData appData = JsonMapper.ToObject(appcfg);
            List<string> verFileList = new List<string>();

            for (int i = 0; i < appData["verFileNameLst"].Count; i++)
            {
                verFileList.Add(appData["verFileNameLst"][i].ToString());
            }

            string resFullpath = Application.dataPath + ResRootDir;
            var resdirs = Directory.GetDirectories(resFullpath, "*", SearchOption.TopDirectoryOnly);
            foreach(string dir in resdirs)
            {
                string dirName = Path.GetFileName(dir);
                string[] patterns = dirName.Split('_');
                if(patterns.Length != 2 || (patterns[0] != "app" && patterns[0] != "game"))
                {
                    Debug.LogError(dir);
                    continue;
                }


                var ver = new VerConf();
                ver.fileName = "ver_" + dirName + ".txt";
                ver.versionNum = GetVerNum(ver.fileName);
                ver.fullDir = dir;
                ver.id = patterns[1];
                ver.depFileName = "dep_" + dirName + ".all";
                if (verFileList.Contains(ver.fileName))
                {
                    ver.isInPackage = true;
                }
                else
                    ver.isInPackage = false;
                verConfLst.Add(ver);

                if(patterns[0] == "app")
                {
                    ver.isApp = true;
                    appid = patterns[1];
                }
            }
        }


        string GetVerNum(string fileName)
        {
            string verNum = "0.0.0";
            string streamingVerFileUrl = string.Format("/{0}/{1}", AssetBundlePathResolver.instance.BundlePlatformStr, AssetBundlePathResolver.instance.BundleSaveDirName);
            if (Directory.Exists(Application.streamingAssetsPath + streamingVerFileUrl))
            {
                VersionInfo verInfo = FileUtils.GetGameVerNo(fileName);
                if(verInfo != null)
                {
                    verNum = verInfo.VersionNum;
                }
            }

            return verNum;
        }

        string GetUpdateVer()
        {
            string ver = "";
            for (int i = 0; i < verConfLst.Count; i++)
            {
                if (verConfLst[i].isApp)
                {
                    ver = verConfLst[i].versionNum;
                    break;
                }
            }
            return ver;
        }

        void ExportAllBundlesAndCodes()
        {
            string destPath = AssetBundlePathResolver.instance.BundlesAllExportPath;
            string destLuaPath = destPath + "/AssetBundles/Lua";
            string destDataPath = destPath + "/AssetBundles/ProtobufDataConfig";
            if (Directory.Exists(destPath))
                Directory.Delete(destPath, true);

            CopyDirectory(AssetBundlePathResolver.instance.BundleSaveFullPath, destPath);
            Debug.Log("复制全部ab完成");
            CopyDirectory(AssetBundlePathResolver.instance.LuaBytesPath, destLuaPath);
            Debug.Log("复制Lua完成");
            CopyDirectory(AssetBundlePathResolver.instance.ProtobufDataPath, destDataPath);
            Debug.Log("复制ProtobufDataConfig完成");
        }

        void ExportAndDeleteGamesBundles()
        {
            string destPath = AssetBundlePathResolver.instance.BundlesGameExportPath + "AssetBundles/";
            string srcPath = AssetBundlePathResolver.instance.BundleSaveFullPath + "AssetBundles/";
            for (int i = 0; i < verConfLst.Count; i++)
            {
                if(!verConfLst[i].isInPackage)
                {
                    CopyDirectory(AssetBundlePathResolver.instance.BundleSaveFullPath + "AssetBundles/game_" + verConfLst[i].id, destPath + "game_" + verConfLst[i].id);
                    if (File.Exists(srcPath + verConfLst[i].fileName))
                    {
                        File.Copy(srcPath + verConfLst[i].fileName, destPath + verConfLst[i].fileName, true);
                        File.Delete(srcPath + verConfLst[i].fileName);
                    }

                    if (File.Exists(srcPath + verConfLst[i].depFileName))
                    {
                        File.Copy(srcPath + verConfLst[i].depFileName, destPath + verConfLst[i].depFileName, true);
                        File.Delete(srcPath + verConfLst[i].depFileName);
                    }

                    if(Directory.Exists(AssetBundlePathResolver.instance.BundleSaveFullPath + "AssetBundles/game_" + verConfLst[i].id))
                        Directory.Delete(AssetBundlePathResolver.instance.BundleSaveFullPath + "AssetBundles/game_" + verConfLst[i].id, true);
                }
            }
            AssetDatabase.Refresh();
            Debug.Log("备份及删除子游戏完成");
        }


        /// <summary>
        /// 复制文件夹（及文件夹下所有子文件夹和文件）
        /// </summary>
        /// <param name="sourcePath">待复制的文件夹路径</param>
        /// <param name="destinationPath">目标路径</param>
        public void CopyDirectory(string sourcePath, string destinationPath)
        {
            DirectoryInfo info = new DirectoryInfo(sourcePath);
            if(!info.Exists)
            {
                return;
            }
            Directory.CreateDirectory(destinationPath);
            foreach (FileSystemInfo fsi in info.GetFileSystemInfos())
            {
                string destName = Path.Combine(destinationPath, fsi.Name);

                if (fsi is FileInfo)          //如果是文件，复制文件
                {
                    if (fsi.Extension == ".txt" || fsi.Extension == ".ab" || fsi.Extension == ".all" || fsi.Extension == ".bytes")
                    {
                        File.Copy(fsi.FullName, destName, true);
                    }
                }
                else                                    //如果是文件夹，新建文件夹，递归
                {
                    Directory.CreateDirectory(destName);
                    CopyDirectory(fsi.FullName, destName);
                }
            }
        }


        void ExportGamesHotUpdateBundles()
        {
            AssetBundleDataReader _streamDepData = new AssetBundleDataReader();
            AssetBundleDataReader _cacheDepData = new AssetBundleDataReader();
            List<string> depFileList = new List<string>();
            List<string> verFileList = new List<string>();
            for (int i = 0; i < verConfLst.Count; i++)
            {
                if(!verConfLst[i].isInPackage)
                {
                    depFileList.Add(verConfLst[i].depFileName);
                    verFileList.Add(verConfLst[i].fileName);
                }
            }
            bool streamSuc, cacheSuc;
            streamSuc = LoadDepInfos(_streamDepData, AssetBundlePathResolver.instance.BundleSaveFullPath + "AssetBundles", depFileList);
            cacheSuc = LoadDepInfos(_cacheDepData, AssetBundlePathResolver.instance.DependenceCahcePath, depFileList);
            if (!streamSuc || !cacheSuc)
                return;

            List<AssetBundleData> changeList = new List<AssetBundleData>();
            List<AssetBundleData> removeList = new List<AssetBundleData>();
            Diff(_streamDepData, _cacheDepData, ref changeList, ref removeList);

            if (changeList.Count == 0)
            {
                Debug.LogError("没有更新文件");
                return;
            }


            string ver = GetUpdateVer();
            if (ver == "")
            {
                Debug.LogError("请先设置版本信息");
                return;
            }

            ver = "gid/" + ver;
            // 拷贝差异文件
            CopyDiffFile(ver, changeList);
            // game没有加载app_4的依赖  暂时不能删除
            //删除不用的ab
            //RemoveUsedBundles(removeList);
            //复制依赖和版本文件（无法判断abdata是哪个dep文件 所以暂时全部拷贝过去）
            CopyDepAndVerFiles(ver, verFileList, depFileList);

        }

        void ExportMainHotUpdateBundlesAndCodes()
        {
            AssetBundleDataReader _streamDepData = new AssetBundleDataReader();
            AssetBundleDataReader _cacheDepData = new AssetBundleDataReader();
            string appcfg = FileUtils.GetAppConfData("config/app_config.txt");
            JsonData appData = JsonMapper.ToObject(appcfg);
            List<string> depFileList = new List<string>();
            List<string> verFileList = new List<string>();
            for(int i = 0; i < appData["depFileNameLst"].Count; i++)
            {
                depFileList.Add(appData["depFileNameLst"][i].ToString());
            }

            for(int i = 0; i < appData["verFileNameLst"].Count; i++)
            {
                verFileList.Add(appData["verFileNameLst"][i].ToString());
            }

            bool streamSuc, cacheSuc;
            streamSuc = LoadDepInfos(_streamDepData, AssetBundlePathResolver.instance.BundleSaveFullPath + "AssetBundles", depFileList);
            cacheSuc = LoadDepInfos(_cacheDepData, AssetBundlePathResolver.instance.DependenceCahcePath, depFileList);
            if (!streamSuc || !cacheSuc)
                return;

            List<AssetBundleData> changeList = new List<AssetBundleData>();
            List<AssetBundleData> removeList = new List<AssetBundleData>();
            Diff(_streamDepData, _cacheDepData, ref changeList, ref removeList);

            if(changeList.Count == 0 )
            {
                Debug.LogError("没有更新文件");
                return;
            }

            string ver = GetUpdateVer();
            if (ver == "")
            {
                Debug.LogError("请先设置版本信息");
                return;
            }

            // 拷贝差异文件
            CopyDiffFile(ver, changeList);
            //删除不用的ab
            RemoveUsedBundles(removeList);
            //复制依赖和版本文件（无法判断abdata是哪个dep文件 所以暂时全部拷贝过去）
            CopyDepAndVerFiles(ver, verFileList, depFileList);
        }

        void RemoveUsedBundles(List<AssetBundleData> removeList)
        {
            string streamFileDir = AssetBundlePathResolver.instance.BundleSaveFullPath + "/Assetbundles/";
            string bytesFileDir = Application.dataPath + "/Resources/";
            for (int i = 0; i < removeList.Count; i++)
            {
                //暂时不删除
                //var abData = removeList[i];
                //if (abData.debugName.EndsWith(".bytes"))
                //{
                //    string srcPath = bytesFileDir + abData.debugName;
                //    if(File.Exists(srcPath))
                //        File.Delete(srcPath);
                //    Debug.LogError("删除"+srcPath);
                //}
                //else
                //{
                //    string srcPath = streamFileDir + abData.belongName + "/" + abData.fullName;
                //    if (File.Exists(srcPath))
                //        File.Delete(srcPath);
                //    Debug.LogError("删除" + srcPath);
                //}
            }
        }

        void CopyDepAndVerFiles(string ver, List<string> verFileList, List<string> depFileList)
        {
            string streamFileDir = AssetBundlePathResolver.instance.BundleSaveFullPath + "/Assetbundles/";
            string exportDir = AssetBundlePathResolver.instance.GetBundlesHotUpdateExportPath(ver);
            for(int i = 0; i < verFileList.Count; i++)
            {
                string srcPath = streamFileDir + verFileList[i];
                string destPath = exportDir + verFileList[i];
                if(File.Exists(srcPath))
                {
                    File.Copy(srcPath, destPath, true);
                }
            }

            for (int i = 0; i < depFileList.Count; i++)
            {
                string srcPath = streamFileDir + depFileList[i];
                string destPath = exportDir + depFileList[i];
                if (File.Exists(srcPath))
                {
                    File.Copy(srcPath, destPath, true);
                }
            }

            Debug.Log("复制依赖和版本文件完成");
        }


        void CopyDiffFile(string version, List<AssetBundleData> changeList)
        {
            string exportDir = AssetBundlePathResolver.instance.GetBundlesHotUpdateExportPath(version);
            string bytesFileDir = Application.dataPath + "/Resources/";
            if(Directory.Exists(exportDir))
            {
                Directory.Delete(exportDir, true);
            }
            Directory.CreateDirectory(exportDir);
            string streamFileDir = AssetBundlePathResolver.instance.BundleSaveFullPath + "/Assetbundles/";
            for(int i = 0; i < changeList.Count; i++)
            {
                var abData = changeList[i];
                //lua && protobufdata
                if(abData.debugName.EndsWith(".bytes"))
                {
                    string destPath = exportDir + abData.fullName;
                    string destDir = Path.GetDirectoryName(destPath);
                    string srcPath = bytesFileDir + abData.fullName;
                    if (!Directory.Exists(destDir))
                        Directory.CreateDirectory(destDir);
                    if(File.Exists(srcPath))
                    {
                        File.Copy(srcPath, destPath);
                        Debug.Log("copy" + srcPath);
                    }
                    else
                    {
                        Debug.LogError("找不到" + srcPath);
                    }
                }
                else
                {
                    string srcPath = streamFileDir + abData.belongName + "/" + abData.fullName;
                    if(!Directory.Exists(exportDir + "/" + abData.belongName))
                    {
                        Directory.CreateDirectory(exportDir + "/" + abData.belongName);
                    }
                    string destPath = exportDir + abData.belongName + "/" + abData.fullName;
                    if (File.Exists(srcPath))
                    {
                        File.Copy(srcPath, destPath);
                        Debug.Log("copy" + srcPath);
                    }
                    else
                    {
                        Debug.LogError("找不到" + srcPath);
                    }
                }

            }
        }

        void Diff(AssetBundleDataReader streamDepData, AssetBundleDataReader cacheDepData, ref List<AssetBundleData> changeList, ref List<AssetBundleData> removeList)
        {
            foreach(string key in streamDepData.infoMap.Keys)
            {
                if (!cacheDepData.infoMap.ContainsKey(key) || streamDepData.infoMap[key].hash != cacheDepData.infoMap[key].hash)
                    changeList.Add(streamDepData.infoMap[key]);
            }
            foreach(string key in  cacheDepData.infoMap.Keys)
            {
                if(!streamDepData.infoMap.ContainsKey(key))
                {
                    removeList.Add(cacheDepData.infoMap[key]);
                }
            }
        }

        bool LoadDepInfos(AssetBundleDataReader dataReader, string fileDir, List<string> fileNames)
        {
            for(int i = 0; i < fileNames.Count; i++)
            {
                string filePath = Path.Combine(fileDir, fileNames[i]);
                if (!File.Exists(filePath))
                {
                    Debug.LogError("未找到" + filePath);
                    return false;
                }
                FileStream fs = File.Open(filePath, FileMode.Open, FileAccess.ReadWrite);
                dataReader.Read(fs);
                fs.Close();
            }
            return true;
        }

        void CopyDeps()
        {
            //@todo  随包和不随包的dep文件分开处理
            if(verConfLst== null || verConfLst.Count == 0)
                return;
            string ver = GetUpdateVer();
            if (ver == "")
            {
                Debug.LogError("请先设置ver文件");
                return;
            }
            string desDir = AssetBundlePathResolver.instance.DependenceCahcePath;
            if (!Directory.Exists(desDir))
                Directory.CreateDirectory(desDir);

            var depFiles = Directory.GetFiles(AssetBundlePathResolver.instance.BundleSaveFullPath + "AssetBundles/", "*.all");
            if(depFiles == null || depFiles.Length == 0)
            {
                Debug.LogError("未找到dep文件，请先打包");
                return;
            }

            string verPath = desDir + "v" + ver;
            if (!Directory.Exists(verPath))
            {
                Directory.CreateDirectory(verPath);
            }


            for (int i = 0; i < depFiles.Length; i++)
            {
                string fileName = Path.GetFileName(depFiles[i]);
                File.Copy(depFiles[i], Path.Combine(verPath, fileName), true);
                File.Copy(depFiles[i], Path.Combine(desDir, fileName), true);
            }
            AssetDatabase.Refresh();
            Debug.Log("复制完成");
        }

        private void OnEnable()
        {
            InitVerConfs();
//            string streamingVerFileUrl = string.Format("/{0}/{1}", AssetBundlePathResolver.instance.BundlePlatformStr, AssetBundlePathResolver.instance.BundleSaveDirName);
//            if (Directory.Exists(Application.streamingAssetsPath + streamingVerFileUrl))
//            {
//                string[] fileNames = Directory.GetFiles(Application.streamingAssetsPath + streamingVerFileUrl, "ver_*.txt");

            //                for (int i = 0; i < fileNames.Length; i++)
            //                {
            //#if UNITY_ANDROID || (AB_WINDOW && UNITY_STANDALONE)
            //                    string fileName = fileNames[i].Split('\\')[1];
            //#elif UNITY_IOS || UNITY_IPHONE
            //                    string fileName = fileNames[i].Substring(fileNames[i].IndexOf("AssetBundles"));
            //                    fileName = fileName.Split('/')[1];
            //#else
            //                    string fileName = "";
            //#endif
            //                    VersionInfo _verInfo = FileUtils.GetGameVerNo(fileName);
            //                    if (_verInfo != null)
            //                    {
            //                        VerConf verConf = new VerConf();
            //                        verConf.fileName = fileName;
            //                        verConf.versionNum = _verInfo.VersionNum;
            //                        verConfLst.Add(verConf);

            //                        appid = _verInfo.appID;




            //                        string str = fileName.Split('_')[2];
            //                        string gid = "";
            //                        if (!string.IsNullOrEmpty(str))
            //                        {
            //                            gid = str.Split('.')[0];
            //                        }

            //                        if (!string.IsNullOrEmpty(gid) && fileName.IndexOf("ver_game_") >= 0)
            //                        {
            //                            string gameFolder = pathResolver.BundleSavePath + "/game_" + gid;
            //                            if (!Directory.Exists(gameFolder))
            //                            {
            //                                verConf.m_IsSelect = false;
            //                            }
            //                        }
            //                    }
            //                }
            //            }           
        }

        private void OnDisable()
        {
            verConfLst.Clear();
        }

        int toolbar = 0;
        void OnGUI()
        {
            if (_config == null)
            {
                InitConfig();
            }

            if (_verList == null)
            {
                InitVerListDrawer();
            }

            if (_list == null)
            {
                InitFilterListDrawer();
            }

            bool execBuild = false;
            //tool bar
            GUILayout.BeginHorizontal(EditorStyles.toolbar);
            {
                if (GUILayout.Button("Add", EditorStyles.toolbarButton))
                {
                    Add();
                }
                if (GUILayout.Button("Save", EditorStyles.toolbarButton))
                {
                    Save();
                }
                if (GUILayout.Button("一键打包", EditorStyles.toolbarButton))
                {
                    AutoBuild();
                }
                GUILayout.FlexibleSpace();
                if (GUILayout.Button("Build", EditorStyles.toolbarButton))
                {
                    execBuild = true;
                }
            }
            GUILayout.EndHorizontal();
            //context
            GUILayout.BeginVertical();
            {
                BuildABsToStreamingAssets = EditorGUILayout.Toggle("是否编内置资源包", BuildABsToStreamingAssets);
                //format
                GUILayout.BeginHorizontal();
                {
                    EditorGUILayout.PrefixLabel("DepInfoFileFormat");
                    _config.depInfoFileFormat = (AssetBundleBuildConfig.Format)EditorGUILayout.EnumPopup(_config.depInfoFileFormat);
                }
                GUILayout.EndHorizontal();

                GUILayout.BeginHorizontal();
                {
                    EditorGUILayout.PrefixLabel("APPID");
                    appid = EditorGUILayout.TextField(appid);
                }
                GUILayout.EndHorizontal();

                //versionNum Edit List
                GUILayout.Space(10);
                _scrollPosition = GUILayout.BeginScrollView(_scrollPosition);
                {
                    _verList.DoLayoutList();
                }
                GUILayout.EndScrollView();


                GUILayout.BeginHorizontal();
                if(GUILayout.Button("复制整包资源"))
                {
                    ExportAllBundlesAndCodes();
                }

                if(GUILayout.Button("导出主热更资源"))
                {
                    ExportMainHotUpdateBundlesAndCodes();
                }

                if(GUILayout.Button("导出game热更资源换"))
                {
                    ExportGamesHotUpdateBundles();
                }

                if (GUILayout.Button("复制备份依赖文件"))
                {
                    CopyDeps();
                }

                if (GUILayout.Button("删除Games并备份"))
                {
                    ExportAndDeleteGamesBundles();
                }
         
                GUILayout.EndHorizontal();

                /*GUILayout.BeginHorizontal();
                {                    
                    if (_verList == null)
                    {
                        InitVerListDrawer();
                    }

                    EditorGUILayout.PrefixLabel("VersionNum");                    
                    VersionInfo verInfo = FileUtils.GetGameVerNo(pathResolver.VerCommSaveFile); 
                    if (verInfo != null)
                    {
                        _config.versionNum = verInfo.VersionNum;
                    }   
                    else
                    {
                        _config.versionNum = "1.0.0";
                    }                                    
                    _config.versionNum = EditorGUILayout.TextField(_config.versionNum);

                    versionNum = _config.versionNum;
                }
                GUILayout.EndHorizontal(); */


                GUILayout.Space(10);

                //Filter item list
                _scrollPosition = GUILayout.BeginScrollView(_scrollPosition);
                {
                    _list.DoLayoutList();
                }
                GUILayout.EndScrollView();
            }
            GUILayout.EndVertical();

            //set dirty
            if (GUI.changed)
                EditorUtility.SetDirty(_config);

            if (execBuild)
                Build();
        }


        private void Build()
        {
            Save();
            BuildAssetBundles();
            AssetDatabase.Refresh();
        }

        //一键打出工程包
        private void AutoBuild()
        {
            ToLuaMenu.CopyLuaFilesToRes();//复制lua文件
            Build();//打包ab资源
            RemoveUnSelectGame();
           
            YX_PublishTools.Publish();
        }
        //移除没有被勾选的资源
        private void RemoveUnSelectGame()
        {
            foreach(VerConf conf in verConfLst)
            {
                if (conf.m_IsSelect == false)
                {
                    //     Debug.LogError("++++++" + pathResolver.BundleSavePath);
                    string fileName = conf.fileName;
                    string str = fileName.Split('_')[2];
                    string gid = "";
                    if (!string.IsNullOrEmpty(str))
                    {
                        gid = str.Split('.')[0];
                    }
                  
                    if (!string.IsNullOrEmpty(gid))
                    {
                        string gameFolder = pathResolver.BundleSavePath + "/game_" + gid;
                        if (Directory.Exists(gameFolder))
                        {
                            Directory.Delete(gameFolder, true);
                       
                        }

                        string fileNameStr = pathResolver.BundleSavePath + "/dep_game_" + gid + ".all";
                        if (File.Exists(fileNameStr))
                        {
                            string[] files = Directory.GetFiles(pathResolver.BundleSavePath, "dep_game_" + gid + ".all", SearchOption.TopDirectoryOnly);
                            for (int i = 0; i < files.Length; i++)
                            {
                                File.Delete(files[i]);
                            }
                        }

                    }
                }
            
            }
            AssetDatabase.Refresh();
        }

        

        void Save()
        {
            AssetBundlePathResolver.instance = new AssetBundlePathResolver();

            if (LoadAssetAtPath<AssetBundleBuildConfig>(savePath) == null)
            {
                AssetDatabase.CreateAsset(_config, savePath);
            }
            else
            {
                EditorUtility.SetDirty(_config);
            }
        }
    }
}