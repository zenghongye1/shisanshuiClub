using System.Collections.Generic;
using UnityEngine;

public class FPSCounter: MonoBehaviour
{    
    public float updateInterval = 0.5f;
    public UIPanel panel = null;
    public UILabel label = null;    
    public int depth = 2100;

    private float lastTime;
    public int frames = 0;
    static public FPSCounter Instance { get; set; }
    private int lastFPSValue = 0;
    private Dictionary<int, string> fpsDict = new Dictionary<int, string>();
    System.Action<int> fpsUpdateCallback=null;
    void Start()
    {
        Instance = this;
        lastTime = Time.unscaledTime;
        frames = 0;
        panel.depth = depth;
        for (int i = 1; i <= 60; ++i)
        {
            fpsDict.Add(i, i.ToString());
        }
    
    }

    void Update()
    { 
        ++frames;
        float timeNow = Time.unscaledTime;        

        if (timeNow > lastTime + updateInterval)
        {
            int fps = (int)(frames / (timeNow - lastTime));
            frames = 0;
            lastTime = timeNow;

            if (lastFPSValue != (int)fps)
            {
                if (fpsDict.ContainsKey((int)fps))
                {
                    string fpsString = fpsDict[(int)fps];
                    if (fpsString != null)
                    {
                        label.text = fpsString;
                        lastFPSValue = (int)fps;
                    }
                }
            }

            if (fpsUpdateCallback != null)
                fpsUpdateCallback(fps);          
        }
    }

    public void SetFpsUpdateCallback(System.Action<int> fpsCallback)
    {
        fpsUpdateCallback += fpsCallback;
    }
    public void RemoveCallback(System.Action<int> fpsCallback)
    {
        fpsUpdateCallback -= fpsCallback;
    }
}