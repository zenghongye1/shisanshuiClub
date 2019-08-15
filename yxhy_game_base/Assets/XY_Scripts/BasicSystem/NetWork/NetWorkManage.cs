/*******************************************************************************
*Author         :  xuemin.lin
*Description    :  http要用的一些基础功能
*Other          :  none
*Modify Record  :  none
*******************************************************************************/

using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using BestHTTP;
using System.Net.NetworkInformation;
using System.IO;
using LitJson;

public enum ServerUrlType 
{
    DEVELOP_URL = 1,
    RELEASE_URL,
    INTEST_URL,
}

public class NetWorkManage : Singleton<NetWorkManage>
{
    public static string testAccount = "";
    private string m_BaseUrl;
    private ServerUrlType m_ServerUrlType;
    private string m_WsUrl;
    private string m_SubPath;
    private string m_globalServerUrl;
    public string m_physicalAddress;

    public string SwithJosnUrl
    { get; set; }

    public string SwitchHomeUrl
    { get; set; }

    public string CfgJsonUrl { get; set; }

    public string BaseUrl
    {
        get { return m_BaseUrl; }
        set
        {
            m_BaseUrl = value;
        }
    }

    public string GlobalServerUrl
    {
        get { return m_globalServerUrl; }
        set { m_globalServerUrl = value; }
    }

    public ServerUrlType EServerUrlType
    {
        get
        {
            return m_ServerUrlType;
        }
        set
        {
            m_ServerUrlType = value;
        }
    }

    public int ServerUrlTypeNum
    {
        get
        {
            return (int)m_ServerUrlType;
        }
    }

    public string WsUrl
    {
        get { return m_WsUrl; }
        set { m_WsUrl = value; }
    }

    public string SubPath
    {
        get { return m_SubPath; }
        set { m_SubPath = value; }
    }
    private void Awake()
    {
        path = "file://" + Application.dataPath + "/StreamingAssets/jsontest.json";
        filepath = Application.persistentDataPath;
#if UNITY_EDITOR
        GetMacAddress();

        LuaInterface.Debugger.Log("MacAddress" + m_physicalAddress);
#endif
        //this.Init();
    }

    public void Init()
    {
        SubPath = "?win_param=";
        JsonData deJson = JsonMapper.ToObject(Framework.GameAppInstaller.appConfData);
        SwithJosnUrl = deJson["swith_jsonUrl"].ToString();
        SwitchHomeUrl = deJson["swith_home_jsonUrl"].ToString();
        LoadLocalCfg(deJson);
        ReqServerCfgJson();
    }

    public void LoadLocalCfg(JsonData json)
    {
        switch (EServerUrlType)
        {
            case ServerUrlType.DEVELOP_URL:
                m_BaseUrl = json["phpUrl_develop"].ToString();
                m_globalServerUrl = json["globalUrl_develop"].ToString();
                CfgJsonUrl = json["cfg_develop"].ToString();
                break;
            case ServerUrlType.INTEST_URL:
                m_BaseUrl = json["phpUrl_intest"].ToString();
                m_globalServerUrl = json["globalUrl_intest"].ToString();
                CfgJsonUrl = json["cfg_intest"].ToString();
                break;
            case ServerUrlType.RELEASE_URL:
                m_BaseUrl = json["phpUrl_release"].ToString();
                m_globalServerUrl = json["globalUrl_release"].ToString();
                CfgJsonUrl = json["cfg_release"].ToString();
                break;
        }
        Debug.Log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!PHPBaseUrl"+ m_BaseUrl);
    }

    public void ReqServerCfgJson()
    {
        HttpDownTextAsset(CfgJsonUrl, (code, content) => 
        {
            if (code != 0)
                return;
            try
            {
                string realContent = LuaHelper.AESDecrypt(content);
                Debug.Log(realContent);
                //防止请求json返回比海外开关还晚
                if (NS_VersionUpdate.AssetUpdateManager.Instance != null && NS_VersionUpdate.AssetUpdateManager.Instance.isUsingAboard)
                    return;
                var jsonData = JsonMapper.ToObject(realContent);
                if (jsonData == null)
                    return;
                BaseUrl = jsonData["phpUrl"].ToString();
                GlobalServerUrl = jsonData["globalUrl"].ToString();
                Framework.GameAppInstaller.serverCfgData = realContent;
            }
            catch (System.Exception ex)
            {
                Debug.LogError(ex);
            }
        });
    }


