using UnityEditor;
using UnityEngine;
using System.Text;
using System.IO;
using System;
using System.Globalization;
using System.Collections.Generic;

public class ViewLuaFileMaker_forSary : EditorWindow
{
    static string m_fileName = "";
    static string m_luaAuthorName;
    static string m_luaFolderName;
    static string m_uiPrefabFolderName;
    static GameObject goPrefab = null;

    string GetFileName()
    {
        return m_fileName;
    }

    string GetLuaBehaviorPath()
    {
        return "logic/" + m_luaFolderName + "/" + m_fileName;
    }

    string GetLuaFilePath()
    {
        return Application.dataPath + "/XY_Lua/" + GetLuaBehaviorPath() + ".lua";
    }

    string GetUIPrefabFilePath()
    {
        return "Prefabs/UI/" + m_uiPrefabFolderName + "/" + m_fileName;
    }

    // Add menu item named "My Window" to the Window menu
    [MenuItem("Lua/GenViewLuaFile for sary", false, 14)]
    public static void ShowWindow_forSary()
    {
      //Show existing window instance. If one doesn't exist, make one.
      Rect wr = new Rect(0, 0, 700, 250);
      EditorWindow.GetWindowWithRect(typeof(ViewLuaFileMaker_forSary), wr, false, "Lua文件生成器");
    }

    public static void MakeUIVariable(StringBuilder fileContent, string controlName)
    {
      if (controlName.StartsWith("label_", true, CultureInfo.GetCultureInfo("en-us")))
      {
        fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UILabel') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("btn_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UIButton') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("sprite_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UISprite') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("tex_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UITexture') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("toggle_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UIToggle') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("progress_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UIProgressBar') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("scrollv_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UIScrollView') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("scrollb_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UIScrollBar') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("input_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UIInput') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("table_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UITable') \n", controlName, controlName);
      }
      else if (controlName.StartsWith("grid_", true, CultureInfo.GetCultureInfo("en-us")))
      {
          fileContent.AppendFormat("    m_{0} = subComponentGet_ext(this.transform, '{1}', 'UIGrid') \n", controlName, controlName);
      }
      else
      {
          fileContent.AppendFormat("    m_{0} = child_ext(this.transform, '{1}') \n", controlName, controlName);
      }     
    }

    public static void DestroyVariable(StringBuilder fileContent, string controlName)
    {
        fileContent.AppendFormat("    m_{0} = nil\n", controlName);
    }

    private void MakeSingleClassLua(StringBuilder fileContent)
    {
      string validFileName = m_fileName;
      validFileName = validFileName.Substring(validFileName.LastIndexOf('/') + 1);
      fileContent.AppendFormat("{0} = {{}} \r\n", validFileName);
      fileContent.AppendFormat("local this = {0} \r\n\n", validFileName);

      // variables declare
      List<string> gameObjectNames = new List<string>();
      for (int i = 0; i < Selection.gameObjects.Length; ++i)
      {
          if (!Selection.gameObjects[i].Equals(goPrefab))
          {
              gameObjectNames.Add(Selection.gameObjects[i].name);
          }
      }

      gameObjectNames.Sort();

      for (int i = 0; i < gameObjectNames.Count; ++i)
      {
          fileContent.AppendFormat("local m_{0} = nil \n", gameObjectNames[i]);
      }
      fileContent.Append("\n");

      fileContent.Append("local m_bShowed = false\r\n");
      fileContent.Append("function this.Show()\r\n");
      fileContent.Append("	if not m_bShowed then\r\n");
      fileContent.AppendFormat("		newui(\"{0}\")\r\n", GetUIPrefabFilePath());
      fileContent.Append("	end\r\n");
      fileContent.Append("end\r\n\r\n");

      fileContent.Append("function this.Hide()\r\n");
      fileContent.Append("	if m_bShowed then\r\n");
      fileContent.Append("		destroy(this.gameObject)\r\n");
      fileContent.Append("	end\r\n");
      fileContent.Append("end\r\n\r\n");

      // Awake function
      fileContent.Append("function this.Awake()\r\n");
      fileContent.Append("	m_bShowed = true\r\n\r\n");
      for (int i = 0; i < gameObjectNames.Count; ++i)
      {
        MakeUIVariable(fileContent, gameObjectNames[i]);
      }
      fileContent.Append("	this.RegistEvents()\r\n");
      fileContent.Append("end\r\n\r\n");
      // Awake function begin

      // onDestroy
      fileContent.Append("function this.OnDestroy() \n");
      fileContent.Append("	m_bShowed = false\n\n");
      fileContent.Append("	this.UnRegistEvents()\r\n");
      for (int i = 0; i < gameObjectNames.Count; ++i)
      {
          DestroyVariable(fileContent, gameObjectNames[i]);
      }
      fileContent.Append("end\n\n");
      // onDestroy end

      // RegistEvents function
      fileContent.Append("function this.RegistEvents()\n");
      List<string> callbacks = new List<string>();
      for (int i = 0; i < gameObjectNames.Count; ++i)
      {
          string controlName = gameObjectNames[i];
          string subName = controlName.Substring(4);
          if (controlName.StartsWith("btn_", true, CultureInfo.GetCultureInfo("en-us")))
          {
              fileContent.AppendFormat("    addClickCallback(m_{0}.transform, this.OnBtn_{1})\r\n", controlName, subName);
              callbacks.Add("this.OnBtn_" + subName);
          }
      }
      fileContent.Append("end\n\n");
      // RegistEvents end

      // Start function
      fileContent.Append("function this.Start()\n");
      fileContent.Append("end\n\n");
      // Start end

      // all callbacks
      for (int i = 0; i < callbacks.Count; ++i)
      {
        fileContent.AppendFormat("function {0}() \n", callbacks[i]);
        fileContent.AppendFormat("    Trace('{0} is called!!!!!') \n", callbacks[i]);
        fileContent.Append("end \n\n");
      }
    }

