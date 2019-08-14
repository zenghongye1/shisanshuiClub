using UnityEngine;
using System.Collections.Generic;

public class UIEffect : MonoBehaviour
{
    public UIPanel parentPanel;
    public UIWidget frontWidget;
    public UIWidget backWidget;

    [System.NonSerialized]
    Renderer[] m_rendererArr;

    Dictionary<Renderer, Material[]> dicRenderMat = new Dictionary<Renderer, Material[]>();

    int matCount = 0;

    void Awake()
    {
        m_rendererArr = this.GetComponentsInChildren<Renderer>();
        for (int i = 0; i < m_rendererArr.Length; i++)
        {
            dicRenderMat[m_rendererArr[i]] = m_rendererArr[i].sharedMaterials;
        }
    }

    public void InitPanel(UIPanel p)
    {
        parentPanel = p;
    }

    void Start()
    {
        parentPanel = this.transform.GetComponentInParent<UIPanel>();
        parentPanel.AddUIEffect(this);     
    }

    public int UpdateEffectUI()
    {
        if (this.frontWidget != null && this.frontWidget.drawCall != null)
        {
            matCount = 0;
            int rq = this.frontWidget.drawCall.renderQueue + 1;

            for(int i= 0; i<m_rendererArr.Length; i++)
            {
                //这里最好再加个同材质及不同材质球处理（后续再加）
                if (m_rendererArr[i] != null)
                {
                    for (int j=0; j< dicRenderMat[m_rendererArr[i]].Length; j++)
                    {                                           
                        Material material = dicRenderMat[m_rendererArr[i]][j];
                        if ((material != null) && (material.renderQueue != rq))
                        {
                            material.renderQueue = rq;
                            matCount += 1;
                        }
                    }
                }
            }
        }
        return matCount;
    }

    void OnDestroy()
    {
        if (parentPanel != null)
            parentPanel.RemoveUIEffect(this);
    }
}