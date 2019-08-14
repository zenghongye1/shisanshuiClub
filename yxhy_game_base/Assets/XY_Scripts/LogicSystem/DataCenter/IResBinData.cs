using System;
using UnityEngine;
using System.Collections.Generic;
using dataconfig;

namespace NS_DataCenter
{
    public interface IResBinData
    {
	    void Initialize();

        void UnInitialize();
                
        //List<string> GetPreloadAssetsByID(uint sceneLevelID);

        //List<string> GetPreloadAndPrehotAssetsByID(uint sceneLevelID);

        //资源配置表
        //ResConfig GetResConfigByID(int ID);

        //获取场景配置根据场景id
        SceneConfig GetSceneConfByID(uint sceneID);

        DirtyConfArray GetDirtyConfigArray();
    }
}