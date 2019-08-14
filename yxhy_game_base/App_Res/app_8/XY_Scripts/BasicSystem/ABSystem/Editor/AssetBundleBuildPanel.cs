using System.IO;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
using System.Collections.Generic;

namespace XYHY.ABSystem
{
    public class VerConf
    {
        public string fileName = "";
        public string versionNum = "";
    }

    public class AssetBundleBuildPanel : EditorWindow
    {
        //是否打资源包至StreamingAssets目录下
        public static bool BuildABsToStreamingAssets = true;

        //public static string versionNum = "1.0.0";

        //public static Dictionary<string, string> dicVersion = new Dictionary<string, string>();
        public static string appid = "1";

        public static List<VerConf> verConfLst = new List<VerConf>();

        AssetBundlePathResolver pathResolver = new AssetBundlePathResolver();

        [MenuItem("ABSystem/Builder Panel")]
        static void Open()
        {
            GetWindow<AssetBundleBuildPanel>("ABSystem", true);
        }

        [MenuItem("ABSystem/Builde AssetBundles")]
        static void BuildAssetBundles()
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
            r.xMax = rect.xMax - r.xMin - GAP;
            verConf.versionNum = GUI.TextField(r, verConf.versionNum);
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
            _list.onAddCallback = (list) => Add();
        }

        void verLstAdd()
        {
            VerConf verConf = new VerConf();
            verConfLst.Add(verConf);
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

        private void OnEnable()
        {
            string streamingVerFileUrl = string.Format("/{0}/{1}", AssetBundlePathResolver.instance.BundlePlatformStr, AssetBundlePathResolver.instance.BundleSaveDirName);
            string[] fileNames = Directory.GetFiles(Application.streamingAssetsPath + streamingVerFileUrl, "ver_*.txt");

            for(int i=0; i<fileNames.Length; i++)
            {
                string fileName = fileNames[i].Split('\\')[1];
                VersionInfo _verInfo = FileUtils.GetGameVerNo(fileName);
                if (_verInfo != null)
                {
                    VerConf verConf = new VerConf();
                    verConf.fileName = fileName;
                    verConf.versionNum = _verInfo.VersionNum;
                    verConfLst.Add(verConf);

                    appid = _verInfo.appID;
                }
            }            
        }

        private void OnDisable()
        {
            verConfLst.Clear();
        }

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