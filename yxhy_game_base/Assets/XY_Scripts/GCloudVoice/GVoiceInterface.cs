using UnityEngine;
using System.Collections;
using gcloud_voice;
using System;

public class GVoiceInterface : Singleton<GVoiceInterface>
{

    public IGCloudVoice m_voiceengine;
    //private string appId = "1680746456";
    //private string appKey = "43db95a53aed51ad1b84697b38f885af";

    public delegate void DelegateMessageKey(int code);
    public delegate void DelegateUploadReccord(int code,string filePath,string fileID);
    public delegate void DelegateDownloadReccord(int code, string filePath, string fileID);
    public delegate void DelegatePlayReccord(int code, string filePath);

    public void SetDelegateMessageKey(DelegateMessageKey del1)
    {
        m_voiceengine.OnApplyMessageKeyComplete += (IGCloudVoice.GCloudVoiceCompleteCode code) =>
          {
              del1((int)code);
          };
    }
    public void SetDelegateUploadReccord(DelegateUploadReccord del2)
    {
        m_voiceengine.OnUploadReccordFileComplete += (IGCloudVoice.GCloudVoiceCompleteCode code, string filePath, string fileID) =>
        {
            del2((int)code,filePath, fileID);
        };
    }
    public void SetDelegateDownloadReccord(DelegateDownloadReccord del3)
    {
        m_voiceengine.OnDownloadRecordFileComplete += (IGCloudVoice.GCloudVoiceCompleteCode code, string filePath, string fileID) =>
        {
            del3((int)code, filePath, fileID);
        };
    }
    public void SetDelegatePlayReccord(DelegatePlayReccord del4)
    {
        m_voiceengine.OnPlayRecordFilComplete += (IGCloudVoice.GCloudVoiceCompleteCode code,string filePath) =>
        {
            del4((int)code,filePath);
        };
    }

