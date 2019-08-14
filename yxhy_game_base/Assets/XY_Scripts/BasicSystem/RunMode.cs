using System.Collections.Generic;
using UnityEngine;

public class RunMode
{
    static RunMode s_instance = new RunMode();
    static public RunMode Instance { get{ return s_instance; } }

    bool m_bSingleMode = false;
    bool m_bLogNetwork = true;

    public bool SingleMode { get { return m_bSingleMode; } set { m_bSingleMode = value; } }
    public bool LogNetwork { get { return m_bLogNetwork; } set { m_bLogNetwork = value; } }

    Dictionary<uint, int> m_dictFilter = new Dictionary<uint, int>();

    Dictionary<uint, int> m_dictShow = new Dictionary<uint, int>();
    public bool OnlyShow = false;

    public void Clear() 
    {
        m_dictFilter.Clear();
        m_dictShow.Clear();
        OnlyShow = false;
    }

    public void Add(uint checkId)
    {
        m_dictFilter[checkId] = 1;
    }

    public void AddShow(uint checkId)
    {
        OnlyShow = true;
        m_dictShow[checkId] = 1;
    }

    //不包含在里面的就显示
    public bool IsShowLog(uint checkId) 
    {
        if (OnlyShow)
        {
            return m_dictShow.ContainsKey(checkId);
        }
        return !m_dictFilter.ContainsKey(checkId);
    }

}