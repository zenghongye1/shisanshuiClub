/********************************************************************
	created:	2017/05/18  20:45
	file base:	BestUIPreview
	file ext:	cs
	author:		shine
	purpose:	用来fix有些NGUI的prefab拖拽到hierarchy窗口中没有默认添加UI Root等相关GameObject的问题
                在右键菜单中添加了一个菜单进行preview
*********************************************************************/
using UnityEngine;
using System.Collections;
using UnityEditor;

public class XYHYUIPreview : MonoBehaviour {

    [MenuItem("Assets/Preview UI Prefab")]
    public static void PreviewGameObject()
    {
        if (null != Selection.gameObjects)
        {
            foreach (GameObject onePrefab in Selection.gameObjects)
            {
                GameObject go = PrefabUtility.InstantiatePrefab(onePrefab) as GameObject;
                GameObject UIRootObject = GameObject.Find("UI Root");
                if (UIRootObject == null)
                {
                    UICreateNewUIWizard.CreateNewUI(UICreateNewUIWizard.CameraType.Simple2D);
                    UIRootObject = GameObject.Find("UI Root");
                }
                UIRootObject.layer = 5;
                UIRoot uiRoot = UIRootObject.GetComponent<UIRoot>();
                uiRoot.scalingStyle = UIRoot.Scaling.Constrained;
                uiRoot.manualHeight = 720;
                go.transform.SetParent(UIRootObject.transform, false);
                Selection.activeObject = go;
            }
        }
    }
}
