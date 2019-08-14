using UnityEngine;
using XYHY.ABSystem;
using System.IO;
using UnityEditor;
using System;
using System.Collections.Generic;
using System.Linq;

public class CheckAtlasWindow: EditorWindow 
{

    [MenuItem("Tools/查找LogicBaseLua")]
    static void FindOldCode()
    {
        var files = Directory.GetFiles(Application.dataPath + "/Res_XYHY", "*.prefab", SearchOption.AllDirectories);
        for(int i = 0; i < files.Length; i++)
        {
            var relpath = files[i].Replace(Application.dataPath.Replace("Assets", ""), "");
            var asset = AssetDatabase.LoadAssetAtPath<GameObject>(relpath);
            if (asset != null)
            {
                var comps = asset.GetComponentsInChildren<LogicBaseLua>(true);
                if(comps.Length > 0)
                {
                    Debug.LogError(relpath);
                }
            }
        }
        Debug.Log("end");
    }

    [MenuItem("Tools/替换Sprites-Default材质")]
    static void ReplaceMaterials()
    {
        var newMat = AssetDatabase.LoadAssetAtPath<Material>("Assets/Res_XYHY/app_4/materials/sprites.mat");
        if(newMat == null)
        {
            return;
        }
        List<Renderer> renderList = new List<Renderer>();
        List<string> withoutExtensions = new List<string>() { ".prefab", ".mat" };
        string[] files = Directory.GetFiles(Application.dataPath, "*.*", SearchOption.AllDirectories)
        
            .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
        int startIndex = 0;
        EditorApplication.update = delegate ()
        {
            string file = files[startIndex];

            bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)files.Length);
            try
            {
                var obj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(GetRelativeAssetsPath(file));
                if (obj != null)
                {
                    var go = obj as GameObject;
                    if (go != null)
                    {
                        go.GetComponentsInChildren(true, renderList);
                        bool dirty = false;
                        for (int i = 0; i < renderList.Count; i++)
                        {
                            if(renderList[i].sharedMaterial != null && renderList[i].sharedMaterial.name == "Sprites-Default")
                            {
                                renderList[i].sharedMaterial = newMat;
                            
                                dirty = true;
                            }
                        }
                        if (dirty)
                        {
                            EditorUtility.SetDirty(go);
                        }
                    }
                }
            }
            catch(Exception e)
            {
                Debug.LogError(e.Message);
                isCancel = true;
            }

            startIndex++;
            if (isCancel || startIndex >= files.Length)
            {
                EditorUtility.ClearProgressBar();
                EditorApplication.update = null;
                startIndex = 0;
                Debug.Log("匹配结束");
            }

        };

    }

    static private string GetRelativeAssetsPath(string path)
    {
        return "Assets" + Path.GetFullPath(path).Replace(Path.GetFullPath(Application.dataPath), "").Replace('\\', '/');
    }


    [MenuItem("Tools/显示所有依赖")]
    static void ShowDep()
    {
        if (Selection.activeObject == null)
            return;
        var objs = EditorUtility.CollectDependencies(new UnityEngine.Object[] { Selection.activeObject });
        for(int i = 0; i < objs.Length; i++)
        {
            if (objs[i] is MonoScript || objs[i] is LightingDataAsset)
                Debug.LogError(objs[i], objs[i]);
        }
    }

    string _atlasName = "";
    [MenuItem("Tools/检查图集引用")]
    static void Open()
    {
        GetWindow<CheckAtlasWindow>();
    }


    private void OnGUI()
    {
        _atlasName = EditorGUILayout.TextField("图集名称:", _atlasName);
        if(GUILayout.Button("检测"))
        {
            Check();
        }
    }


    void Check()
    {
        if(Selection.activeGameObject == null)
        {
            Debug.LogError("请选择UI");
            return;
        }
        List<UISprite> spList = new List<UISprite>();
        Selection.activeGameObject.GetComponentsInChildren(true, spList);
        for(int i = 0; i < spList.Count; i++)
        {
            if(spList[i].atlas != null && spList[i].atlas.name == _atlasName)
            {
                Debug.LogError(spList[i], spList[i].gameObject);
            }
        }
    }
}


