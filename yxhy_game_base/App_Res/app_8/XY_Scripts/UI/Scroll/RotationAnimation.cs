using UnityEngine;
using System.Collections;

public class RotationAnimation : MonoBehaviour {
    public GameObject[] go;
    public int current = 0;
	// Use this for initialization
	void Start () {
	    
	}
	
	// Update is called once per frame
	void Update () {
	    
	} 
    public void Show()
    {
        if (current == 1)
        { 
            gameObject.transform.localScale=Vector3.one;
            gameObject.transform.eulerAngles = Vector3.zero;
           
        }else
        {
            gameObject.transform.localScale=Vector3.zero;
           
        }
    } 
    public void add()
    {
        if (current == 1)
            current--;
        else
            current++;
    }
}
