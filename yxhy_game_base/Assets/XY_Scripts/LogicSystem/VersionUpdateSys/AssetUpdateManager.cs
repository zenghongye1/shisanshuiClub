using UnityEngine;
using System.Collections;
using System.IO;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net;
using Framework;
using NS_DataCenter;
using XYHY;
using XYHY.ABSystem;
using System.Text;
using LitJson;

namespace NS_VersionUpdate
{
    public enum VersionUpdateType
    {
        NoNeedUpdate,               //不需要更新
        PatchPackageUpdate,         //增量包更新
        OSPackageUpdate,
    }


    //@todo  热更逻辑与UI抽离
    public class AssetUpdateManager : MonoBehaviour
    {
        public static AssetUpdateManager Instance;

        [SerializeField]
        private bool isEnableVersionUpdate = true;

        /// <summary>
        /// 版本校验服务器地址
        /// </summary>
        [SerializeField]
        private string httpUrl = "http://intest.dstars.cc/appid/appid_4/appid_4_v1.0.0";

        [SerializeField]
        private UILabel currentVerNoLab;
        [SerializeField]
        private UILabel checkState;  //检查更新状态
        [SerializeField]
        private UISlider slider;     //进度条
        [SerializeField]
        private UILabel downSizeLab;

        public GameObject commPanel;

        private long allSize = 0;
        private MessageBox curMsgBox = null;
        private MessageNoticeUI curNoticeUI = null;
        private Coroutine versionReqCor = null;
        private AssetBundleParams abp = null;

        List<VersionInfo> verInfoLst = new List<VersionInfo>();
        public List<string> verFileNameLst = new List<string>();

        private List<string> depFileNameLst = new List<string>();

        public string urlFilePath = "";      
        private AssetBundleDataReader _depInfoReader = null;
        List<DownLoadFile> downloadLst = new List<DownLoadFile>();
        Dictionary<string, bool> downloadUrlDic = new Dictionary<string, bool>();
        bool isStartUpdate = false;
        List<VersionDepInfo> verDepInfoLst = new List<VersionDepInfo>();

        public bool isUsingAboard;

        int retryTime = 0;

        private string m_verFileName = "";
        private string m_depFileName = "";
        private Action m_gameHotEvent = null;
        private Action<long> m_needDownLoadCallback = null;
        private Coroutine m_gameVerReqCor = null;        
        private AssetBundleDataReader m_gameDepInfoReader = null;
        private AssetBundleDataReader m_localGameDepInfoReader = null;
        private VersionDepInfo m_gameVerDepInfo = null;
        private List<VersionDepInfo> m_gameDepInfoLst = new List<VersionDepInfo>();
        private bool m_isCanGameDownload = false;
        private bool m_isGameStartUpdate = false;
        private List<DownLoadFile> m_gameDownloadLst = new List<DownLoadFile>();

        private GameObject _rootGo;

        int packLimit = 0;
        int gamePackLimit = 0;



        public void HttpPOSTRequest(string rt, Action<string, int, string> callback)
        {
            NetWorkManage.Instance.HttpPOSTRequest(rt, delegate (int code, string msg, string str)
            {
                if (code == 0)
                {
                    callback(str, code, msg);
                }
                else
                {
					//if (NetWorkManage.Instance.EServerUrlType == ServerUrlType.ABROAD_URL)
					//{
					//	NetWorkManage.Instance.EServerUrlType = ServerUrlType.RELEASE_URL;
					//	NetWorkManage.Instance.Init();
					//}

                    if (retryTime == 3)
                    {
                        ShowMsg("确定", delegate
                        {
                            CloseMessageBox();
                            this.HttpPOSTRequest(rt, callback);
                        }, 1, "网络请求失败，是否重新请求");
                        return;
                    }

                    retryTime = retryTime + 1;
                    this.HttpPOSTRequest(rt, callback);
                }
            });            
        }


#region Mono方法
        void Awake()
        {
            Instance = this;
            new AssetBundlePathResolver();

            _rootGo = transform.Find("root").gameObject;

            depFileNameLst = GameAppInstaller.Instance.depFileNameLst;

            JsonData deJson = JsonMapper.ToObject(GameAppInstaller.appConfData);
            for (int i = 0; i < deJson["verFileNameLst"].Count; i++)
            {
                verFileNameLst.Add(deJson["verFileNameLst"][i].ToString());
            }

            GameObject.DontDestroyOnLoad(this.gameObject);
        }


        bool CheckIosCard()
        {
            return PlayerPrefs.HasKey("ioscard") && PlayerPrefs.GetInt("ioscard") == 0;
        }

        void PassIosCardAndCheckVer(bool saveKey)
        {
            CheckVer();
            LuaHelper.isAppleVerify = false;
            if (saveKey)
                PlayerPrefs.SetInt("ioscard", 0);
        }

        void Start()
        {
            Messenger.AddListener(MSG_DEFINE.MSG_DESTROY_VERSION_UPDATE_UI, AssetUpdateMgrHandler);

            if (!isEnableVersionUpdate)
            {
                SkipAssetUpdate();
                return;
            }           

            if (checkState != null)
            {
                checkState.gameObject.SetActive(true);
                checkState.text = "正在连接服务器...";
            }

#if UNITY_ANDROID
				//安卓直接进入热更
				CheckVer();
				return;
#endif
#if UNITY_EDITOR
            PlayerPrefs.DeleteKey("ioscard");
#endif
            //本地有ioscard标识  直接当做过审
            if (CheckIosCard())
            {
                PassIosCardAndCheckVer(false);
                return;
            }
            var versionInfo = FileUtils.GetStreamAssetVer(verFileNameLst[0]);
            if (versionInfo == null)
            {
                PassIosCardAndCheckVer(true);
            }
            else
            {
                string ver = versionInfo.VersionNum;
                string switchUrl = string.Format("{0}/v{1}.json", NetWorkManage.Instance.SwithJosnUrl, ver);
                string swithHomeUrl = string.Format("{0}/v{1}.json", NetWorkManage.Instance.SwitchHomeUrl, ver);
                ReqIosCard(switchUrl, () =>
                {
                    ReqIosCard(swithHomeUrl, () =>
                    {
                        PassIosCardAndCheckVer(true);
                    });
                });
            }
       





            ////拉取开关
            //JsonData ioscardData = new JsonData();
            //ioscardData["method"] = "GameSAR.getFunFbd";
            //ioscardData ["siteid"] = GetSiteIDByPlatform ();
            //VersionInfo _verInfo = FileUtils.GetGameVerNo(verFileNameLst[0]);
            //if (_verInfo == null)
            //{
            //	ShowMsg("确定", delegate
            //		{
            //			CloseMessageBox();
            //			Application.Quit();
            //                     DownloadFileChecker.Close();
            //		}, 1, "版本信息读取失败");
            //	return;
            //}
            //ioscardData["version"] = _verInfo.VersionNum;
            //ioscardData["appid"] = _verInfo.appID;
            //if (PlayerPrefs.HasKey("USER_UID"))
            //{
            //	ioscardData["uid"] = PlayerPrefs.GetString("USER_UID");
            //}
            //string reqStr = ioscardData.ToJson();
            //LuaInterface.Debugger.Log(string.Format("reqStr:{0}", reqStr));
            //HttpPOSTRequest (reqStr, delegate (string _data, int code, string rtStr) 
            //{
            //	LuaInterface.Debugger.Log(string.Format("_data:{0}", _data));
            //             if (code != 0)
            //                 return;
            //             JsonData deJson = JsonMapper.ToObject(_data);
            //             int iIoscard = 0;
            //             deJson = deJson["data"];
            //             //var deJsonDic = deJson as IDictionary;
            //             //if (deJsonDic != null && deJsonDic.Contains("ioscard"))
            //	if (!(deJson.IsArray) && ((IDictionary)deJson).Contains("ioscard"))
            //             {
            //                 deJson = deJson["ioscard"];
            //                 if (deJson != null)
            //                 {
            //                     iIoscard = int.Parse(deJson.ToString());
            //                 }
            //             }
            //             //				//LuaInterface.Debugger.Log(string.Format("iIoscard:{0}", iIoscard));
            //             //				if (NetWorkManage.Instance.EServerUrlType == ServerUrlType.RELEASE_URL && iIoscard ==1)
            //             //				{
            //             //					//审核连了国内服?
            //             //				}
            //             //				else
            //             //				{
            //             //					CheckVer();
            //             //				}

            //             if (iIoscard != 1)
            //             {
            //                 //if(NetWorkManage.Instance.EServerUrlType == ServerUrlType.ABROAD_URL)
            //                 //{
            //                 //    NetWorkManage.Instance.EServerUrlType = ServerUrlType.RELEASE_URL;
            //                 //    NetWorkManage.Instance.Init();
            //                 //}
            //                 CheckVer();
            //             }
            //             else
            //             {
            //                 SkipAssetUpdate();
            //             }

            //});
        }

