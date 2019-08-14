using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class EffectComp : MonoBehaviour
{
    List<Renderer> _renderList;
    [HideInInspector]
    public int sortOrder = 0;

    public int Order = 0;

    public void SetSortOrder(int sortOrder)
    {
        if (this.sortOrder == sortOrder)
            return;
        if (_renderList == null)
        {
            _renderList = new List<Renderer>();
            GetComponentsInChildren<Renderer>(_renderList);
        }
        for (int i = 0; i < _renderList.Count; i++)
        {
            _renderList[i].sortingOrder = sortOrder;
        }
        Order = sortOrder;
    }

#if UNITY_EDITOR 
    [ExecuteInEditMode]
    private void Update()
    {
        if(Order != sortOrder)
        {
            SetSortOrder(Order);
        }
    }
#endif

}
