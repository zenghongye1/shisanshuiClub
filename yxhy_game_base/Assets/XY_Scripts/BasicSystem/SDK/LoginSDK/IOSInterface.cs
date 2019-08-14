using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;


public class IOSInterface
{
#if UNITY_IOS
    [DllImport("__Internal")]
	 public static extern void Init(string appId, bool isTest, string observer);

	[DllImport("__Internal")]
	public static extern void WeiXinLogin();

	[DllImport("__Internal")]
	public static extern void WeiXinShare(int shareType, int type, string title, string filePath, string url, string description);

	[DllImport ("__Internal")]
	public static extern void CopyToClipboard(string text);

    [DllImport ("__Internal")]
    public static extern void setPushUID(string uid);

    [DllImport ("__Internal")]
	public static extern void CheckWXInstall();

    [DllImport ("__Internal")]
    public static extern void TencentQQLogin();
    
    [DllImport ("__Internal")]
    public static extern void CheckQQInstall();

    [DllImport("__Internal")]
	public static extern void TencentQQSharRiceText(string title, string summary, string targetUrl, string imgPath);

    [DllImport("__Internal")]
	public static extern void TencentQQShareImg(string imagPath, string appName);

    [DllImport("__Internal")]
	public static extern void TencentQQShareToQQZone(string title, string summary, string targeUrl, string imgPath);

    [DllImport ("__Internal")]
    public static extern void ApplePayInit(string _proList);
    [DllImport ("__Internal")]
    public static extern void ApplePay(string _proID);

    [DllImport ("__Internal")]
    public static extern bool isIphoneX();

    [DllImport("__Internal")]
    public static extern void GetCopyText();

    [DllImport("__Internal")]
    public static extern void locationStart();

    [DllImport("__Internal")]
    public static extern void locationStop();
    [DllImport("__Internal")]
    public static extern double getLocationDistance(double latitudeA, double longitudeA, double latitudeB, double longitudeB);
    #endif
}