    void OnGUI()
    {
        GUILayout.Label("请确保Prefab的预览挂在【UIRoot】或【UICamera】下，否则出错", EditorStyles.boldLabel);
        GUILayout.Space(30f);

        GUILayout.Label("作者名字:", EditorStyles.label);
        m_luaAuthorName = EditorGUILayout.TextArea(m_luaAuthorName, GUILayout.Width(150));
        GUILayout.Space(10f);

        GUILayout.Label("lua文件所在的文件夹名（相对于 XY_Lua/logic/，如：level_sys)", EditorStyles.label);
        m_luaFolderName = EditorGUILayout.TextArea(m_luaFolderName, GUILayout.Width(150));
        GUILayout.Space(10f);

        GUILayout.Label("ui prefab文件所在的文件夹名（相对于 Resource/Prefab/UI/，如：Level)", EditorStyles.label);
        m_uiPrefabFolderName = EditorGUILayout.TextArea(m_uiPrefabFolderName, GUILayout.Width(150));
        GUILayout.Space(30f);

      if (GUILayout.Button("生 成"))
      {
          if (m_luaFolderName == null || m_uiPrefabFolderName == null || m_luaFolderName.Length < 1 || m_uiPrefabFolderName.Length < 1)
          {
              ShowNotification(new GUIContent("失败！文件夹名不能为空！"));
              return;
          }

        // 文件名和prefab的名字一样
        // 向上取得prefab的名字
          goPrefab = null;
       if (Selection.gameObjects.Length > 0)
       {
           GameObject go = Selection.gameObjects[0];
           Transform parentTrans = go.transform.parent;
           while (parentTrans != null)
           {
               if (parentTrans.gameObject.GetComponent<UIRoot>() != null || parentTrans.gameObject.GetComponent<Camera>() != null)
               {
                   goPrefab = go;
                   m_fileName = goPrefab.name;
                   break;
               }
               go = parentTrans.gameObject;
               parentTrans = parentTrans.parent;
           }

           if (goPrefab == null)
           {
               ShowNotification(new GUIContent("失败！Prefab的根节点没有挂在【UIRoot】或【UICamera】下！"));
               return;
           }
        }
       else
       {
           ShowNotification(new GUIContent("失败！请至少选择一个节点，如果不想选，就选择根节点"));
           return;
       }

       Debug.Log("开始！！！！！！！！！");
       Debug.Log("lua文件：" + GetLuaFilePath());
       Debug.Log("ui prefab文件：" + GetUIPrefabFilePath());

        // 挂上LogicBaseLua
       LogicBaseLua logicBaseLua = goPrefab.GetComponent<LogicBaseLua>();
       if (logicBaseLua == null)
       {
           logicBaseLua = goPrefab.AddComponent<LogicBaseLua>();
       }
       logicBaseLua.fullLuaFileName = GetLuaBehaviorPath();
       logicBaseLua.isOldUnique = true;

        // table declare
        StringBuilder fileContent = new StringBuilder();

        fileContent.Append("--[[--\n");
        fileContent.Append("* @Description: description\n");
        fileContent.AppendFormat("* @Author:   {0}\n", m_luaAuthorName);
        fileContent.AppendFormat("* @FileName:  {0}\n", m_fileName + ".lua");
        fileContent.Append("* @DateTime:  " + DateTime.Now.ToString() + "\n");
        fileContent.Append("]]\n\n");

        // 目前只支持生成单例对象的lua
        MakeSingleClassLua(fileContent);

        string file = GetLuaFilePath();
        StreamWriter textWriter = new StreamWriter(file, false, Encoding.UTF8);

        textWriter.Write(fileContent.ToString());
        textWriter.Flush();
        textWriter.Close();

        Debug.Log("完成！！！！！！！！！！！");

        ShowNotification(new GUIContent("成功！Lua文件生成在：" + GetLuaBehaviorPath()));
      }
    }
}
