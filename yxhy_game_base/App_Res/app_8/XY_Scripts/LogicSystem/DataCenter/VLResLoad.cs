
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Framework;
using System.IO;

namespace NS_DataCenter
{
    public class VLResLoad : VLData, IVLResLoad
    {
        private WWW m_wwwScene = null;

        public override void Initialize(IDataCenter datacenter)
        {
            m_Parent = datacenter;
        }

        public override void UnInitialize()
        {
            if (m_wwwScene != null)
            {
                m_wwwScene.assetBundle.Unload(false);
                m_wwwScene = null;
            }
            Resources.UnloadUnusedAssets();
        }

        public Object Load(string strName)
        {
            return Load(strName, typeof(GameObject));
        }

        public Object Load(string strName, System.Type type)
        {
            Object obj = Resources.Load(strName, type);
            return obj;
        }

        //IEnumerator LoadScene(string strSceneName)
        //{
        //    yield return null;
        //    Application.LoadLevel(strSceneName);
        //}

        //public void LoadLevelAsync(string strSceneName)
        //{
        //    GameKernel.StartMonoCoroutine(LoadScene(strSceneName));
        //}

        public void UnloadSceneAB()
        {
            if (m_wwwScene != null)
            {
                m_wwwScene.assetBundle.Unload(false);
                m_wwwScene = null;
            }
        }

        IEnumerator UnloadSceneABEnumerator()
        {
            yield return null;

            UnloadSceneAB();
        }
    }	
}
