using UnityEngine;
using System.Collections;

public class CurstomAnimation : MonoBehaviour
{
    public UISprite m_sprite;
    float m_interval = 0.3f;
    int index = 0;
    void Awake()
    {
        m_sprite = transform.Find("dot").GetComponent<UISprite>();
    }
    void OnEnable ()
    {
        CancelInvoke("SetAnimation");
        InvokeRepeating("SetAnimation", m_interval, m_interval);
        
	}
    void OnDisable()
    {
        CancelInvoke("SetAnimation");
        index = 0;
    }
    void SetAnimation()
    {
        if (m_sprite != null)
        {
            if (index == 0)
            {
                m_sprite.gameObject.SetActive(false);
            }
            else
            {
                m_sprite.gameObject.SetActive(true);
                m_sprite.spriteName = "liapi0" + index;
                m_sprite.MakePixelPerfect();
            }
            index++;
            index %= 4;
        }
    }
}
