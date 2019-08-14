using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace NS_DataCenter
{
    public interface IVLResLoad
    {
        /// <summary>
        /// 加载资源
        /// </summary>
        /// <param name="strName"></param>
        /// <returns></returns>
        Object Load(string strName);
        Object Load(string strName, System.Type type);

        /// <summary>
        /// 异步加载场景文件
        /// </summary>
        /// <param name="strSceneName"></param>
        //void LoadLevelAsync(string strSceneName);
    }
}