        void ReqIosCard(string url, Action errorHandler)
        {
            NetWorkManage.Instance.HttpDownTextAsset(url, (code, content) =>
            {
                if (code != 0)
                {
                    errorHandler();
                    return;
                    //PassIosCardAndCheckVer(true);
                    //return;
                }
                try
                {
                    UnityEngine.Debug.Log("switch : " + url + "   " + content);
                    isUsingAboard = true;
                    JsonData deJson = JsonMapper.ToObject(content);
                    if (deJson != null && deJson["ioscard"] != null && int.Parse(deJson["ioscard"].ToString()) == 1)
                    {
                        LuaHelper.isAppleVerify = true;
                        NetWorkManage.Instance.BaseUrl = "http://" + deJson["phpUrl"].ToString();
                        NetWorkManage.Instance.GlobalServerUrl = "http://" + deJson["globalUrl"].ToString();
                        SkipAssetUpdate();
                    }
                    else
                    {
                        PassIosCardAndCheckVer(true);
                    }
                }
                catch (System.Exception ex)
                {
                    UnityEngine.Debug.LogError(ex);
                    errorHandler();
                    //PassIosCardAndCheckVer(true);
                }
            });
        }


		void CheckVer()
		{
            VersionResult(VersionUpdateType.NoNeedUpdate);
            return;
#if UNITY_ANDROID || UNITY_IPHONE || (AB_WINDOW && UNITY_STANDALONE)
            //php请求 检测是否需要强更或者是热更
            JsonData data = new JsonData();
			data["siteid"] = GetSiteIDByPlatform ();

			VersionInfo verInfo = FileUtils.GetGameVerNo(verFileNameLst[0]);
			if (verInfo == null)
			{
				ShowMsg("确定", delegate
					{
						CloseMessageBox();
						Application.Quit();
					}, 1, "版本信息读取失败");
				return;
			}

			data["version"] = verInfo.VersionNum;
			data["appid"] = verInfo.appID;
			if (PlayerPrefs.HasKey("USER_UID"))
			{
				data["uid"] = PlayerPrefs.GetString("USER_UID");
			}            
			data["method"] = "GameSAR.getVersionUp";
			string reqStr = data.ToJson();
			LuaInterface.Debugger.Log(string.Format("reqStr:{0}", reqStr));
			HttpPOSTRequest(reqStr, delegate (string _data, int code, string rtStr)
				{
					LuaInterface.Debugger.Log(string.Format("_data:{0}", _data));
					JsonData deJson = JsonMapper.ToObject(_data);
					bool isForce = bool.Parse(deJson["updateInfo"]["forceUpdate"]["isForce"].ToString());
                    PrasePackLimits(deJson);
                    if (isForce)
					{
						string downUrl = deJson["updateInfo"]["forceUpdate"]["url"].ToString();
                        ShowNotice("发现新版本，是否立即更新？", "更 新", "取 消", "建议:请在WiFi环境下下载", () =>
                        {
                            Application.OpenURL(downUrl);
                            Application.Quit();
                        }, ()=> { Application.Quit(); });
                        //ShowMsg("确定", delegate
                        //	{
                        //		CloseMessageBox();
                        //		Application.OpenURL(downUrl);
                        //		Application.Quit();
                        //	}, 1, "发现新的内容需要更新，\n是否现在进行更新？");
                    }
					else
					{
						bool isNeed = bool.Parse(deJson["updateInfo"]["hotUpdate"]["isNeed"].ToString());
						if (isNeed)
						{
							httpUrl = deJson["updateInfo"]["hotUpdate"]["url"].ToString();
							for (int i=0; i<verFileNameLst.Count; i++)
							{
								if (i == 0)
								{
									verInfoLst.Add(verInfo);
								}
								else
								{
									VersionInfo _verInfo = FileUtils.GetGameVerNo(verFileNameLst[i]);
									if (_verInfo != null)
									{
										verInfoLst.Add(_verInfo);
									}
									else
									{
										ShowMsg("确定", delegate
											{
												CloseMessageBox();
												Application.Quit();
											}, 1, "版本信息读取失败");
										return;
									}
								}     
							}

							if (currentVerNoLab != null && verInfoLst.Count > 0)
							{
								currentVerNoLab.text = string.Format("当前资源版本 v{0}", verInfoLst[0].VersionNum);
							}
							versionReqCor = StartCoroutine(VersionReqCorFun());
						}
						else
						{
							VersionResult(VersionUpdateType.NoNeedUpdate);
						}
					}
				});
#else
			VersionResult(VersionUpdateType.NoNeedUpdate);
#endif
		}

        void PrasePackLimits(JsonData deJson)
        {
            if (deJson.Keys.Contains("packlimit") && deJson["packlimit"] != null)
            {
                if(!int.TryParse(deJson["packlimit"].ToString(), out packLimit))
                {
                    packLimit = 0;
                }
            }
            if (deJson.Keys.Contains("gamepacklimit") && deJson["gamepacklimit"] != null)
            {
                if (!int.TryParse(deJson["gamepacklimit"].ToString(), out packLimit))
                {
                    gamePackLimit = 0;
                }
            }
        }

        bool CheckNeedShowDownTip(long size, bool isGame = false)
        {
            long limitSize = packLimit;
            if (isGame)
                limitSize = gamePackLimit;
            limitSize *= (1024 * 1024);
            if (limitSize == 0)
                return false;
            return limitSize <= size;
        }


		int GetSiteIDByPlatform()
		{
			int ret = -1;
			//php请求 检测是否需要强更或者是热更
			switch(Application.platform)
			{
			case RuntimePlatform.WindowsEditor:
				ret = 1;
				break;
			case RuntimePlatform.Android:
				ret = 1;
				break;
			case RuntimePlatform.IPhonePlayer:
				ret = 1001;
				break;
			}
			return ret;
		}

        private void Update()
        {

            //进入游戏默认包的热更处理
            if (IsAllUpdateFileCheck() && !isStartUpdate)
            {
                if (checkState != null)
                {
                    checkState.text = "正在检查更新...";
                }

                GetDownloadFileLst();
                if (downloadLst.Count > 0)
                {
                    VersionResult(VersionUpdateType.PatchPackageUpdate);
                    isStartUpdate = true;
                }
                else
                {                    
                    VersionResult(VersionUpdateType.NoNeedUpdate);
                    isStartUpdate = true;
                }
            }

            //大厅中热更游戏处理
            if (m_isCanGameDownload && !m_isGameStartUpdate)
            {
                m_isGameStartUpdate = true;
                GetGameDownloadFileLst(()=>{
                    if (m_gameDownloadLst.Count > 0)
                    {
                        HandleGamePatchPackageData();                        
                    }
                    else
                    {
                        if (m_gameHotEvent != null)
                        {
                            m_gameHotEvent();
                        }
                        //m_isGameStartUpdate = true;
                    }
                });
            }
        }

        private bool CheckRecommendPlay()
        {
            if (!DeviceQuality.IsRecommendPlay())
            {
                ShowMsg("确定", () =>
                {
                    CloseMessageBox();
                    Application.Quit();
                }, 1, "手机配置较低，不推荐游玩");

                return false;
            }

            return true;
        }

        void OnDestroy()
        {
            Messenger.RemoveListener(MSG_DEFINE.MSG_DESTROY_VERSION_UPDATE_UI, AssetUpdateMgrHandler);
            DownloadFileChecker.Close();
        }
#endregion Mono方法

        private bool isSkipAssetUpdate = false;
        public void SkipAssetUpdate()
        {
            if (!isSkipAssetUpdate)
            {
                isSkipAssetUpdate = true;
                CloseMessageBox();
                if (versionReqCor != null)
                {
                    StopCoroutine(versionReqCor);
                }
                if (startGameCor != null)
                {
                    StopCoroutine(startGameCor);
                }
                startGameCor = StartCoroutine(StartGameCorFun());
            }
        }

