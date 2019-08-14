using UnityEngine;
using System;

public class TimeSpanManager
{
    private static volatile TimeSpanManager instance;
    private static readonly object syncRoot = new object();
    private TimeSpanManager() { }
    public static TimeSpanManager Instance
    {
        get
        {
            lock (syncRoot)
            {
                if (instance == null)
                {
                    instance = new TimeSpanManager();
                }
            }
            return instance;
        }
    }

    System.Diagnostics.Stopwatch watch = new System.Diagnostics.Stopwatch();

    public void Start()
    {
        watch.Reset();
        watch.Start();
    }

    public void Stop(string tag)
    {
        watch.Stop();
        TimeSpan time = watch.Elapsed;
        Debug.LogError(tag + "总毫秒数：" + time.TotalMilliseconds);
    }

}
