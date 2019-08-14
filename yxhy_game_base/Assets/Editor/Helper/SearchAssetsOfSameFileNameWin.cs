using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class SearchAssetsOfSameFileNameWin : EditorWindow
{
    #region 成员变量
    static int EditorWindow_W = 500;
    static int EditorWindow_H = 400;
    static string s_EditorName = "同目录相同文件名检索编辑器";

    Vector2 m_fileScroll;

    static SearchAssetsOfSameFileNameWin s_window = null;

    List<SameFileNameCell> allSameFileNameCellList = null;
    #endregion 成员变量

    [MenuItem("Tools/同目录相同文件名检索编辑器")]
    static void OpenWinUI()
    {
        s_window = (SearchAssetsOfSameFileNameWin)EditorWindow.GetWindow(typeof(SearchAssetsOfSameFileNameWin), true, s_EditorName);
        s_window.name = s_EditorName;
        s_window.minSize = new Vector2(EditorWindow_W, EditorWindow_H);
        s_window.Show();
    }



    #region 界面绘制
    void OnGUI()
    {
        GUILayout.BeginVertical();
        {
            GUILayout.Space(10);

            if (GUILayout.Button("开始检索", GUILayout.Height(40f), GUILayout.Width(100f)))
            {
                searchDataHandle();
            }

            GUILayout.Space(10);
            drawLine();

            onGUI_DisplayAssetsOfSameFileName();
        }
        GUILayout.EndVertical();
    }

    //bool ret = false;
    //显示在同一目录下文件名相同的文件名
    private void onGUI_DisplayAssetsOfSameFileName()
    {
        m_fileScroll = GUILayout.BeginScrollView(m_fileScroll, GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));

        if (allSameFileNameCellList != null)
        {
            for (int i = 0; i < allSameFileNameCellList.Count; i++)
            {
                SameFileNameCell cell = allSameFileNameCellList[i];

                cell.DisplayAll = EditorGUILayout.Foldout(cell.DisplayAll, "目录名" + (i + 1) + ":" + cell.FileDir);
                if (cell.DisplayAll)
                {
                    List<string> list = cell.FileNameHS.ToDynList<string>();
                    for (int j = 0; j < list.Count; j++)
                    {
                        GUILayout.Label("    文件名" + (j / 2 + 1) + ":" + list[j]);
                    }
                }
            }
            if (allSameFileNameCellList.Count == 0)
            {
                GUILayout.Label("--->>在同一目录下没有文件名相同的文件<<---");
            }
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
        string[] dirArray = Directory.GetDirectories(Application.dataPath, "*.*", SearchOption.AllDirectories);
        for (int i = 0; i < dirArray.Length; i++)
        {
            string[] fileArray = Directory.GetFiles(dirArray[i]);

            Dictionary<string, string> tempDic = new Dictionary<string, string>();
            SameFileNameCell cell = null;

            for (int j = 0; j < fileArray.Length; j++)
            {
                string fileName = fileArray[j];
                if (!isIgnoreFile(fileName))
                {
                    int index = fileName.LastIndexOf('.');
                    string fileNameNoSuffix;
                    if (index != -1)
                    {
                        fileNameNoSuffix = fileName.Substring(0, index);
                    }
                    else
                    {
                        fileNameNoSuffix = fileName;
                        Debug.LogWarning("无后缀名的文件名:" + fileNameNoSuffix);
                    }

                    if (tempDic.ContainsKey(fileNameNoSuffix))
                    {
                        if (cell == null)
                            cell = new SameFileNameCell();

                        cell.FileDir = dirArray[i];
                        if (!cell.FileNameHS.Contains(tempDic[fileNameNoSuffix]))
                        {
                            cell.FileNameHS.Add(tempDic[fileNameNoSuffix]);
                        }
                        if (!cell.FileNameHS.Contains(fileName))
                        {
                            cell.FileNameHS.Add(fileName);
                        }
                    }
                    else
                    {
                        tempDic.Add(fileNameNoSuffix, fileName);
                    }
                }
            }

            if (allSameFileNameCellList == null)
                allSameFileNameCellList = new List<SameFileNameCell>();

            if (cell != null && cell.FileNameHS.Count >= 2)
                allSameFileNameCellList.Add(cell);
        }
    }

    private bool isIgnoreFile(string fileName)
    {
        if (fileName.EndsWith(".meta") || fileName.EndsWith(".bytes") || fileName.EndsWith(".anim") || fileName.EndsWith(".controller")
            || fileName.EndsWith(".mat") || fileName.EndsWith(".prefab") || fileName.EndsWith(".cs") || fileName.EndsWith(".unity")
            || fileName.EndsWith(".dll") || fileName.EndsWith(".fnt"))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    #endregion 数据检索逻辑处理

    //装载同一目录下相同文件名的单元器
    public class SameFileNameCell
    {
        //文件目录
        public string FileDir = null;

        //文件名集
        public HashSet<string> FileNameHS = new HashSet<string>();

        //是否展开显示
        public bool DisplayAll = false;
    }
}
