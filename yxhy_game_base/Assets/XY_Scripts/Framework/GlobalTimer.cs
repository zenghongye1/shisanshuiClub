using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;

namespace Framework
{
    /// <summary>
    /// <para>KLTimer基于Time.realtimeSinceStartup，不受Time.timeScale的影响。</para>
    /// </summary>
    public class GlobalTimer
    {
        static GlobalTimer s_instance = new GlobalTimer();
        public static GlobalTimer Instance
        {
            get { return s_instance; }
        }

        public delegate void TimerHandler(float deltaTime);
        public delegate void TimerCompleteHandler();

        #region definition
        class TimerData
        {
            public float m_intervalSec;         // 间隔(s)
            public int m_repeatCount;           // 重复次数，小于等于0表示无限循环
            public int m_currentCount = 0;      // 当前重复次数
            public float m_lastTime = 0.0f;     // 上次触发时间

            event TimerHandler OnTimerHandler = null;
            event TimerCompleteHandler OnTimerCompleteHandler = null;

            public void Clear()
            {
                OnTimerHandler = null;
                OnTimerCompleteHandler = null;
            }

            public void AddHandler(TimerHandler handler, TimerCompleteHandler completeHandler)
            {
                OnTimerHandler += handler;
                OnTimerCompleteHandler += completeHandler;
            }
            public void RemoveHandler(TimerHandler handler, TimerCompleteHandler completeHandler)
            {
                OnTimerHandler -= handler;
                OnTimerCompleteHandler -= completeHandler;
            }
            public void ExcuteTimerHandler(float deltaTime)
            {
                if (OnTimerHandler != null)
                {
                    OnTimerHandler(deltaTime);
                }
            }
            public void ExcuteTimerCompleteHandler()
            {
                if (OnTimerCompleteHandler != null)
                {
                    OnTimerCompleteHandler();
                }
            }
            public TimerHandler GetTimerHandler()
            {
                return OnTimerHandler;
            }
        }
        Dictionary<TimerHandler, TimerData> m_dicTimer = new Dictionary<TimerHandler, TimerData>();
        Queue<TimerData> m_timerDataPool = new Queue<TimerData>(50);        // timer对象池,最多支持50个timer同时存在

        bool m_isRunning = false;
        bool m_bListChanged = false;
        List<TimerData> m_listNeedDeleteData = new List<TimerData>();
        #endregion

        #region interface
        public void SetTimer(float intervalSec, TimerHandler handler, int repeatCount = 0, TimerCompleteHandler completeHandler = null)
        {
            TimerData timerData = NewTimerData(handler);
            if (timerData != null)
            {
                timerData.m_intervalSec = intervalSec;
                timerData.m_repeatCount = repeatCount;
                timerData.m_currentCount = 0;
                timerData.m_lastTime = Time.time;

                timerData.AddHandler(handler, completeHandler);
            }
        }

        public void RemoveTimer(TimerHandler handler)
        {
            DeleteTimerData(handler);
        }

        public void Update()
        {
            if (m_isRunning)
            {
                Dictionary<TimerHandler, TimerData>.Enumerator iter = m_dicTimer.GetEnumerator();
                TimerData data = null;
                float deltaTime = 0.0f;
                float curTime = Time.time;

                m_bListChanged = false;
                m_listNeedDeleteData.Clear();
                while (m_bListChanged == false && iter.MoveNext())
                {
                    data = m_dicTimer[iter.Current.Key];
                    deltaTime = curTime - data.m_lastTime;
                    if (deltaTime > data.m_intervalSec)
                    {
                        data.m_currentCount++;
                        data.m_lastTime = curTime;
                        data.ExcuteTimerHandler(deltaTime);
                    }

                    if (data.m_repeatCount > 0 && data.m_currentCount >= data.m_repeatCount)
                    {
                        m_listNeedDeleteData.Add(data);
                        //data.ExcuteTimerCompleteHandler();

                        //// 删除这个timer
                        //RemoveTimer(data.GetTimerHandler());
                    }
                }

                if (m_listNeedDeleteData.Count > 0)
                {
                    for (int i = m_listNeedDeleteData.Count - 1; i >= 0; --i)
                    {
                        if (m_listNeedDeleteData[i] != null)
                        {
                            m_listNeedDeleteData[i].ExcuteTimerCompleteHandler();
                            RemoveTimer(m_listNeedDeleteData[i].GetTimerHandler());
                        }
                    }
                    m_listNeedDeleteData.Clear();
                }
            }
        }
        #endregion

        #region private functions
        TimerData NewTimerData(TimerHandler handler)
        {
            if (handler == null)
            {
                Debugger.LogError("Create TimerData Fail!!! can not settimer without TimerHandler");
                return null;
            }
            if (m_dicTimer.ContainsKey(handler))
            {
                Debugger.LogWarning("Create TimerData Fail!!! TimerHandler is already in Timer List");
                return null;
            }

            TimerData data = null;
            if (m_timerDataPool.Count > 0)
            {
                data = m_timerDataPool.Dequeue();
            }
            else
            {
                data = new TimerData();
            }
            m_dicTimer.Add(handler, data);
            m_bListChanged = true;

            if (m_dicTimer.Count > 50)
            {
                Debugger.LogError("too many timer: " + m_dicTimer.Count);
            }

            m_isRunning = true;
            return data;
        }

        void DeleteTimerData(TimerHandler handler)
        {
            if (m_dicTimer.ContainsKey(handler))
            {
                m_timerDataPool.Enqueue(m_dicTimer[handler]);
                m_dicTimer[handler].Clear();

                m_dicTimer.Remove(handler);
                m_bListChanged = true;

                if (m_dicTimer.Count == 0)
                {
                    m_isRunning = false;
                }
            }
            //else
            //{
            //    Debugger.Log("RemoveTimer Fail!!! TimerHandler not in Timer List");
            //}
        }
        #endregion
    }
}

