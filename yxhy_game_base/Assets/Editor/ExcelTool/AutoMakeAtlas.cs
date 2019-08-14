using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;
using LitJson;
public class AutoMakeAtlas:EditorWindow  {
    public static List<AtlasConfig> s_AtlasConfigList = new List<AtlasConfig>();
    public static string s_AtlasCfgData = "";
    [MenuItem("Tools/换皮工具",false,30)]
    static void createAtlas()
    {
        s_AtlasConfigList.Clear();
        EditorWindow.GetWindow<AutoMakeAtlas>(false, "自动打包图集", true).Show();
    }

    public static void GetAtlas(string path)
    {
        FileInfo prefab = new FileInfo(path);
        int index = prefab.FullName.IndexOf("Assets");
        string assetPath = prefab.FullName.Substring(index);
        GameObject game = AssetDatabase.LoadAssetAtPath(assetPath, typeof(GameObject)) as GameObject;
        if (game != null)
        {
            UIAtlas atlas = game.GetComponent<UIAtlas>();
            if (atlas != null)
            {
                NGUISettings.atlas = atlas;
            }
        }
    }

    public static void UpdataAtlas()
    {
        foreach (AtlasConfig cfg in s_AtlasConfigList)
        {
            if (cfg.m_IsSelect)
            {
                foreach (AtlasMap map in cfg.m_AtlasMapList)
                {
                    GetAtlas(map.m_AtlasPath);
                    DirectoryInfo dirInfo = new DirectoryInfo(map.m_ImageFolder);
                    FileInfo[] images = dirInfo.GetFiles("*.png", SearchOption.AllDirectories);
                    List<Texture> textures = new List<Texture>();
                    if (images != null && images.Length > 0)
                    {
                        foreach (FileInfo image in images)
                        {
                            int index = image.FullName.IndexOf("Assets");
                            string assetPath = image.FullName.Substring(index);
                            Object obj = AssetDatabase.LoadMainAssetAtPath(assetPath);
                            Debug.Log("File FullName : " + image.FullName);
                            Texture tex = obj as Texture;
                            if (tex == null || tex.name == "Font Texture") continue;
                            if (NGUISettings.atlas == null || NGUISettings.atlas.texture != tex)
                                textures.Add(tex);
                        }
                        UpdataAtlas(textures, true);
                    }
                }
            }
        }
        Debug.Log("Finish UpdateAtlas");
        AssetDatabase.Refresh();
    }

    public static void UpdataAtlas(List<Texture> textures,bool keepSprites)
    {
        List<UIAtlasMaker.SpriteEntry> sprites = UIAtlasMaker.CreateSprites(textures);
        if (sprites.Count > 0)
        {
            if (keepSprites) UIAtlasMaker.ExtractSprites(NGUISettings.atlas, sprites);
            UIAtlasMaker.UpdateAtlas(NGUISettings.atlas, sprites);
        }
        else if(!keepSprites)
        {
            UIAtlasMaker.UpdateAtlas(NGUISettings.atlas, sprites);
        }
    }

    void OnGUI()
    {
        SetConfigData();
        NGUIEditorTools.DrawHeader("Input", true);
        GUILayout.BeginHorizontal(EditorStyles.toolbar);
        if (GUILayout.Button("UpdateAtlas",EditorStyles.toolbarButton))
        {
            UpdataAtlas();
        }
        GUILayout.EndHorizontal();
        NGUIEditorTools.BeginContents(false);
        GUILayout.BeginVertical();
        {
            GUILayout.BeginVertical();
            GUILayout.Label("APPID:",GUILayout.Width(50));
            GUILayout.EndVertical();
            SetUi();
        }
        GUILayout.EndVertical();
        NGUIEditorTools.EndContents();
    }

