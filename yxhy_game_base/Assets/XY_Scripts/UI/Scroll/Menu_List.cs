using UnityEngine;
using System.Collections;

public class Menu_List : MonoBehaviour {
    public UILabel label;
    public UILabel Mlabel;
    private UIToggle m_toggle;

    void Awake()
    {
        m_toggle = GetComponentInChildren<UIToggle>();
    }
    public void SetLabel()
    {
        Mlabel.text= label.text;
        if (m_toggle != null)
            m_toggle.value = true;
    }
}
