using UnityEngine;
using System.Collections;

public class CommonAnimation : MonoBehaviour
{
    public UISprite m_sprite;
    public float m_interval = 0.3f;
    public string m_StartSpriteName = "";  
    public int startIndex = 1;
    public int endIndex = 5;
    int index = 0;
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
            m_sprite.gameObject.SetActive(true);
            int indexName = startIndex + index;
            m_sprite.spriteName = m_StartSpriteName + indexName;
            m_sprite.MakePixelPerfect();

            index++;
            index %= (endIndex - startIndex) + 1;
        }
    }
}