public class AssetBundleView : EditorWindow
{
    [Serializable]
    class AssetBundleDataSerialized : ScriptableObject
    {
        public string shortName;
        public string fullName;
        public string hash;
        public string debugName;
        public AssetBundleExportType compositeType;
        public string[] dependencies;
        public bool isAnalyzed;
        public List<string> dependNameList = new List<string>();
        public long size;


        public static AssetBundleDataSerialized Create(AssetBundleData data)
        {
            if (data == null)
                return null;
            AssetBundleDataSerialized abDataS = ScriptableObject.CreateInstance<AssetBundleDataSerialized>();
            abDataS.shortName = data.shortName;
            abDataS.fullName = data.fullName;
            abDataS.hash = data.hash;
            abDataS.debugName = data.debugName;
            abDataS.compositeType = data.compositeType;
            abDataS.dependencies = data.dependencies;
            abDataS.size = data.size;
            if (data.dependList != null)
            {
                for (int i = 0; i < data.dependList.Length; i++)
                {
                    abDataS.dependNameList.Add(data.dependList[i].debugName);
                }
            }

            return abDataS;
        }
    }

    [MenuItem("Assets/移动到备份路径")]
    static void MoveToBackup()
    {
        string desPath = Application.dataPath.Replace("Assets", "") + "Res_XYHY_old";
        var obj = Selection.activeObject;
        if (Selection.activeObject == null)
            return;
        string path = AssetDatabase.GetAssetPath(obj);
        string subPath = path.Replace("Assets", "");
        string fullPath = Application.dataPath + subPath;
        string outputPath = desPath + subPath;
        if (Directory.Exists(path))
        {
            Debug.LogError("暂不支持复制文件夹");
            //Directory.Move(fullPath, desPath + subPath);
            //AssetDatabase.Refresh();
        }
        else
        {
            if(File.Exists(fullPath))
            {
                string dir = Path.GetDirectoryName(outputPath);
                if (!Directory.Exists(dir))
                    Directory.CreateDirectory(dir);
                File.Move(fullPath, desPath + subPath);
                AssetDatabase.Refresh();
            }
        }

        Debug.LogError("复制" + path + "到" + desPath + subPath);
    }


    [MenuItem("Tools/查看AssetBundle")]
    static void Open()
    {
        GetWindow<AssetBundleView>("查看AB", true);
    }

    string _assetBundleName = "";
    AssetBundleDataSerialized _selectBundleData = null;
    SerializedObject _selectSerializeData = null;
    static AssetBundleTools _abTool;

    bool _abFadeState = false;
    bool _abPathFadeState = true;
    public static AssetBundleTools abTool
    {
        get
        {
            if (_abTool == null)
            {
                Debug.LogError("create");
                _abTool = new AssetBundleTools();
                _abTool.Init();
            }
            return _abTool;
        }
        set
        {
            _abTool = value;
        }
    }

    private void OnDisable()
    {
        abTool = null;
    }

    void OnGUI()
    {
        EditorGUILayout.BeginHorizontal();
        _assetBundleName = EditorGUILayout.TextField("abName:", _assetBundleName);
        if (GUILayout.Button("查看", GUILayout.Width(80)))
        {
            var data = abTool.GetAssetBundleInfo(_assetBundleName);
            _selectBundleData = AssetBundleDataSerialized.Create(data);
            _abFadeState = false;
            _abPathFadeState = false;
        }
        EditorGUILayout.EndHorizontal();

        if (_selectBundleData != null)
        {
            EditorGUILayout.ObjectField(_selectBundleData, typeof(AssetBundleDataSerialized), false);
            Selection.activeObject = _selectBundleData;
            DrawABInfo();
        }
    }


