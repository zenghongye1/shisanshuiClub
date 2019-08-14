using UnityEngine;
using System.Collections;
public class AndroidInterface
	{
		private   AndroidJavaObject m_JavaObject = null;
    private AndroidJavaObject m_QQGameObj = null;
    public AndroidJavaObject activiy = null;
    public AndroidInterface()
		{
			using (AndroidJavaClass jpushClass = new AndroidJavaClass("com.yaoxing.android.api.YX_APIManage"))
			{
            m_JavaObject = jpushClass.CallStatic<AndroidJavaObject>("Instance");

			}
        activiy = new AndroidJavaClass("com.unity3d.player.UnityPlayer").GetStatic<AndroidJavaObject>("currentActivity");
    }

	    //初始化接口
	    public void InitPlugins(bool isTest, string gameObjectName)
	    {
			
			if (m_JavaObject == null) return;
            m_JavaObject.Call("YXAndroidPluginsInit", isTest, gameObjectName, activiy);
	    }
    public void CheckWXInstall() {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_CheckWXInstall");
    }
    public void WeiXinLogin()
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_WeiXinLogin");
    }

    public void WeiXinShare(int shareType, int type, string title, string filePath, string url, string description)
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_WeiXinShare", shareType, type, title, filePath, url, description);
    }

    public void WeiXinPay(string data)
    {
        if (m_JavaObject == null) return;
        
         m_JavaObject.Call("YX_WeiXinPay", data);
        
    }

    public void QQLogin()
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_QQlogin");
    }
   
    public void QQLogOut()
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_QQLogout");
    }

    public void CheckQQInstall() {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_CheckQQInstall");
    }
    
    public void QQSharRiceText(string title,string summary,string targetUrl,string imgPath)
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_QQShareRichTxt", title, summary, targetUrl, imgPath);
    }

    public void QQShareImg(string imagPath,string appName)
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("XY_QQShareImg", imagPath, appName);
    }

    public void QQShareToQQZone(string title,string summary,string targeUrl,string imgPath)
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_QQShareToQQZone", title, summary, targeUrl, imgPath);
    }

    public void QQActivityResult(int requestCode,int resultCode,object data)
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YC_QQOnActivityResult", requestCode, resultCode, data);
    }

    public void GetBattery(bool isEnable)
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_IsEnableBattery", isEnable);
    }

    public void GetPhoneStreng()
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("YX_GetPhoneStreng");
    }

    public void startIAppPay(string param)
    {
        if (m_JavaObject == null) return;
        Debug.Log("AndroidInterface startIAppPay ");
        m_JavaObject.Call("YX_StartIAppPay", param);
    }

    public void DouYouPay(string _money, string _pid)
    {
        if (m_JavaObject == null) return;
        Debug.Log("AndroidInterface DouYouPay ");
        m_JavaObject.Call("YX_DouYouPay", _money, _pid);
    }
    public void DouYouLogin(string _plaformID, string _openID)
    {
        if (m_JavaObject == null) return;
        Debug.Log("AndroidInterface DouYouLogin ");
        m_JavaObject.Call("YX_DouYouLogin", _plaformID, _openID);
    }

    public void onCopy(string msg)
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("copyTextToClipboard", activiy, msg);

    }

    public void setPushUID(string msg)
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("setPushUID", activiy, msg);

    }

    public void getCopyText()
    {
        if (m_JavaObject == null) return;


        m_JavaObject.Call("getCopyText");
    }

    public void locationStart()
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("locationStart");
    }

    public void locationStop()
    {
        if (m_JavaObject == null) return;
        m_JavaObject.Call("locationStop");
    }

    public double getLocationDistance(double latitudeA,double longitudeA,double latitudeB,double longitudeB)
    {
        if (m_JavaObject == null) return 0.0;
        return m_JavaObject.Call<double>("getLocationDistance", latitudeA, longitudeA, latitudeB, longitudeB);
    }
}