        void DownloadVersionFile(string verUrl, string depUrl, VersionInfo verInfo, int verIndex)
        {
            int curVerIndex = verIndex;
            LuaInterface.Debugger.Log("url==============" + verUrl);
            NetWorkManage.Instance.HttpDownTextAsset(verUrl, (code, msg) => {
                if (code == -1)
                {
                    ShowMsg("确定", delegate
                    {
                        CloseMessageBox();
                        if (versionReqCor != null)
                        {
                            StopCoroutine(versionReqCor);
                            versionReqCor = StartCoroutine(VersionReqCorFun());
                        }
                        else
                        {
                            versionReqCor = StartCoroutine(VersionReqCorFun());
                        }
                    }, 1, "连接失败，请更换网络环境后重试");
                    return;
                }

                if (code < 0)
                {
                    ShowMsg("确定", delegate { Application.Quit(); DownloadFileChecker.Close(); }, 1, "系统异常，请重试");
                    return;
                }

                if (code >= 0)
                {
                    LuaInterface.Debugger.Log("msg==============" + msg);
                    if (msg != null && msg != "")
                    {
                        VersionInfo srvVerInfo = LitJson.JsonMapper.ToObject<VersionInfo>(msg);
                        Version srvVersion = new Version(srvVerInfo.VersionNum);
                        Version curVersion = new Version(verInfo.VersionNum);

                        // 下载完成ver_app_4后  读取版本号 查询本地下载完成资源
                        if(curVerIndex == 1)
                        {
                            DownloadFileChecker.InitDownFileInfo(srvVerInfo.VersionNum);
                        }
                        
                        if (srvVerInfo.OsType == verInfo.OsType && curVersion < srvVersion)
                        {
                            int index = verUrl.LastIndexOf('/');
                            string fileName = verUrl.Substring(index + 1, verUrl.Length - index - 1);                            

                            //检测需要更新的文件列表                    
                            CheckUpdateFileList(depUrl, () => {
                                downloadUrlDic[verUrl] = true;
                                VersionDepInfo verDepInfo = new VersionDepInfo();
                                verDepInfo.msg = msg;
                                verDepInfo.fileName = fileName;
                                verDepInfoLst.Add(verDepInfo);
                                //NetWorkManage.Instance.CreateFile(AssetBundlePathResolver.instance.BundlesPathForPersistent, fileName, msg);
                            });
                        }
                        else
                        {
                            downloadUrlDic[verUrl] = true;
                        }
                    }
                    else
                    {
                        LuaInterface.Debugger.Log("{0}版本文件读取有误", verUrl);
                    }
                }
            });
        }


        void ReloadDepInfo()
        {
            var appData = FileUtils.GetAppConfData("config/app_config.txt");
            JsonData deJson = JsonMapper.ToObject(appData);
            for (int i = 0; i < deJson["depFileNameLst"].Count; i++)
            {
                depFileNameLst.Add(deJson["depFileNameLst"][i].ToString());
            }
            var abManager = AssetBundleManager.Instance;
            for(int i = 0; i < depFileNameLst.Count; i++)
            {
                abManager.LoadRemoteDepInfoDirectly(depFileNameLst[i], null);
            }
            //abManager.StartCoroutine(abManager.LoadDepInfo(depFileNameLst[0]));
            ////根据需要加载
            //if (depFileNameLst.Count > 1)
            //{
            //    for (int i = 1; i < depFileNameLst.Count; i++)
            //    {
            //        abManager.StartCoroutine(abManager.SubLoadDepInfo(depFileNameLst[i]));
            //    }
            //}
        }

        bool IsAllUpdateFileCheck()
        {
            if (downloadUrlDic.Values.Count <= 0)
            {
                return false;
            }

            bool ret = true;
            foreach(bool var in downloadUrlDic.Values)
            {
                if (!var)
                {
                    ret = false;
                    break;
                }
            }
            return ret;
        }

        IEnumerator VersionReqCorFun()
        {
            yield return null;            

            for (int i=0; i< verFileNameLst.Count; i++)
            {
                string filePath = string.Format(urlFilePath, AssetBundlePathResolver.instance.BundlePlatform, verFileNameLst[i]);
                string gameVerUrl = httpUrl + filePath;
                if (downloadUrlDic.ContainsKey(gameVerUrl))
                {
                    downloadUrlDic[gameVerUrl] = false;
                }
                else
                {
                    downloadUrlDic.Add(gameVerUrl, false);
                }
                
                string depPath = string.Format(urlFilePath, AssetBundlePathResolver.instance.BundlePlatform, depFileNameLst[i]);
                string depUrl = httpUrl + depPath;
                DownloadVersionFile(gameVerUrl, depUrl, verInfoLst[i], i);
            }
        }

        void CheckUpdateFileList(string depUrl, Action callback)
        {            
            //读取服务器端依赖文件            
            NetWorkManage.Instance.HttpDownTextAssetByte(depUrl, (code, msgByte) =>
            {
                MemoryStream depStream = new MemoryStream(msgByte);
                if (depStream.Length > 4)
                {
                    if (_depInfoReader == null)
                    {
                        BinaryReader br = new BinaryReader(depStream);
                        if (br.ReadChar() == 'A' && br.ReadChar() == 'B' && br.ReadChar() == 'D')
                        {
                            if (br.ReadChar() == 'T')
                                _depInfoReader = new AssetBundleDataReader();
                            else
                                _depInfoReader = new AssetBundleDataBinaryReader();

                            depStream.Position = 0;
                            _depInfoReader.Read(depStream);
                        }
                    }
                    else
                    {
                        depStream.Position = 0;
                        _depInfoReader.Read(depStream);
                    }

                    int index = depUrl.LastIndexOf('/');
                    string fileName = depUrl.Substring(index + 1, depUrl.Length - index - 1);

                    VersionDepInfo verDepInfo = new VersionDepInfo();
                    verDepInfo.msg = System.Text.Encoding.UTF8.GetString(msgByte);
                    verDepInfo.fileName = fileName;
                    verDepInfoLst.Add(verDepInfo);
                }
                depStream.Close();

                if (callback != null)
                {
                    callback();
                }
            });
        }

        bool CheckAddToDownList(AssetBundleDataReader remoteDepInfoReader, AssetBundleDataReader localDepInfoReader,  string key, bool checkLocal = true)
        {
            var remoteBundleInfo = remoteDepInfoReader.infoMap[key];
            if (checkLocal && DownloadFileChecker.CheckKeyHasDownLoad(key, remoteBundleInfo.hash))
                return false;
            if (localDepInfoReader == null || localDepInfoReader.infoMap == null)
                return true;
            if (!localDepInfoReader.infoMap.ContainsKey(key))
                return true;
            return localDepInfoReader.infoMap[key].hash != remoteBundleInfo.hash;

        }

