using System;
using System.IO;
using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;

public class GenerateAlphaTextureEditor : EditorWindow
{
    public class EtcAlphaInfo
    {
        public Texture2D SourceTexture;
        public Texture2D AlphaTexture;
        public string SourcePath;
        public string AlphaPath;
        public TextureImporter SoureTextureImporter;
        public TextureImporter AlphaTextureImporter;
        public int AlphaFormat;
    }

    private EtcAlphaInfo[] _etcAlphaInfos;
    private static Texture2D _arrowTexture2D;
    private string[] _alphaFormats = new string[] { "Alpha using R channel", "Alpha using G channel", "Alpha using B channel" };
    private readonly Rect _textRect=new Rect(85,45,250,50);
	// Use this for initialization
    [MenuItem("Tools/J3Tech/ETC+Alpha/GenerateAlphaTexture")]
    private static void Init()
    {
        GenerateAlphaTextureEditor textureSettingEditor = GetWindow<GenerateAlphaTextureEditor>(false);
        textureSettingEditor.position=new Rect(Screen.currentResolution.width/2-200,Screen.currentResolution.height/2-70,400,140);
        textureSettingEditor.title = "Create Alpha";
        textureSettingEditor.minSize=new Vector2(420,140);
		textureSettingEditor.maxSize=new Vector2(425,1000);
    }

    private void OnFocus()
    {
        OnSelectionChange();
    }

    // Update is called once per frame
    void OnSelectionChange()
	{
        Object[] objects = Selection.GetFiltered(typeof(Texture2D), SelectionMode.Assets);
        if (objects.Length > 0)
        {
            _etcAlphaInfos=new EtcAlphaInfo[objects.Length];
            for (int i = 0; i < _etcAlphaInfos.Length; ++i)
            {
                _etcAlphaInfos[i]=new EtcAlphaInfo();
                _etcAlphaInfos[i].SourceTexture = objects[i] as Texture2D;
                _etcAlphaInfos[i].SourcePath = AssetDatabase.GetAssetPath(objects[i]);
                _etcAlphaInfos[i].SoureTextureImporter = AssetImporter.GetAtPath(_etcAlphaInfos[i].SourcePath) as TextureImporter;
                _etcAlphaInfos[i].AlphaPath =Path.GetDirectoryName(_etcAlphaInfos[i].SourcePath)+"/"+ Path.GetFileNameWithoutExtension(_etcAlphaInfos[i].SourcePath) +"_Alpha.png";
                if (File.Exists(Application.dataPath.Substring(0, Application.dataPath.Length-6) + _etcAlphaInfos[i].AlphaPath))
                {
                    _etcAlphaInfos[i].AlphaTexture = AssetDatabase.LoadAssetAtPath(_etcAlphaInfos[i].AlphaPath, typeof(Texture)) as Texture2D;                
                    _etcAlphaInfos[i].AlphaTextureImporter = AssetImporter.GetAtPath(_etcAlphaInfos[i].AlphaPath) as TextureImporter;
                    _etcAlphaInfos[i].AlphaFormat = -1;

                    string[] label=AssetDatabase.GetLabels(_etcAlphaInfos[i].AlphaTexture);

                    if (label != null && label.Length > 0)
                    {
                        if (label[0].Contains("ETC+Alpha using R channel"))
                        {
                            _etcAlphaInfos[i].AlphaFormat = 0;
                        }
                        else if (label[0].Contains("ETC+Alpha using G channel"))
                        {
                            _etcAlphaInfos[i].AlphaFormat = 1;
                        }
                        else
                        {
                            _etcAlphaInfos[i].AlphaFormat = 2;
                        }
                    }
                }
            }
            Repaint();
        }        
	}