	public string getReleaseUrl() {
		JsonData deJson = JsonMapper.ToObject(Framework.GameAppInstaller.appConfData);
		return deJson["phpUrl_release"].ToString();
	}

    public void SetBaseUrl(string url)
    {
        m_BaseUrl = url;
    }

    public void HttpPostRequestWithData(string url, string param, Action<int, string, string> callBack)
    {
        Debug.Log(BaseUrl);
        Debug.Log(SubPath);
        Debug.Log(BaseUrl + SubPath + param);
        Debug.Log("发送请求：" + url);
        Debug.Log("发送数据：" + param);
        HTTPRequest request = new HTTPRequest(new Uri(url), HTTPMethods.Post, (HTTPRequest originalRequest, HTTPResponse response) =>
        {
            string responseStr = "";
            int result = 0;
            string msg = "";
            if (originalRequest.State == HTTPRequestStates.Finished)
            {
                Debug.Log("网络请求成功:" + response.StatusCode + response.IsSuccess);
                result = response.StatusCode;
                msg = response.Message;
                if (response.IsSuccess)
                {
                    result = 0;
                    responseStr = Encoding.UTF8.GetString(response.Data);
                }
                Debug.Log(responseStr);
            }
            else
            {
                result = -1;
                msg = "TimeOut";
            }
            if (callBack != null)
            {
                callBack(result, msg, responseStr);
            }
        });

        request.RawData = Encoding.UTF8.GetBytes(param);
        Debug.Log(request.Uri);
        HTTPManager.SendRequest(request);
    }

    public void HttpPOSTRequestV(string url, Action<int, string, string> callBack)
    {
        Debug.Log("发送请求：" + url);
        HTTPManager.SendRequest(url, HTTPMethods.Post, (HTTPRequest originalRequest, HTTPResponse response) => {
            string responseStr = "";
            int result = 0;
            string msg = "";
            if (originalRequest.State == HTTPRequestStates.Finished)
            {
                Debug.Log("网络请求成功" + response.StatusCode + response.IsSuccess);
                result = response.StatusCode;
                msg = response.Message;
                if (response.IsSuccess)
                {
                    result = 0;
                    responseStr = Encoding.UTF8.GetString(response.Data);
                }
            }
            else
            {
                result = -1;
                msg = "TimeOut";
            }
            if (callBack != null)
            {
                callBack(result, msg, responseStr);
            }
        });
    }


    public void HttpPOSTRequest(string param, Action<int, string, string> callBack)
    {
		string url = BaseUrl + SubPath + param;
//		PlayerPrefs.DeleteAll();
//		Debug.Log("HttpPOSTRequest url " + url);
        Debug.Log("请求:" + url);
        HTTPManager.SendRequest(url, HTTPMethods.Post, (HTTPRequest originalRequest, HTTPResponse response) =>
        {
            string responseStr = "";
            int result = 0;
            string msg = "";
            if (originalRequest.State == HTTPRequestStates.Finished)
            {
                Debug.Log("网络请求成功" + response.StatusCode + response.IsSuccess);
                result = response.StatusCode;
                msg = response.Message;
                if (response.IsSuccess)
                {
                    result = 0;
                    responseStr = Encoding.UTF8.GetString(response.Data);
                }
            }
            else
            {
                result = -1;
                msg = originalRequest.State.ToString();
                //msg = "TimeOut";
            }
            if (callBack != null)
            {
                callBack(result, msg, responseStr);
            }
        });
    }
    

