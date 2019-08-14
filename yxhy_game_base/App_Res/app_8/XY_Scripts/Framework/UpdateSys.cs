using UnityEngine;
using System.Collections;


namespace Framework
{
    public class UpdateSys : MonoBehaviour
    {
        static string  UpdateMgr = "UpdateMgr";
        static private UpdateSys m_Instance = null;
        static public UpdateSys Instance
        {
            get
            {
                if (m_Instance == null)
                {
                    m_Instance = (new GameObject(UpdateMgr)).AddComponent<UpdateSys>();
                    GameObject.DontDestroyOnLoad(m_Instance.gameObject);
                }
                return m_Instance;
            }
        }

        public void ShowUpdateUI()
        {
            XYHY.IResourceMgr resMgr = GameKernel.Get<XYHY.IResourceMgr>();
            Object verUpdateObj = resMgr.LoadNormalObjSync(new AssetBundleParams("app_8/ui/version_update_ui/version_update_ui", typeof(GameObject)));
            GameObject verUpdateGo = GameObject.Instantiate(verUpdateObj) as GameObject;
            DontDestroyOnLoad(verUpdateGo);            
            verUpdateGo.transform.parent = GameObject.FindGameObjectWithTag("NGUI").transform;
            verUpdateGo.transform.localScale = Vector3.one;
        }

        public void StartGame()
        {
            //GameKernel.GetResourceMgr().UnloadAllNormalResources();
            GameKernel.Shutdown();

            StartCoroutine(startGame());
        }
        
        /// <summary>
        /// 加载完成
        /// </summary>
        IEnumerator startGame()
        {
            LuaInterface.Debugger.Log("开始游戏");
            // 创建游戏内核
            yield return null;

            GameAppInstaller.CreateUIRoot();

            GameKernel.Create();
        }
    }
}