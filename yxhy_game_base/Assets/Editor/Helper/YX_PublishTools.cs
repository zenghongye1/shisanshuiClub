using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using LitJson;
public class YX_PublishTools : EditorWindow
{
    public static List<ChannelCfg> s_ChannelConfigList = new List<ChannelCfg>();
    static string s_BuildPath;
    static string s_AppName;
    static string s_KeyStorePath;
 
//    [MenuItem("XXX/public",false)]
   public static void Publish()
    {
        SetBuildKPath();
    //    PlayerSettings.Android.keyaliasName = "dstars.keystore";
        PlayerSettings.Android.keystorePass = "dstars2017";
        PlayerSettings.Android.keyaliasPass = "dstars2017";
        List<string> selectScenes = new List<string>();
        foreach(EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
        {
            if (!scene.enabled) continue;
            selectScenes.Add(scene.path);
        }
#if UNITY_ANDROID
        string response = BuildPipeline.BuildPlayer(selectScenes.ToArray(), s_AppName, BuildTarget.Android, BuildOptions.None);
# elif UNITY_IOS
        string response = BuildPipeline.BuildPlayer(selectScenes.ToArray(), s_AppName, BuildTarget.iOS, BuildOptions.None);
#endif
        if (response.Length > 0)
        {
            throw new System.Exception("BuildPlayer failure:" + response);
        }
        else
        {
            Debug.Log("Build APK OK:" + s_AppName);
        }

    }

    //子版本号加+1
    private static string CurrentVersion(bool bPlus = false)
    {
        string version = PlayerSettings.bundleVersion;
        if (bPlus)
        {
            int lastCode;
            try
            {
                lastCode = version.LastIndexOf('.');
                if (lastCode > 0)
                {
                    version = version.Substring(0, lastCode + 1);
                    lastCode = int.Parse(PlayerSettings.bundleVersion.Substring(lastCode + 1));
                    version += ++lastCode;
                    PlayerSettings.bundleVersion = version;
                }
            }
            catch (System.Exception ex)
            {
                Debug.Log(ex.Message);
                version = PlayerSettings.bundleVersion;
            }
        }
        return version;
    }

    public static string SetBuildKPath()
    {
        int index = Application.dataPath.LastIndexOf("/Assets");
        string rootpath = "";
        if (index != -1)
        {
            rootpath = Application.dataPath.Substring(0, index);
        }
#if UNITY_ANDROID
        string path = rootpath + "/AndroidPacket";
        s_AppName = "YXQP_Android.apk";
#elif UNITY_IOS
        string path = rootpath + "/IOSProj_4_5.4";
         s_AppName = "";
#endif
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
        s_AppName = path + "/" + s_AppName;
       if (File.Exists(s_AppName))
        {
            File.Delete(s_AppName);
        }

        return s_AppName;
    }



    private int shortLength = 50;
    private int lognLength = 200;
    Vector2 scrollPos = Vector2.zero;
    [MenuItem("Tools/渠道发布")]
    public static void PublishShow()
    {
        s_ChannelConfigList.Clear();
        EditorWindow.GetWindow<YX_PublishTools>(false, "渠道发布", true).Show();
    }

    private void OnGUI()
    {
        SetConfigData();
        //显示标题
        GUILayout.BeginHorizontal();
        GUIStyle a = new GUIStyle();
        GUILayout.Label("",  GUILayout.Width(shortLength/2));
        GUILayout.Label("渠道名", "box", GUILayout.Width(shortLength));
        GUILayout.Label("渠道ID", "box", GUILayout.Width(lognLength));
        GUILayout.Label("Appkey", "box", GUILayout.Width(lognLength));
        GUILayout.Label("系统", "box", GUILayout.Width(shortLength));
        GUILayout.Label("运营平台", "box", GUILayout.Width(lognLength));
        GUILayout.Label("平台代码", "box", GUILayout.Width(lognLength));
        GUILayout.EndHorizontal();

        foreach(ChannelCfg cfg in s_ChannelConfigList)
        {
           
            EditorGUILayout.BeginHorizontal();
            cfg.m_IsSelect = EditorGUILayout.ToggleLeft("", cfg.m_IsSelect, GUILayout.Width(shortLength/2));
            EditorGUILayout.LabelField(new GUIContent(cfg.m_ChannelName, "test"), GUILayout.Width(shortLength));
            EditorGUILayout.LabelField(new GUIContent(cfg.m_ChannelId, "test"), GUILayout.Width(lognLength));
            EditorGUILayout.LabelField(new GUIContent(cfg.m_AppKey, "test"), GUILayout.Width(lognLength));
            EditorGUILayout.LabelField(new GUIContent(cfg.m_OS, "test"), GUILayout.Width(shortLength));
            EditorGUILayout.LabelField(new GUIContent(cfg.m_OperationPlatform, "test"), GUILayout.Width(lognLength));
            EditorGUILayout.LabelField(new GUIContent(cfg.m_OperationId, "test"), GUILayout.Width(lognLength));
       
            EditorGUILayout.EndHorizontal();
        }
        GUILayout.Space(10);
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("All", GUILayout.Width(shortLength)))
        {
            ChooseAll(true);
        }
        if (GUILayout.Button("None", GUILayout.Width(shortLength)))
        {
            ChooseAll(false);
        }
        if (GUILayout.Button("ReLoad Config", GUILayout.Width(lognLength)))
        {

        }
        if (GUILayout.Button(new GUIContent("New", "Add a new Channle"), GUILayout.Width(shortLength)))
        {

        }
        if (GUILayout.Button(new GUIContent("Publish", "Publish selected Channles"), GUILayout.Width(shortLength * 3)))
        {

        }
        EditorGUILayout.EndHorizontal();
    }

