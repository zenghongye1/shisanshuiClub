using UnityEngine;
using System.Collections;

public class UIscroll : MonoBehaviour { 
	public void OnClick()
    {
        UICenterOnChild center = NGUITools.FindInParents<UICenterOnChild>(gameObject);
        UIPanel panel = NGUITools.FindInParents<UIPanel>(gameObject); 
        if (center != null)
        { 
            if (center.enabled)
                center.CenterOn(transform);
        }
        else if (panel != null && panel.clipping != UIDrawCall.Clipping.None)
        {
            UIScrollView sv = panel.GetComponent<UIScrollView>();
            Vector3 offset = -panel.cachedTransform.InverseTransformPoint(transform.position);
            if (!sv.canMoveHorizontally) offset.x = panel.cachedTransform.localPosition.x;
            if (!sv.canMoveVertically) offset.y = panel.cachedTransform.localPosition.y;
            SpringPanel.Begin(panel.cachedGameObject, offset, 6f);
        }
        setActive(); 
    }
    
    public GameObject[] DisableO;
    public GameObject[] EnableO;
    
    public void setActive()
    {
        for (int i = 0; i < DisableO.Length; i++)
        {
            DisableO[i].SetActive(false);
        }
        for (int i = 0; i < EnableO.Length; i++)
        {
            EnableO[i].SetActive(true);
        }
    }
 
}
