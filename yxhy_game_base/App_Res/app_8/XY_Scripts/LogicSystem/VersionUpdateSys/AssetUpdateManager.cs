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

    public class AssetUpdateManager : MonoBehaviour
    {
        public static AssetUpdateManager Instance;

        [SerializeField]
        private bool isEnableVersionUpdate = true;

        /// <summary>
        /// 版本校验服务器地址
        /// </summary>
        [SerializeField]
        private string httpUrl = "http://intest.dstars.cc/appid/appid_8/appid_8_v1.0.0";

        [SerializeField]
        private UILabel currentVerNoLab;
        [SerializeField]
        private UILabel checkState;  //检查更新状态
        [SerializeField]
        private UISlider slider;     //进度条
        [SerializeField]
        private UILabel downSizeLab;

        private long allSize = 0;
        private MessageBox curMsgBox = null;
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


        int retryTime = 0;
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

            depFileNameLst = GameAppInstaller.Instance.depFileNameLst;
        }

        void Start()
        {
            Messenger.AddListener(MSG_DEFINE.MSG_DESTROY_VERSION_UPDATE_UI, destroySelf);

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

            //php请求 检测是否需要强更或者是热更
            JsonData data = new JsonData();
            switch(Application.platform)
            {
                case RuntimePlatform.WindowsEditor:
                    data["siteid"] = 3001;
                    break;
                case RuntimePlatform.Android:
                    data["siteid"] = 1;
                    break;
                case RuntimePlatform.IPhonePlayer:
                    data["siteid"] = 1001;
                    break;
            }

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
            data["method"] = "GameSAR.getVersionUp";
            string reqStr = data.ToJson();
            LuaInterface.Debugger.Log(string.Format("reqStr:{0}", reqStr));
            HttpPOSTRequest(reqStr, delegate (string _data, int code, string rtStr)
            {
                LuaInterface.Debugger.Log(string.Format("_data:{0}", _data));
                JsonData deJson = JsonMapper.ToObject(_data);
                bool isForce = bool.Parse(deJson["updateInfo"]["forceUpdate"]["isForce"].ToString());
                if (isForce)
                {
                    string downUrl = deJson["updateInfo"]["forceUpdate"]["url"].ToString();
                    ShowMsg("确定", delegate
                    {
                        CloseMessageBox();
                        Application.OpenURL(downUrl);
                        Application.Quit();
                    }, 1, "发现新的内容需要更新，是否现在进行更新？");
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
        }

        private void Update()
        {
            if (IsAllUpdateFileCheck() && !isStartUpdate)
            {
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
            Messenger.RemoveListener(MSG_DEFINE.MSG_DESTROY_VERSION_UPDATE_UI, destroySelf);
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

        void DownloadVersionFile(string verUrl, string depUrl, VersionInfo verInfo)
        {
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
                    ShowMsg("确定", delegate { Application.Quit(); }, 1, "系统异常，请重试");
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
                DownloadVersionFile(gameVerUrl, depUrl, verInfoLst[i]);
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

                GetDownloadFileLst();
                if (callback != null)
                {
                    callback();
                }
            });
        }

        void GetDownloadFileLst()
        {
            if (_depInfoReader != null)
            {
                foreach (string key in _depInfoReader.infoMap.Keys)
                {
                    if (AssetBundleManager.Instance.depInfoReader.infoMap.ContainsKey(key))
                    {
                        if (AssetBundleManager.Instance.depInfoReader.infoMap[key].hash != _depInfoReader.infoMap[key].hash)
                        {
                            DownLoadFile downloadFile = new DownLoadFile();
                            string firstFileName = _depInfoReader.infoMap[key].debugName.Split('\\')[2];
                            downloadFile.remoteFile = httpUrl + "/" + AssetBundlePathResolver.instance.BundlePlatform + "/" + AssetBundlePathResolver.instance.BundleSaveDirName + "/"
                                + firstFileName + "/" + _depInfoReader.infoMap[key].fullName.Replace("\\", "/");
                            downloadFile.localFile = AssetBundlePathResolver.instance.BundlesPathForPersistent + firstFileName + "/" + _depInfoReader.infoMap[key].fullName.Replace("\\", "/");
                            if (File.Exists(downloadFile.localFile))
                            {
                                File.Delete(downloadFile.localFile);
                            }
                            LuaInterface.Debugger.Log("downloadFile.remoteFile--------------------------" + downloadFile.remoteFile);
                            downloadFile.totalSize = ThreadDownLoad.GetHttpLength(downloadFile.remoteFile);     //_depInfoReader.infoMap[key].size;   //(计算大小有误)
                            downloadFile.size = downloadFile.totalSize - ThreadDownLoad.GetSize(downloadFile.localFile);
                            downloadLst.Add(downloadFile);
                        }
                    }
                    else
                    {
                        DownLoadFile downloadFile = new DownLoadFile();
                        string firstFileName = _depInfoReader.infoMap[key].debugName.Split('\\')[2];
                        downloadFile.remoteFile = httpUrl + "/" + AssetBundlePathResolver.instance.BundlePlatform + "/" + AssetBundlePathResolver.instance.BundleSaveDirName + "/"
                            + firstFileName + "/" + _depInfoReader.infoMap[key].fullName.Replace("\\", "/");
                        downloadFile.localFile = AssetBundlePathResolver.instance.BundlesPathForPersistent + firstFileName + "/" + _depInfoReader.infoMap[key].fullName.Replace("\\", "/");                       
                        downloadFile.totalSize = ThreadDownLoad.GetHttpLength(downloadFile.remoteFile);         //_depInfoReader.infoMap[key].size;                            
                        downloadFile.size = downloadFile.totalSize - ThreadDownLoad.GetSize(downloadFile.localFile);     
                        downloadLst.Add(downloadFile);
                    }
                }
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
            if (checkState != null)
            {
                checkState.text = "检查更新...";
            }

            string localPersistentPath = AssetBundlePathResolver.instance.BundlesPathForPersistent;
            if (!Directory.Exists(localPersistentPath))
                Directory.CreateDirectory(localPersistentPath);


            for (int i = 0; i < downloadLst.Count; i++)
            {
                DownLoadFile df = downloadLst[i];
                if (df.size == 0)
                {
                    df.isDownFinished = true;
                }
                allSize += df.size;
            }

            if (checkState != null)
            {
                checkState.gameObject.SetActive(false);
            }

            if (allSize > 0 && downloadLst.Count > 0)
            {
                ShowMsg("取消", delegate { CloseMessageBox(); Application.Quit(); }, 0,
                        string.Format("发现游戏有更新，需要下载{0}的更新包", GetSize(allSize)),
                        "确定", delegate { CloseMessageBox(); StartUpdateAssets(downloadLst); }, 1);
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

        private const int timeout = 5000;
        float totalDownSize;
        IEnumerator OnUpdateAssets(List<DownLoadFile> updateList)
        {
            if (downSizeLab != null)
            {
                downSizeLab.gameObject.SetActive(true);
                downSizeLab.text = string.Format("正在下载更新 {0}/{1}", GetSize(totalDownSize), GetSize(allSize));
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
                if (!updateList[i].isDownFinished)
                {
                    BeginDownLoad(updateList[i]);

                    timeoutSw.Reset();
                    timeoutSw.Start();
                    while (isDownLoading)
                    {
                        if (timeoutSw.ElapsedMilliseconds > timeout)     //如果正在下载中的文件 5秒都没有下载信息回调，说明有问题
                        {
                            ThreadDownLoad.BeingAssetUpdate = false;
                            ShowMsg("取消", delegate { CloseMessageBox(); Application.Quit(); }, 0,
                                "更新出现异常，请点击确定再次更新",
                                "确定", delegate { CloseMessageBox(); StartUpdateAssets(updateList); }, 1);
                            yield break;
                        }

                        yield return new WaitForEndOfFrame();

                        totalDownSize = GetTotalDownSize(updateList);
                        if (slider != null)
                        {
                            slider.value = totalDownSize / allSize;
                        }

                        if (downSizeLab != null)
                        {
                            downSizeLab.text = string.Format("正在下载更新 {0}/{1}", GetSize(totalDownSize), GetSize(allSize));
                        }
                    }

                    totalDownSize = GetTotalDownSize(updateList);
                    if (slider != null)
                    {
                        slider.value = totalDownSize / allSize;
                    }

                    if (downSizeLab != null)
                    {
                        downSizeLab.text = string.Format("正在下载更新 {0}/{1}", GetSize(totalDownSize), GetSize(allSize));
                    }
                }
            }

            //保存版本以及依赖文件
            for(int i=0; i<verDepInfoLst.Count; i++)
            {
                NetWorkManage.Instance.CreateFile(AssetBundlePathResolver.instance.BundlesPathForPersistent, verDepInfoLst[i].fileName, verDepInfoLst[i].msg);
            }

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
                totalDownSize += updateList[i].downSize;
            }
            return totalDownSize;
        }

        private ThreadDownLoad threadDownLoad = null;
        void BeginDownLoad(DownLoadFile df)
        {
            threadDownLoad.AddEvent(df, OnDownLoad);
            isDownLoading = true;
        }

        //监测网络问题，超出一定时间没有收到任何网络数据，断定网络有问题
        Stopwatch timeoutSw = new Stopwatch();
        void OnDownLoad(DownLoadFile df)
        {
            if (df.isDownFinished)
            {
                isDownLoading = false;
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
                checkState.transform.parent.gameObject.SetActive(false);
            }
        }

        void destroySelf()
        {
            if (curMsgBox != null)
            {
                Destroy(curMsgBox.gameObject);
            }
            Destroy(gameObject);
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

    public class DownLoadFile
    {
        public string remoteFile;   //文件的url地址
        public string localFile;    //文件的本地url
        public long size;           //还需下载文件大小
        public long downSize;       //已经下载的大小
        public long totalSize;      //该文件总大小
        public string md5;          //文件的Md5
        public bool isDownFinished = false; //下载是否完成

        public bool isValid = true;

        public Stream fs;
        public HttpWebRequest request = null;
    }
}