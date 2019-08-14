using UnityEngine;
using System.Collections;
using System.IO;
using System.Collections.Generic;
using System;

public class TimeCostType
{
    public static string LoadingLoad = "Loading加载";
    //空场景加载
    public static string NullSceneLoad;
    //场景资源加载
    public static string SaceneAssetsLoad = "场景资源加载";
    //预加载资源
    //public static string PreloadAssets = "预加载";
    public static string InstantiateAssets = "同步实例化资源";
    public static string CreateSceneUI = "创建场景UI";
    public static string PiaoZiMode = "飘字模块";

    public static string InitData = "初始化数据";
    public static string UIPrefabPool = "UI预设池创建";

    public static string LevelSysEnter = "进入场景系统";

    public static string ClearData = "清除数据";
    public static string StartLevel = "开始进入关卡后的相应处理";

    public static string One = "One";
    public static string Two = "Two";
    public static string Three = "Three";
    public static string Four = "Four";
    public static string Five = "Five";
    public static string Six = "Six";
    public static string Seven = "Seven";
    public static string Eight = "Eight";
}

public enum eTimeCost 
{
    eNone = 0,
    eChangePart,
    ePreLoad,  //总的loading
    ePreloadScene, //纯scene
    ePreUnloadScn, //scene的资源
    ePreloadAsset, //load各种资源
    ePreLoadAssetAsy,//load各种资源异步等待的时间
    ePreLoadSycAndAsy,//后面节异步等待的时间
}



public class TimeCostInfo 
{
    public int num = 0;
    public float times = 0.0f;
    public float beginTime = 0.0f;
}

public class SceneTimeInfo
{
    public int scneid = 0;
    public eTimeCost key = 0;
    public int num = 0;
    public float times = 0.0f;
    public float beginTime = 0.0f;
    public float endTime = 0.0f;
}


public class TimeCostLog : MonoBehaviour
{
    private static TimeCostLog instance = null;
    public static TimeCostLog Instance
    {
        get
        {
            if (instance == null)
            {
                GameObject go = new GameObject("TempDebugger");
                DontDestroyOnLoad(go);
                instance = go.AddComponent<TimeCostLog>();
            }
            return instance;
        }
    }

    private Dictionary<string, DateTime> timingDic = new Dictionary<string, DateTime>();
    private List<string> logList = new List<string>();

    private Dictionary<int, TimeCostInfo> timeRecord = new Dictionary<int, TimeCostInfo>();

    private Dictionary<int, SceneTimeInfo> scnRecord = new Dictionary<int, SceneTimeInfo>();

    private bool m_bRecord = false;

    public void Record(bool bRecord)
    {
        if (!bRecord)
        {
            timeRecord.Clear();
        }
        m_bRecord = bRecord;
    }

    public void WriteLog(string log)
    {
        if (!string.IsNullOrEmpty(log))
        {
            if (!timingDic.ContainsKey(log))
            {
                timingDic.Add(log, DateTime.Now);
            }
            else
            {
                DateTime lastDT = timingDic[log];
                DateTime dtNow = DateTime.Now;
                TimeSpan ts = dtNow - lastDT;

                timingDic.Remove(log);

                log = string.Format("--加载--开始时间:{0}--结束时间:{1}--耗时:{2}--模块名:{3}", lastDT.ToString("hh:mm:ss.fff"), dtNow.ToString("hh:mm:ss.fff"), (int)ts.TotalMilliseconds, log);
                logList.Add(log);
            }
        }
        else
        {
            logList.Add(log);
        }
    }

    public void WiriteLog(eTimeCost e,bool begin = true) 
    {
        if (!m_bRecord)
            return;
        if (!timeRecord.ContainsKey((int)e))
        {
            timeRecord[(int)e] = new TimeCostInfo();
        }
        TimeCostInfo tc = timeRecord[(int)e];
        if (begin)
        {
            tc.beginTime = Time.realtimeSinceStartup;
        }
        else 
        {
            tc.num++;
            tc.times += Time.realtimeSinceStartup - tc.beginTime;
        }
    }

    public void WriteLog(uint sceneid,eTimeCost e,bool begin = true) 
    {
        int id = (int)sceneid << 16 | (int)e;
        if (!scnRecord.ContainsKey(id))
        {
            scnRecord[id] = new SceneTimeInfo();
        }
        SceneTimeInfo st = scnRecord[id];
        st.key = e;
        st.scneid = (int)sceneid;
        if (begin)
        {
            st.beginTime = Time.realtimeSinceStartup;
        }
        else 
        {
            st.endTime = Time.realtimeSinceStartup;
            st.times += (st.endTime - st.beginTime);
            st.num++;
        }
    }

    public void WriteLogToFile()
    {
        if (Application.isMobilePlatform || m_bRecord)
        {
            if (timingDic.Count != 0)
            {
                Debug.LogWarning("--WriteLogToFile-->" + timingDic.Count);
            }

            foreach (var item in scnRecord)
            {
                SceneTimeInfo st = item.Value;
                string str = string.Format("scid:{0},key:{1},num:{2},times:{3}", st.scneid, st.key, st.num, st.times);
                if (st.num > 0)
                    str += " avt:" + (st.times / st.num).ToString();
                LuaInterface.Debugger.Log(str);
            }

            //StreamWriter sw = null;
            //sw = new StreamWriter(Best.BundleConfig.Instance.BundlesPathForPersist + "loadtime.txt");
            //sw.WriteLine("");
            //sw.WriteLine("记录时间:" + System.DateTime.Now);

            //foreach (string item in logList)
            //{
            //    sw.WriteLine(item);
            //}

            //foreach (var item in timeRecord)
            //{
            //    string str = string.Format("key:{0},num:{1},val:{2}", item.Key, item.Value.num, item.Value.times);
            //    sw.WriteLine(str);
            //}

            //foreach (var item in scnRecord)
            //{
            //    SceneTimeInfo st = item.Value;
            //    string str = string.Format("scid:{0},key:{1},num:{2},times:{3}",st.scneid,st.key,st.num,st.times);
            //    if (st.num > 0)
            //        str += " avt:" + (st.times / st.num).ToString();
            //    sw.WriteLine(str);
            //}

            //sw.Flush();
            //sw.Close();
        }
    }
}
