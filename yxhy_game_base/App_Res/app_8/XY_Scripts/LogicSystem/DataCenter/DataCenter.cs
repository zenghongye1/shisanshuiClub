using UnityEngine;
using System;
using System.Collections.Generic;
using Framework;
using cs;

namespace NS_DataCenter
{
    public enum eGlobleData
    {
        eNone = 0,
        eMax,
    }

    public class DataCenter : IDataCenter, IInitializeable
    {
        IResBinData m_resBinData = null;
        /// <summary>
        /// 数据中心管理数据存储
        /// </summary>
        private Dictionary<VLDataType, object> m_DicDatas = new Dictionary<VLDataType, object>();

        /// <summary>
        /// 类型对应的数据类型
        /// </summary>
        private Dictionary<Type, VLDataType> m_DicType = new Dictionary<Type, VLDataType>();



        //全局的数据
        ulong m_globleState = 0;

        public void Initialize()
        {
            MemCostLog.Instance.Record(eTM.eResLoad, false);

            StartLoadConfigData();
            InitGlobleState();
            MemCostLog.Instance.Record(eTM.eCSharpBin, false);
        }


        public void UnInitialize()
        {

            m_resBinData = null;
        }

        void InitGlobleState() 
        {
            m_globleState = 0;
        }

        public bool IsBitMask(eGlobleData e) 
        {
            ulong val = (ulong)((ulong)1 << (int)e);
            return (m_globleState & val) > 0;
        }

        public void SetBitMask(eGlobleData e, bool bVal = false)
        {
            if (e < eGlobleData.eMax)
            {
                ulong val = (ulong)(1<<(int)e);
                if (bVal)
                {
                    m_globleState |= val;
                }
                else 
                {
                    m_globleState &= ~val;
                }
            }
        }

        public void StartLoadConfigData()
        {
            CreateDataType(VLDataType.BIN_DATA);         
        }

        void ClearLstData() 
        {

        }

        //不写判空，有异常直接让它崩，避免有内存问题
        private void DestroyData(VLDataType dt,object val) 
        {
  
        }

        private void CreateDataType(VLDataType dt)
        {
            if (m_DicDatas.ContainsKey(dt))
            {
                return;
            }

            switch (dt)
            {
                case VLDataType.BIN_DATA:
                    {
                        ResBinData res = ResBinData.Instance;//new ResBinData();
                        res.Initialize();
                        m_DicDatas.Add(dt, res);
                        m_DicType.Add(typeof(IResBinData), dt);
                        m_resBinData = res;
                    }
                    break;
                case VLDataType.RES_LOAD:
                    {
                        VLResLoad resLoad = new VLResLoad();
                        resLoad.Initialize(this);
                        m_DicDatas.Add(dt, resLoad);
                        m_DicType.Add(typeof(IVLResLoad), dt);
                    }
                    break;
                default:
                    break;
            }
        }

        public T GetDataType<T>()
        {
            T classT = default(T);
            Type type = typeof(T);
            if (m_DicType.ContainsKey(type) == true)
            {
                VLDataType dt = m_DicType[type];
                if (m_DicDatas.ContainsKey(dt) == true)
                {
                    object obj = m_DicDatas[dt];
                    classT = (T)obj;
                }
            }            

            return classT;
        }

        public IResBinData GetResBinData()
        {
            if (m_resBinData== null)
            {
                m_resBinData = GetDataType<NS_DataCenter.IResBinData>();
            }
            return m_resBinData;
        }
    }
}