        void GetDownloadFileLst()
        {
            if (_depInfoReader != null)
            {
                foreach (string key in _depInfoReader.infoMap.Keys)
                {
                    if (CheckAddToDownList(_depInfoReader, AssetBundleManager.Instance.depInfoReader, key))
                    {
                        DownLoadFile downloadFile = new DownLoadFile();
                        string firstFileName = "";
                        if (!_depInfoReader.infoMap[key].fullName.EndsWith(".bytes"))
                        {
                            firstFileName = _depInfoReader.infoMap[key].belongName;
                        }
                        downloadFile.remoteFile = httpUrl + "/" + AssetBundlePathResolver.instance.BundlePlatform + "/" + AssetBundlePathResolver.instance.BundleSaveDirName + "/"
                            + firstFileName + "/" + _depInfoReader.infoMap[key].fullName;
                        downloadFile.localFile = AssetBundlePathResolver.instance.BundlesPathForPersistent + firstFileName + "/" + _depInfoReader.infoMap[key].fullName;
                        //if (File.Exists(downloadFile.localFile))
                        //{
                        //    File.Delete(downloadFile.localFile);
                        //}
                        var time = Time.realtimeSinceStartup;
                        //downloadFile.totalSize = ThreadDownLoad.GetHttpLength(downloadFile.remoteFile);     //_depInfoReader.infoMap[key].size;   //(计算大小有误)
                        downloadFile.totalSize = _depInfoReader.infoMap[key].size;
                        downloadFile.size = downloadFile.totalSize;
                        downloadFile.key = key;
                        downloadFile.crc = _depInfoReader.infoMap[key].hash;
                        if (downloadFile.size > 0)
                            downloadLst.Add(downloadFile);
                    }
                }
            }

#region old
            //              if (AssetBundleManager.Instance.depInfoReader.infoMap.ContainsKey(key))
            //              {
            //                  if (AssetBundleManager.Instance.depInfoReader.infoMap[key].hash != _depInfoReader.infoMap[key].hash)
            //                  {
            //                      DownLoadFile downloadFile = new DownLoadFile();
            //                      //#if UNITY_IOS || UNITY_IPHONE
            //                      //                            string firstFileName = _depInfoReader.infoMap[key].debugName.Split('/')[2];
            //                      //#elif UNITY_ANDROID || (AB_WINDOW && UNITY_STANDALONE)
            //                      //                            string firstFileName = _depInfoReader.infoMap[key].debugName.Split('\\')[2];
            //                      //#else
            //                      //                            string firstFileName = "";
            //                      //#endif                
            //                      string firstFileName = "";
            //                      if (!_depInfoReader.infoMap[key].fullName.EndsWith(".bytes"))
            //                      {
            //                          firstFileName = _depInfoReader.infoMap[key].belongName;
            //                      }
            //                      downloadFile.remoteFile = httpUrl + "/" + AssetBundlePathResolver.instance.BundlePlatform + "/" + AssetBundlePathResolver.instance.BundleSaveDirName + "/"
            //	+ firstFileName + "/" + _depInfoReader.infoMap[key].fullName.Replace("\\", "/");
            //	downloadFile.localFile = AssetBundlePathResolver.instance.BundlesPathForPersistent + firstFileName + "/" + _depInfoReader.infoMap[key].fullName.Replace("\\", "/");
            //                      if (File.Exists(downloadFile.localFile))
            //                      {
            //                          File.Delete(downloadFile.localFile);
            //                      }
            //                      LuaInterface.Debugger.Log("downloadFile.remoteFile--------------------------" + downloadFile.remoteFile);
            //                      downloadFile.totalSize = ThreadDownLoad.GetHttpLength(downloadFile.remoteFile);     //_depInfoReader.infoMap[key].size;   //(计算大小有误)
            //                      downloadFile.size = downloadFile.totalSize;
            //                      if(downloadFile.size > 0)
            //                          downloadLst.Add(downloadFile);
            //                  }
            //              }
            //              else
            //              {
            //                  DownLoadFile downloadFile = new DownLoadFile();
            //                  //#if UNITY_IOS || UNITY_IPHONE
            //                  //                        string firstFileName = _depInfoReader.infoMap[key].debugName.Split('/')[2];
            //                  //#elif UNITY_ANDROID || (AB_WINDOW && UNITY_STANDALONE)
            //                  //                        string firstFileName = _depInfoReader.infoMap[key].debugName.Split('\\')[2];
            //                  //#else
            //                  //                        string firstFileName = "";
            //                  //#endif            
            //                  string firstFileName = "";
            //                  if (!_depInfoReader.infoMap[key].fullName.EndsWith(".bytes"))
            //                  {
            //                      firstFileName = _depInfoReader.infoMap[key].belongName;
            //                  }
            //                  downloadFile.remoteFile = httpUrl + "/" + AssetBundlePathResolver.instance.BundlePlatform + "/" + AssetBundlePathResolver.instance.BundleSaveDirName + "/"
            //	+ firstFileName + "/" + _depInfoReader.infoMap[key].fullName.Replace("\\", "/");
            //downloadFile.localFile = AssetBundlePathResolver.instance.BundlesPathForPersistent + firstFileName + "/" + _depInfoReader.infoMap[key].fullName.Replace("\\", "/");                       
            //                  downloadFile.totalSize = ThreadDownLoad.GetHttpLength(downloadFile.remoteFile);         //_depInfoReader.infoMap[key].size;                            
            //                  downloadFile.size = downloadFile.totalSize - ThreadDownLoad.GetSize(downloadFile.localFile);     
            //                  downloadLst.Add(downloadFile);
            //              }
            //          }
            //}
#endregion
        }

        void ShowNotice(string content, string yes, string no, string tip, Action yesCallback, Action noCallback)
        {
            if(curNoticeUI == null)
            {
                curNoticeUI = MessageNoticeUI.CreateMessageNoticeUI();
            }
            curNoticeUI.ShowYesNoBox(content, yes, no, yesCallback, noCallback);
            if (!string.IsNullOrEmpty(tip))
            {
                curNoticeUI.ShowTip(tip);
            }
        }

        private void ShowMsg(string firstBtnText, Action firstBtnAct, int index1, string content, string secondBtnText = null, Action secondBtnAct = null, int index2=1)
        {
            List<ButtonEvent> btnEventList = new List<ButtonEvent>();
            ButtonEvent btn1 = new ButtonEvent(firstBtnText, firstBtnAct, index1);
            btnEventList.Add(btn1);
            if (!string.IsNullOrEmpty(secondBtnText))
            {
                ButtonEvent btn2 = new ButtonEvent(secondBtnText, secondBtnAct, index2);
                btnEventList.Add(btn2);
            }
            ShowMessageBox("", content, btnEventList);
        }

        /// <summary>
        /// 版本检测结果
        /// </summary>
        /// <param name="result"></param>
        void VersionResult(VersionUpdateType type)
        {
            VersionInfoData.CurVersionUpdateType = type;
            switch (type)
            {
                //当前版本已是最新
                case VersionUpdateType.NoNeedUpdate:
                    {
                        if (startGameCor != null)
                        {
                            StopCoroutine(startGameCor);
                        }
                        startGameCor = StartCoroutine(StartGameCorFun());
                    }
                    break;
                //更新增量包
                case VersionUpdateType.PatchPackageUpdate:
                    {
                        HandlePatchPackageData();
                    }
                    break;
                //更新渠道包(木有地址，暂时不管)
                /*case VersionUpdateType.OSPackageUpdate:
                    {
                        ShowMsg("取消", delegate { CloseMessageBox(); Application.Quit(); },
                            "版本过低，请前往商店下载最新版本",
                            "确定", delegate { CloseMessageBox(); Application.OpenURL(url); Application.Quit(); });
                    }
                    break;*/
            }
        }

        void HandlePatchPackageData()
        {
       
            string localPersistentPath = AssetBundlePathResolver.instance.BundlesPathForPersistent;
            if (!Directory.Exists(localPersistentPath))
                Directory.CreateDirectory(localPersistentPath);

            allSize = 0;
            for (int i = 0; i < downloadLst.Count; i++)
            {
                DownLoadFile df = downloadLst[i];
                if (df.size == 0)
                {
                    df.status = DownLoadFileStatus.Loaded;
                }
                allSize += df.size;
            }

            if (checkState != null)
            {
                checkState.gameObject.SetActive(false);
            }

            if (allSize > 0 && downloadLst.Count > 0)
            {
                if (CheckNeedShowDownTip(allSize))
                {
                    ShowMsg("取消", delegate {
                        CloseMessageBox();
                        DownloadFileChecker.Close();
                        Application.Quit();
                        }, 0,
                        string.Format("发现新版本，需要更新\n资源大小：{0}", GetSize(allSize)),
                        "更新", delegate { CloseMessageBox(); StartUpdateAssets(downloadLst); }, 1);
                }
                else
                {
                    StartUpdateAssets(downloadLst);
                }
            }
        }

        bool _isDownLoading = false;
        bool isDownLoading
        {
            get
            {
                return _isDownLoading;
            }
            set
            {
                _isDownLoading = value;
            }
        }

        Coroutine updateAssetsCor = null;
        private void StartUpdateAssets(List<DownLoadFile> updateList)
        {
            ThreadDownLoad.BeingAssetUpdate = true;

            if (updateAssetsCor != null)
            {
                StopCoroutine(updateAssetsCor);
            }

            if (threadDownLoad == null)
            {
                threadDownLoad = gameObject.AddComponent<ThreadDownLoad>();
            }
            threadDownLoad.ClearEvent();
            isDownLoading = false;

            updateAssetsCor = StartCoroutine(OnUpdateAssets(updateList));
        }

