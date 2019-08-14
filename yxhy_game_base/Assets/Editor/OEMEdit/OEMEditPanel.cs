using System.IO;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
using System.Collections.Generic;
using System.Xml;
using System.Drawing;
using System.Text;
using LitJson;
using Spine.Unity;
using Spine.Unity.Editor;


public class OEMEditPanel : EditorWindow
{
    public string gameName = "";
    public string packageName = "com.dstars.fuzhou.mahjong";
    public string versionNum = "1.1";
    public string iconPath = "";
    public string defaulticonPath = "";
    public string loginBgPath = "";
    public string loginLogoPath = "";
    public string hallBgPath = "";
    public string hallLogoPath = "";
    public string shareBgPath = "";
    public string skeletonPngPath = "";
    public string skeletonJsonPath = "";
    public string skeletonTxtPath = "";

    public static string assetsPath = Application.dataPath;
    public static string resRootPath = assetsPath.Replace("/Assets", "/App_Res");
    string resRootPathSelected = resRootPath;
    public static List<string> resXYHYLst = new List<string>();
    public static List<string> assetsLst = new List<string>();

    public static Dictionary<string, string> Dic_Value = new Dictionary<string, string>();
    //public static string mDicFileName="DicFile";
    //public static string mDicFolderName="DicFolder";
    //public static string DicFileName {
    //    get { return Path.Combine(DicFileName, mDicFileName); }
    //}
    //public static string DicFolderName{
    //    get { return Path.Combine(assetsPath, mDicFolderName); }
    //}
    string jsonValues = null;

    private ReorderableList Res_XYHY_list;
    private ReorderableList Assets_list;
    private Vector2 _scrollPosition = Vector2.zero;

    [MenuItem("Tools/OEM Panel")]
    static void Open()
    {
        GetWindow<OEMEditPanel>("OEM Panel", true);
    }


