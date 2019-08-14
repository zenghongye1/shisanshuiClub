using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;

public class LogOutput : MonoBehaviour
{
    static LogOutput instance;

    public static LogOutput Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new GameObject("LogOutput").AddComponent<LogOutput>();
                DontDestroyOnLoad(instance.gameObject);
            }
            return instance;
        }
    }

    static List<string> mLines = new List<string>();
    static List<string> mWriteTxt = new List<string>();
    private string outpath;


    float _checkTime = 0;
    const float CHECK_INTERNAL = 2;
    public void Init()
    {

    }

    void Start()
    {
#if UNITY_EDITOR
        outpath = Application.dataPath + "Log";//路径：/AssetsCaches/
#elif UNITY_IOS
            outpath = Application.temporaryCachePath + "/Log";//路径：Application/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/Library/Caches/
#elif UNITY_ANDROID
            outpath = Application.persistentDataPath + "/Log";//路径：/data/data/xxx.xxx.xxx/files/
#else
            outpath = Application.streamingAssetsPath + "/Log";//路径：/xxx_Data/StreamingAssets/
#endif
        //Application.persistentDataPath Unity中只有这个路径是既可以读也可以写的。
        //outpath = Application.persistentDataPath + "/outLog.txt";
        //每次启动客户端删除之前保存的Log
        
        if (!Directory.Exists(outpath))
        {
            Directory.CreateDirectory(outpath);
        }

        if (System.IO.File.Exists(outpath + "/outLog.txt"))
        {
            File.Delete(outpath + "/outLog.txt");
        }

        //在这里做一个Log的监听
        //Application.RegisterLogCallback(HandleLog);
        Application.logMessageReceived += HandleLog;
        //BuglyAgent.RegisterLogCallback(HandleLog);

    }

    void Update()
    {
        _checkTime += Time.unscaledDeltaTime;
        if(_checkTime > CHECK_INTERNAL)
        {
            _checkTime = 0;
            WriteLogToFile();
        }
       
    }

    void WriteLogToFile()
    {
        if (mWriteTxt.Count == 0)
            return;
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < mWriteTxt.Count; i++)
        {
            sb.AppendLine(mWriteTxt[i]);
        }
        mWriteTxt.Clear();
        using (StreamWriter writer = new StreamWriter(outpath + "/outLog.txt", true, Encoding.UTF8))
        {
            writer.Write(sb.ToString());
        }
        //因为写入文件的操作必须在主线程中完成，所以在Update中哦给你写入文件。
        //if (mWriteTxt.Count > 0)
        //{
        //    string[] temp = mWriteTxt.ToArray();
        //    foreach (string t in temp)
        //    {
        //        using (StreamWriter writer = new StreamWriter(outpath + "/outLog.txt", true, Encoding.UTF8))
        //        {
        //            writer.WriteLine(t);
        //        }
        //        mWriteTxt.Remove(t);
        //    }
        //}
    }

    void HandleLog(string logString, string stackTrace, LogType type)
    {
        mWriteTxt.Add(logString);
        if (type == LogType.Error || type == LogType.Exception)
        {
            Log(logString);
            Log(stackTrace);
        }
    }

    //这里我把错误的信息保存起来，用来输出在手机屏幕上
    static public void Log(params object[] objs)
    {
        string text = "";
        for (int i = 0; i < objs.Length; ++i)
        {
            if (i == 0)
            {
                text += objs[i].ToString();
            }
            else
            {
                text += ", " + objs[i].ToString();
            }
        }
        if (Application.isPlaying)
        {
            if (mLines.Count > 20)
            {
                mLines.RemoveAt(0);
            }
            mLines.Add(text);

        }
    }


}