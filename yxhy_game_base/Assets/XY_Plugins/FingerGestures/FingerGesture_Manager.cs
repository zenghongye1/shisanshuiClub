using UnityEngine;
using System.Collections;

public class FingerGesture_Manager : Singleton<FingerGesture_Manager> {

    public FingerGestures m_fingerGestures = null;
    private void Awake()
    {
        GameObject fingerGestures =  GameObject.Find("FingerGestures");
        if (fingerGestures != null)
            m_fingerGestures = fingerGestures.GetComponent<FingerGestures>();
    }

    private void OnEnable()
    {
        if (m_fingerGestures != null)
        {
         
        }
       
    }

    private void OnDisable()
    {
        
    }

}
