/********************************************************************
	created:	2017.6.7
	file base:	
	file ext:	cs
	author:		xuemin.lin	
	purpose:	
*********************************************************************/
using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public delegate void VoidCallback();
public class UIWin : MonoBehaviour
{
    public DynamicAtlas DAtlas { private set; get; }
    public EUILayer eLayer = EUILayer.Normal;
    [HideInInspector]
    public WinID ID;
#region back type
    //the back type of the win, it will used when open the win to judge which parent win show open and which should closed
    //only use for normal win
    public enum eCloseType
    {
        CloseNothing = 0, //close all the exist window
        ClosePrev1,
        ClosePrev2,
        ClosePrev3,
        CloseOthers = 99999, //close all the exist window. important: this value must be large
        Max = 100000,
    };
    public eCloseType closeType = eCloseType.CloseNothing; //this value can only be set from edit. you should change it by script. if you want to change the close type, use CloseType = X,the value is used only one time;
    private eCloseType tempCloseType = eCloseType.Max; //temp close type, use it one time. if the value is not CloseType.Max, UIManager will use this value as close type.
    public UIWin.eCloseType CloseType
    {
        get { 
            if(tempCloseType != eCloseType.Max) {
                eCloseType ret = tempCloseType;
                return ret;
            } else {
                return closeType; 
            }
        }
        set { 
            tempCloseType = value; 
        }
    }
#endregion
    

    //public bool CloseOthers = false; //whether close all other window. only for normal layer windows
    //public bool HideLast = false; ////whether hide the last window. only for normal layer windows
    public AnimationClip openAnim;
    public AnimationClip closeAnim;
    //return if the OnBack is used only once
    public Func<bool> OnBack;

#region active items
    public float itemAnimInterval = 0.2f;
    [HideInInspector]
    public List<WinItem> ActiveItems = new List<WinItem>();
    protected virtual void InitActiveItems()
    {
        ActiveItems.Clear();
        //default, all of the item is active, collect all of them
        WinItem[] items = GetComponentsInChildren<WinItem>();
        ActiveItems.AddRange(items);
    }

    protected void InitGridActiveItems(UIGrid grid, UIPanel panel)
    {
        if (!grid || !panel) return;
        ActiveItems.Clear();
        WinItem[] items = grid.GetComponentsInChildren<WinItem>();
        int index = 0;
        for(int i = 0; i < items.Length; ++i)
        {
            WinItem item = items[i];
            if (panel.IsVisible(item.transform.position) && item.gameObject.activeSelf)
            {
                item.AnimDelay = this.itemAnimInterval * index++; //enable the open animation
                ActiveItems.Add(item);
            }
            else
            {
                item.AnimDelay = -1; //disable the open animation
            }
        }
    }
#endregion


    public virtual void Close(object message)
    {
        if (!this)
        {
            Debug.LogError("close a win which is already destory!!!!!");
            return;
        }        
        if (onClose != null)
        {
            onClose(message);
            onClose = null;
        }
        OnClose();
    }

    public virtual bool ReOpenable { get { return true; } } //wether open it even it is opened aleady. just for ui need reopend such as UIHome
    public bool BackEnable = true;  //wether the window need back button. only the normal child window need set this to true;
    public bool IsOpen()
    {
        return UIManager.Instance().IsOpen(ID);
    }

#region init
    private bool inited = false;
    private void Init()
    {
        if (inited) return;
        inited = true;        
        OnInit();
    }
    protected virtual void OnInit()
    {

    }
#endregion


    /// <summary>
    /// 打开窗口
    /// </summary>
    /// <param name="onClose">关闭时的回调</param>
    /// <param name="args">其它参数</param>
    /// <returns></returns>
    protected object[] args; //open params
    public object[] Args
    {
        get { return args; }
    }
    private Action<object> onClose;
    public bool Open(Action<object> onClose = null, params object[] args)
    {
        this.args = args;
        Init();
        DAtlas = GetComponent<DynamicAtlas>();
        fromOpen = true;
        OnOpen(args);
        InitActiveItems();
        PlayOpenAnim();
        if(onClose != null) this.onClose = onClose;
        return true;
    }

