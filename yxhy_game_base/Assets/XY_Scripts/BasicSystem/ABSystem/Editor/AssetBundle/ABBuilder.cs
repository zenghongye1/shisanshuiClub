using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using LitJson;

namespace XYHY.ABSystem
{
    public class ABBuilder
    {
        protected AssetBundleDataWriter dataWriter = new AssetBundleDataBinaryWriter();
        protected AssetBundlePathResolver pathResolver;

        public ABBuilder() : this(new AssetBundlePathResolver())
        {

        }

        public ABBuilder(AssetBundlePathResolver resolver)
        {
            this.pathResolver = resolver;
            this.InitDirs();
            AssetBundleUtils.pathResolver = pathResolver;
        }

        void InitDirs()
        {
            new DirectoryInfo(pathResolver.BundleSavePath).Create();
            new FileInfo(pathResolver.HashCacheSaveFile).Directory.Create();
        }

        public void Begin()
        {
            EditorUtility.DisplayProgressBar("Loading", "Loading...", 0.1f);

            for(int i=0; i<AssetBundleBuildPanel.verConfLst.Count; i++)
            {
                AssetBundlePathResolver.dicVersion[AssetBundleBuildPanel.verConfLst[i].fileName] = new System.Version(AssetBundleBuildPanel.verConfLst[i].versionNum);
            }

            //AssetBundlePathResolver.version = new System.Version(AssetBundleBuildPanel.versionNum);
            AssetBundleUtils.Init();
        }

        public void End()
        {
            //AssetBundleUtils.SaveCache();
            AssetBundleUtils.ClearCache();
            EditorUtility.ClearProgressBar();
        }

        public virtual void Analyze()
        {
            var all = AssetBundleUtils.GetAll();
            foreach (AssetTarget target in all)
            {
                target.Analyze();
            }
            all = AssetBundleUtils.GetAll();
            foreach (AssetTarget target in all)
            {
                target.Merge();
            }
            all = AssetBundleUtils.GetAll();
            foreach (AssetTarget target in all)
            {
                target.BeforeExport();
            }

            var confAndLua = AssetBundleUtils.GetAllConfAndLua();
            foreach(AssetTarget target in confAndLua)
            {
                target.Analyze();
            }
        }

        public virtual void Export()
        {
            this.Analyze();
        }

        public void AddRootTargets(DirectoryInfo bundleDir, FilterType filterType, string[] partterns = null, SearchOption searchOption = SearchOption.AllDirectories)
        {
            if (partterns == null)
                partterns = new string[] { "*.*" };
            for (int i = 0; i < partterns.Length; i++)
            {
                FileInfo[] prefabs = bundleDir.GetFiles(partterns[i], searchOption);
                foreach (FileInfo file in prefabs)
                {
                    if (file.Extension.Contains("meta"))
                        continue;

                    AssetTarget target = null;
                    switch (filterType)
                    {
                        case FilterType.Asset:
                            target = AssetBundleUtils.Load(file);  
                                                      
                            break;
                        case FilterType.ConfAndLua:
                            target = AssetBundleUtils.LoadConfAndLua(file, null);
                            break;
                    }
                    if (target != null)
                    {
                        target.exportType = AssetBundleExportType.Root;
                    }
                    else
                    {
                        Debug.Log("资源svn冲突或者数据损坏，请检查:" + file);
                    }
                }
            }
        }


