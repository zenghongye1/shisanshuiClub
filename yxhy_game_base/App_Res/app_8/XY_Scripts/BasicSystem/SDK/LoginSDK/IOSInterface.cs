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
	public static extern void CheckWXInstall();
#endif
}