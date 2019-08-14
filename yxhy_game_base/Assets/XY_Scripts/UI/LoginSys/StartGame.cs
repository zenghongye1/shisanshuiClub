using UnityEngine;
using System.Collections;

public class StartGame : MonoBehaviour
{
    /*[SerializeField]
    private GameObject mSplash;
    [SerializeField]
    private GameObject mAssetUpdate;
    */

    private void Awake()
    {        
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
    }

    private void Start()
    {        
        GameObject.DontDestroyOnLoad(this.gameObject);
        Framework.GameAppInstaller.m_UIRoot = this.gameObject;
        YX_APIManage.Instance.InitPlugins(true);
        //SetSplash();
    }

    /*void SetSplash()
    {
        if (mSplash != null)
        {
            if (Framework.GameAppInstaller.Instance.showSplashAnimation)
            {
                Spine.Unity.SkeletonAnimation ske = mSplash.GetComponentInChildren<Spine.Unity.SkeletonAnimation>();
                ske.playComPleteCallBack = (Spine.TrackEntry trackEntry) =>
                {
                    mSplash.gameObject.SetActive(false);
                    if (mAssetUpdate != null)
                    {
                        mAssetUpdate.gameObject.SetActive(true);
                    }
                };
            }
            else
            {
                mSplash.gameObject.SetActive(false);
                if (mAssetUpdate != null)
                {
                    mAssetUpdate.gameObject.SetActive(true);
                }
            }
            GameObject.Destroy(mSplash);
        }
    }*/
}
