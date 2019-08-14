using UnityEngine;
using System.Collections;
using System.IO;
using BestHTTP;
using System;

public class FileReader : MonoBehaviour
{
    //string path;
    string filepath;
    public static FileReader mInstance;
    void Awake()
    {
        
        //path = Application.persistentDataPath + "/gamerule/";
        mInstance = this;
    }
   

    

    public static FileReader GetInstance()
    {
        if(mInstance!=null)
        {
            return mInstance;
        }
        return null;
    }
    public static string ReadFile(string filepath)
    {
        if (!File.Exists(filepath))
        {
            Debug.Log("文件不存在--------------");
            return null;
        }
        //print(filepath);
        var str = File.ReadAllText(filepath);
        return str;

    }
    //void OnGUI()
    //{
    //    GUIStyle bb = new GUIStyle();
    //    bb.normal.background = null;    //这是设置背景填充的
    //    bb.normal.textColor = new Color(1, 0, 0);   //设置字体颜色的
    //    bb.fontSize = 40;       //当然，这是字体颜色
    //    GUI.Label(new Rect(10, 10, 200, 200), path);
    //}

    public static bool IsFileExists(string name)
    {
        if (name == null||name == "")
        {
            return false;
        }
        return File.Exists(name);
    }
   

}