    private void OnGUI()
    {
        if (_etcAlphaInfos != null && _etcAlphaInfos.Length>0)
        {
            int y = 10;
            for (int i = 0; i < _etcAlphaInfos.Length; ++i)
            {            
                DrawGrid.Draw(new Rect(10, y, 100, 100));
                GUI.DrawTexture(new Rect(10, y, 100, 100), _etcAlphaInfos[i].SourceTexture);
                GUI.Label(new Rect(10, y + 100, 100, 20), Path.GetFileName(_etcAlphaInfos[i].SourcePath));
                DrawGrid.Draw(new Rect(160, y, 100, 100));
                if (_etcAlphaInfos[i].AlphaTexture != null)
                {                   
                    GUI.DrawTexture(new Rect(160, y, 100, 100), _etcAlphaInfos[i].AlphaTexture);
                    GUI.Label(new Rect(160, y + 100, 100, 20), Path.GetFileName(_etcAlphaInfos[i].AlphaPath));
                }
                if (_arrowTexture2D == null)
                {
                    _arrowTexture2D = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/ETC+Alpha/Editor/Texture/arrow.png");
                }
                GUI.DrawTexture(new Rect(120, y + (100 - _arrowTexture2D.height)/2, _arrowTexture2D.width, _arrowTexture2D.height), _arrowTexture2D);
                GUI.Label(new Rect(270, y+20, 120, 20), "Format");
                _etcAlphaInfos[i].AlphaFormat = EditorGUI.Popup(new Rect(270, y + 40, 140, 20), "", _etcAlphaInfos[i].AlphaFormat, _alphaFormats);

                if (GUI.Button(new Rect(270, y + 60, 140, 20), "Generate"))
                {
                    try
                    {
						_etcAlphaInfos[i].SoureTextureImporter.isReadable=true;
						_etcAlphaInfos[i].SoureTextureImporter.SetPlatformTextureSettings("Android",2048,TextureImporterFormat.RGBA32);
						AssetDatabase.ImportAsset(_etcAlphaInfos[i].SourcePath);

                        _etcAlphaInfos[i].AlphaTexture = new Texture2D(_etcAlphaInfos[i].SourceTexture.width,
                            _etcAlphaInfos[i].SourceTexture.height, TextureFormat.RGBA32, false);
                        Color32[] color32S = _etcAlphaInfos[i].AlphaTexture.GetPixels32();
                        Color32[] srcColor32S = _etcAlphaInfos[i].SourceTexture.GetPixels32();

                        if (_etcAlphaInfos[i].AlphaFormat == 0)
                        {
                            for (int n = 0; n < color32S.Length; ++n)
                            {
                                color32S[n] = new Color32(srcColor32S[n].a, 0, 0, 0);
                            }                            
                        }
                        else if (_etcAlphaInfos[i].AlphaFormat == 1)
                        {
                            for (int n = 0; n < color32S.Length; ++n)
                            {
                                color32S[n] = new Color32(0, srcColor32S[n].a, 0, 0);
                            }
                        }
                        else
                        {
                            for (int n = 0; n < color32S.Length; ++n)
                            {
                                color32S[n] = new Color32(0, 0, srcColor32S[n].a, 0);
                            }
                        }
                        _etcAlphaInfos[i].AlphaTexture.SetPixels32(color32S);
                        _etcAlphaInfos[i].AlphaTexture.Apply(false);
                        string fileName = Application.dataPath.Substring(0, Application.dataPath.Length - 6) +
                                          _etcAlphaInfos[i].AlphaPath;
                        File.WriteAllBytes(fileName, _etcAlphaInfos[i].AlphaTexture.EncodeToPNG());
                        while (!File.Exists(fileName)) ;
                        AssetDatabase.Refresh(ImportAssetOptions.Default);
                        _etcAlphaInfos[i].AlphaTextureImporter =
                            AssetImporter.GetAtPath(_etcAlphaInfos[i].AlphaPath) as TextureImporter;
                        while (_etcAlphaInfos[i].AlphaTextureImporter == null)
                        {
                            _etcAlphaInfos[i].AlphaTextureImporter =
                                AssetImporter.GetAtPath(_etcAlphaInfos[i].AlphaPath) as TextureImporter;
                        }
                        _etcAlphaInfos[i].AlphaTextureImporter.textureType = TextureImporterType.Advanced;
                        _etcAlphaInfos[i].AlphaTextureImporter.SetPlatformTextureSettings("Android", 2048,TextureImporterFormat.ETC_RGB4);                      
						_etcAlphaInfos[i].SoureTextureImporter.SetPlatformTextureSettings("Android",2048,TextureImporterFormat.ETC_RGB4);
                        
						AssetDatabase.ImportAsset(_etcAlphaInfos[i].SourcePath);
						AssetDatabase.ImportAsset(_etcAlphaInfos[i].AlphaPath);

                        _etcAlphaInfos[i].AlphaTexture = AssetDatabase.LoadAssetAtPath(_etcAlphaInfos[i].AlphaPath, typeof(Texture)) as Texture2D;

                        if (_etcAlphaInfos[i].AlphaFormat == 0)
                        {                            
                            AssetDatabase.SetLabels(_etcAlphaInfos[i].AlphaTexture, new string[] { "ETC+Alpha using R channel for " + Path.GetFileName(_etcAlphaInfos[i].SourcePath) });
                        }
                        else if (_etcAlphaInfos[i].AlphaFormat == 1)
                        {
                            AssetDatabase.SetLabels(_etcAlphaInfos[i].AlphaTexture, new string[] { "ETC+Alpha using G channel for " + Path.GetFileName(_etcAlphaInfos[i].SourcePath) });
                        }
                        else
                        {
                            AssetDatabase.SetLabels(_etcAlphaInfos[i].AlphaTexture, new string[] { "ETC+Alpha using B channel for " + Path.GetFileName(_etcAlphaInfos[i].SourcePath) });
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.LogWarning(e);
                    }
                }    
                y += 120;              
            }
        }
        else
        {
            GUI.Label(_textRect, "Please select texture in project view");
        }
    }

    private void OnDesroy()
    {
        DrawGrid.Done();
    }
}
