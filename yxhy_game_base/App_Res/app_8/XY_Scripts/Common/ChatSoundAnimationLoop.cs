using UnityEngine;
using System.Collections;

public class ChatSoundAnimationLoop : MonoBehaviour
{
    public UISprite m_sprite;
    float m_interval = 0.3f;
    int index = 0;
    int startIndex = 1;
    //void Awake()
    //{
    //    m_sprite = transform.Find("dot").GetComponent<UISprite>();
    //}
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
            m_sprite.spriteName = "voice_" + indexName;
            m_sprite.MakePixelPerfect();

            index++;
            index %= 5;
        }
    }
}
