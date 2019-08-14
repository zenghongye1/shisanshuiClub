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

public enum WinID
{
	EN_UIWID_NONE,
    UIUnSupport,
    UILogin,
    Max,
}
public enum EUILayer
{
    //顶层
    Top = -200, //用于MESAGEBOX 等提示界面
    //main层，可以用来MAIN UI
    Main = 1800,
    //普通层，这一层的UI支持CLOSE ALL操作，并且最近打开的UI永远在最上面。他们的深度在（0 - 300）之间
    Normal = 200,
    //底层，用于背景
    Bottom = 1600
}



public class UIManager : MonoBehaviour {
        
    private static UIManager instance;
    public static UIManager Instance()
    {
        return instance;
    }

    void Awake()
    {
        instance = this; 
    }

    public enum AtlasList
    {
        Atlas_Hero = 0,
        Atlas_Beauty,
    }
     
#region init
    private void InitEvent()
    {
        //注意：对于那些要在UI没起来之前就需要注册的事件都应该这里注册
 //       CSystemEventManager.AddListener(ESystemEventType.EN_LEAGUE_FINISH_UPGRADE, UILoadPackage.Load);
    }
    private void InitItem()
    {
        //hide all of the ui at first. we will show them by special state
        for (int i = 0; i < transform.childCount; ++i)
        {
            Transform child = transform.GetChild(i);
            //add exist UIs under to the UIManager
            UIWin ui = child.GetComponent<UIWin>();
            if (ui != null)
            {
                try
                {
                    //Main.Log("add ui:==+++++=" + ui.GetType());
                    WinID ID = (WinID)Enum.Parse(typeof(WinID), ui.GetType().ToString());
                    //Main.Log("add ui:====" + uiType);
                    UIInstances[(int)ID] = ui;
                    ui.ID = ID;
                    child.gameObject.SetActive(false);
                }
                catch (System.Exception ex)
                {
    //                Main.LogWarning("Unsupport UI" + child.name);
                }
            }
        }
    }

    public UIFont defFont;

    public void Init()
    {
        try
        {
            //if (GetComponent<UITipManager>() == null)
            //    gameObject.AddComponent<UITipManager>();
            //if (GetComponent<UITipBroadcast>() == null)
            //    gameObject.AddComponent<UITipBroadcast>();
            InitItem();
            InitEvent();
      //      HTMLMgr.Create();
        }
        catch (System.Exception ex)
        {
            Debug.LogException(ex);
        }

    }
    public void UnInit()
    {
        foreach (UIWin win in UIInstances)
        {
            if (win)
            {
                doClose(win, null);
                DestroyImmediate(win.gameObject);
            }
        }
        Array.Clear(UIInstances, 0, UIInstances.Length);
    }
#endregion

    #region manager UI
    //get special type of UI. if the ui is not created, return null
    public static UIWin GetUI(WinID ID)
    {
        return instance.UIInstances[(int)ID];
    }
    //get special type of UI. if the ui is not created, return null
    public static T GetUI<T>() where T : UIWin
    {
        try
        {
            WinID ID = (WinID)Enum.Parse(typeof(WinID), typeof(T).ToString());
            return instance.UIInstances[(int)ID] as T;
        }
        catch (System.Exception ex)
        {
            return default(T);
        }
    }
    //get special type of UI. if the ui is not created, created it.
    public static T SafeGetUI<T>() where T: UIWin
    {
        try
        {
            WinID ID = (WinID)Enum.Parse(typeof(WinID), typeof(T).ToString());
            return Instance().getUI(ID) as T;
        }
        catch (System.Exception ex)
        {
        	return default(T);
        }
    }
   
    //销毁UI
    public void Destroy(WinID ID)
    {
        UIWin win = UIInstances[(int)ID];
        if (!win) return;
        if (IsOpen(ID))
        {
            win.closeAnim = null; //needn't play animation. destory it now!
            CloseWindow(win);
        }
        NGUITools.Destroy(win.gameObject);
        UIInstances[(int)ID] = null;
        Resources.UnloadUnusedAssets();
        GC.Collect();
    }


    private UIWin[] UIInstances = new UIWin[(int)WinID.Max];
    private UIWin getUI(WinID ID)
    {
        UIWin UI = null;
        try
        {
            if (ID == WinID.Max) return null;
            UI = UIInstances[(int)ID];
            if (UI == null)
            {
                //there is none can use, then add a new one
                UnityEngine.Object prefab = Resources.Load(string.Format("UI/{0}", ID));
                if (prefab == null)
                {
                    Debug.LogWarning(string.Format("UI/{0} is not exist!", ID));
                    return null;
                }
                else
                {
                    GameObject go = (GameObject)Instantiate(prefab);
                    go.name = prefab.name;
                    UI = go.GetComponent<UIWin>();
                    if (!UI)
                    {
                        Debug.LogError(string.Format("UI:{0} has not UIWin component!", ID));
                        return null;
                    }
                    Transform trans = go.transform;
                    trans.parent = transform;
                    trans.localScale = Vector3.one;
                    trans.localPosition = new Vector3(0, 0, (float)UI.eLayer);
                    UIInstances[(int)ID] = UI;
                    UI.ID = ID;
                    //init anchor
                    UIAnchor anchor = UI.GetComponent<UIAnchor>();
                    if(anchor)
                    {
                        anchor.runOnlyOnce = true;
                        anchor.uiCamera = UICamera.currentCamera;                    
                    }
                    go.SetActive(false);
                }
            }
            return UI;
        }
        catch (System.Exception ex)
        {
            Debug.LogException(ex);
            return null;
        }
    }