   public void HttpRequestByMothdType(HTTPMethods methodType, string param, bool isKeepAlive,bool disableCache, Action<int, string, string> callBack)
    {
        string url = BaseUrl + SubPath + param;
        Debug.Log("发送请求：" + url);
        HTTPManager.SendRequest(url, methodType,isKeepAlive, disableCache, (HTTPRequest originalRequest, HTTPResponse response) =>
        {
            if (response == null)
            {
                callBack(-1, "", "");
                return;
            }
            string responseStr = "";
            int result = 0;
            string msg = "";
            if (response.IsSuccess)
            {
                responseStr = Encoding.UTF8.GetString(response.Data);
            }
            else
            {

                result = response.StatusCode;
                msg = response.Message;


            }
            if (callBack != null)
            {
                callBack(result, msg, responseStr);
            }
        });
    }


    public void HttpDownImage(string url, int imageWidth, int imageHeight, Action<HTTPRequestStates, Texture2D> callBack)
    {       
         HTTPRequest request = new HTTPRequest(new Uri(url), (req, resp) => {
            //HTTPRequest request = HTTPManager.SendRequest(new Uri(url).ToString(), HTTPMethods.Get,(req, resp) => {
            if(req.State == HTTPRequestStates.Finished)
            {
                Texture2D texture = null;
                int result;
                if (resp.IsSuccess)
                {
                     if (!resp.HasHeaderWithValue("Server", "nginx"))
                     {
                         //msg = "被中间运营商概率性劫持1次";
                         HTTPRequest request2 = new HTTPRequest(new Uri(url), (req2, resp2) =>
                         {
                             if (req2.State == HTTPRequestStates.Finished)
                             {
                                 if (resp2.IsSuccess)
                                 {
                                     texture = req.Tag as Texture2D;
                                     texture.LoadImage(resp2.Data);
                                 }
                                 else
                                 {
                                     result = resp2.StatusCode;
                                 }
                                 if (callBack != null)
                                 {
                                     callBack(req2.State, texture);
                                 }
                             }
                             else
                             {
                                 if (callBack != null)
                                 {
                                     callBack(req.State, null);
                                 }
                             }
                         });
                         request2.Tag = new Texture2D(imageWidth, imageHeight);
                         request2.Send();
                         return;
                     }
                     else
                     {
                         texture = req.Tag as Texture2D;
                         texture.LoadImage(resp.Data);
                     }
                }
                else
                {
                    result = resp.StatusCode;
                }

                if (callBack != null)
                {
                    callBack(req.State, texture);
                }
            }
            else
            {
                if (callBack != null)
                {
                    callBack(req.State, null);
                }
            }
        });
        request.Tag = new Texture2D(imageWidth, imageHeight);
        request.Send();
    }

    public void HttpDownAssetBundle(string url, Action<HTTPRequestStates, AssetBundle> callBack)
    {
        StartCoroutine(DownloadAssetAssetBundle(url, callBack));
    }

    private IEnumerator DownloadAssetAssetBundle(string url,Action<HTTPRequestStates, AssetBundle> callBack)
    {
        HTTPRequest request = new HTTPRequest(new Uri(url)).Send();
        while(request.State < HTTPRequestStates.Finished)
        {
            yield return new WaitForSeconds(0.1f);
        }
        switch(request.State)
        {
            case HTTPRequestStates.Finished:
                if (request.Response.IsSuccess)
                {
                    AssetBundleCreateRequest asyncAssetBundle = AssetBundle.LoadFromMemoryAsync(request.Response.Data);
                    yield return asyncAssetBundle;
                    if (callBack != null)
                    {
                        callBack(HTTPRequestStates.Finished, asyncAssetBundle.assetBundle);
                    }
                }
                break;
            default:
                if (callBack != null)
                {
                    callBack(request.State, null);
                }
                break;
        }
       
    }

