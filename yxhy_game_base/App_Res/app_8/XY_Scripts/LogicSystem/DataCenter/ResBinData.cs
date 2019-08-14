using System;
using UnityEngine;
using System.Collections.Generic;
using dataconfig;
using ProtobufDataConfig;
using LuaInterface;

namespace NS_DataCenter
{
    public class ResBinData : IResBinData
    {
        private SceneConfigArray m_sceneConfList = null;                                        // 场景配置表
        private Dictionary<int, SceneConfig> dicSceneConfig = new Dictionary<int, SceneConfig>();
        private DirtyConfArray m_dirtyConfList = null;
        private Dictionary<int, DirtyConf> dicDirtyConf = new Dictionary<int, DirtyConf>();

        private bool m_bHadLoadBin = false;

        private ResBinData()
        {
            //私有，避免有同学乱创建
        }

        static ResBinData s_instance = null;
        static public ResBinData Instance
        {
            get
            {
                if (s_instance == null)
                {
                    s_instance = new ResBinData();
                }
                return s_instance;
            }
        }


        public void Initialize()
        {
            LoadBinConfig();
        }

        public void UnInitialize()
        {

        }

        private void LoadBinConfig()
        {
            //避免反复初始化
            if (m_bHadLoadBin)
                return;
            m_bHadLoadBin = true;

            if (m_sceneConfList == null)
            {
                m_sceneConfList = ProtobufDataConfigMgr.ReadOneDataConfig<SceneConfigArray>("dataconfig_sceneconfig");
                //m_dirtyConfList = ProtobufDataConfigMgr.ReadOneDataConfig<DirtyConfArray>("dataconfig_dirtyconf");
            }                
        }

        /*public GeneralConfig GetCommConfigByID(int ID)
        {
            if (dicGeneralConfig.ContainsKey((int)ID))
            {
                return dicGeneralConfig[(int)ID];
            }

            GeneralConfig ret = null;
            for (int i = 0; i < m_listCommConfig.items.Count; ++i)
            {
                GeneralConfig item = m_listCommConfig.items[i];
                if (item.id == ID)
                {
                    ret = item;
                    dicGeneralConfig.Add((int)ID, ret);
                    break;
                }
            }

            if (ret == null)
            {
                //Debugger.LogError("GetCommConfigByID, not found: " + ID);
            }

            return ret;
        }
        

        public List<string> GetPreloadAssetObjListInfoByID(uint ID)
        {
            return null;
        }

        public List<string> GetPreloadAssetsByID(uint sceneLevelID)
        {
            List<string> retList = new List<string>();
            LevelConfig levelConfig = null;
            
            if (levelConfig == null)
            {
                if (m_LevelDataList == null)
                    m_LevelDataList = ProtobufDataConfigMgr.ReadOneDataConfig<LevelConfigArray>("dataconfig_levelconfig");

                if (m_LevelDataList != null)
                    levelConfig = m_LevelDataList.items.Find(item => item.id == sceneLevelID);
            }

            if (levelConfig == null)
            {
                return retList;
            }

            List<uint> assetPathIdList = levelConfig.assetPathIdList;
            if (assetPathIdList != null)
            {
                for (int i = 0; i < assetPathIdList.Count; i++)
                {
                    InitLevelUISetList();
                    LevelUISet set = m_LevelUISetList.items.Find(item => item.assetPathListId == assetPathIdList[i]);
                    if (set != null)
                        retList.AddRange(set.assetPathList);
                }
            }
            
            retList = filterNullString(retList);

            return retList;
        }

        public List<string> GetPreloadAndPrehotAssetsByID(uint sceneLevelID)
        {
            List<string> retList = new List<string>();
            LevelConfig levelConfig = null;

            if (levelConfig == null)
            {
                if (m_LevelDataList == null)
                    m_LevelDataList = ProtobufDataConfigMgr.ReadOneDataConfig<LevelConfigArray>("dataconfig_levelconfig");

                if (m_LevelDataList != null)
                    levelConfig = m_LevelDataList.items.Find(item => item.id == sceneLevelID);
            }

            if (levelConfig == null)
            {
                return retList;
            }

            List<uint> prehotAssetPathIdList = levelConfig.prehotAssetPathIdList;
            if (prehotAssetPathIdList != null)
            {
                for (int i = 0; i < prehotAssetPathIdList.Count; i++)
                {
                    if (m_LevelUISetList == null)
                        m_LevelUISetList = ProtobufDataConfigMgr.ReadOneDataConfig<LevelUISetArray>("dataconfig_leveluiset");

                    LevelUISet set = m_LevelUISetList.items.Find(item => item.assetPathListId == prehotAssetPathIdList[i]);
                    if (set != null)
                        retList.AddRange(set.assetPathList);
                }
            }
  
            retList = filterNullString(retList);

            return retList;
        }*/

        private List<string> filterNullString(List<string> list)
        {
            List<string> retList = new List<string>();
            for (int i = 0; i < list.Count; i++)
            {
                if (!string.IsNullOrEmpty(list[i]))
                {
                    retList.Add(list[i]);
                }
            }

            return retList;
        }

        /*public List<string> GetPreloadAssetGOListInfoByName(string sceneName)
        {
            List<string> retList = null;

            if (m_LevelPrefabsSetList == null)
            {
                m_LevelPrefabsSetList = ProtobufDataConfigMgr.ReadOneDataConfig<LevelPrefabsSetArray>("dataconfig_levelprefabsset");
            }
            LevelPrefabsSet set = m_LevelPrefabsSetList.items.Find(item => item.sceneName == sceneName);

            if (set != null)
                retList = new List<string>(set.assetPrefabPathList);

            return retList;
        }*/

        public List<string> GetImmortalAssetList(uint ID)
        {
            List<string> retList = new List<string>();

            return retList;
        }

        public SceneConfig GetSceneConfByID(uint ID)
        {
            if (m_sceneConfList == null) m_sceneConfList = ProtobufDataConfigMgr.ReadOneDataConfig<SceneConfigArray>("dataconfig_sceneconfig");

            if (dicSceneConfig.ContainsKey((int)ID))
            {
                return dicSceneConfig[(int)ID];
            }

            SceneConfig ret = null;
            for (int i = 0; i < m_sceneConfList.items.Count; ++i)
            {
                SceneConfig item = m_sceneConfList.items[i];
                if (item.id == ID)
                {
                    ret = item;
                    dicSceneConfig.Add((int)ID, ret);
                    break;
                }
            }

            return ret;
        }

        public DirtyConfArray GetDirtyConfigArray()
        {
            return m_dirtyConfList;
        }
    }
}