    void OnGUI()
    {
        if (Assets_list == null)
        {
            InitAssetsListDrawer();
        }

        if (Res_XYHY_list == null)
        {
            InitResListDrawer();
        }
     
        bool execSet = false;
        //tool bar
        GUILayout.BeginHorizontal(EditorStyles.toolbar);
        {
            if (GUILayout.Button("Import", EditorStyles.toolbarButton))
            {
                string JsonReadPath = SelectFile("Config_Import");
                if (string.IsNullOrEmpty(JsonReadPath))
                {
                    LuaInterface.Debugger.Log("import is canceled");
                    return;
                }
                FileStream fs = new FileStream(JsonReadPath,FileMode.Open);
                StreamReader sr = new StreamReader(fs);
                JsonData dejson= JsonMapper.ToObject(sr.ReadToEnd());
                foreach (var key in dejson.Keys)
                {
                    Dic_Value.Add(key, dejson[key].ToString());
                }
                if (fs != null)
                {
                    fs.Close();
                }
                if (sr != null)
                {
                    sr.Close();
                }
                ReadDataFromDic();
                Dic_Value.Clear();
            }
            if (GUILayout.Button("Export", EditorStyles.toolbarButton))
            {
                string jsonSavePath = SaveFile();
               // Debug.LogError("jsonSavePath"+ jsonSavePath);
                if (string.IsNullOrEmpty(jsonSavePath))
                {
                    LuaInterface.Debugger.Log("export is canceled");
                    return;
                }
                WriteDataToDic();
                jsonValues = JsonMapper.ToJson(Dic_Value);
                LuaInterface.Debugger.Log(jsonValues);
                FileStream fs = new FileStream(jsonSavePath, FileMode.Create);
                byte[] bts = Encoding.UTF8.GetBytes(jsonValues);
                fs.Write(bts,0,bts.Length);
                if (fs != null)
                    fs.Close();
                Dic_Value.Clear();
            }

            GUILayout.FlexibleSpace();
            if (GUILayout.Button("Set", EditorStyles.toolbarButton))
            {
                execSet = true;
            }
        }
        GUILayout.EndHorizontal();


        //context
        GUILayout.Space(10);
        GUILayout.BeginVertical();
        {
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("游戏名称：");
                gameName = EditorGUILayout.TextField(gameName);
            }
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("游戏包名：");
                packageName = EditorGUILayout.TextField(packageName);
            }
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("游戏版本号：");
                versionNum = EditorGUILayout.TextField(versionNum);
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("游戏ICON：");
                if (GUILayout.Button("Add", EditorStyles.toolbarButton,GUILayout.Width(150)))
                {
                    string path = SelectFile("游戏ICON");
                    if (!string.IsNullOrEmpty(path))
                    {
                        iconPath = GetFolderFileName(path);
                    }
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("启动动画：");
                if (GUILayout.Button("Add", EditorStyles.toolbarButton, GUILayout.Width(150)))
                {
                    string path = SelectFile("启动动画");
                    if (!string.IsNullOrEmpty(path))
                    {
                        defaulticonPath = GetFolderFileName(path);
                    }
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("登陆背景：");
                if (GUILayout.Button("Add", EditorStyles.toolbarButton, GUILayout.Width(150)))
                {
                    string path = SelectFile("登陆背景");
                    if (!string.IsNullOrEmpty(path))
                    {
                        loginBgPath = GetFolderFileName(path);
                    }
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("登陆Logo：");
                if (GUILayout.Button("Add", EditorStyles.toolbarButton, GUILayout.Width(150)))
                {
                    string path = SelectFile("登陆Logo");
                    if (!string.IsNullOrEmpty(path))
                    {
                        loginLogoPath = GetFolderFileName(path);
                    }
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("大厅背景：");
                if (GUILayout.Button("Add", EditorStyles.toolbarButton, GUILayout.Width(150)))
                {
                    string path = SelectFile("大厅背景");
                    if (!string.IsNullOrEmpty(path))
                    {
                        hallBgPath = GetFolderFileName(path);
                    }
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("大厅Logo：");
                if (GUILayout.Button("Add", EditorStyles.toolbarButton, GUILayout.Width(150)))
                {
                    string path = SelectFile("大厅Logo");
                    if (!string.IsNullOrEmpty(path))
                    {
                        hallLogoPath = GetFolderFileName(path);
                    }
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("分享背景：");
                if (GUILayout.Button("Add", EditorStyles.toolbarButton, GUILayout.Width(150)))
                {
                    string path = SelectFile("分享背景");
                    if (!string.IsNullOrEmpty(path))
                    {
                        shareBgPath = GetFolderFileName(path);
                    }
                }
            }
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("导入动画：");
                if (GUILayout.Button("Add png", EditorStyles.toolbarButton, GUILayout.Width(150)))
                {
                    string path = SelectFile("动画Png");
                    if (!string.IsNullOrEmpty(path))
                    {
                        skeletonPngPath = Get2FolderFileName(path);
                    }
                }
                if (GUILayout.Button("Add json", EditorStyles.toolbarButton, GUILayout.Width(150)))
                {
                    string path = SelectFile("动画Json");
                    if (!string.IsNullOrEmpty(path))
                    {
                        skeletonJsonPath = Get2FolderFileName(path);
                    }
                }
                if (GUILayout.Button("Add txt", EditorStyles.toolbarButton, GUILayout.Width(150)))
                {
                    string path = SelectFile("动画Txt");
                    if (!string.IsNullOrEmpty(path))
                    {
                        skeletonTxtPath = Get2FolderFileName(path);
                    }
                }
            }
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("ICON PATH:");
                EditorGUILayout.LabelField(resRootPath+iconPath);
               // resRootPath= assetsPath.Replace("/Assets", "/App_Res");
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("Defaulticon PATH:");
                EditorGUILayout.LabelField(resRootPath+defaulticonPath);
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("LoginBg PATH:");
                EditorGUILayout.LabelField(resRootPath+loginBgPath);
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("LoginLogo PATH:");
                EditorGUILayout.LabelField(resRootPath+loginLogoPath);
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("hallBg PATH:");
                EditorGUILayout.LabelField(resRootPath+hallBgPath);
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("hallLogo PATH:");
                EditorGUILayout.LabelField(resRootPath+hallLogoPath);
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("shareBg PATH:");
                EditorGUILayout.LabelField(resRootPath+shareBgPath);
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                EditorGUILayout.PrefixLabel("skeleton PATH:");
                GUILayout.BeginVertical();
                {
                    EditorGUILayout.LabelField(resRootPath + skeletonPngPath);
                    EditorGUILayout.LabelField(resRootPath + skeletonJsonPath);
                    EditorGUILayout.LabelField(resRootPath + skeletonTxtPath);
                }
                GUILayout.EndVertical();
            }
            GUILayout.EndHorizontal();

            GUILayout.Space(10);
            _scrollPosition = GUILayout.BeginScrollView(_scrollPosition);
            {
                Res_XYHY_list.DoLayoutList();
            }
            GUILayout.EndScrollView();

            GUILayout.Space(10);
            _scrollPosition = GUILayout.BeginScrollView(_scrollPosition);
            {
                Assets_list.DoLayoutList();
            }
            GUILayout.EndScrollView();
        }
        GUILayout.EndVertical();

        if (execSet)
        {
            OEMSet();
        }
    }

    private void OEMSet()
    {
        //OEMSetHandler();
        PlayerSettings.bundleIdentifier = packageName;
        PlayerSettings.bundleVersion = versionNum;

#if UNITY_ANDROID
        string[] verNumArray = versionNum.Split('.');
        int verCode = 0;
        for (int i = 0; i < verNumArray.Length; i++)
        {
            verCode += int.Parse(verNumArray[i]);
        }
        PlayerSettings.Android.bundleVersionCode = verCode;
#endif

        string loginUiPrefabPath = "Assets/Res_XYHY/app_4/ui/login_ui/login_ui.prefab";
        GameObject login_ui = AssetDatabase.LoadAssetAtPath(loginUiPrefabPath, typeof(GameObject)) as GameObject;
        GameObject login = PrefabUtility.InstantiatePrefab(login_ui) as GameObject;
        string updateUiPrefabPath = "Assets/Res_XYHY/app_4/ui/version_update_ui/version_update_ui.prefab";
        GameObject update_ui = AssetDatabase.LoadAssetAtPath(updateUiPrefabPath, typeof(GameObject)) as GameObject;
        GameObject update = PrefabUtility.InstantiatePrefab(update_ui) as GameObject;
        GameObject[] targs = GameObject.FindGameObjectsWithTag("Oem");
        foreach (GameObject gobj in targs)
        {
            gobj.SetActive(false);
        }
        login.transform.FindChild("oemBg").gameObject.SetActive(true);
        login.transform.FindChild("oemLogo").gameObject.SetActive(true);
        update.transform.FindChild("root/comm_panel/oemLogo").gameObject.SetActive(true);

        GameObject prefabpre1 = PrefabUtility.CreatePrefab(loginUiPrefabPath, login);
        PrefabUtility.ReplacePrefab(login, prefabpre1, ReplacePrefabOptions.ConnectToPrefab);
        DestroyImmediate(login);
        AssetDatabase.Refresh();
        GameObject prefabpre2 = PrefabUtility.CreatePrefab(updateUiPrefabPath, update);
        PrefabUtility.ReplacePrefab(update, prefabpre2, ReplacePrefabOptions.ConnectToPrefab);
        DestroyImmediate(update);
        AssetDatabase.Refresh();

        if (!string.IsNullOrEmpty(gameName))
        {
            string cnFilePath = assetsPath + "/Plugins/Android/res/values-zh-rCN/strings.xml";
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.Load(cnFilePath);
            XmlNode root = xmlDoc.DocumentElement;
            root.InnerXml = "\n<string name=\"app_name\">" + gameName + "</string>\n";
            xmlDoc.Save(cnFilePath);
        }

        if (!string.IsNullOrEmpty(iconPath))
        {
            string iconAimPath = assetsPath + "/YX_app_4/XY_Textures/icon/icon192.png";
            string sourcePath = resRootPath + iconPath;
            FileInfo iconFile = new FileInfo(sourcePath);
            if (iconFile.Exists)
                iconFile.CopyTo(iconAimPath, true);
            else
                LuaInterface.Debugger.Log("iconFile not Exist");
        }

        if (!string.IsNullOrEmpty(defaulticonPath))
        {
            string defaulticonAimPath1 = assetsPath + "/Plugins/Android/res/drawable-hdpi/defaulticon.png";
            string defaulticonAimPath2 = assetsPath + "/Plugins/Android/res/drawable-xxhdpi/defaulticon.png";
            string sourcePath = resRootPath + defaulticonPath;
            FileInfo defaulticonFile = new FileInfo(sourcePath);
            if (defaulticonFile.Exists)
            {
                defaulticonFile.CopyTo(defaulticonAimPath1, true);
                defaulticonFile.CopyTo(defaulticonAimPath2, true);
            }
            else
                LuaInterface.Debugger.Log("defaulticonFile not Exist");
        }

        if (!string.IsNullOrEmpty(loginBgPath))
        {
            string loginBgAimPath = assetsPath + "/Res_XYHY/app_4/uitextures/login/bj_1.jpg";
            string sourcePath = resRootPath + loginBgPath;
            FileInfo loginBgFile = new FileInfo(sourcePath);
            if (loginBgFile.Exists)
                loginBgFile.CopyTo(loginBgAimPath, true);
            else
                LuaInterface.Debugger.Log("loginBgFile not Exist");
        }

        if (!string.IsNullOrEmpty(hallBgPath))
        {
            string hallBgAimPath = assetsPath + "/YX_app_4/XY_Textures/hall/bj_2.jpg";
            string sourcePath = resRootPath + hallBgPath;
            FileInfo hallBgFile = new FileInfo(sourcePath);
            if (hallBgFile.Exists)
                hallBgFile.CopyTo(hallBgAimPath, true);
            else
                LuaInterface.Debugger.Log("hallBgFile not Exist");
        }

        if (!string.IsNullOrEmpty(shareBgPath))
        {
            string shareBgAimPath = assetsPath + "/YX_app_4/XY_Textures/Share/fx_1.png";
            string sourcePath = resRootPath + shareBgPath;
            FileInfo shareBgFile = new FileInfo(sourcePath);
            if (shareBgFile.Exists)
                shareBgFile.CopyTo(shareBgAimPath, true);
            else
                LuaInterface.Debugger.Log("shareBgFile not Exist");
        }

        if (!string.IsNullOrEmpty(loginLogoPath))
        {
            string sourcePath = resRootPath + loginLogoPath;
            FileStream fs = new FileStream(sourcePath, FileMode.Open, FileAccess.Read);
            Image img = Image.FromStream(fs);
            MemoryStream ms = new MemoryStream();
            img.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
            Texture2D tex2D = new Texture2D(660, 180, TextureFormat.ARGB32, false);
            tex2D.LoadImage(ms.ToArray());
            tex2D.name = fs.Name.Substring(fs.Name.LastIndexOf('/')+1).Split('.')[0];
            if (tex2D.name != "logo_1")
                tex2D.name = "logo_1";
            string uiAtlasPath = "Assets/YX_app_4/XY_Atlases/loginAtlas/login_atlas.prefab";
            UIAtlas login_atlas = AssetDatabase.LoadAssetAtPath(uiAtlasPath, typeof(UIAtlas)) as UIAtlas;
            UIAtlasMaker.AddOrUpdate(login_atlas,tex2D);        
        }

        if (!string.IsNullOrEmpty(hallLogoPath))
        {
            string sourcePath = resRootPath + hallLogoPath;
            FileStream fs = new FileStream(sourcePath, FileMode.Open, FileAccess.Read);
            Image img = Image.FromStream(fs);
            MemoryStream ms = new MemoryStream();
            img.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
            Texture2D tex2D = new Texture2D(660, 180, TextureFormat.ARGB32, false);
            tex2D.LoadImage(ms.ToArray());
            tex2D.name = fs.Name.Substring(fs.Name.LastIndexOf('/') + 1).Split('.')[0];
            if (tex2D.name != "logo_2")
                tex2D.name = "logo_2";
            string uiAtlasPath = "Assets/YX_app_4/XY_Atlases/hallAtlas/hall_background.prefab";
            UIAtlas login_atlas = AssetDatabase.LoadAssetAtPath(uiAtlasPath, typeof(UIAtlas)) as UIAtlas;
            UIAtlasMaker.AddOrUpdate(login_atlas, tex2D);
        }
        if (!string.IsNullOrEmpty(skeletonPngPath) && !string.IsNullOrEmpty(skeletonJsonPath) && !string.IsNullOrEmpty(skeletonTxtPath))
        {
            string AimPath = assetsPath + "/YX_app_4/XY_Animations/hall/forOEM";
            //string sourcePath = resRootPath + shareBgPath;
            FileInfo skeletonPngFile = new FileInfo(resRootPath + skeletonPngPath);
            FileInfo skeletonJsonFile = new FileInfo(resRootPath + skeletonJsonPath);
            FileInfo skeletonTxtFile = new FileInfo(resRootPath + skeletonTxtPath);
            if (skeletonPngFile.Exists && skeletonJsonFile.Exists && skeletonTxtFile.Exists)
            {
                skeletonPngFile.CopyTo(AimPath + skeletonPngPath.Substring(skeletonPngPath.LastIndexOf("/")), true);
                skeletonJsonFile.CopyTo(AimPath + skeletonJsonPath.Substring(skeletonJsonPath.LastIndexOf("/")), true);
                skeletonTxtFile.CopyTo(AimPath + skeletonTxtPath.Substring(skeletonTxtPath.LastIndexOf("/")), true);
            }
            else
            {
                LuaInterface.Debugger.LogError("Files not Exist,check and try again");
                return;
            }
            AssetDatabase.Refresh();
            string skeletonPath = "Assets/YX_app_4/XY_Animations/hall/forOEM" + skeletonPngPath.Substring(skeletonPngPath.LastIndexOf("/")).Split('.')[0] + "_SkeletonData.asset";
            SkeletonDataAsset skeletonAsset = AssetDatabase.LoadAssetAtPath(skeletonPath, typeof(SkeletonDataAsset)) as SkeletonDataAsset;
            string halluiPrefabPath = "Assets/Res_XYHY/app_4/ui/hall_ui/hall_ui.prefab";
            GameObject hall_ui = AssetDatabase.LoadAssetAtPath(halluiPrefabPath, typeof(GameObject)) as GameObject;
            GameObject hall = PrefabUtility.InstantiatePrefab(hall_ui) as GameObject;
            GameObject leftTex = GameObject.FindGameObjectWithTag("dt_1");
            GameObject rightTex = GameObject.FindGameObjectWithTag("dt_2");
            leftTex.GetComponent<SkeletonAnimation>().skeletonDataAsset = skeletonAsset;
            rightTex.GetComponent<SkeletonAnimation>().skeletonDataAsset = skeletonAsset;
            object[] targets = new object[2];
            targets[0] = leftTex.GetComponent<SkeletonRenderer>();
            targets[1] = rightTex.GetComponent<SkeletonRenderer>();
            reloadButtonEnable(targets);
            GameObject prefabpre = PrefabUtility.CreatePrefab(halluiPrefabPath, hall);
            PrefabUtility.ReplacePrefab(hall, prefabpre, ReplacePrefabOptions.ConnectToPrefab);
            DestroyImmediate(hall);
            AssetDatabase.Refresh();
        }
        LuaInterface.Debugger.Log("Set Successfully");
    }
    public void reloadButtonEnable(object[] targets)
    {
        foreach (var c in targets)
        {
            var component = c as SkeletonRenderer;
            if (component.skeletonDataAsset != null)
            {
                foreach (AtlasAsset aa in component.skeletonDataAsset.atlasAssets)
                {
                    if (aa != null)
                        aa.Clear();
                }
                component.skeletonDataAsset.Clear();
            }
            component.Initialize(true);
        }
        AssetDatabase.Refresh();
    }

    void InitResListDrawer()
    {
        Res_XYHY_list = new ReorderableList(resXYHYLst, typeof(string));
        Res_XYHY_list.drawElementCallback = OnResLstElementGUI;
        Res_XYHY_list.drawHeaderCallback = OnResLstHeaderGUI;
        Res_XYHY_list.draggable = true;
        Res_XYHY_list.elementHeight = 22;
        Res_XYHY_list.onAddCallback = (list) => ResLstAdd();
    }

    void InitAssetsListDrawer()
    {
        Assets_list = new ReorderableList(assetsLst, typeof(string));
        Assets_list.drawElementCallback = OnAssetsLstElementGUI;
        Assets_list.drawHeaderCallback = OnAssetsLstHeaderGUI;
        Assets_list.draggable = true;
        Assets_list.elementHeight = 22;
        Assets_list.onAddCallback = (list) => AssetsLstAdd();
    }

    void OnAssetsLstElementGUI(Rect rect, int index, bool isactive, bool isfocused)
    {
        const float GAP = 5;
        rect.y++;

        Rect r = rect;
        r.width = 16;
        r.height = 18;

        r.xMin = r.xMax + GAP;
        r.xMax = rect.xMax - 100;
        GUI.enabled = false;
        assetsLst[index] = GUI.TextField(r, assetsLst[index]);
        GUI.enabled = true;

        r.xMin = rect.xMax - 50 - GAP;
        r.width = 50;
        if (GUI.Button(r, "Select"))
        {
            var path = SelectFolder();
            if (path != null)
                assetsLst[index] = path;
        }
    }

    void OnResLstElementGUI(Rect rect, int index, bool isactive, bool isfocused)
    {
        const float GAP = 5;        
        rect.y++;

        Rect r = rect;
        r.width = 16;
        r.height = 18;

        r.xMin = r.xMax + GAP;
        r.xMax = rect.xMax - 100;
        GUI.enabled = false;
        resXYHYLst[index] = GUI.TextField(r, resXYHYLst[index]);
        GUI.enabled = true;

        r.xMin = rect.xMax - 50 - GAP;
        r.width = 50;
        if (GUI.Button(r, "Select"))
        {
            var path = SelectFolder();
            if (path != null)
                resXYHYLst[index] = path;
        }
    }

    void OnAssetsLstHeaderGUI(Rect rect)
    {
        EditorGUI.LabelField(rect, "Assets Edit");
    }

    void OnResLstHeaderGUI(Rect rect)
    {
        EditorGUI.LabelField(rect, "Res_XYHY Edit");
    }

    void AssetsLstAdd()
    {
        assetsLst.Add("");
    }

    void ResLstAdd()
    {
        resXYHYLst.Add("");
    }

    string SelectFolder()
    {
        string selectedPath = EditorUtility.OpenFolderPanel("Path", resRootPath, "");
        return selectedPath;
    }
    string SelectFile(string tips)
    {
        
        string selectedPath = EditorUtility.OpenFilePanel(tips + " Path", resRootPathSelected, "");
        if (!string.IsNullOrEmpty(selectedPath))
        {
            string temp = selectedPath.Substring(selectedPath.LastIndexOf("/"));
            resRootPathSelected = selectedPath.Replace(temp, "");
        }
        return selectedPath; 
    }

    string SaveFile()
    {
        string savedPath = EditorUtility.SaveFilePanel("OEM Config", resRootPath, "default", "txt");
        return savedPath;
    }
    void WriteDataToDic()
    {
        Dic_Value.Clear();
        Dic_Value.Add("gameName", gameName.ToString());
        Dic_Value.Add("packageName",packageName.ToString());
        Dic_Value.Add("versionNum", versionNum.ToString());
        Dic_Value.Add("iconPath", iconPath.ToString());
        Dic_Value.Add("defaulticonPath", defaulticonPath.ToString());
        Dic_Value.Add("loginBgPath", loginBgPath.ToString());
        Dic_Value.Add("loginLogoPath", loginLogoPath.ToString());
        Dic_Value.Add("hallBgPath", hallBgPath.ToString());
        Dic_Value.Add("hallLogoPath", hallLogoPath.ToString());
        Dic_Value.Add("shareBgPath", shareBgPath.ToString());
        Dic_Value.Add("skeletonPngPath", skeletonPngPath.ToString());
        Dic_Value.Add("skeletonJsonPath", skeletonJsonPath.ToString());
        Dic_Value.Add("skeletonTxtPath", skeletonTxtPath.ToString());
    }
    void ReadDataFromDic()
    {
        gameName = Dic_Value["gameName"];
        packageName = Dic_Value["packageName"];
        versionNum = Dic_Value["versionNum"];
        iconPath = Dic_Value["iconPath"];
        defaulticonPath = Dic_Value["defaulticonPath"];
        loginBgPath = Dic_Value["loginBgPath"];
        loginLogoPath = Dic_Value["loginLogoPath"];
        hallBgPath = Dic_Value["hallBgPath"];
        hallLogoPath = Dic_Value["hallLogoPath"];
        shareBgPath = Dic_Value["shareBgPath"];
        skeletonPngPath = Dic_Value["skeletonPngPath"];
        skeletonJsonPath = Dic_Value["skeletonJsonPath"];
        skeletonTxtPath = Dic_Value["skeletonTxtPath"];
    }
    /// <summary>
    /// 从全路径截取资源所在/文件夹/文件名
    /// </summary>
    /// <param name="sPath"></param>
    /// <returns>/folder/fileName</returns>
    string  GetFolderFileName(string sPath)
    {
        string path2 = sPath.Substring(sPath.LastIndexOf("/"));
        string pathTemp1 = sPath.Replace(path2, "");
        string path1 = pathTemp1.Substring(pathTemp1.LastIndexOf("/"));
        return (path1 + path2);
    }
    string Get2FolderFileName(string sPath)
    {
        string path3= sPath.Substring(sPath.LastIndexOf("/"));
        string pathTemp2= sPath.Replace(path3, "");
        string path2 = pathTemp2.Substring(pathTemp2.LastIndexOf("/"));
        string pathTemp1 = pathTemp2.Replace(path2, "");
        string path1 = pathTemp1.Substring(pathTemp1.LastIndexOf("/"));
        return (path1 + path2 + path3);
    }
}
