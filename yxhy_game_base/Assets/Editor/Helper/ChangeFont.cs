using UnityEngine;
using System.Collections;
using UnityEditor;
using System;
using System.IO;

public class ChangeFont : EditorWindow
{
    [MenuItem("Tools/Change Font")]
    private static void AddWindow()
    {
        EditorWindow.GetWindow(typeof(ChangeFont), true, "Change Font");  //ChangeFont CF = (ChangeFont)
    }

    UIFont fzzy_font;
    UIFont ttf_font;

    FileInfo[] fs;

    /// <summary>
    /// 加载项目中所有prefab文件
    /// </summary>
    private void LoadAllPrefabFiles()
    {
        DirectoryInfo d = new DirectoryInfo(Application.dataPath);
        fs = d.GetFiles("*.prefab", SearchOption.AllDirectories);
    }

    /// <summary>
    /// 加载指定字体
    /// </summary>
    private void LoadFont()
    {
        LoadAllPrefabFiles();

        foreach (FileInfo f in fs)
        {
            if (f.Name.Equals("fengzhengzhunyuan.prefab"))
            {
                string s = f.FullName;
                int index = s.IndexOf("Assets");
                string loadPath = s.Substring(index);
                //加载目标字体
                fzzy_font = AssetDatabase.LoadAssetAtPath<GameObject>(loadPath).GetComponent<UIFont>();
            }
            if (f.Name.Equals("ttf.prefab"))
            {
                string s = f.FullName;
                int index = s.IndexOf("Assets");
                string loadPath = s.Substring(index);
                //加载目标字体
                ttf_font = AssetDatabase.LoadAssetAtPath<GameObject>(loadPath).GetComponent<UIFont>();
            }
        }
    }
    
    void OnGUI()
    {
        LoadFont();

        if (GUILayout.Button("fzzy", GUILayout.Width(200)))
        {
            Change_Fzzy();
        }
        if (GUILayout.Button("ttf", GUILayout.Width(200)))
        {
            Change_ttf();
        }
    }

    /// <summary>
    /// 替换指定字体fzzy
    /// </summary>
    private void Change_Fzzy()
    {
        foreach (FileInfo f in fs)
        {
            string fullName = f.FullName;//文件的本地路径
            int index = fullName.IndexOf("Assets");
            string loadPath = fullName.Substring(index);//项目资源加载路径
            GameObject go = AssetDatabase.LoadAssetAtPath<GameObject>(loadPath);//指定文件路径下的prefab资源
            UILabel[] us = go.GetComponentsInChildren<UILabel>();

            if(us.Length>=1)
            {
                for(int i=0;i<us.Length;i++)
                {
                    us[i].ambigiousFont = fzzy_font;
                }

                EditorUtility.SetDirty(go);//Apply
            }
        }
    }

    /// <summary>
    /// 替换指定字体ttf
    /// </summary>
    private void Change_ttf()
    {
        foreach (FileInfo f in fs)
        {
            string fullName = f.FullName;//文件的本地路径
            int index = fullName.IndexOf("Assets");
            string loadPath = fullName.Substring(index);//项目资源加载路径
            GameObject go = AssetDatabase.LoadAssetAtPath<GameObject>(loadPath);//指定文件路径下的prefab资源
            UILabel[] us = go.GetComponentsInChildren<UILabel>();

            if (us.Length >= 1)
            {
                for (int i = 0; i < us.Length; i++)
                {
                    us[i].ambigiousFont = ttf_font;
                }

                EditorUtility.SetDirty(go);//Apply
            }
        }
    }
}
