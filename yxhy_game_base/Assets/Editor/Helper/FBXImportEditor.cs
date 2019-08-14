using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class FBXImportEditor : EditorWindow
{
    private bool isReadWriteEnable = false;
    private bool isImportMaterial = false;

    #region 成员变量
    static int EditorWindow_W = 500;
    static int EditorWindow_H = 400;
    static string s_EditorName = "模型导入编辑器";

    Vector2 m_fileScroll;

    static FBXImportEditor mWindow = null;

    static List<string> list = null;
    static List<ModelImporter> modelList = null;

    #endregion 成员变量

    [MenuItem("Tools/模型导入编辑器")]
    static void OpenWinUI()
    {
        mWindow = (FBXImportEditor)EditorWindow.GetWindow(typeof(FBXImportEditor), true, s_EditorName);
        mWindow.name = s_EditorName;
        mWindow.minSize = new Vector2(EditorWindow_W, EditorWindow_H);
        mWindow.Show();
    }

    #region 界面绘制
    void OnGUI()
    {
        GUILayout.BeginVertical();
        {
            GUILayout.Space(10);

            GUILayout.BeginHorizontal();
            {
                if (GUILayout.Button("开始检索", GUILayout.Height(40f), GUILayout.Width(100f)))
                {
                    list = null;
                    searchDataHandle();
                }

                GUILayout.Space(20);

                if (GUILayout.Button("批量处理", GUILayout.Height(40f), GUILayout.Width(100f)))
                {
                    for (int i = 0; i < modelList.Count; i++)
                    {
                        ModelImporter mi = modelList[i];
                        mi.importMaterials = isImportMaterial;
                        mi.isReadable = isReadWriteEnable;

                        AssetDatabase.ImportAsset(mi.assetPath);
                    }

                    AssetDatabase.Refresh();
                    list.Clear();
                    modelList.Clear();
                }
            }
            GUILayout.EndHorizontal();

            GUILayout.Space(10);
            drawLine();

            onGUI_DisplayFBXOfImportedMaterial();
        }
        GUILayout.EndVertical();
    }

    //bool ret = false;
    //显示在同一目录下文件名相同的文件名
    private void onGUI_DisplayFBXOfImportedMaterial()
    {
        m_fileScroll = GUILayout.BeginScrollView(m_fileScroll, GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));

        if (list != null)
        {
            for (int i = 0; i < list.Count; i++)
            {
                GUILayout.Label("    文件名" + (i + 1) + ":" + list[i]);

            }
            if (list.Count == 0)
            {
                GUILayout.Label("--->>没有模型导入了材质<<---");
            }
        }
        else
        {
            GUILayout.Label("--->>没有模型导入了材质<<---");
        }

        GUILayout.EndScrollView();
    }

    private void drawLine()
    {
        string go = "-";
        for (int i = 0; i < 200; i++)
        {
            go += "-";
        }
        GUILayout.Label(go);
    }
    #endregion 界面绘制

    #region 数据检索逻辑处理
    private void searchDataHandle()
    {
        DirectoryInfo di = new DirectoryInfo(Application.dataPath);
        if (di.Exists)
        {
            FileInfo[] fileArray = di.GetFiles("*.FBX", SearchOption.AllDirectories);

            for (int j = 0; j < fileArray.Length; j++)
            {
                string fileName = fileArray[j].FullName;
                fileName = fileName.Replace("\\", "/");
                int deleteLength = Application.dataPath.Length - 6;
                fileName = fileName.Remove(0, deleteLength);

                ModelImporter mi = AssetImporter.GetAtPath(fileName) as ModelImporter;
                if (mi.importMaterials)
                {
                    if (list == null)
                        list = new List<string>();
                    list.Add(fileName);

                    if (modelList == null)
                        modelList = new List<ModelImporter>();
                    modelList.Add(mi);
                }
            }
        }
    }

    private bool isTargetFile(string fileName)
    {
        if (fileName.EndsWith(".FBX"))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    #endregion 数据检索逻辑处理

}
