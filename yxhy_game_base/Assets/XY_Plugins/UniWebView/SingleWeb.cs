using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
#if UNITY_ANDROID || UNITY_IPHONE || UNITY_IOS
public delegate void OnloadComplete(UniWebView webView, bool success, string errorMessage);
public delegate void OnReceiveMessage(UniWebView webView, UniWebViewMessage message);
#endif    
public class WebPage
{
#if UNITY_ANDROID || UNITY_IPHONE || UNITY_IOS
    public UniWebView webView;
    public OnloadComplete complete;
    public OnReceiveMessage receive;
    public GameObject go;
    public WebPage(UniWebView webView, string url)
    {
        webView.CleanCookie();
        webView.CleanCache();
        this.webView = webView;
        if (url != null)
        {
            webView.url = url;
        }
        else
        {
            webView.url = "http://baidu.com";
        }
        webView.SetBackgroundColor(Color.clear);
        webView.Load();
        webView.OnReceivedMessage += this.ReceiveMsg;
        webView.OnLoadComplete += this.CompleteMsg;
    }
    public WebPage(UniWebView webView, string url, int top, int bottom, int left, int right)
    {
        webView.CleanCookie();
        webView.CleanCache();
        this.webView = webView;
        SetSize(top, bottom, left, right); 
        if (url != null)
        {
            webView.url = url;
        }
        else
        {
            webView.url = "http://baidu.com";
        }
        webView.SetBackgroundColor(Color.clear);
        webView.Load();
       
        webView.OnReceivedMessage += this.ReceiveMsg;
        webView.OnLoadComplete += this.CompleteMsg;
    }

    void CompleteMsg(UniWebView webView, bool success, string errorMessage)
    {
        if (complete != null)
        {
            webView.Show(false, UniWebViewTransitionEdge.Top);
            complete(webView, success, errorMessage);
           // RunJavaScript("function concatme(){publicWebFunction(); }", "concatme()");
        }
    }
    public void Run()
    {
        RunJavaScript("function concatme(){publicWebFunction(); }", "concatme()");
    }
    void ReceiveMsg(UniWebView webView, UniWebViewMessage message)
    {
        if (receive != null)
        {
            receive(webView, message);
        }
    }
    public void Show()
    {
        webView.Show(false,UniWebViewTransitionEdge.Top); 
    }
    public void Hide()
    {
        webView.Hide();
    }
    public void SetSize(int top, int bottom, int left, int right)
    {
        float width = Screen.width;
        float height = Screen.height;
        float widthr = Screen.width /(float) 1280.0;
        float heightr = Screen.height /(float) 720.0; 
#if UNITY_ANDROID
        this.webView.insets = new UniWebViewEdgeInsets((int)(top* heightr), (int)(left * widthr), (int)(bottom * heightr), (int)(right* widthr));
#elif UNITY_IPHONE || UNITY_IOS
        this.webView.insets= new UniWebViewEdgeInsets(top,left,bottom,right);
#endif
    }
    public void RunJavaScript(string fun, string method)
    {
        webView.AddJavaScript(fun);//"function concatme(){publicWebFunction(); }"
        webView.EvaluatingJavaScript(method);//"concatme()"
    }
#endif
}
   
public class SingleWeb : Singleton<SingleWeb> {
#if UNITY_ANDROID || UNITY_IPHONE || UNITY_IOS 

