using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
using LitJson;

public class MessageBox : MonoBehaviour
{
    [SerializeField]
    private UIGrid grid;
    [SerializeField]
    private UILabel title_Lab;
    [SerializeField]
    private UILabel content_Lab;
    [SerializeField]
    private List<UIButton> btnList; //UIButton最多为3

    public UIButton btnClose;

    public void ShowMessageBox(string title, string content, List<ButtonEvent> btnEventList)
    {
        grid.repositionNow = true;
        //title_Lab.text = title;
        content_Lab.text = content;

        for (int i = 0; i < btnList.Count; i++)
        {
            btnList[i].gameObject.SetActive(false);
        }

        for(int j=0; j<btnEventList.Count; j++)
        {            
            int index = btnEventList[j].index;            
            btnList[index].gameObject.SetActive(true);
            //btnList[i].transform.Find("text").GetComponent<UILabel>().text = btnEventList[i].btnText;

            if (index == 0)
            {
                int _index2 = j;
                UIEventListener.Get(btnList[index].gameObject).onClick = delegate
                {
                    btnEventList[_index2].btnEvent.Invoke();
                };
            }
            else if (index == 1)
            {
                int _index2 = j;
                UIEventListener.Get(btnList[index].gameObject).onClick = delegate
                {                    
                    btnEventList[_index2].btnEvent.Invoke();
                };
            }
            else if (index == 2)
            {
                int _index2 = j;
                UIEventListener.Get(btnList[index].gameObject).onClick = delegate
                {
                    btnEventList[_index2].btnEvent.Invoke();
                };
            }
        }   
        
        if (btnEventList.Count > 0)
        {
            SetBtnCloseEvent(delegate {
                if (this.gameObject.activeSelf)
                {
                    this.gameObject.SetActive(false);
                    Application.Quit();
                }
            });
        }   
        /*else if(btnEventList.Count > 1)
        {
            SetBtnCloseEvent(delegate {
                if (this.gameObject.activeSelf)
                {
                    this.gameObject.SetActive(false);
                    Application.Quit();
                }
            });
        } */ 
    }

    public void SetBtnCloseEvent(Action callback)
    {
        UIEventListener.Get(btnClose.gameObject).onClick = delegate
        {
            if (callback != null)
            {
                callback();
            }
        };
    }

    public static MessageBox CreateMessageBox()
    {
        XYHY.IResourceMgr resMgr = Framework.GameKernel.Get<XYHY.IResourceMgr>();
        JsonData deJson = JsonMapper.ToObject(Framework.GameAppInstaller.appConfData);
        System.Text.StringBuilder stringBuilder = new System.Text.StringBuilder(deJson["appPath"].ToString());
        //UnityEngine.Object verUpdateObj = resMgr.LoadNormalObjSync(new AssetBundleParams(stringBuilder.Append("/ui/version_update_ui/message_box_ui").ToString(), typeof(GameObject)));
        UnityEngine.Object verUpdateObj = Resources.Load("UI/message_box_ui");
        GameObject verUpdateGo = GameObject.Instantiate(verUpdateObj) as GameObject;
        XYHY.LuaDestroyBundle ctrl = verUpdateGo.AddComponent<XYHY.LuaDestroyBundle>();
        //ctrl.BundleName = "Prefabs/UI/VersionUpdate/message_box_ui";
        ctrl.ResType = typeof(GameObject);
        verUpdateGo.transform.parent = GameObject.FindGameObjectWithTag("NGUI").transform;
        verUpdateGo.transform.localPosition = Vector3.zero;
        verUpdateGo.transform.localScale = Vector3.one;

        return verUpdateGo.GetComponent<MessageBox>();
    }
}

public struct ButtonEvent
{
    //public string btnText;
    public Action btnEvent;
    public int index;

    public ButtonEvent(string btnText, Action btnEvent, int _index)
    {
        //this.btnText = btnText;
        this.btnEvent = btnEvent;
        this.index = _index;
    }
}