using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class FindSpriteRef : EditorWindow
{
    [MenuItem("Tools/查找sprite引用")]
    static void Open()
    {
        GetWindow<FindSpriteRef>().Show();
    }

    bool _allAtlas = false;
    UIAtlas _targetAtlas;
    string _spriteName;
    List<UISprite> spList = new List<UISprite>();

    private void OnGUI()
    {
        _allAtlas = EditorGUILayout.Toggle("所有图集：", _allAtlas);
        _targetAtlas = (UIAtlas)EditorGUILayout.ObjectField("选择图集", _targetAtlas, typeof(UIAtlas));
        _spriteName = EditorGUILayout.TextField("图集名称:", _spriteName);
        if (GUILayout.Button("查找"))
        {
            Check();
        }
    }

    void Check()
    {
        if (!_allAtlas)
        {
            if (_targetAtlas == null)
            {
                Debug.LogError("请选择图集");
                return;
            }
        }
        if (_spriteName == null)
        {
            Debug.LogError("请输入名称");
            return;
        }
        FindPrefabs();
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
                    if (go != null)
                    {
                        go.GetComponentsInChildren(true, spList);
                        //bool dirty = false;
                        for (int i = 0; i < spList.Count; i++)
                        {
                            if (!_allAtlas)
                            {
                                if (spList[i].atlas != null && spList[i].atlas == _targetAtlas && spList[i].spriteName == _spriteName)
                                {
                                    Debug.Log(string.Format("{0},{1}", file, spList[i].gameObject.name), AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(GetRelativeAssetsPath(file)));
                                    //dirty = true;
                                }
                            }
                            else
                            {
                                if (spList[i].atlas != null && spList[i].spriteName == _spriteName)
                                {
                                    Debug.Log(string.Format("{0},{1},{2}", file, spList[i].atlas.name, spList[i].gameObject.name), AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(GetRelativeAssetsPath(file)));
                                    //dirty = true;
                                }
                            }
                        }
                        //if (dirty)
                        //{
                        //    EditorUtility.SetDirty(go);
                        //}
                    }
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

    static private string GetRelativeAssetsPath(string path)
    {
        return "Assets" + Path.GetFullPath(path).Replace(Path.GetFullPath(Application.dataPath), "").Replace('\\', '/');
    }
}