        private const int timeout = 20000;
        float totalDownSize;
        IEnumerator OnUpdateAssets(List<DownLoadFile> updateList)
        {
            if (downSizeLab != null)
            {
                downSizeLab.gameObject.SetActive(true);
                downSizeLab.text = string.Format("正在更新游戏资源 {0}/{1}", GetSize(totalDownSize), GetSize(allSize));
            }

            if (slider != null)
            {
                slider.gameObject.SetActive(true);      //进度条
            }

            totalDownSize = GetTotalDownSize(updateList);
            if (slider != null)
            {
                slider.value = totalDownSize / allSize;
            }

            for (int i = 0; i < updateList.Count; i++)
            {
                // 暂时不做多次下载尝试  @todo   异步 多线程下载
                if (updateList[i].status != DownLoadFileStatus.Loaded)
                {
                    BeginDownLoad(updateList[i]);

                    timeoutSw.Reset();
                    timeoutSw.Start();
                    while (isDownLoading)
                    {
                        //if(updateList[i].status == DownLoadFileStatus.Failed)
                        //{
                        //    LuaInterface.Debugger.Log("status == DownLoadFileStatus.Failed");
                        //    ThreadDownLoad.BeingAssetUpdate = false;
                        //    ShowMsg("取消", delegate { CloseMessageBox(); Application.Quit(); }, 0,
                        //        "更新出现异常，请点击确定再次更新",
                        //        "确定", delegate { CloseMessageBox(); StartUpdateAssets(updateList); }, 1);
                        //    yield break;
                        //}
                        if (timeoutSw.ElapsedMilliseconds > timeout || updateList[i].status == DownLoadFileStatus.Failed)     //如果正在下载中的文件 5秒都没有下载信息回调，说明有问题
                        {
                            if(slider.value >= 1)
                            {
                                isDownLoading = false;                                
                            }
                            else
                            {
                                LuaInterface.Debugger.Log("timeout");
                                ThreadDownLoad.BeingAssetUpdate = false;
                                ShowMsg("取消", delegate { CloseMessageBox(); Application.Quit(); }, 0,
                                    "更新出现异常，请点击确定再次更新",
                                    "确定", delegate { CloseMessageBox(); StartUpdateAssets(updateList); }, 1);
                                yield break;
                            }
                        }

                        yield return new WaitForEndOfFrame();

                        totalDownSize = GetTotalDownSize(updateList);
                        if (slider != null)
                        {
                            slider.value = totalDownSize / allSize;
                        }

                        if (downSizeLab != null)
                        {
                            downSizeLab.text = string.Format("正在更新游戏资源 {0:P}", totalDownSize / allSize);
                        }
                    }

                    totalDownSize = GetTotalDownSize(updateList);
                    if (slider != null)
                    {
                        slider.value = totalDownSize / allSize;
                    }

                    if (downSizeLab != null)
                    {
                        downSizeLab.text = string.Format("正在更新游戏资源 {0:P}", totalDownSize / allSize);
                    }
                }
            }

            //保存版本以及依赖文件
            for(int i=0; i<verDepInfoLst.Count; i++)
            {
                NetWorkManage.Instance.CreateFile(AssetBundlePathResolver.instance.BundlesPathForPersistent, verDepInfoLst[i].fileName, verDepInfoLst[i].msg);
            }
            DownloadFileChecker.CloseAndClearDownFileChecker();
            ReloadDepInfo();

            VersionInfo verInfo = verInfoLst[0];
            if (currentVerNoLab != null)
            {
                currentVerNoLab.text = string.Format("当前资源版本 {0}", verInfo.VersionNum);
            }
            if (downSizeLab != null)
            {
                downSizeLab.gameObject.SetActive(false);
            }
            if (slider != null)
            {
                slider.gameObject.SetActive(false);
            }

            if (startGameCor != null)
            {
                StopCoroutine(startGameCor);
            }
            startGameCor = StartCoroutine(StartGameCorFun());
            yield break;
        }


        Coroutine unZipCor = null;
        private IEnumerator UnZip(List<DownLoadFile> list)
        {
            VersionInfo verInfo = verInfoLst[0];

            if (!CheckFiles(list))
            {
                //文件校验失败，重新下载
                ShowMsg("取消",
                    delegate { CloseMessageBox(); Application.Quit(); }, 0,
                    "文件校验失败，是否重新下载",
                    "确定",
                    delegate
                    {
                        CloseMessageBox();
                        if (versionReqCor != null)
                        {
                            StopCoroutine(versionReqCor);
                            versionReqCor = StartCoroutine(VersionReqCorFun());
                        }
                    }, 1);
                yield break;
            }

            yield return null;
            if (slider != null)
            {
                slider.gameObject.SetActive(true);
            }

            for (int i = 0; i < list.Count; i++)
            {
                if (!downSizeLab.gameObject.activeSelf)
                {
                    downSizeLab.gameObject.SetActive(true);
                    downSizeLab.text = string.Format("正在解压:{0}/{1}", i, list.Count);
                    yield return new WaitForSeconds(0.5f);
                }

                string gzipFileUrl = list[i].localFile;

                if (File.Exists(gzipFileUrl))
                {
                    string[] arraytemp = gzipFileUrl.Split('/');
                    string gzipFileName = arraytemp[arraytemp.Length - 1];
                    string gzipFilePath = gzipFileUrl.Replace(gzipFileName, "");

                    ZipResult zipResult = new ZipResult();
                    ZipHelper.Decompress(string.Format("{0}{1}", gzipFilePath, gzipFileName), gzipFilePath, ref zipResult);

                    if (zipResult.Errors)
                    {
                        if (!verInfo.IsReleaseVer)
                        {
                            LuaInterface.Debugger.LogError("解压结果：失败" + i);
                        }

                        //重新下包。。。
                        ShowMsg("取消",
                        delegate { CloseMessageBox(); Application.Quit(); }, 0,
                        "解压失败，是否重新解压文件",
                        "确定",
                        delegate
                        {
                            CloseMessageBox();
                            if (unZipCor != null)
                            {
                                StopCoroutine(unZipCor);
                            }
                            unZipCor = StartCoroutine(UnZip(list));
                        }, 1);
                        yield break;
                    }

                    if (downSizeLab != null)
                    {
                        downSizeLab.text = string.Format("正在解压:{0}/{1}", (i + 1), list.Count);
                        yield return null;
                        if (!verInfo.IsReleaseVer)
                        {
                            LuaInterface.Debugger.Log(string.Format("--->:{0}, {1}", downSizeLab.gameObject.activeSelf, downSizeLab.text));
                        }
                    }

                    //删除patch压缩包
                    if (File.Exists(gzipFileUrl))
                    {
                        File.Delete(gzipFileUrl);
                    }
                }
            }


            verInfo = FileUtils.GetCurrentVerNo();
            VersionInfoData.CurrentVersionInfo = verInfo;

            if (currentVerNoLab != null)
            {
                currentVerNoLab.text = string.Format("当前资源版本 {0}", verInfo.VersionNum);
            }
            if (downSizeLab != null)
            {
                downSizeLab.gameObject.SetActive(false);
            }
            if (slider != null)
            {
                slider.gameObject.SetActive(false);
            }

            if (startGameCor != null)
            {
                StopCoroutine(startGameCor);
            }
            startGameCor = StartCoroutine(StartGameCorFun());
        }

        //文件校验
        private bool CheckFiles(List<DownLoadFile> list)
        {
            bool ret = true;
            for (int i = 0; i < list.Count; i++)
            {
                if (File.Exists(list[i].localFile))
                {
                    string srvFileMd5 = list[i].md5;
                    string localFileMd5 = FileUtils.getFileMd5(list[i].localFile);

                    if (!srvFileMd5.Equals(localFileMd5))
                    {
                        UnityEngine.Debug.LogWarning("MD5值不同" + i);
                        ret = false;
                        break;
                    }
                }
                else
                {
                    ret = false;
                    UnityEngine.Debug.LogWarning("不存在");
                }
            }

            return ret;
        }

        private float GetTotalDownSize(List<DownLoadFile> updateList)
        {
            float totalDownSize = 0;
            for (int i = 0; i < updateList.Count; i++)
            {
                if(updateList[i].status == DownLoadFileStatus.Loaded)
                    totalDownSize += updateList[i].size;
            }
            return totalDownSize;
        }

        private ThreadDownLoad threadDownLoad = null;
        void BeginDownLoad(DownLoadFile df)
        {
            df.status = DownLoadFileStatus.Loading;
            threadDownLoad.AddEvent(df, OnDownLoad);
            isDownLoading = true;
        }

        //监测网络问题，超出一定时间没有收到任何网络数据，断定网络有问题
        Stopwatch timeoutSw = new Stopwatch();
        void OnDownLoad(DownLoadFile df)
        {
            if (df.status == DownLoadFileStatus.Loaded)
            {
                isDownLoading = false;
                // game分包下载不需要 
                if(!string.IsNullOrEmpty(df.key))
                    DownloadFileChecker.DownFileFinish(df.key, df.crc);
            }
            else
            {
                timeoutSw.Reset();
                timeoutSw.Start();
            }

            /*
            else if (!df.isValid)   //下载的数据不合法，需重新下载
            {
                timeoutSw.Reset();
                timeoutSw.Start();

                if (File.Exists(df.localFile))
                {
                    File.Delete(df.localFile);
                }
                df.downSize = 0L;
                df.size = df.totalSize - ThreadDownLoad.GetSize(df.localFile);
                BeginDownLoad(df);
            }
            */
        }

        Coroutine startGameCor = null;
        /// <summary>
        /// 加载完成
        /// </summary>
        IEnumerator StartGameCorFun()
        {
            if (checkState != null)
            {
                if (!checkState.gameObject.activeSelf)
                    checkState.gameObject.SetActive(true);

                checkState.text = "正在初始化游戏...";
            }

            if (_initAssetCor != null)
            {
                StopCoroutine(_initAssetCor);
            }
            _initAssetCor = StartCoroutine(InitAssetCorFun());
            yield return _initAssetCor;

            // 创建游戏内核
            Framework.GameKernel.Create();

            if (checkState != null)
            {
                //checkState.transform.parent.gameObject.SetActive(false);
                _rootGo.SetActive(false);
            }
        }