    public void SetConfigData()
    {
        if (s_AtlasConfigList.Count == 0)
        {
            s_AtlasCfgData = FileUtils.GetAppConfData("config/atlas_config.txt");
            JsonData deJson = JsonMapper.ToObject(s_AtlasCfgData);

            for (int i = 0; i < deJson["appId"].Count; i++)
            {
                AtlasConfig cfg = new AtlasConfig();
                cfg.m_AppId = deJson["appId"][i].ToString();
                string imageRootFolderPath = deJson["imageRootFolderPath"] + cfg.m_AppId;
                cfg.m_ImageRootFolderPath = imageRootFolderPath;
                for (int j = 0; j < deJson["atlasMap"].Count; j++)
                {
                    AtlasMap map = new AtlasMap();
                    map.m_ImageFolder = imageRootFolderPath + PathSymbol() + deJson["atlasMap"][j]["imageFolder"];
                    map.m_AtlasPath = deJson["atlasMap"][j]["atlasPath"].ToString();
                    cfg.m_AtlasMapList.Add(map);
                }
                s_AtlasConfigList.Add(cfg);
            }
        }
    }

    public void SetUi()
    {
        GUILayout.BeginHorizontal();
        foreach (AtlasConfig atls in s_AtlasConfigList)
        {
            atls.m_IsSelect = EditorGUILayout.ToggleLeft(atls.m_AppId, atls.m_IsSelect, GUILayout.Width(100));
            if (atls.m_IsSelect == true)
            {
                DisableOtherAppId(atls);
            }
        }
        GUILayout.EndHorizontal();
        SetImageFolder();
    }

    public void DisableOtherAppId(AtlasConfig cfg)
    {
        foreach (AtlasConfig atls in s_AtlasConfigList)
        {
            if (cfg.m_AppId != atls.m_AppId)
            {
                atls.m_IsSelect = false;
            }
        }
    }

    public void SetImageFolder()
    {
        NGUIEditorTools.BeginContents(false);
        foreach (AtlasConfig atls in s_AtlasConfigList)
        {
            if (atls.m_IsSelect)
            {
                foreach(AtlasMap map in atls.m_AtlasMapList)
                {
                    GUILayout.BeginVertical();
                    int index = map.m_ImageFolder.LastIndexOf(PathSymbol());
                    string str = map.m_ImageFolder.Substring(index + 1);
                    map.m_IsSelect =  EditorGUILayout.ToggleLeft(str, map.m_IsSelect, GUILayout.Width(200));
                    GUILayout.EndVertical();
                }
            }
        }
        NGUIEditorTools.EndContents();
    }

    public string PathSymbol()
    {
        string path = "";
#if UNITY_STANDALONE_OSX || UNITY_EDITOR_OSX
        path = "/";
#elif UNITY_STANDALONE_WIN || UNITY_EDITOR
        path = "\\";
#endif
        return path;
    }


    public class AtlasConfig
    {
        public string m_AppId = "";
        public string m_ImageRootFolderPath = "";
        public bool m_IsSelect = false;
        public List<AtlasMap> m_AtlasMapList = new List<AtlasMap>();
    }

    public class AtlasMap
    {
        public string m_ImageFolder = "";
        public string m_AtlasPath = "";
        public string m_AtlasName = "";
        public bool m_IsSelect = true;
        public string AtlasName
        {
            get {
                    if (m_AtlasPath != "" && m_AtlasName == "")
                    {
                        int index = m_AtlasPath.LastIndexOf(PathSymbol());
                        string subStr = m_AtlasPath.Substring(index + 1);
                        string[] subStrSplit = subStr.Split('.');
                        AtlasName = subStrSplit[0];
                    }
                    return m_AtlasName;
                }
            set { m_AtlasName = value; }
        }

        public string PathSymbol()
        {
            string path = "";
#if UNITY_STANDALONE_OSX || UNITY_EDITOR_OSX
        path = "/";
#elif UNITY_STANDALONE_WIN || UNITY_EDITOR
            path = "\\";
#endif
            return path;
        }
    }
}