    static private void SetBundleIdentifier(string bundleIdentifier)
    {
        PlayerSettings.bundleIdentifier = bundleIdentifier;
    }

    static private bool CopyPluginFiles(string GamePlatform)
    {
        string appPath = Application.dataPath + "/plugins/";
        string AndroidPath = appPath + "Android";
        string pluginPath = Application.dataPath.Replace("Assets", "AndroidPlugins/Android_" + GamePlatform);
        int fileNameStartPos = (pluginPath.Split(new char[] { '/', '\\' })).Length;
        string[] files;
        if (!Directory.Exists(pluginPath))
        {
            Debug.LogError("平台" + GamePlatform + "的sdk文件夹不存在\n" + pluginPath);
            return false;
        }
        if (!Directory.Exists(AndroidPath))
        {
            Directory.CreateDirectory(AndroidPath);
            Debug.Log("创建Android平台目录：" + AndroidPath);
        }
        else
        {
            files = Directory.GetFiles(AndroidPath, "*.*", SearchOption.TopDirectoryOnly);
            for(int i = 0; i< files.Length; i++)
            {
                File.Delete(files[i]);
            }
            files = Directory.GetDirectories(AndroidPath, "*.*", SearchOption.TopDirectoryOnly);
            for (int i = 0; i < files.Length; i ++)
            {
                Directory.Delete(files[i], true);
            }
         
        }
        files = Directory.GetFiles(pluginPath, "*.*", SearchOption.AllDirectories);
        string fileName = "";

        for (int i = 0; i < files.Length; i++)
        {
            fileName = files[i];
            string[] token = fileName.Split(new char[] { '/', '\\' });
            fileName = AndroidPath;
            for (int j = fileNameStartPos; j < token.Length - 1; j++)
            {
                fileName = fileName + "\\" + token[j];
                if (!Directory.Exists(fileName))
                {
                    Directory.CreateDirectory(fileName);
                }
            }
            fileName = fileName + "\\" + token[token.Length - 1];
            File.Copy(files[i], fileName);
        }
        AssetDatabase.Refresh();
        return true;
    }
    public static string s_ChannelCfgData = "";
    public void SetConfigData()
    {
        if (s_ChannelConfigList.Count == 0)
        {
            s_ChannelCfgData = FileUtils.GetAppConfData("config/channel_config.txt");
            JsonData deJson = JsonMapper.ToObject(s_ChannelCfgData);

            for (int i = 0; i < deJson["cfg"].Count; i++)
            {
                ChannelCfg cfg = new ChannelCfg();
                cfg.m_ChannelName = deJson["cfg"][i]["channel_Name"].ToString();
                cfg.m_ChannelId = deJson["cfg"][i]["channel_Id"].ToString();
                cfg.m_AppKey = deJson["cfg"][i]["Appkey"].ToString();
                cfg.m_OS = deJson["cfg"][i]["OS"].ToString();
                cfg.m_OperationPlatform = deJson["cfg"][i]["OperationPlatform"].ToString();
                cfg.m_OperationId = deJson["cfg"][i]["Operation_Id"].ToString();
                cfg.m_BundleIdentifier = deJson["cfg"][i]["BundleIdentifier"].ToString();
                s_ChannelConfigList.Add(cfg);
            }
        }
    }

    public void ChooseAll(bool isSelect)
    {
        if (s_ChannelConfigList.Count > 0)
        {
            foreach (ChannelCfg cfg in s_ChannelConfigList)
            {
                cfg.m_IsSelect = isSelect;
            }
        }
    }

    public class ChannelCfg
    {
        public string m_ChannelName = "";
        public string m_ChannelId = "";
        public string m_AppKey = "";
        public string m_OS = "";
        public string m_OperationPlatform = "";
        public string m_OperationId = "";
        public string m_BundleIdentifier = "";
        public bool m_IsSelect = true;
    }
}