        void AssetUpdateMgrHandler()
        {
            if (curMsgBox != null)
            {
                Destroy(curMsgBox.gameObject);
            }

            if(curNoticeUI != null)
            {
                Destroy(curNoticeUI.gameObject);
                curNoticeUI = null;
            }
            //Destroy(gameObject);
            //commPanel.SetActive(false);
            //commPanel.transform.parent.gameObject.SetActive(false);
        }

        Coroutine _initAssetCor = null;
        IEnumerator InitAssetCorFun()
        {
            InitAsset();
            int toProgress = 0;
            int displayProgress = 0;
            if (preloadResult != null && preloadResult.TotalCount > 0)
            {
                if (slider != null)
                {
                    slider.gameObject.SetActive(true);
                    slider.value = 0;
                }

                while (true)
                {
                    toProgress = (int)(preloadResult.PreloadPercent * 100);

                    while (displayProgress < toProgress)
                    {
                        displayProgress += 2;
                        if (slider != null)
                        {
                            slider.value = 0.01f * displayProgress;
                        }

                        yield return new WaitForEndOfFrame();
                    }
                    if (toProgress >= 100)
                    {
                        if (slider != null)
                        {
                            slider.gameObject.SetActive(false);
                        }
                        yield break;
                    }
                    yield return null;
                }
            }
        }

        PreloadResult preloadResult;
        void InitAsset()
        {
            preloadResult = null;
            preloadResult = new PreloadResult();

            GameKernel.CreateForInitData();
            IResourceMgr resourceMgr = GameKernel.Get<IResourceMgr>();

            //预加载资源，不需要提前获取mainAsset           
            //预加载资源，需要提前获取mainAsset
        }

        private void ResidentAssetCallback(AssetBundleInfo info)
        {
            this.preloadResult.Index++;
            this.preloadResult.PreloadPercent = 1.0f * this.preloadResult.Index / this.preloadResult.TotalCount;
        }

        private string GetSize(float size)
        {
            string sizeInfo = "";
            if (size >= 1024 * 1024)
            {
                sizeInfo = ((double)size / (1024 * 1024)).ToString("0.00") + "M";
            }
            else
            {
                sizeInfo = ((double)size / 1024).ToString("0.00") + "K";
            }
            return sizeInfo;
        }

        private Coroutine msgBoxCor = null;
        private TweenScale msgBoxTS = null;
        private void ShowMessageBox(string title, string content, List<ButtonEvent> btnEventList)
        {
            if (msgBoxCor != null)
            {
                StopCoroutine(msgBoxCor);
            }
            msgBoxCor = StartCoroutine(ShowMsgBoxIEtor(title, content, btnEventList));
        }

        private IEnumerator ShowMsgBoxIEtor(string title, string content, List<ButtonEvent> btnEventList)
        {
            yield return null;
            if (curMsgBox == null)
            {
                curMsgBox = MessageBox.CreateMessageBox();
            }
            else
            {
                if (!curMsgBox.gameObject.activeSelf)
                {
                    curMsgBox.gameObject.SetActive(true);
                }
            }
            if (msgBoxTS == null)
            {
                msgBoxTS = curMsgBox.gameObject.GetComponent<TweenScale>();
            }

            //msgBoxTS.ResetToBeginning();
            //msgBoxTS.PlayForward();

            curMsgBox.ShowMessageBox(title, content, btnEventList);
        }

        private void CloseMessageBox()
        {
            if (msgBoxCor != null)
            {
                StopCoroutine(msgBoxCor);
            }
            if (curMsgBox != null && curMsgBox.gameObject.activeSelf)
            {
                curMsgBox.gameObject.SetActive(false);
            }
        }

/*===========================================================================================================
    游戏分包热更下载机制处理
    1. 根据游戏id以及版本号来判断是否需要热更
    2. 需要热更，则下载热更资源
    3. 进入游戏场景
*/
        public void EnterGameHotHander(string appid, string gid, string version, string verFileName, Action callback)
        {
            allSize = 0L;
            m_gameDownloadLst.Clear();
            m_verFileName = "ver_game_" + gid.ToString() + ".txt";
            m_depFileName = "dep_game_" + gid.ToString() + ".all";

            // 先加载依赖
            //AssetBundleManager.Instance.StartCoroutine(AssetBundleManager.Instance.SubLoadDepInfo(m_depFileName));
            AssetBundleManager.Instance.LoadRemoteDepInfoDirectly(m_depFileName, null);
            m_isGameStartUpdate = false;
#if UNITY_ANDROID || UNITY_IPHONE || (AB_WINDOW && UNITY_STANDALONE) || AB_MODE
            //php请求 检测是否需要强更或者是热更
            JsonData data = new JsonData();
            switch (Application.platform)
            {
                case RuntimePlatform.WindowsEditor:
                    data["siteid"] = 1;
                    break;
                case RuntimePlatform.Android:
                    data["siteid"] = 1;
                    break;
                case RuntimePlatform.IPhonePlayer:
                    data["siteid"] = 1001;
                    break;
            }

            data["version"] = version;
            data["appid"] = appid;
            data["gid"] = gid;
            if (PlayerPrefs.HasKey("USER_UID"))
            {
                data["uid"] = PlayerPrefs.GetString("USER_UID");
            }
            data["method"] = "GameSAR.getVersionUp";
            string reqStr = data.ToJson();
            LuaInterface.Debugger.Log(string.Format("gameReqStr:{0}", reqStr));
            HttpPOSTRequest(reqStr, delegate (string _data, int code, string rtStr)
            {
                LuaInterface.Debugger.Log(string.Format("_data:{0}", _data));
                JsonData deJson = JsonMapper.ToObject(_data);
                bool isNeed = bool.Parse(deJson["updateInfo"]["hotUpdate"]["isNeed"].ToString());
                if (isNeed)
                {
                    httpUrl = deJson["updateInfo"]["hotUpdate"]["url"].ToString();
                    m_gameVerReqCor = StartCoroutine(GameVersionReqCorFun());

                    //下载依赖文件，比对后下载资源,资源下载完成后再回调处理

                    //检测需要更新的文件列表      
                    /*string filePath = string.Format(urlFilePath, AssetBundlePathResolver.instance.BundlePlatform, verFileName);
                    string gameVerUrl = httpUrl + filePath;

                    string depPath = string.Format(urlFilePath, AssetBundlePathResolver.instance.BundlePlatform, verFileName);
                    string depUrl = httpUrl + depPath;

                    VersionInfo _verInfo = FileUtils.GetGameVerNo(verFileName);
                    DownloadVersionFile(gameVerUrl, depUrl, _verInfo);*/
                }
                else if(callback != null)
                {
                    callback();
                }
            });

            m_gameHotEvent = callback;
#else
            if (callback != null)
            {
                callback();
            } 
#endif
        }

        public void StartDownloadGame(string url, string gid, Action callback, Action<long> needDownLoadCallback)
        {
            httpUrl = url;
            allSize = 0L;
            m_gameDownloadLst.Clear();
            m_verFileName = "ver_game_" + gid.ToString() + ".txt";
            m_depFileName = "dep_game_" + gid.ToString() + ".all";
            m_isGameStartUpdate = false;

            m_gameHotEvent = callback;
            m_needDownLoadCallback = needDownLoadCallback;
            m_gameVerReqCor = StartCoroutine(GameVersionReqCorFun());
        }




        IEnumerator GameVersionReqCorFun()
        {
            yield return null;
            string filePath = string.Format(urlFilePath, AssetBundlePathResolver.instance.BundlePlatform, m_verFileName);
            string gameVerUrl = httpUrl + filePath;
            
            string depPath = string.Format(urlFilePath, AssetBundlePathResolver.instance.BundlePlatform, m_depFileName);
            string depUrl = httpUrl + depPath;
            VersionInfo _verInfo = FileUtils.GetGameVerNo(m_verFileName);
            GameDownloadVerFile(gameVerUrl, depUrl, _verInfo);
        }