    public Dictionary<string, WebPage> dic = new Dictionary<string, WebPage>();
    public WebPage InitWebPage(string url)
    {
        if (dic.ContainsKey(url))
        {
            return dic[url];
        } 
        GameObject go = new GameObject(url);
        DontDestroyOnLoad(go);
        go.AddComponent<UniWebView>();
        UniWebView webView = go.GetComponent<UniWebView>();
        WebPage webPage = new WebPage(webView, url);
        webPage.go = go;
        if (!dic.ContainsKey(url))
        {
            dic.Add(url, webPage);
        }
        return webPage;
    }
    public WebPage InitWebPage(string url,int top,int bottom,int left, int right)
    {
        if (dic.ContainsKey(url))
        {
            return dic[url];
        }
        GameObject go = new GameObject(url);
        //Debug.Log(go.name);
        DontDestroyOnLoad(go);
        go.AddComponent<UniWebView>();
        UniWebView webView = go.GetComponent<UniWebView>();
        WebPage webPage = new WebPage(webView, url, top, bottom,left,right);
        webPage.go = go;
        if (!dic.ContainsKey(url))
        {
            dic.Add(url, webPage);
        }
        return webPage;
    }
    public WebPage GetDicObj(string url)
    {
        if (dic.ContainsKey(url)&& dic[url].webView!=null && dic[url].webView.gameObject!=null)
        {
            return dic[url];
        }
        else
        {
            return null;
        }
    }
    public void DestroyDicObj(string url)
    {
        if (dic.ContainsKey(url))
        {
            WebPage webPage = SingleWeb.Instance.GetDicObj(url);
            UniWebView webView = webPage.webView;
            dic.Remove(url);
            webView.CleanCache(); 
            Destroy(webView.gameObject); 
        }
    }
    public void DestroyAll()
    {
        var key = new List<string>(dic.Keys);
        for (int i = 0; i < key.Count; i++)
        {
            DestroyDicObj(key[i]);
        }
    }
#endif 
}

public class SingleFullWeb : Singleton<SingleFullWeb> {
#if UNITY_ANDROID || UNITY_IPHONE || UNITY_IOS 

    public Dictionary<string, WebPage> dic = new Dictionary<string, WebPage>();
    public WebPage InitWebPage(string url)
    {
        if (dic.ContainsKey(url))
        {
            return dic[url];
        } 
        GameObject go = new GameObject(url);
        DontDestroyOnLoad(go);
        go.AddComponent<UniWebView>();
        UniWebView webView = go.GetComponent<UniWebView>();
        WebPage webPage = new WebPage(webView, url);
        webPage.go = go;
        if (!dic.ContainsKey(url))
        {
            dic.Add(url, webPage);
        }
        return webPage;
    }
    public WebPage InitWebPage(string url,int top,int bottom,int left, int right, bool isPortrait)
    {
        if (dic.ContainsKey(url))
        {
            UniWebView webView2 = dic[url].webView;
            if (webView2)
            {
                webView2.ShowToolBar(false);
            }
            
            return dic[url];
		}
		UniWebView.SetPortrait(isPortrait); //reset to false when init
        UniWebView.SetDoneButtonText("关闭");

        GameObject go = new GameObject(url);
        //Debug.Log(go.name);
        DontDestroyOnLoad(go);
        go.AddComponent<UniWebView>();
        UniWebView webView = go.GetComponent<UniWebView>();
        WebPage webPage = new WebPage(webView, url, top, bottom,left,right);
        webPage.go = go;
        if (!dic.ContainsKey(url))
        {
            dic.Add(url, webPage);
        }
		
        //show toolBar
        webView.ShowToolBar(false);
        webView.SetBackgroundColor(Color.white);
        webView.backButtonEnable = true; //android
        webView.OnWebViewShouldClose += this.OnWebViewDone;

        return webPage;
    }
    public bool OnWebViewDone(UniWebView webView)
    {
        webView.HideToolBar(false);
        webView.Hide();
        
        SingleFullWeb.Instance.DestroyDicObj(webView.url);

        return false;
    }

    public WebPage GetDicObj(string url)
    {
        if (dic.ContainsKey(url)&& dic[url].webView!=null && dic[url].webView.gameObject!=null)
        {
            return dic[url];
        }
        else
        {
            return null;
        }
    }
    public void DestroyDicObj(string url)
    {
        if (dic.ContainsKey(url))
        {
            WebPage webPage = SingleFullWeb.Instance.GetDicObj(url);
            UniWebView webView = webPage.webView;
            dic.Remove(url);
            webView.CleanCache(); 
            Destroy(webView.gameObject); 
        }
    }
    public void DestroyAll()
    {
        var key = new List<string>(dic.Keys);
        for (int i = 0; i < key.Count; i++)
        {
            DestroyDicObj(key[i]);
        }
    }
#endif 
}
