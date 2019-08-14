using System;
using UnityEngine;
using BestHTTP;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Collections.Generic;

public class DownloadCachesMgr : Singleton<DownloadCachesMgr>
{

    private string AssetCachesDir
    {
        get
        {
            string dir = "";
#if UNITY_EDITOR
            dir = Application.dataPath + "Caches/";//路径：/AssetsCaches/
#elif UNITY_IOS
            dir = Application.temporaryCachePath + "/Download/";//路径：Application/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/Library/Caches/
#elif UNITY_ANDROID
            dir = Application.persistentDataPath + "/Download/";//路径：/data/data/xxx.xxx.xxx/files/
#else
            dir = Application.streamingAssetsPath + "/Download/";//路径：/xxx_Data/StreamingAssets/
#endif
            return dir;
        }
    }

    private string ImagePathName { get { return AssetCachesDir + "Image/"; } }
    private string TextPathName { get { return AssetCachesDir + "Config/"; } }

    private string GetFileName(string url)
    {
        string name = StrToMD5(url);
        return name;
    }

    private string StrToMD5(string str)
    {
        byte[] data = System.Text.Encoding.UTF8.GetBytes(str);
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] OutBytes = md5.ComputeHash(data);

        StringBuilder sb = new StringBuilder();
        //string OutString = "";
        for (int i = 0; i < OutBytes.Length; i++)
        {
            //OutString += OutBytes[i].ToString("x2");
            sb.Append(OutBytes[i].ToString("x2"));
        }
        // return OutString.ToUpper();
        return sb.ToString().ToLower();
    }

    private bool CheckFileExists(string path , string name)
    {
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
        FileInfo t = new FileInfo(path + "//" + name);
        if (!t.Exists)
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    private void CreateFile(string path, string name,byte[] bytes)
    {
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }

        FileStream fs;
        FileInfo t = new FileInfo(path + "//" + name);
        if (!t.Exists)
        {
            fs = t.Create();
        }
        else
        {
            t.Delete();
            fs = t.Create();
        }
        fs.Write(bytes, 0, bytes.Length);
        fs.Close();
        fs.Dispose();
    }

    public void LoadImage(string url, Action<int, Texture2D ,string> callBack)
    {
        if (string.IsNullOrEmpty(url))
            return;
        
        string name = GetFileName(url);
        string localImageUrl = ImagePathName + "//" + name;
        if (CheckFileExists(ImagePathName, name))
        {
            var bytes = File.ReadAllBytes(localImageUrl);
            Texture2D tex = new Texture2D(0, 0, UnityEngine.TextureFormat.ARGB32, false);
            tex.LoadImage(bytes);
            callBack(0, tex, localImageUrl);
        }
        else
        {
            try
            {
                new HTTPRequest(new Uri(url), (request, response) =>
                {
                    if (request.State == HTTPRequestStates.Finished)
                    {
                        int result = 0;
                        Texture2D tex = null;
                        if (response.IsSuccess)
                        {
                            byte[] bytes = response.Data;
                            tex = response.DataAsTexture2D;
                            if (tex == null)
                            {
                                result = -1;
                            }
                            else if (bytes[0] == 'G' && bytes[1] == 'I' && bytes[2] == 'F')
                            {
                                int loop, w, h;
                                List<UniGif.GifTexture> gifTexList = UniGif.GetTextureList(bytes, out loop, out w, out h);
                                if (null != gifTexList && gifTexList.Count > 0)
                                {
                                    tex = gifTexList[0].texture2d;
                                }
                                byte[] newData = tex.EncodeToPNG();
                                if (tex != null && newData != null)
                                {
                                    CreateFile(ImagePathName, name, newData);
                                }
                                else
                                {
                                    result = -1;
                                }
                            }
                            else if (tex.height == 8 && tex.width == 8)
                            {
                                result = -1;
                            }
                            else
                            {
                                CreateFile(ImagePathName, name, bytes);
                            }
                        }
                        else
                        {
                            result = response.StatusCode;
                        }
                        if (callBack != null)
                        {
                            callBack(result, tex, localImageUrl);
                        }
                    }
                }).Send();
            }
            catch (Exception e)
            {
                if (callBack != null)
                {
                    callBack(-1, new Texture2D(0, 0), localImageUrl);
                }
                LuaInterface.Debugger.Log("LoadImage------------->" + e);
            }
        }
    }

}