        void GameDownloadVerFile(string verUrl, string depUrl, VersionInfo verInfo)
        {
            LuaInterface.Debugger.Log("url==============" + verUrl);
            LuaInterface.Debugger.Log("depUrl==============" + depUrl);
            NetWorkManage.Instance.HttpDownTextAsset(verUrl, (code, msg) => {
                if (code == -1)
                {
                    ShowMsg("确定", delegate
                    {
                        CloseMessageBox();
                        if (m_gameVerReqCor != null)
                        {
                            StopCoroutine(m_gameVerReqCor);
                            m_gameVerReqCor = StartCoroutine(GameVersionReqCorFun());
                        }
                        else
                        {
                            m_gameVerReqCor = StartCoroutine(GameVersionReqCorFun());
                        }
                    }, 1, "连接失败，请更换网络环境后重试");
                    return;
                }

                if (code < 0)
                {
                    ShowMsg("确定", delegate { Application.Quit(); DownloadFileChecker.Close(); }, 1, "系统异常，请重试");
                    return;
                }

                if (code >= 0)
                {
                    LuaInterface.Debugger.Log("msg==============" + msg);
                    if (msg != null && msg != "")
                    {
                        VersionInfo srvVerInfo = LitJson.JsonMapper.ToObject<VersionInfo>(msg);
                        Version srvVersion = new Version(srvVerInfo.VersionNum);
                        Version curVersion = null;
                        if (verInfo != null)
                        {
                            curVersion = new Version(verInfo.VersionNum);
                        }

                        bool flag = false;
                        if (curVersion == null)
                        {
                            flag = true;
                        }
                        else
                        {
                            if (srvVerInfo.OsType == verInfo.OsType && curVersion < srvVersion)
                            {
                                flag = true;
                            }
                        }

                        if (flag)
                        {
                            int index = verUrl.LastIndexOf('/');
                            string fileName = verUrl.Substring(index + 1, verUrl.Length - index - 1);

                            //检测需要更新的文件列表                    
                            GameCheckUpdateFileList(depUrl, () => {
                                m_isCanGameDownload = true;
                                VersionDepInfo verDepInfo = new VersionDepInfo();
                                verDepInfo.msg = msg;
                                verDepInfo.fileName = fileName;
                                m_gameDepInfoLst.Add(verDepInfo);
                                //NetWorkManage.Instance.CreateFile(AssetBundlePathResolver.instance.BundlesPathForPersistent, fileName, msg);
                            });
                        }
                        else
                        {
                            if (m_gameHotEvent != null)
                            {
                                m_gameHotEvent();
                            }
                        }
                    }
                    else
                    {
                        LuaInterface.Debugger.Log("{0}版本文件读取有误", verUrl);
                    }
                }
            });
        }


        void GameCheckUpdateFileList(string depUrl, Action callback)
        {            
            //读取服务器端依赖文件            
            NetWorkManage.Instance.HttpDownTextAssetByte(depUrl, (code, msgByte) =>
            {
                MemoryStream depStream = new MemoryStream(msgByte);
                if (depStream.Length > 4)
                {
                    if (m_gameDepInfoReader != null)
                    {
                        m_gameDepInfoReader = null;
                    }

                    //@todo  每一个dep文件对应一个depreader   curdownfile 存储game相关信息
                    if (m_gameDepInfoReader == null)
                    {
                        BinaryReader br = new BinaryReader(depStream);
                        if (br.ReadChar() == 'A' && br.ReadChar() == 'B' && br.ReadChar() == 'D')
                        {
                            if (br.ReadChar() == 'T')
                                m_gameDepInfoReader = new AssetBundleDataReader();
                            else
                                m_gameDepInfoReader = new AssetBundleDataBinaryReader();

                            depStream.Position = 0;
                            m_gameDepInfoReader.Read(depStream);
                        }
                    }

                    int index = depUrl.LastIndexOf('/');
                    string fileName = depUrl.Substring(index + 1, depUrl.Length - index - 1);

                    VersionDepInfo verDepInfo = new VersionDepInfo();
                    verDepInfo.msg = System.Text.Encoding.UTF8.GetString(msgByte);
                    verDepInfo.fileName = fileName;
                    m_gameDepInfoLst.Add(verDepInfo);
                }
                depStream.Close();

                if (callback != null)
                {
                    callback();
                }
            });
        }


        void GetGameDownloadFileLst(Action callback)
        {            
            if (m_gameDepInfoReader != null)
            {
                this.StartCoroutine(AssetBundleManager.Instance.LoadGameDepInfo(m_depFileName, () =>
                {
                    foreach (string key in m_gameDepInfoReader.infoMap.Keys)
                    {
                        if(CheckAddToDownList(m_gameDepInfoReader, AssetBundleManager.Instance.gameDepInfoReader, key, false))
                        {
                            DownLoadFile downloadFile = new DownLoadFile();
                            string firstFileName = m_gameDepInfoReader.infoMap[key].belongName;
                            if (m_gameDepInfoReader.infoMap[key].fullName.EndsWith(".bytes"))
                                firstFileName = "";
                            downloadFile.remoteFile = httpUrl + "/" + AssetBundlePathResolver.instance.BundlePlatform + "/" + AssetBundlePathResolver.instance.BundleSaveDirName + "/"
                                                    + firstFileName + "/" + m_gameDepInfoReader.infoMap[key].fullName;
                            downloadFile.localFile = AssetBundlePathResolver.instance.BundlesPathForPersistent + firstFileName + "/" + m_gameDepInfoReader.infoMap[key].fullName;

                            LuaInterface.Debugger.Log("downloadFile.remoteFile--------------------------" + downloadFile.remoteFile);
                            LuaInterface.Debugger.Log("downloadFile.localFile --------------------------" + downloadFile.localFile);
                            //downloadFile.totalSize = ThreadDownLoad.GetHttpLength(downloadFile.remoteFile);     //_depInfoReader.infoMap[key].size;   //(计算大小有误)
                            downloadFile.totalSize = m_gameDepInfoReader.infoMap[key].size;   
                            downloadFile.size = downloadFile.totalSize;
                            downloadFile.key = null;
                            if (downloadFile.size > 0)
                                m_gameDownloadLst.Add(downloadFile);

                        }

                        //                 if (AssetBundleManager.Instance.gameDepInfoReader != null && AssetBundleManager.Instance.gameDepInfoReader.infoMap.ContainsKey(key))
                        //                 {
                        //                     if (AssetBundleManager.Instance.gameDepInfoReader.infoMap[key].hash != m_gameDepInfoReader.infoMap[key].hash)
                        //                     {
                        //                         DownLoadFile downloadFile = new DownLoadFile();
                        //                         //#if UNITY_IOS || UNITY_IPHONE
                        //                         //                                string firstFileName = m_gameDepInfoReader.infoMap[key].debugName.Split('/')[2];
                        //                         //#elif UNITY_ANDROID || (AB_WINDOW && UNITY_STANDALONE)
                        //                         //                                string firstFileName = m_gameDepInfoReader.infoMap[key].debugName.Split('\\')[2];
                        //                         //#else
                        //                         //                                string firstFileName = "";
                        //                         //#endif
                        //                         string firstFileName = m_gameDepInfoReader.infoMap[key].belongName;
                        //                         if (m_gameDepInfoReader.infoMap[key].fullName.EndsWith(".bytes"))
                        //                             firstFileName = "";
                        //                         downloadFile.remoteFile = httpUrl + "/" + AssetBundlePathResolver.instance.BundlePlatform + "/" + AssetBundlePathResolver.instance.BundleSaveDirName + "/"
                        //+ firstFileName + "/" + m_gameDepInfoReader.infoMap[key].fullName;
                        //downloadFile.localFile = AssetBundlePathResolver.instance.BundlesPathForPersistent + firstFileName + "/" + m_gameDepInfoReader.infoMap[key].fullName;
                        //                         if (File.Exists(downloadFile.localFile))
                        //                         {
                        //                             File.Delete(downloadFile.localFile);
                        //                         }
                        //                         LuaInterface.Debugger.Log("downloadFile.remoteFile--------------------------" + downloadFile.remoteFile);
                        //                         downloadFile.totalSize = ThreadDownLoad.GetHttpLength(downloadFile.remoteFile);     //_depInfoReader.infoMap[key].size;   //(计算大小有误)
                        //                         downloadFile.size = downloadFile.totalSize - ThreadDownLoad.GetSize(downloadFile.localFile);
                        //                         m_gameDownloadLst.Add(downloadFile);
                        //                     }
                        //                 }
                        //                 else
                        //                 {
                        //                     DownLoadFile downloadFile = new DownLoadFile();
                        //                     //#if UNITY_IOS || UNITY_IPHONE
                        //                     //                            string firstFileName = m_gameDepInfoReader.infoMap[key].debugName.Split('/')[2];
                        //                     //#elif UNITY_ANDROID || (AB_WINDOW && UNITY_STANDALONE)
                        //                     //                            string firstFileName = m_gameDepInfoReader.infoMap[key].debugName.Split('\\')[2];
                        //                     //#else
                        //                     //                            string firstFileName = "";
                        //                     //#endif
                        //                     string firstFileName = m_gameDepInfoReader.infoMap[key].belongName;
                        //                     if (m_gameDepInfoReader.infoMap[key].fullName.EndsWith(".bytes"))
                        //                         firstFileName = "";
                        //                     downloadFile.remoteFile = httpUrl + "/" + AssetBundlePathResolver.instance.BundlePlatform + "/" + AssetBundlePathResolver.instance.BundleSaveDirName + "/"
                        //+ firstFileName + "/" + m_gameDepInfoReader.infoMap[key].fullName;
                        //downloadFile.localFile = AssetBundlePathResolver.instance.BundlesPathForPersistent + firstFileName + "/" + m_gameDepInfoReader.infoMap[key].fullName;
                        //                     downloadFile.totalSize = ThreadDownLoad.GetHttpLength(downloadFile.remoteFile);         //_depInfoReader.infoMap[key].size;                            
                        //                     downloadFile.size = downloadFile.totalSize - ThreadDownLoad.GetSize(downloadFile.localFile);
                        //                     m_gameDownloadLst.Add(downloadFile);
                        //                 }
                    }

                    if (callback != null)
                    {
                        callback();
                    }
                }));
            }
        }

