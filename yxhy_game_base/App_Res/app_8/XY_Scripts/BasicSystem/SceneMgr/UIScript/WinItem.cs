/********************************************************************
	created:	2017.6.7
	file base:	
	file ext:	cs
	author:		xuemin.lin	
	purpose:	
*********************************************************************/
using UnityEngine;
using System;
using System.Collections.Generic;

public class WinItem : MonoBehaviour
{
    public UIWin Parent { get; private set; }
    public AnimationClip openAnim;
    public float AnimDelay = -1;

    
    public void Open(UIWin parent, params object[] args)
    {
        Parent = parent;
        if (!inited) Init();
        try
        {
            OnOpen(args);
        }
        catch (System.Exception ex)
        {
            Debug.LogException(ex);        	
        }
    }

    private bool inited = false;
    public void Init()
    {
        if (inited) return;
        inited = true;
        try
        {
            OnInit();
        }
        catch (System.Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    /// <summary>
    /// init, just call on time
    /// </summary>
    /// <returns></returns>
    protected virtual void OnInit() { }

    /// <summary>
    /// init, called on each opening
    /// </summary>
    /// <param name="args"></param>
    /// <returns></returns>
    protected virtual void OnOpen(object[] args) { }

    public void Close()
    {
        OnClose();
    }
    protected virtual void OnClose() { }

    public bool PlayOpenAnim(float parentDelay = 0)
    {   
        if (openAnim && AnimDelay >= 0)
        {
            transform.localScale = Vector3.zero;
            Animation anim = UIWin.SafeGetComponent<Animation>(gameObject);
            anim.enabled = true;
            anim.playAutomatically = false;
            if (anim[openAnim.name] == null)
            {
                anim.AddClip(openAnim, openAnim.name);
            }
            Invoke("DoPlayAnim", AnimDelay + parentDelay);
            return true;
        } else {
            CancelInvoke("DoPlayAnim");
            if (GetComponent<Animation>()) GetComponent<Animation>().enabled = false;
            return false;
        }
    }

    private void DoPlayAnim()
    {
        try
        {
            GetComponent<Animation>().enabled = false;
            GetComponent<Animation>().enabled = true;
            transform.localScale = Vector3.one;     
            GetComponent<Animation>().Play(openAnim.name, PlayMode.StopSameLayer);
        }
        catch (System.Exception ex)
        {
            Debug.LogWarning(ex.Message);
        }
    }


}