    public IGCloudVoice GetVoiceEngine()
    {
        m_voiceengine = GCloudVoice.GetEngine();

        return m_voiceengine;

    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="appId">开通业务页面中的游戏ID</param>
    /// <param name="appKey">开通业务页面中的游戏Key</param>
    /// <param name="openId">玩家唯一标示，比如从手Q或者微信获得到的OpenID</param>
    /// <returns>成功时返回GCLOUD_VOICE_SUCC</returns>
    public int SetAppInfo(string appId, string appKey, string openId)
    {
        if (m_voiceengine == null)
        {
            return -1;
        }
        return m_voiceengine.SetAppInfo(appId, appKey, openId);
    }
    /// <summary>
    /// 初始化
    /// </summary>
    /// <returns></returns>
    public int Init()
    {
        if (m_voiceengine == null)
        {
            return -1;
        }
        return  m_voiceengine.Init();
    }
    /// <summary>
    /// 如果是小队语音或者国战语音，设置成实时模式；如果是语音消息，设置成离线模式；如果是语音转文字，设置成翻译模式
    /// </summary>
    /// <param name="mode"></param>
    /// <returns></returns>
    public int SetMode(GCloudVoiceMode mode)
    {
        if (m_voiceengine == null)
        {
            return -1;
        }
        return m_voiceengine.SetMode(mode);
    }

    public int Poll()
    {
        if (m_voiceengine == null)
        {
            return -1;
        }
        return m_voiceengine.Poll();
    }
    public void OnApplicationPause(bool pauseStatus)
    {
        Debug.Log("Voice OnApplicationPause: " + pauseStatus);
        if (pauseStatus)
        {
            if (m_voiceengine == null)
            {
                return;
            }
            m_voiceengine.Pause();
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="pauseStatus"></param>
    public void OnApplicationResume(bool pauseStatus)
    {
        Debug.Log("Voice OnApplicationPause: " + pauseStatus);
        if (pauseStatus)
        {
            if (m_voiceengine == null)
            {
                return;
            }
            m_voiceengine.Resume();
        }
    }

    /// <summary>
    /// 获取语音消息安全密钥key 当申请成功后会通过OnApplyMessageKeyComplete进行回调
    /// </summary>
    /// <param name="msTimeout"></param>
    /// <returns></returns>
    public int ApplyMessageKey(int msTimeout)
    {

        if (m_voiceengine==null)
        {
            Debug.LogError("You should get voiceEngine first");
            return -1;
        }
       return m_voiceengine.ApplyMessageKey(msTimeout);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="msTime"></param>
    /// <returns></returns>
    public int SetMaxMessageLength(int msTime)
    {
        if (m_voiceengine == null)
        {
            Debug.LogError("You should get voiceEngine first");
            return -1;
        }
        return m_voiceengine.SetMaxMessageLength(msTime);

    }

    /// <summary>
    /// 当需要录音时，调用录制音频到文件中
    /// </summary>
    /// <param name="filePath"></param>
    /// <returns></returns>
    public int StartRecording(string filePath)
    {
        if (m_voiceengine == null)
        {
            Debug.LogError("You should get voiceEngine first");
            return -1;
        }
        return m_voiceengine.StartRecording(filePath);
    }

    /// <summary>
    /// 取消录音
    /// </summary>
    /// <returns></returns>
    public int StopRecording()
    {
        if (m_voiceengine == null)
        {
            Debug.LogError("You should get voiceEngine first");
            return -1;
        }
        return m_voiceengine.StopRecording();
    }
    /// <summary>
    /// 当录制完成后，
    /// 将文件上传到GcloudVoice的服务器上，
    /// 该过程会通过OnUploadReccordFileComplete回调，
    /// 在上传成功的时候返还一个ShareFileID.
    /// 该ID是这个文件的唯一标识符，
    /// 用于其他用户收听时候的下载。
    /// 服务器需要对其进行管理和转发
    /// </summary>
    /// <param name="filePath">录音文件存储的地址路径，路径中需要"/"作分隔，不能用"\" </param>
    /// <param name="msTimeout">上传文件超时时间</param>
    /// <returns></returns>
    public int UploadRecordedFile(string filePath, int msTimeout)
    {
        if (m_voiceengine == null)
        {
            Debug.LogError("You should get voiceEngine first");
            return -1;
        }
        return m_voiceengine.UploadRecordedFile(filePath, msTimeout);
    }

    /// <summary>
    /// 当游戏客户端需要收听其他人的录音时，
    /// 首先从服务器获取转发的ShareFileID，
    /// 然后调用DownloadRecordedFile下载该语言文件，
    /// 下载结果通过OnDownloadRecordFileComplete回调来通知。
    /// 当下载成功时，就可以调用PlayRecordedFile播放下载完成的语音数据了。
    /// 同样的，如果想取消播放，可以调用StopPlayFile进行取消。
    /// </summary>
    /// <param name="fileID">要下载文件的文件ID</param>
    /// <param name="downloadFilePath">下载录音文件存储的地址路径，路径中需要"/"作分隔，不能用"\"</param>
    /// <param name="msTimeout">下载文件超时时间</param>
    /// <returns></returns>
    public int DownloadRecordedFile(string fileID, string downloadFilePath, int msTimeout)
    {
        if (m_voiceengine == null)
        {
            Debug.LogError("You should get voiceEngine first");
            return -1;
        }
        return m_voiceengine.DownloadRecordedFile(fileID,downloadFilePath, msTimeout);
    }
    public int StopPlayFile()
    {
        if (m_voiceengine == null)
        {
            Debug.LogError("You should get voiceEngine first");
            return -1;
        }
        return m_voiceengine.StopPlayFile();
    }
    public int PlayRecordedFile(string downloadFilePath)
    {
        if (m_voiceengine == null)
        {
            Debug.LogError("You should get voiceEngine first");
            return -1;
        }
        return m_voiceengine.PlayRecordedFile(downloadFilePath);
    }
}