    #endregion


#region Open and Close

    public bool IsOpen(WinID id)
    {
        UIWin win = UIInstances[(int)id];
        if (win == null)
        {
            return false;
        }
        else
        {
            if (win.eLayer == EUILayer.Normal)
            {
                return openedNormalWins.Contains(win);
            }
            else
            {
                return win.gameObject.activeSelf;
            }
        }
    }

#region normal win
#region back manager    
    
    //back to the last win if it is exist or do nothing.
    private GameObject back;
    public GameObject Back
    {
        get { return back; }
        set { 
            if(value != null)
            {
                back = value;
                UIEventListener.Get(value).onClick = (go) =>
                {
                    OnBack();
                };
            }

        }
    }

    private void OnBack()
    {
        if (openedNormalWins.Count < 1) return;
        UIWin curWin = openedNormalWins.Last.Value;
        if (curWin.OnBack != null)
        {
            //custom, do on back call
            if(curWin.OnBack())
            {
                curWin.OnBack = null;
            }
        }
        else
        {
            //default, close current window 
            CloseWindow(openedNormalWins.Last.Value);
        }
    }
    //return if the win can't go back.
    public void CheckBack()
    {
        if (!back) return;
        bool enable = false;
        if(openedNormalWins.Last != null)
        {
            enable = openedNormalWins.Last.Value.BackEnable;
        }
        back.SetActive(enable);
    }

    private void ClearCustomOnBacks()
    {
        foreach(UIWin win in UIInstances)
        {
            if (win != null) //注意：不能用if(!win) 
            {
                win.OnBack = null;
            }
        }
    }
#endregion    

    private LinkedList<UIWin> openedNormalWins = new LinkedList<UIWin>();
    /// <summary>
    /// open normal widow. the window will on top of other normal windows. and it will close the windows base on the target win's close type
    /// </summary>
    /// <param name="win"></param>
    /// <param name="onClose"></param>
    /// <param name="args"></param>
    /// <returns></returns>
    private void OpenNormalWin(UIWin win, Action<object> onClose = null, params object[] args)
    {
        //close other windows base on close type
        if (win.CloseType == UIWin.eCloseType.CloseOthers)
        {
            //close all
            CloseAll();
        } else {
            //close partial
            int count = (int)win.CloseType;
            if (count > 0)
            {
                //close window
                for (int index = 0; index < count - 1; ++index)
                {
                    LinkedListNode<UIWin> last = openedNormalWins.Last;
                    if (last == null) break;
                    //close the last
                    openedNormalWins.RemoveLast();
                    doClose(last.Value);
                    last = openedNormalWins.Last;
                }
                //hide the last
                LinkedListNode<UIWin> lastWin = openedNormalWins.Last;
                if (lastWin != null && lastWin.Value)
                {
                    lastWin.Value.gameObject.SetActive(false);
                }
            }
        }
        win.CloseType = UIWin.eCloseType.Max; //reset the custom close type of win

        //open the win
        if (openedNormalWins.Contains(win)) openedNormalWins.Remove(win);
        openedNormalWins.AddLast(win);
        //refresh all normal window's position
        int i = 0;
        float start = (float)EUILayer.Bottom - 50;
        float end = (float)EUILayer.Normal;
        float delta = (int)(start - end) / 10;
        foreach (UIWin temp in openedNormalWins)
        {
            //refresh position
            if (temp)
            {
                temp.transform.localPosition = new Vector3(temp.transform.localPosition.x, temp.transform.localPosition.y, start - delta * i++);
            } else {
                Debug.LogError("refresh window that is null!");
            }
        }        
    }

    private bool refreshing = false;
    private void CloseNormalWin(UIWin win, bool doRefresh)
    {        
        openedNormalWins.Remove(win); //remove it from normalWins
        if (doRefresh && !refreshing)
        {
            refreshing = true;
            //back to the last win if there is
            if (openedNormalWins.Count > 0)
            {
                //show back the last win
                UIWin lastWin = openedNormalWins.Last.Value;
                if(lastWin)
                {
                    lastWin.Refresh();
                    lastWin.gameObject.SetActive(true);
                }
            }
            refreshing = false;
        }
    }
        
