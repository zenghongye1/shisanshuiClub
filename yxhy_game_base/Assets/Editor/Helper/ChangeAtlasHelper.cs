using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class ChangeAtlasHelper : EditorWindow
{
    [MenuItem("Tools/替换图集")]
    static void Open()
    {
        GetWindow<ChangeAtlasHelper>().Show();
    }

    UIAtlas oldAtlas;
    UIAtlas newAtlas;
    [SerializeField]//必须要加
    protected List<string> _spNameList = new List<string>(3);
    protected SerializedObject _serializedObject;
    protected SerializedProperty _assetLstProperty;
    bool isAllPrefabs = false;
    GameObject onePrefab;
    List<UISprite> spList = new List<UISprite>();

    void Awake()
    {
        _spNameList.Add("common_38");
        _spNameList.Add("common_29");
        _spNameList.Add("common_44");
    }

    protected void OnEnable()
    {
        //使用当前类初始化
        _serializedObject = new SerializedObject(this);
        //获取当前类中可序列话的属性
        _assetLstProperty = _serializedObject.FindProperty("_spNameList");
    }

    private void OnGUI()
    {
        //更新
        _serializedObject.Update();
        //开始检查是否有修改
        EditorGUI.BeginChangeCheck();
        oldAtlas = (UIAtlas)EditorGUILayout.ObjectField("选择被替换图集", oldAtlas, typeof(UIAtlas));
        newAtlas = (UIAtlas)EditorGUILayout.ObjectField("选择替换图集", newAtlas, typeof(UIAtlas));
        EditorGUILayout.PropertyField(_assetLstProperty, true);
        isAllPrefabs = EditorGUILayout.Toggle("所有预设：", isAllPrefabs);
        onePrefab = (GameObject)EditorGUILayout.ObjectField("选择预设", onePrefab, typeof(GameObject));

        if (GUILayout.Button("替换"))
        {
            Check();
        }
        //结束检查是否有修改
        if (EditorGUI.EndChangeCheck())
        {//提交修改
            _serializedObject.ApplyModifiedProperties();
        }
    }

    void Check()
    {
        if (_spNameList.Count == 0)
        {
            Debug.LogError("请输入spriteName");
            return;
        }
        if (oldAtlas == null || newAtlas == null)
        {
            Debug.LogError("请选择图集");
            return;
        }
        if (!isAllPrefabs)
        {
            GameObject go = onePrefab;
            if (go == null)
            {
                go = Selection.activeGameObject;
                if (go == null)
                {
                    Debug.LogError("请选择预设");
                    return;
                }
            }
            Excute(onePrefab);
            Debug.Log("匹配结束");
        }
        else
        {
            FindPrefabs();
        }
    }

    void FindPrefabs()
    {
        List<string> withoutExtensions = new List<string>() { ".prefab" };
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
                    if (go!=null)
                        Excute(go);
                }
            }
            catch (Exception e)
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

    void Excute(GameObject go)
    {
        if (go != null)
        {
            go.GetComponentsInChildren(true, spList);
            bool dirty = false;
            for (int i = 0; i < spList.Count; i++)
            {
                if (spList[i].atlas != null && spList[i].atlas == oldAtlas && CheckSpriteName(spList[i].spriteName))
                {
                    spList[i].atlas = newAtlas;
                    dirty = true;
                }
            }
            if (dirty)
            {
                EditorUtility.SetDirty(go);
            }
        }
    }

    bool CheckSpriteName(string name)
    {
        for(int i = 0;i< _spNameList.Count; ++i)
        {
            if (_spNameList[i] == name)
                return true;
        }
        return false;
    }

    static private string GetRelativeAssetsPath(string path)
    {
        return "Assets" + Path.GetFullPath(path).Replace(Path.GetFullPath(Application.dataPath), "").Replace('\\', '/');
    }
}
