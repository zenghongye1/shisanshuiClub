using UnityEngine;
using UnityEditor;
using System.Diagnostics;

public class ExcelTool
{
    static string toolPath = Application.dataPath + "/Editor/ExcelTool/ExcelTools.exe";

    [MenuItem("Tools/打开ExcelTool")]
    public static void Tool()
    {
        Process.Start(toolPath);
    }
}