        protected void SaveDepAll(List<AssetTarget> all, List<AssetTarget> confAndLua)
        {
            string commDepFileName = "";
            //string[] depFileLst = Directory.GetFiles(pathResolver.BundleSavePath, "dep_*.all");
            //if (depFileLst != null)
            //{
            //    for(int i=0; i<depFileLst.Length; i++)
            //    {
            //        if (File.Exists(depFileLst[i]))
            //        {
            //            File.Delete(depFileLst[i]);
            //        }
            //    }
            //}

            Dictionary<string, List<AssetTarget>> dicExportGameLst = new Dictionary<string, List<AssetTarget>>();
//            string[] dstFileNameLst = Directory.GetDirectories(Application.dataPath + "/Res_XYHY");
//            if (dstFileNameLst != null)
//            {                                
//                for (int i = 0; i < dstFileNameLst.Length; i++)
//                {
////#if UNITY_IOS || UNITY_IPHONE
////                   string directoryName = dstFileNameLst[i].Substring(dstFileNameLst[i].IndexOf("Res_XYHY"));
////                   directoryName = directoryName.Split('/')[1];
////#elif UNITY_ANDROID || (AB_WINDOW && UNITY_STANDALONE)
////                    string directoryName = dstFileNameLst[i].Split('\\')[1];
////#else
////                    string directoryName = "";
////#endif                     
//                    //string key = "dep_" + directoryName + ".all";
//                    dicExportGameLst[key] = new List<AssetTarget>();
//                    if (i==0)
//                    {
//                        commDepFileName = key;
//                    }
//                }
//            }

            for (int i = 0; i < all.Count; i++)
            {
                AssetTarget target = all[i];
                if (target.needSelfExport)
                {
                    string belongPath = "dep_" + target.belongName + ".all";
                    if (dicExportGameLst.ContainsKey(belongPath))
                    {
                        dicExportGameLst[belongPath].Add(target);
                    }
                    else
                    {
                        dicExportGameLst[belongPath] = new List<AssetTarget>();
                        dicExportGameLst[belongPath].Add(target);
                        //if (commDepFileName != "")
                        //    dicExportGameLst[commDepFileName].Add(target);
                    }                   
                }                    
            }

            for (int i = 0; i < confAndLua.Count; i++)
            {
                AssetTarget target = confAndLua[i];
                if (target.needSelfExport)
                {
                    string belongPath = "dep_" + target.belongName + ".all";
                    if (dicExportGameLst.ContainsKey(belongPath))
                    {
                        dicExportGameLst[belongPath].Add(target);
                    }
                    else
                    {
                        dicExportGameLst[belongPath] = new List<AssetTarget>();
                        dicExportGameLst[belongPath].Add(target);
                    }
                }
            }
            AssetBundleDataWriter writer = dataWriter;

            foreach(KeyValuePair<string, List<AssetTarget>> var in dicExportGameLst)
            {
                string path = Path.Combine(pathResolver.BundleSavePath, var.Key);
                writer.Save(path, var.Value.ToArray());

                ////复制至上传服务器的路径
                //string destUrl = string.Format("{0}ver_{1}/{2}/{3}", AssetBundlePathResolver.instance.BundlesPathForServer, AssetBundlePathResolver.version.ToString(), AssetBundlePathResolver.instance.BundlePlatformStr + "/" + AssetBundlePathResolver.instance.BundleSaveDirName, var.Key);
                //string destDir = Path.GetDirectoryName(destUrl);
                //if (!Directory.Exists(destDir))
                //{
                //    Directory.CreateDirectory(destDir);
                //}
                //if (File.Exists(path))
                //{
                //    File.Copy(path, destUrl, true);
                //}
            }
        }

        public void SetDataWriter(AssetBundleDataWriter w)
        {
            this.dataWriter = w;
        }

        /// <summary>
        /// 删除未使用的AB，可能是上次打包出来的，而这一次没生成的
        /// </summary>
        /// <param name="all"></param>
        protected void RemoveUnused(List<AssetTarget> all)
        {
            HashSet<string> usedSet = new HashSet<string>();
            for (int i = 0; i < all.Count; i++)
            {
                AssetTarget target = all[i];
                if (target.needSelfExport)
                    usedSet.Add(target.bundleName);
            }

            DirectoryInfo di = new DirectoryInfo(pathResolver.BundleSavePath);
            FileInfo[] abFiles = di.GetFiles("*.ab");
            for (int i = 0; i < abFiles.Length; i++)
            {
                FileInfo fi = abFiles[i];
                if (usedSet.Add(fi.Name))
                {
                    Debug.Log("Remove unused AB : " + fi.Name);

                    fi.Delete();
                    //for U5X
                    File.Delete(fi.FullName + ".manifest");
                }
            }
        }