    /// <summary>
    /// 设置窗口为模态窗口
    /// </summary>
    /// <returns></returns>
    public void SetMode()
    {
        BoxCollider co = gameObject.GetComponent<Collider>() as BoxCollider;
        if (co == null)
        {
            Debug.LogWarning(string.Format("UI:{0} has no win colldier, so it can't surpport mode open", name));
        }
        else
        {
            co.size = new Vector3(Screen.width, Screen.height, 0);
            Debug.Log("max the size of me.........");
        }
    }
    private bool fromOpen = false;
    protected bool FromOpen
    {
        get { return fromOpen; }
    }
    protected virtual void OnOpen(object[] args)
    {
        
    }

    public void Refresh()
    {
        fromOpen = false;
        OnOpen(args);
        OnRefresh();
        onPlayOpenAnimEnd();
    }

    protected virtual void OnRefresh()
    {

    }

    protected virtual void OnClose()
    {

    }

    public void PlayOpenAnim()
    {
        if (GetComponent<Animation>() && GetComponent<Animation>().isPlaying) return; //animation is playing
        //play items' animation
        PlayItemsAnim(true);
        if (openAnim)
        {
            //play close anim
            Animation anim = SafeGetComponent<Animation>(gameObject);
            if (anim[openAnim.name] == null)
            {
                //Debug.LogError("Trying to play an animation : " + animationClip.name + " but it isn't in the animation list. I will add it, this time, though you should add it manually.");
                anim.AddClip(openAnim, openAnim.name);
            }
            anim.enabled = true;
            anim.Play(openAnim.name);
        }
    }
        
    //play items' open animation
    private float openAnimPlayTime = 0;
    public void PlayItemsAnim(bool afterOpenAnim = false)
    {
        if (IsPlayingAnim) return;
        IsPlayingAnim = true;
        try
        {
            //if (!HasItemsAnimComplete()) return;
            float winOpenDelay = (afterOpenAnim && openAnim) ? openAnim.length : 0;
            openAnimPlayTime = 0;
            //int count = 0;
            for (int i = 0; i < ActiveItems.Count; ++i)
            {
                WinItem item = ActiveItems[i];
                if (item.PlayOpenAnim(winOpenDelay))
                {
                    if (item.AnimDelay > openAnimPlayTime)
                    {
                        openAnimPlayTime = item.AnimDelay + item.openAnim.length;
                    }
                    //Main.Log("play anim@@@:" + item.name);
                }
            }
            openAnimPlayTime = openAnimPlayTime + winOpenDelay + 0.1f;
            Invoke("onPlayOpenAnimEnd", openAnimPlayTime);
        }
        catch (System.Exception ex)
        {
            Debug.LogException(ex);
            onPlayOpenAnimEnd();
        }
    }

    private bool playingAnim = false;
    public bool IsPlayingAnim
    {
        get { return playingAnim; }
        set {
//            Main.instance.MsgWaitingCollider(Main.LockKey.ChangeUI, value);
            playingAnim = value;
        }
    }
    public Action OnPlayOpenAnimEnd;
    private void onPlayOpenAnimEnd()
    {
        IsPlayingAnim = false;
        if (OnPlayOpenAnimEnd != null)
        {
            OnPlayOpenAnimEnd();
        }
    }

//     public bool HasItemsAnimComplete()
//     {
//         bool ret = true;
//         foreach(WinItem item in items)
//         {
//             if (item.openAnim && item.animation  && item.animation.IsPlaying(item.openAnim.name))
//             {
//                 ret = false;
//             }
//         }
//         return ret;
//     }

    public void PlayCloseAnim(VoidCallback cb)
    {
        if (closeAnim)
        {
            //play close anim
            Animation anim = SafeGetComponent<Animation>(gameObject);
            if (anim[closeAnim.name] == null)
            {
                //Debug.LogError("Trying to play an animation : " + animationClip.name + " but it isn't in the animation list. I will add it, this time, though you should add it manually.");
                anim.AddClip(closeAnim, closeAnim.name);
            }
            anim.Play(closeAnim.name);
  //          Utils.Instance.DelayCall(closeAnim.length, cb);
        }
        else
        {
            if (cb != null) cb();
        }
    }



    #region Utils
    static public T SafeGetComponent<T>(GameObject owner) where T : Component
    {
        if (owner == null) return null;
        T component = owner.GetComponent<T>();
        if (component == null)
        {
            component = owner.AddComponent<T>();
        }
        return component;
    }
    #endregion
}
