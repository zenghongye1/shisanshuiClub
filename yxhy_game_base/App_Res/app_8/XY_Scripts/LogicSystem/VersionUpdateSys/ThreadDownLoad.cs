using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using System;
using System.Diagnostics;
using System.Net;
using System.IO;

namespace NS_VersionUpdate
{
    public class ThreadDownLoad : MonoBehaviour
    {
        #region 私有变量
        private Thread thread;

        private Action<DownLoadFile> callback;

        private static readonly object m_lockObj = new object();

        private static Queue<DownLoadFile> downloadsQueue = new Queue<DownLoadFile>();

        //定义一个委托事件
        private delegate void ThreadSyncEvent(DownLoadFile data);

        private ThreadSyncEvent m_SyncEvent;
        
        private static Stream _fileStream = null;
        private static Stream fileStream
        {
            get { return _fileStream; }
            set
            {
                if (value == null)
                    if (_fileStream != null)
                    {
                        _fileStream.Close();
                        _fileStream.Dispose();
                    }

                _fileStream = value;
            }
        }
        
        private const int timeout = 5000;
        #endregion 私有变量

        #region 公有变量
        //是否正在进行资源更新
        public static bool BeingAssetUpdate = false;
        #endregion 公有变量

        #region Mono方法
        void Awake()
        {
            m_SyncEvent = OnSyncEvent;
            thread = new Thread(OnUpdate);
        }

        void Start()
        {
            thread.Start();
        }

        void OnDestroy()
        {
            thread.Abort();

            thread = null;
            fileStream = null;
        }
        #endregion Mono方法

        #region 业务逻辑方法
        /// <summary>
        /// 添加到事件队列
        /// </summary>
        public void AddEvent(DownLoadFile ev, Action<DownLoadFile> func)
        {
            lock (m_lockObj)
            {
                callback = func;
                downloadsQueue.Enqueue(ev);
            }
        }

        public void ClearEvent()
        {
            lock (m_lockObj)
            {
                fileStream = null;

                downloadsQueue.Clear();
            }
        }

        /// <summary>
        /// 通知表现层发生的数据变化
        /// </summary>
        /// <param name="data">当前下载数据</param>
        private void OnSyncEvent(DownLoadFile data)
        {
            if (callback != null)
                callback(data);
        }

        /// <summary>
        /// 线程方法
        /// </summary>
        void OnUpdate()
        {
            while (true)
            {
                lock (m_lockObj)
                {
                    if (downloadsQueue.Count > 0)
                    {
                        DownLoadFile e = downloadsQueue.Dequeue();
                        try
                        {
                            //下载文件
                            httpDownFile(e);
                        }
                        catch (System.Exception ex)
                        {
                            UnityEngine.Debug.LogError(ex.Message);
                        }
                    }
                }
                Thread.Sleep(1);
            }
        }
        
        /// <summary>
        /// 开始下载文件
        /// </summary>
        /// <param name="curDF">当前要下载的文件信息</param>
        private void httpDownFile(DownLoadFile curDF)
        {
            UnityEngine.Debug.Log("--httpDownFile-->" + curDF.remoteFile);
            //打开网络连接
            try
            {
                if (!curDF.isDownFinished)
                {
                    HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(new Uri(curDF.remoteFile));

                    if (File.Exists(curDF.localFile))
                    {
                        if (curDF.fs != null)
                        {
                            curDF.fs.Close();
                            curDF.fs.Dispose();
                            curDF.fs = null;
                        }

                        Stream fs = File.OpenWrite(curDF.localFile);
                        //移动文件流中的当前指针
                        fs.Seek(fs.Length, SeekOrigin.Current);
                        request.AddRange((int)fs.Length);
                        curDF.fs = fs;
                    }
                    else
                    {
                        string dirPath = curDF.localFile.Substring(0, curDF.localFile.LastIndexOf('/'));
                        if (!Directory.Exists(dirPath))
                        {
                            Directory.CreateDirectory(dirPath);
                        }

                        Stream fs = File.Open(curDF.localFile, FileMode.Create);
                        curDF.fs = fs;
                    }

                    curDF.request = request;
                    request.BeginGetResponse(new AsyncCallback(httpDownFileCallBack), curDF);
                }
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogError("--httpDownFile-->" + ex.ToString());
                if (curDF.fs != null)
                {
                    curDF.fs.Close();
                    curDF.fs.Dispose();
                }

                if (curDF.request != null)
                {
                    curDF.request.Abort();
                    curDF.request = null;
                }
            }
        }

        const int bufferbytes = 1024;
        private void httpDownFileCallBack(IAsyncResult asynchronousResult)
        {
            DownLoadFile df = null;
            Stream ns = null;
            HttpWebResponse response = null;
            try
            {
                df = (DownLoadFile)asynchronousResult.AsyncState;
                response = (HttpWebResponse)(df.request.EndGetResponse(asynchronousResult));                
                ns = response.GetResponseStream();

                byte[] nbytes = new byte[bufferbytes];
                int nReadSize = 0;
                nReadSize = ns.Read(nbytes, 0, bufferbytes);
                while (nReadSize > 0)
                {
                    if (BeingAssetUpdate && df.fs != null)
                    {
                        df.downSize += nReadSize;//已经下载大小  
                        df.fs.Write(nbytes, 0, nReadSize);//写文件
                        nReadSize = ns.Read(nbytes, 0, bufferbytes); //继续读流
                        if (m_SyncEvent != null)
                            m_SyncEvent(df);
                    }
                }

                if (df.downSize == df.size)
                {
                    df.isDownFinished = true;
                    if (m_SyncEvent != null)
                        m_SyncEvent(df);
                }
                /*else
                {
                    df.isValid = false;
                    if (m_SyncEvent != null)
                        m_SyncEvent(df);
                }*/
                
                if (df.fs != null)
                {
                    df.fs.Close();
                    df.fs.Dispose();
                    df.fs = null;
                }

                if (ns != null)
                {
                    ns.Close();
                    ns.Dispose();
                }

                if (df.request != null)
                {
                    df.request.Abort();
                    df.request = null;
                }

                if (response != null)
                {
                    response.Close();
                    response = null;
                }
            }
            catch (Exception ex)
            {
                if (df != null)
                {
                    if (df.fs != null)
                    {
                        df.fs.Close();
                        df.fs.Dispose();
                        df.fs = null;
                    }

                    if (df.request != null)
                    {
                        df.request.Abort();
                        df.request = null;
                    }
                }

                if (response != null)
                {
                    response.Close();
                    response = null;
                }
                UnityEngine.Debug.LogWarning("httpDownFileCallBack --ex-->" + ex.ToString() + "<--LocalFile-->" + df.localFile);
            }
        }
        
        public static long GetSize(string localFile)
        {
            long fileSize = 0;

            if (File.Exists(localFile))
            {
                fileStream = File.OpenWrite(localFile);
                fileSize = fileStream.Length;

                fileStream = null;
            }

            return fileSize;
        }


        public static long GetHttpLength(string url)
        {
            var length = 0L;
            try
            {
                var req = (HttpWebRequest)WebRequest.CreateDefault(new Uri(url));
                req.Method = "HEAD";
                req.Timeout = 5000;
                var res = (HttpWebResponse)req.GetResponse();
                if (res.StatusCode == HttpStatusCode.OK)
                {
                    length = res.ContentLength;
                }

                res.Close();
                return length;
            }
            catch (WebException wex)
            {
                UnityEngine.Debug.LogWarning("GetHttpLength --wex-->" + wex.ToString());
                return 0L;
            }
        }
        #endregion 业务逻辑方法
    }
}