        protected void _SaveVersion()
        {
            //            string commVerFileName = "";
            //            Dictionary<string, bool> dicVerChange = new Dictionary<string, bool>();
            //            string[] dstFileNameLst = Directory.GetDirectories(Application.dataPath + "/Res_XYHY");
            //            if (dstFileNameLst != null)
            //            {
            //                for (int i = 0; i < dstFileNameLst.Length; i++)
            //                {
            //#if UNITY_IOS || UNITY_IPHONE
            //                   string directoryName = dstFileNameLst[i].Substring(dstFileNameLst[i].IndexOf("Res_XYHY"));
            //                   directoryName = directoryName.Split('/')[1];
            //#elif UNITY_ANDROID || (AB_WINDOW && UNITY_STANDALONE)
            //                    string directoryName = dstFileNameLst[i].Split('\\')[1];
            //#else
            //                    string directoryName = "";
            //#endif
            //                    string key = "ver_" + directoryName + ".txt";
            //                    dicVerChange[key] = false;
            //                    if (i == 0)
            //                    {
            //                        commVerFileName = key;
            //                    }
            //                }
            //            }

            //            foreach (var item in AssetBundleUtils.GetAll())
            //            {
            //                if (item.FileChangeMode != FileChangeType.None)
            //                {
            //#if UNITY_IOS || UNITY_IPHONE
            //                    string fileUrl = "ver_" + item.assetPath.Split('/')[2] + ".txt";
            //#elif UNITY_ANDROID || (AB_WINDOW && UNITY_STANDALONE)
            //                    string fileUrl = "ver_" + item.assetPath.Split('\\')[2] + ".txt";
            //#else
            //                    string fileUrl = "";
            //#endif                    
            //                    if (dicVerChange.ContainsKey(fileUrl))
            //                    {
            //                        dicVerChange[fileUrl] = true;
            //                    }
            //                    else
            //                    {
            //                        dicVerChange[commVerFileName] = true;
            //                    }
            //                }
            //            }
            bool isDirty = false;
            foreach (var item in AssetBundleUtils.GetAll())
            {
                if (item.FileChangeMode != FileChangeType.None)
                {
                    isDirty = true;
                    break;
                }
            }

            if (!isDirty)
                return;

            Dictionary<string, bool> dicVerChange = new Dictionary<string, bool>();

            foreach (var item in AssetBundleUtils.GetAll())
            {
                string fileUrl = "ver_" + item.belongName + ".txt";
                dicVerChange[fileUrl] = false;
                if (item.FileChangeMode != FileChangeType.None)
                {
                    if (dicVerChange.ContainsKey(fileUrl))
                    {
                        dicVerChange[fileUrl] = true;
                    }
                }
            }

            foreach (KeyValuePair<string, bool> var in dicVerChange)
            {
                if (var.Value)
                {
                    if (File.Exists(var.Key))
                    {
                        File.Delete(var.Key);
                    }


                    VersionInfo version = new VersionInfo();
                    switch (EditorUserBuildSettings.activeBuildTarget)
                    {
                        case BuildTarget.StandaloneOSXIntel64:
                        case BuildTarget.StandaloneWindows:
                            version.OsType = "windows";
                            break;
                        case BuildTarget.iOS:
                            version.OsType = "ios";
                            break;
                        case BuildTarget.Android:
                            version.OsType = "android";
                            break;
                    }

                    version.appID = AssetBundleBuildPanel.appid;
                    version.VersionNum = AssetBundlePathResolver.dicVersion[var.Key].ToString();             //AssetBundlePathResolver.version.ToString();
                    System.DateTime currentDT = System.DateTime.Now;
                    version.CurrentDT = currentDT.ToString("yyyyMMdd");
                    version.CurrentTime = currentDT.ToString("HHmm");

                    string saveUrl = "";
                    if (AssetBundleBuildPanel.BuildABsToStreamingAssets)
                    {
                        saveUrl = Path.Combine(AssetBundlePathResolver.instance.BundlesPathForStreaming, var.Key);
                    }
                    else
                    {
                        saveUrl = string.Format("{0}ver_{1}/{2}", AssetBundlePathResolver.instance.BundlesPathForServer, AssetBundlePathResolver.version.ToString(), var.Key);
                    }
                    
                    File.WriteAllText(saveUrl, JsonMapper.ToJson(version));

                    ////复制至上传服务器的路径
                    //string destUrl = string.Format("{0}ver_{1}/{2}/{3}", AssetBundlePathResolver.instance.BundlesPathForServer, AssetBundlePathResolver.version.ToString(), AssetBundlePathResolver.instance.BundlePlatformStr + "/" + AssetBundlePathResolver.instance.BundleSaveDirName,var.Key);
                    //string destDir = Path.GetDirectoryName(destUrl);
                    //if (!Directory.Exists(destDir))
                    //{
                    //    Directory.CreateDirectory(destDir);
                    //}
                    //if (File.Exists(saveUrl))
                    //{
                    //    File.Copy(saveUrl, destUrl, true);
                    //}
                }
            }


            /*string commSaveUrl;
            string game11SaveUrl;
            string game18SaveUrl;
            if (AssetBundleBuildPanel.BuildABsToStreamingAssets)
            {
                commSaveUrl = Path.Combine(AssetBundlePathResolver.instance.BundlesPathForStreaming, AssetBundlePathResolver.instance.VerCommSaveFile);
                game11SaveUrl = Path.Combine(AssetBundlePathResolver.instance.BundlesPathForStreaming, AssetBundlePathResolver.instance.VerGame11SaveFile);
                game18SaveUrl = Path.Combine(AssetBundlePathResolver.instance.BundlesPathForStreaming, AssetBundlePathResolver.instance.VerGame18SaveFile);
            }
            else
            {
                commSaveUrl = string.Format("{0}ver_{1}/{2}", AssetBundlePathResolver.instance.BundlesPathForServer, AssetBundlePathResolver.version.ToString(), AssetBundlePathResolver.instance.VerCommSaveFile);
                game11SaveUrl = string.Format("{0}ver_{1}/{2}", AssetBundlePathResolver.instance.BundlesPathForServer, AssetBundlePathResolver.version.ToString(), AssetBundlePathResolver.instance.VerGame11SaveFile);
                game18SaveUrl = string.Format("{0}ver_{1}/{2}", AssetBundlePathResolver.instance.BundlesPathForServer, AssetBundlePathResolver.version.ToString(), AssetBundlePathResolver.instance.VerGame18SaveFile);
            }

            if (File.Exists(commSaveUrl))
                File.Delete(commSaveUrl);
            if (File.Exists(game11SaveUrl))
                File.Delete(game11SaveUrl);
            if (File.Exists(game18SaveUrl))
                File.Delete(game18SaveUrl);



            File.WriteAllText(commSaveUrl, JsonMapper.ToJson(version));
            File.WriteAllText(game11SaveUrl, JsonMapper.ToJson(version));
            File.WriteAllText(game18SaveUrl, JsonMapper.ToJson(version));*/
        }
    }
}