        void HandleGamePatchPackageData()
        {
            string localPersistentPath = AssetBundlePathResolver.instance.BundlesPathForPersistent;
            if (!Directory.Exists(localPersistentPath))
                Directory.CreateDirectory(localPersistentPath);

            allSize = 0;
            for (int i = 0; i < m_gameDownloadLst.Count; i++)
            {
                DownLoadFile df = m_gameDownloadLst[i];
                if (df.size == 0)
                {
                    df.status = DownLoadFileStatus.Loaded;
                }
                allSize += df.size;
            }

            if (checkState != null)
            {
                checkState.gameObject.SetActive(false);
            }

            if (allSize > 0 && m_gameDownloadLst.Count > 0)
            {
               if(m_needDownLoadCallback != null)
                {
                    m_needDownLoadCallback(allSize);
                }
                else
                {
                    StartUpdateGameAssets(m_gameDownloadLst);
                }
            }
        }


        public void RealDownGameAsset()
        {
            StartUpdateGameAssets(m_gameDownloadLst);
        }

        Coroutine updateGameAssetsCor = null;
        private void StartUpdateGameAssets(List<DownLoadFile> updateList)
        {
            ThreadDownLoad.BeingAssetUpdate = true;

            if (updateGameAssetsCor != null)
            {
                StopCoroutine(updateGameAssetsCor);
            }

            if (threadDownLoad == null)
            {
                threadDownLoad = gameObject.AddComponent<ThreadDownLoad>();
            }
            threadDownLoad.ClearEvent();
            isDownLoading = false;

            updateGameAssetsCor = StartCoroutine(OnUpdateGameAssets(updateList));
        }

        float gameTotalDownSize;
        IEnumerator OnUpdateGameAssets(List<DownLoadFile> updateList)
        {
            //if (m_curResBox == null)
            //{
            //    m_curResBox = ResBox.CreateResBox();
            //}

            //m_curResBox.percentLbl.text = string.Format("{0:P}", (gameTotalDownSize / allSize));

            //if (m_curResBox.slider != null)
            //{
            //    m_curResBox.slider.gameObject.SetActive(true);      //进度条
            //}
            _rootGo.SetActive(true);
            if (downSizeLab != null)
            {
                downSizeLab.gameObject.SetActive(true);
                downSizeLab.text = string.Format("正在更新游戏资源 {0}/{1}", GetSize(totalDownSize), GetSize(allSize));
            }

            if (slider != null)
            {
                slider.gameObject.SetActive(true);      //进度条
            }

            gameTotalDownSize = GetTotalDownSize(updateList);
            //if (m_curResBox.slider != null)
            //{
            //    m_curResBox.slider.value = gameTotalDownSize / allSize;
            //}
            slider.value = gameTotalDownSize / allSize;

            for (int i = 0; i < updateList.Count; i++)
            {
                if (updateList[i].status != DownLoadFileStatus.Loaded)
                {
                    BeginDownLoad(updateList[i]);

                    timeoutSw.Reset();
                    timeoutSw.Start();
                    while (isDownLoading)
                    {
                        if (timeoutSw.ElapsedMilliseconds > timeout || updateList[i].status == DownLoadFileStatus.Failed)     //如果正在下载中的文件 5秒都没有下载信息回调，说明有问题
                        {
                            if (slider.value >= 1)
                            {
                                isDownLoading = false;
                            }
                            else
                            {
                                ThreadDownLoad.BeingAssetUpdate = false;
                                ShowMsg("取消", delegate { CloseMessageBox(); Application.Quit(); DownloadFileChecker.Close(); }, 0,
                                    "更新出现异常，请点击确定再次更新",
                                    "确定", delegate { CloseMessageBox(); StartUpdateGameAssets(updateList); }, 1);
                                yield break;
                            }
                        }

                        yield return new WaitForEndOfFrame();

                        gameTotalDownSize = GetTotalDownSize(updateList);
                        //if (m_curResBox.slider != null)
                        //{
                        //    m_curResBox.slider.value = gameTotalDownSize / allSize;
                        //}

                        if (slider != null)
                        {
                            slider.value = gameTotalDownSize / allSize;
                        }

                        if (downSizeLab != null)
                        {
                            downSizeLab.text = string.Format("正在更新游戏资源 {0:P}", gameTotalDownSize / allSize);
                        }

                        //m_curResBox.percentLbl.text = string.Format("{0:P}", (gameTotalDownSize / allSize));
                    }

                    gameTotalDownSize = GetTotalDownSize(updateList);
                    //if (m_curResBox.slider != null)
                    //{
                    //    m_curResBox.slider.value = gameTotalDownSize / allSize;
                    //}

                    //m_curResBox.percentLbl.text = string.Format("{0:P}", (gameTotalDownSize / allSize));
                    if (slider != null)
                    {
                        slider.value = gameTotalDownSize / allSize;
                    }

                    if (downSizeLab != null)
                    {
                        downSizeLab.text = string.Format("正在更新游戏资源 {0:P}", gameTotalDownSize / allSize);
                    }
                }
            }

            //保存游戏版本以及依赖文件
            for (int i = 0; i < m_gameDepInfoLst.Count; i++)
            {
                NetWorkManage.Instance.CreateFile(AssetBundlePathResolver.instance.BundlesPathForPersistent, m_gameDepInfoLst[i].fileName, m_gameDepInfoLst[i].msg);
            }
            //加载依赖
            AssetBundleManager.Instance.LoadRemoteDepInfoDirectly(m_depFileName, null);

            if (downSizeLab != null)
            {
                downSizeLab.gameObject.SetActive(false);
            }
            //if (m_curResBox.slider != null)
            //{
            //    m_curResBox.slider.gameObject.SetActive(false);
            //}

            //if (m_curResBox != null)
            //{
            //    Destroy(m_curResBox.gameObject);
            //}
            _rootGo.SetActive(false);
            if (m_gameHotEvent != null)
            {
                m_gameHotEvent();
                m_gameHotEvent = null;
            }

            yield break;
        }

    }

    public class VersionDepInfo
    {        
        public string msg;
        public string fileName;
    }

    public class VersionUpdateBody
    {
        //类型，如果type为"patch"，则为增量包
        public string type;
        public string bin_url;
        public List<PatchPackage> res_list;
    }

    public class PatchPackage
    {
        //patch包版本号
        public string ver;
        //patch包下载地址
        public string url;
        //patch包的大小
        public string size;
        //patch包的md5
        public string md5;
    }

    public enum DownLoadFileStatus
    {
        None,
        Loading,
        Loaded,
        Failed,
    }

    public class DownLoadFile
    {
        public string remoteFile;   //文件的url地址
        public string localFile
        {
            set
            {
                _localFile = value;
                localTempFile = value + ".temp";
            }
            get
            {
                return _localFile;
            }
        }

        public string _localFile; //文件的本地url

        public DownLoadFileStatus status = DownLoadFileStatus.None;


        public string localTempFile; //本地临时文件
        public long size;           //还需下载文件大小
        public long downSize;       //已经下载的大小
        public long totalSize;      //该文件总大小
        public string md5;          //文件的Md5
        public bool isDownFinished = false; //下载是否完成


        // 用于断点续传，检查文件是否被下载过
        public string key;
        public string crc;

        public bool isValid = true;

        //@todo 下载次数 用于出错文件下载
        //public int loadCount = 1;

        public Stream fs;
        public HttpWebRequest request = null;
    }
}