    public void HttpDownloadFile(string url, Action<HTTPRequestStates, string, List<byte[]>> callBack)
    {
        HTTPRequest requset = new HTTPRequest(new Uri(url), (req, resp) => {

            switch(req.State)
            {
                case HTTPRequestStates.Processing:
                    //下载进度
                    string processingLength = resp.GetFirstHeaderValue("content-length");
                    if(callBack != null)
                    {
                        callBack(HTTPRequestStates.Processing, processingLength, resp.GetStreamedFragments());
                    }
                    break;
                case HTTPRequestStates.Finished:
                    if(resp.IsSuccess)
                    {
                        //完全下载完
                        if(resp.IsStreamingFinished)
                        {
                            if (callBack != null)
                            {
                                callBack(HTTPRequestStates.Finished, resp.GetFirstHeaderValue("content-length"), resp.GetStreamedFragments());
                            }
                        }
                    }
                    else
                    {
                      string  str = string.Format("Request finished Successfully, but the server sent an error. Status Code: {0}-{1} Message: {2}",
                                                           resp.StatusCode,
                                                           resp.Message,
                                                           resp.DataAsText);
                        Debug.LogWarning(str);
                    }
                    break;
                default:
                    if (callBack != null)
                    {
                        callBack(req.State, "", null);
                    }
                    break;
            }
        });
        requset.DisableCache = true;
        requset.StreamFragmentSize = HTTPResponse.MinBufferSize;
        requset.Send();
    }

    string path;
    //GameRule
    string filepath;
    public void HttpDownTextAsset(string url, Action<int, string> callBack, string filepath = null)
    {        
        HTTPRequest request = new HTTPRequest(new Uri(url), (req, resp) =>
        {
            if (resp == null)
            {
                Debug.LogError("resp is null");
                Debug.LogError(req.Exception);
                callBack(-1, "");
                return;
            }

            if (req.State == HTTPRequestStates.Finished)
            {                
                if (resp.IsSuccess)
                {
                    int index = url.LastIndexOf('/');
                    string fileName = url.Substring(index + 1, url.Length - index -1);
                    string context = System.Text.Encoding.UTF8.GetString(resp.Data);
                    if (filepath != null)
                    {
                        CreateFile(filepath, fileName, context);
                    }
                    if (callBack !=null)
                    {
                        callBack(0, context);
                    }
                }
                else
                {
                    if (callBack != null)
                    {
                        callBack(resp.StatusCode, null);
                    }
                }
            }
            else
            {
                if (callBack != null)
                {
                    callBack(resp.StatusCode, null);
                }
            }
        });
        request.Send();
    }

    public void HttpDownTextAssetByte(string url, Action<HTTPRequestStates, byte[]> callBack)
    {
        HTTPRequest request = new HTTPRequest(new Uri(url), (req, resp) =>
        {
            if (req.State == HTTPRequestStates.Finished)
            {
                int result;
                if (resp.IsSuccess)
                {
                    if (callBack != null)
                    {
                        callBack(req.State, resp.Data);
                    }
                }
                else
                {
                    result = resp.StatusCode;
                    if (callBack != null)
                    {
                        callBack(req.State, null);
                    }
                }
            }
            else
            {
                if (callBack != null)
                {
                    callBack(req.State, null);
                }
            }
        });
        request.Send();
    }

    public void CreateFile(string path, string name ,string info)
    {
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }

        StreamWriter sw;
        FileInfo t = new FileInfo(path + "//" + name);
        if(!t.Exists)
        {
            sw = t.CreateText();
        }
        else
        {
            t.Delete();
            sw = t.CreateText();
        }
        sw.Write(info);
        sw.Close();
        sw.Dispose();
    }

    public string GetMacAddress()
    {

        m_physicalAddress = SystemInfo.deviceUniqueIdentifier;
#if UNITY_EDITOR
        NetworkInterface[] nice = NetworkInterface.GetAllNetworkInterfaces();

        foreach (NetworkInterface adaper in nice)
        {

            LuaInterface.Debugger.Log(adaper.Description);

            if (adaper.Description == "en0")
            {
                m_physicalAddress = adaper.GetPhysicalAddress().ToString() + testAccount;
                break;
            }
            else
            {
                m_physicalAddress = adaper.GetPhysicalAddress().ToString() + testAccount;
                if (m_physicalAddress != "")
                {
                    break;
                };
            }
        }
#endif
        return m_physicalAddress;
    }


}
