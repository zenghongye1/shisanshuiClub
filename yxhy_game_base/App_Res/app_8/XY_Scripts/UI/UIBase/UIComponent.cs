using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Framework;
using NS_DataCenter;
using XYHY;

public interface IUIComponentContainer
{
    void SetUIComponent<T>(T Comp) where T : UIComponent<T>;
}

public abstract class UIComponent<T> : UIComponentBase 
    where T : UIComponent<T>
{
    public static bool HasInstance
    {
        get
        {
            return mInstance.IsValid;
        }
    }

    public static T Instance
    {
        get
        {
            if (!mInstance.IsValid)
            {
                CreateInstance();
            }

            return mInstance.Target;
        }
    }

    public static T Create(MonoBehaviour container, GameObject parent, Camera camera, string resPath, 
        bool bCreateInstance = false,
       int nDestroyType = 0)
    {
        mParent.Target =  parent;
        mCamera.Target = camera;
        mContainer.Target = container;
        mResPath = resPath;
        CreateInstanceTable[typeof(T).ToString()] = CreateInstance;
        DestroyInstanceTable[typeof(T).ToString()] = ReleaseObject;
        mCurReleaseType = (int)nDestroyType;

        if (bCreateInstance)
        {
            return Instance;
        }

        return null;
    }

    IEnumerator DestroyUIGameObject( GameObject go)
    {
        yield return null;
        RealDestroyGameObject(go);
    }
    private static void RealDestroyGameObject(GameObject go)
    {      
        if (go == m_kAlwaysToTopGo)
        {
            m_kAlwaysToTopGo = null;
        }
        Object.Destroy(go);
        mInstance.Target = null;

        GameKernel.StartMonoCoroutine(ReleaseResources());
    }

    private static IEnumerator ReleaseResources()
    {
        yield return new WaitForEndOfFrame();
        Resources.UnloadUnusedAssets();
    }

    public static void ReleaseObject()
    {
        if (HasInstance)
        {
            if (Instance.gameObject)
            {
                if (Instance.gameObject.activeInHierarchy == false)
                {
                    RealDestroyGameObject(Instance.gameObject);
                }
                else
                {
                    Instance.StartCoroutine(Instance.DestroyUIGameObject(Instance.gameObject));
                }
                if (m_nCurMaxDepth > 0x0fffffff)
                {
                    m_nCurMaxDepth = 1000;
                }
            }           
        }
    }

    public static GameObject AddChildToGameObj(GameObject kGoParent, string strPrefabPath)
    {
        GameObject obj = null;
        if (string.IsNullOrEmpty(strPrefabPath) == false)
        {
            Object resObj = GameKernel.Get<IDataCenter>().GetDataType<IVLResLoad>().Load(strPrefabPath);
            if (resObj != null)
            {
                obj = Object.Instantiate(resObj) as GameObject;

                if (kGoParent != null)
                {
                    obj.transform.parent = kGoParent.transform;
                    obj.transform.localPosition = new Vector3(0f, 0f, 0f);
                    obj.transform.localRotation = Quaternion.identity;
                    obj.transform.localScale = Vector3.one;
                }

                UIAnchor[] m_Anchors = obj.GetComponentsInChildren<UIAnchor>();
                obj.SetActive(true);

                foreach (UIAnchor a in m_Anchors)
                {
                    a.uiCamera = kGoParent.GetComponent<Camera>();
                }
            }            
        }

        return obj;
    }

    static void  RefreshPanelDepth(GameObject goPanel)
    {
        XY_UILayer uiLayer = goPanel.GetComponent<XY_UILayer>();
        if (uiLayer)
        {
            int nDelta = 400 * uiLayer.GetLayerbase();
            int nZDelta = -1000 * uiLayer.GetLayerbase();

            UIPanel[] uiPanels = goPanel.GetComponentsInChildren<UIPanel>(true);
            if (uiPanels.Length > 0)
            {
                Vector3 pos = uiPanels[0].gameObject.transform.localPosition;
                pos.z += nZDelta;
                uiPanels[0].gameObject.transform.localPosition = pos;
            }

            for (int i = 0; i < uiPanels.Length; ++i)
            {
                uiPanels[i].depth += nDelta;               
            }
        }
    }  

    static void CreateInstance()
    {
        ReleaseObject();

        IResourceMgr resourceMgr = GameKernel.Get<IResourceMgr>();
        Object resObj = resourceMgr.LoadNormalObjSync(new AssetBundleParams(mResPath, typeof(GameObject), 0));
        if (resObj != null)
        {
            GameObject obj = Object.Instantiate(resObj) as GameObject;

            if (Parent != null)
            {
                obj.transform.parent = Parent.transform;
                obj.transform.localPosition = new Vector3(0f, 0f, 0f);
                obj.transform.localRotation = Quaternion.identity;
                obj.transform.localScale = Vector3.one;
                RefreshPanelDepth(obj);
            }

            UIAnchor[] m_Anchors = obj.GetComponentsInChildren<UIAnchor>();
            obj.SetActive(false);

            foreach (UIAnchor a in m_Anchors)
            {
                a.uiCamera = UICamera;
                a.gameObject.SetActive(true);
            }

            T component = obj.GetComponent<T>();
            mInstance.Target = component;
            mInstance.Target.ReleaseType = mCurReleaseType;
            IUIComponentContainer container = Container;
            if (container != null)
            {
                container.SetUIComponent<T>(component);
            }
        }
    }

    static XYWeakRef<T> mInstance = new XYWeakRef<T>(null);

    static GameObject Parent
    {
        get
        {
            if ( mParent.IsValid )
            {
                return mParent.Target;
            }

            return null;
        }
    }
    static XYWeakRef<GameObject> mParent = new XYWeakRef<GameObject>(null);

    static Camera UICamera
    {
        get 
        {
            if (mCamera.IsValid)
            {
                return mCamera.Target;
            }
            return null;
        }
    }
    static XYWeakRef<Camera> mCamera = new XYWeakRef<Camera>(null);

    static IUIComponentContainer Container
    {
        get
        {
            if ( mContainer.IsValid )
            {
                return mContainer.Target as IUIComponentContainer;
            }
            return null;
        }
    }
    static XYWeakRef<MonoBehaviour> mContainer = new XYWeakRef<MonoBehaviour>(null);
    static string mResPath;
    static int mCurReleaseType;
}
