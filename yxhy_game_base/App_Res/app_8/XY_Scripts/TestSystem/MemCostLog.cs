
using System.Collections;
using System.Collections.Generic;

public enum eTM 
{
    eCSharpBin = 0,
    eGameStart = 1,
    eBin,
    eResLoad,
}

public class TMem 
{
    public int id = 0;
    public uint totle = 0;
    public uint before = 0;
    public uint after = 0;
    public uint num = 0;
    public uint curHeap = 0;
    public uint beforeHeap = 0;
}

public class MemCostLog  
{
    static MemCostLog s_instance = null;
    public static MemCostLog Instance 
    {
        get 
        {
            if (s_instance==null)
            {
                s_instance = new MemCostLog();
            }
            return s_instance;
        }
    }

    Dictionary<int, TMem> dict = new Dictionary<int, TMem>();
    //List<TMem> LstMem = new List<TMem>();
    //Directory<int, TMem> dict = new Directory<int, TMem>();
    public void Record(eTM e,bool before)
    {
        int id = (int)e;
        TMem t = null;
        if (dict.ContainsKey(id))
        {
            t = dict[id];
        }
        else 
        {
            t = new TMem();
            dict[id] = t;
        }
       /* uint val = UnityEngine.Profiling.Profiler.GetMonoUsedSize();
        if (before)
        {
            t.before = val;
            t.beforeHeap = UnityEngine.Profiling.Profiler.GetMonoHeapSize();
        }
        else 
        {
            t.after = val;
            if (t.after > t.before)
                t.totle = t.after - t.before;
            t.num++;
            t.curHeap = UnityEngine.Profiling.Profiler.GetMonoHeapSize();
        }*/
    }
}