    void DrawABInfo()
    {
        _abFadeState = EditorGUILayout.Foldout(_abFadeState, "abNames");
        if (_abFadeState)
        {
            if (_selectBundleData.dependencies != null)
            {
                for (int i = 0; i < _selectBundleData.dependencies.Length; i++)
                {
                    DrawSelectedPath(_selectBundleData.dependencies[i], GetAbAssetPath(_selectBundleData.dependencies[i]));
                }
            }
        }

        _abPathFadeState = EditorGUILayout.Foldout(_abPathFadeState, "abAssetPath");
        //if(_abPathFadeState)
        //{
        //    if(_selectBundleData.dependNameList != null)
        //    {
        //        for(int i =  1; i < _selectBundleData.dependNameList.Count; i++)
        //        {

        //        }
        //    }
        //}
    }

    //string GetAssetPath(string path)
    //{
    //    var fileName = Path.GetFileNameWithoutExtension(path);
    //}

    string GetAbAssetPath(string abName)
    {
        var guids = AssetDatabase.FindAssets(abName.Split('.')[0], new string[] { "Assets/StreamingAssets" });
        string path = "";
        for(int i = 0; i < guids.Length; i++)
        {
            string fpath = UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i]);
            if(fpath.EndsWith(".ab"))
            {
                path = fpath;
                break;
            }
        }
        return path;
    }

    void DrawSelectedPath(string value, string path)
    {
        EditorGUILayout.BeginHorizontal();
        GUILayout.Space(24);
        EditorGUILayout.LabelField(value, GUILayout.Height(20));
        var filePath = Application.dataPath.Substring(0, Application.dataPath.LastIndexOf('/') + 1) +path;
        if(File.Exists(filePath))
        {
            var fileInfo = new FileInfo(filePath);
            EditorGUILayout.LabelField(((float)fileInfo.Length / 1024) + "KB", GUILayout.Height(20));
        }
        if (GUILayout.Button("查看", GUILayout.Height(20), GUILayout.Width(60)))
        {
            _assetBundleName = value;
            var data = abTool.GetAssetBundleInfo(_assetBundleName);
            _selectBundleData = AssetBundleDataSerialized.Create(data);
        }
        if (GUILayout.Button("选择", GUILayout.Height(20), GUILayout.Width(60)))
        {
            var obj = AssetDatabase.LoadMainAssetAtPath(path);
            if (obj != null)
            {
                EditorGUIUtility.PingObject(obj);
                Selection.activeObject = obj;
            }
        }
        EditorGUILayout.EndHorizontal();
    }


}


public class AssetBundleTools
{
    AssetBundleDataReader _dataReader ;
    string _depForderPath;
    public void Init()
    {
        //为什么不搞成静态类  或者动态创建instance??
        new AssetBundlePathResolver();
        _depForderPath = Application.dataPath.Substring(0, Application.dataPath.LastIndexOf('/') + 1) + AssetBundlePathResolver.instance.BundleSavePath;
        _dataReader = new AssetBundleDataReader();
        var depFiles = GetAllDepFileList();
        if (depFiles == null)
            return;
        for(int i = 0; i < depFiles.Length; i++)
        {
            var bytes = File.ReadAllBytes(depFiles[i]);
            var ms = new MemoryStream(bytes);
            _dataReader.Read(ms);
        }
        _dataReader.Analyze();
    }

    public AssetBundleData GetAssetBundleInfo(string key)
    {
        if (!key.EndsWith(".ab"))
            key = key + ".ab";
        if (_dataReader.infoMap.ContainsKey(key))
            return _dataReader.infoMap[key];
        return null;
    }


    string[] GetAllDepFileList()
    {
        if (!Directory.Exists(_depForderPath))
            return null;
        var files = Directory.GetFiles(_depForderPath, "*.all", SearchOption.TopDirectoryOnly);
        return files;
    }
}

