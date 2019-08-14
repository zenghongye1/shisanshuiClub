using UnityEditor;
using UnityEngine;
using System.Text;
using System.IO;
using System;
using System.Globalization;
using System.Collections.Generic;

public class ViewLuaFileMaker : EditorWindow
{
    static string luaFileString = "";

    // Add menu item named "My Window" to the Window menu
    [MenuItem("Lua/GenViewLuaFile", false, 14)]
    public static void ShowWindow()
    {
        //Show existing window instance. If one doesn't exist, make one.
        EditorWindow.GetWindow(typeof(ViewLuaFileMaker));
    }

    public static void MakeUIVariable(StringBuilder fileContent, string controlName)
    {
        if (controlName.StartsWith("label_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UILabel') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("btn_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UIButton') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("sprite_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UISprite') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("tex_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UITexture') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("toggle_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UIToggle') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("progress_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UIProgressBar') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("scrollv_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UIScrollView') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("scrollb_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UIScrollBar') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("input_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UIInput') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("table_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UITable') \n", controlName, controlName);
        }
        else if (controlName.StartsWith("grid_", true, CultureInfo.GetCultureInfo("en-us")))
        {
            fileContent.AppendFormat("      {0} = subComponentGet_ext(this.transform, '{1}', 'UIGrid') \n", controlName, controlName);
        }
        else
        {
            fileContent.AppendFormat("      {0} = child_ext(this.transform, '{1}') \n", controlName, controlName);
        }     
    }

    private void MakeSingleClassLua(StringBuilder fileContent)
    {
        string validFileName = luaFileString.Replace('\\', '/');
        validFileName = validFileName.Substring(validFileName.LastIndexOf('/') + 1);
        fileContent.AppendFormat("{0} = {{}} \r\n", validFileName);
        fileContent.AppendFormat("local this = {0} \r\n\n", validFileName);

        // variables declare
        List<string> gameObjectNames = new List<string>();
        for (int i = 0; i < Selection.gameObjects.Length; ++i)
        {
            gameObjectNames.Add(Selection.gameObjects[i].name);
        }

        gameObjectNames.Sort();

        for (int i = 0; i < gameObjectNames.Count; ++i)
        {
            fileContent.AppendFormat("local {0} = nil \r\n", gameObjectNames[i]);
        }

        fileContent.Append("\n\n");
        // Awake function
        fileContent.Append("function this.Awake() \n");
        for (int i = 0; i < gameObjectNames.Count; ++i)
        {
            MakeUIVariable(fileContent, gameObjectNames[i]);
        }
        fileContent.Append("\n\n      this.RegistEvents() \n");

        fileContent.Append("end \n\n\n\n");

        fileContent.Append("function this.Start() \n\n\n\n");
        fileContent.Append("end \n\n\n\n");

        // RegistEvents function 
        List<string> callbacks = new List<string>();
        fileContent.Append("function this.RegistEvents() \n");
        for (int i = 0; i < gameObjectNames.Count; ++i)
        {
            string controlName = gameObjectNames[i];
            string subName = controlName.Substring(4);
            if (controlName.StartsWith("btn_", true, CultureInfo.GetCultureInfo("en-us")))
            {
                fileContent.AppendFormat("      addClickCallback({0}.transform, this.OnBtn_{1})\r\n", controlName, subName);
                callbacks.Add("this.OnBtn_" + subName);
            }
        }

        fileContent.Append("end \n\n\n\n");

        // all callbacks
        for (int i = 0; i < callbacks.Count; ++i)
        {
            fileContent.AppendFormat("function {0}() \n", callbacks[i]);
            fileContent.AppendFormat("    Trace('{0} is called!!!!!') \n", callbacks[i]);
            fileContent.Append("end \n\n\n\n");
        }


        fileContent.Append("function this.OnDestroy() \n\n\n\n");
        fileContent.Append("end \n\n\n\n");
    }

    void OnGUI()
    {
        GUILayout.Label("设置路径，从XY_Lua/logic/开始", EditorStyles.boldLabel);
        luaFileString = EditorGUILayout.TextField("Lua File Path: ", luaFileString);

        if (GUILayout.Button("生成"))
        {
            // table declare
            string file = Application.dataPath + "/XY_Lua/logic/" + luaFileString + ".lua";
            StringBuilder fileContent = new StringBuilder();

            fileContent.Append("--[[--\n");
            fileContent.Append("* @Description: description\n");
            fileContent.Append("* @Author:   xxxx\n");
            fileContent.AppendFormat("* @FileName:  {0}\n", luaFileString + ".lua");
            fileContent.Append("* @DateTime:  " + DateTime.Now.ToString() + "\n");
            fileContent.Append("]]\n\n\n");

            // 目前只支持生成单例对象的lua
            MakeSingleClassLua(fileContent);

            StreamWriter textWriter = new StreamWriter(file, false, Encoding.UTF8);

            textWriter.Write(fileContent.ToString());
            textWriter.Flush();
            textWriter.Close();
        }
    }
}