    //close all normal wins
    public void CloseAll()
    {
        try
        {
            LinkedListNode<UIWin> last = openedNormalWins.Last;
            while(last != null)
            {
                //close the last
                openedNormalWins.RemoveLast();
                doClose(last.Value);                
                last = openedNormalWins.Last;
            }
            ClearCustomOnBacks();//清除所有一次性的ONBACK。
        }
        catch (System.Exception ex)
        {
            Debug.LogException(ex);
        }
    }
    
#endregion

    //public Action<UIWin> OnOpenWin;
    public UIWin OpenWindow(WinID winID, Action<object> onClose = null, params object[] args)
    {
        try
        {
            if (winID > WinID.UIUnSupport)
            {
  //             UITipManager.Instance().ShowTip(11102);
                return null;
            }

            UIWin win = getUI(winID);
            if (win)
            {
                if (win.ReOpenable || !IsOpen(winID))
                {
                    openWindow(win, onClose, args);
                }
            }
            return win;
        }
        catch (System.Exception ex)
        {
            Debug.LogException(ex);
            return null;
        }        
    }

    private void openWindow(UIWin win, Action<object> onClose, params object[] args)
    {
        if (win.eLayer == EUILayer.Normal)
            OpenNormalWin(win, onClose, args);
        //play animation
        win.gameObject.SetActive(true);
        win.Open(onClose, args);
        CheckBack();
    }

    public void CloseWindow(WinID winID, object message=null)
    {
        try
        {
            if (!UIInstances[(int)winID]) return;
            UIWin ui = getUI(winID);
            CloseWindow(ui, message);            
        }
        catch (System.Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    private void doClose(UIWin win, object message = null)
    {
        if (win)
        {
            win.gameObject.SetActive(false);
            win.Close(message);
        }
    }

    /// <summary>
    /// close the win.
    /// </summary>
    /// <param name="win"></param>
    /// <param name="message">the param pass back in OnClose</param>
    /// <param name="doRefresh">if need refresh the other normal win. only used for normal window</param>
    /// <returns></returns>
    public void CloseWindow(UIWin win, object message = null, bool doRefresh = true)
    {
        try
        {
            if (win && IsOpen(win.ID))
            {
                //这里需要先关闭窗口(CloseNormalWin)，因为在win Close里面很可能调用CLOSEALL, CLOSEALL又会调用到该win的CloseWindow，造成死循环
                if (win.closeAnim)
                {
                    win.PlayCloseAnim(() =>
                    {
                        doClose(win, message);
                        if (win.eLayer == EUILayer.Normal)
                            CloseNormalWin(win, doRefresh);
                        CheckBack();
                    });
                    
                } else {
                    doClose(win, message);
                    if (win.eLayer == EUILayer.Normal)
                        CloseNormalWin(win, doRefresh);
                    CheckBack();
                }
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogException(ex);
        }
    }

//     private void PlayAnim(GameObject target, AnimationClip clip, VoidCallback cb)
//     {
//         if (clip)
//         {
//             //play close anim
//             Animation anim = Utils.SafeGetComponent<Animation>(target);
//             if (anim[clip.name] == null)
//             {
//                 //Debug.LogError("Trying to play an animation : " + animationClip.name + " but it isn't in the animation list. I will add it, this time, though you should add it manually.");
//                 anim.AddClip(clip, clip.name);
//             }
//             anim.Play(clip.name);
//             Utils.Instance.DelayCall(clip.length, cb);
//         }
//         else
//         {
//             if(cb != null) cb();
//         }
//     }


#endregion

  
	#region common prefab	

    public GameObject GetPrefab(string name)
    {
        string path = string.Format("Prefab/{0}", name);
        GameObject obj = Resources.Load(path) as GameObject;
        if (obj == null)
        {
            Debug.LogError("can't load resource from " + path);
            return null;
        }

        return obj;
    }
	#endregion

 //   private int homeClickTimes = 0; 
    void LateUpdate()
    {
        //点击手机返回键关闭应用程序
        if (CheckEscape()) OnEscape();
        EscapeUsed = false;

    }
    #region on escape
    public static bool EscapeUsed = false;
    public static bool CheckEscape()
    {
        return Input.GetKeyUp(KeyCode.Escape) || Input.GetKeyUp(KeyCode.Home);
    }
    private void OnEscape()
    {
        if (EscapeUsed) return;
        EscapeUsed = true;
        if (openedNormalWins.Count > 1)
        {
            OnBack();
        }
        else
        {


            //GameCounter.Event(GameCounter.BtnBackOnClick);
            //UITipManager.Instance().ShowTip(11105, (isSure) =>
            // {
            //     if (isSure)
            //     {
            //         GameCounter.Event(GameCounter.GameExit);
            //         Application.Quit();
            //     }
                

            // });


        }
    }
    #endregion

}

