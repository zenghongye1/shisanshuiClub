using System;
using System.IO;
using System.Linq;
using UnityEngine;
using System.Collections;
using UnityEditor;
using Object = UnityEngine.Object;

public class CombineAlphaTextureEditor : EditorWindow 
{
    private static Texture2D _combineNavigationTexture;

    private readonly Rect _rectR = new Rect(10, 30, 100, 100);
    private readonly Rect _rectG = new Rect(10, 140, 100, 100);
    private readonly Rect _rectB = new Rect(10, 250, 100, 100);
    private readonly Rect _rectNavigation = new Rect(110, 60, 160, 260);
    private readonly Rect _rectCombine = new Rect(280, 140, 100, 100);
    private Texture2D _textureR;
    private Texture2D _textureG;
    private Texture2D _textureB;
    private Texture2D _textureCombine;
    [MenuItem("Tools/J3Tech/ETC+Alpha/CombineAlphaTexture")]
    private static void Init()
    {
        CombineAlphaTextureEditor textureSettingEditor = GetWindow<CombineAlphaTextureEditor>(false);
        textureSettingEditor.position = new Rect(Screen.currentResolution.width / 2 - 200, Screen.currentResolution.height / 2 - 70, 400, 140);
        textureSettingEditor.titleContent = new GUIContent("Combine Tex");
        textureSettingEditor.minSize = new Vector2(390, 360);
        textureSettingEditor.maxSize = new Vector2(395, 365);
    }

    private void OnGUI()
    {
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Clear", EditorStyles.toolbarButton, GUILayout.Width(80)))
        {
            _textureR = null;
            _textureG = null;
            _textureB = null;
        }
        GUILayout.Label("", EditorStyles.toolbarButton);
        if (GUILayout.Button("Combine", EditorStyles.toolbarButton,GUILayout.Width(80)))
        {
            #region RGB

            if (_textureR != null && _textureG != null && _textureB != null)
            {
                string filename = EditorUtility.SaveFilePanel("Combine Texture", Application.dataPath,
                    "Combine_Texture_RGB_Channel.png", "png");
                if (!String.IsNullOrEmpty(filename) && filename.Contains(Application.dataPath))
                {
                    string assetName = filename.Replace(Application.dataPath, "Assets");

                    string pathR = AssetDatabase.GetAssetPath(_textureR);
                    string pathG = AssetDatabase.GetAssetPath(_textureG);
                    string pathB = AssetDatabase.GetAssetPath(_textureB);
                    TextureImporter textureImporterR = AssetImporter.GetAtPath(pathR) as TextureImporter;
                    TextureImporter textureImporterG = AssetImporter.GetAtPath(pathG) as TextureImporter;
                    TextureImporter textureImporterB = AssetImporter.GetAtPath(pathB) as TextureImporter;
                    textureImporterR.isReadable = true;
                    textureImporterR.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGBA32);
                    AssetDatabase.ImportAsset(pathR);
                    textureImporterG.isReadable = true;
                    textureImporterG.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGBA32);
                    AssetDatabase.ImportAsset(pathG);
                    textureImporterB.isReadable = true;
                    textureImporterB.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGBA32);
                    AssetDatabase.ImportAsset(pathB);

                    int maxWidth = Mathf.Max(_textureR.width, _textureG.width, _textureB.width);
                    int maxHeigth = Mathf.Max(_textureR.height, _textureG.height, _textureB.height);
                    _textureCombine = new Texture2D(maxWidth, maxHeigth,TextureFormat.RGBA32,false);
                
                    Color32[] rColor32S = _textureR.GetPixels32();
                    Color32[] gColor32S = _textureG.GetPixels32();
                    Color32[] bColor32S = _textureB.GetPixels32();

                    if (_textureR.width != maxWidth || _textureR.height != maxHeigth)
                    {
                        float com2Rw = (float)_textureR.width / (float)maxWidth;
                        float com2Rh = (float)_textureR.height / (float)maxHeigth;
                        Texture2D newTextureR = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);
                        for (int x = 0; x < maxWidth; ++x)
                        {
                            int xR = Mathf.Min(Mathf.RoundToInt(x * com2Rw), _textureR.width);
                            for (int y = 0; y < maxHeigth; ++y)
                            {
                                int yR = Mathf.Min(Mathf.RoundToInt(y * com2Rh), _textureR.height);
                                newTextureR.SetPixel(x, y, _textureR.GetPixel(xR, yR));
                            }
                        }
                        newTextureR.Apply();
                        rColor32S = newTextureR.GetPixels32();
                    }

                    if (_textureG.width != maxWidth || _textureG.height != maxHeigth)
                    {
                        float com2Gw = (float)_textureG.width / (float)maxWidth;
                        float com2Gh = (float)_textureG.height / (float)maxHeigth;
                        Texture2D newTextureG = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);
                        for (int x = 0; x < maxWidth; ++x)
                        {
                            int xG = Mathf.Min(Mathf.RoundToInt(x * com2Gw), _textureG.width);
                            for (int y = 0; y < maxHeigth; ++y)
                            {
                                int yG = Mathf.Min(Mathf.RoundToInt(y * com2Gh), _textureG.height);
                                newTextureG.SetPixel(x, y, _textureG.GetPixel(xG, yG));
                            }
                        }
                        newTextureG.Apply();
                        gColor32S = newTextureG.GetPixels32();
                    }

                    if (_textureB.width != maxWidth || _textureB.height != maxHeigth)
                    {
                        float com2Bw = (float)_textureB.width / (float)maxWidth;
                        float com2Bh = (float)_textureB.height / (float)maxHeigth;
                        Texture2D newTextureB = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);
                        for (int x = 0; x < maxWidth; ++x)
                        {
                            int xB = Mathf.Min(Mathf.RoundToInt(x * com2Bw), _textureB.width);
                            for (int y = 0; y < maxHeigth; ++y)
                            {
                                int yB = Mathf.Min(Mathf.RoundToInt(y * com2Bh), _textureB.height);
                                newTextureB.SetPixel(x, y, _textureB.GetPixel(xB, yB));
                            }
                        }
                        newTextureB.Apply();
                        bColor32S = newTextureB.GetPixels32();
                    }

                    Color32[] comColor32S = new Color32[maxWidth*maxHeigth];

                    for (int i = 0,imax=comColor32S.Length; i < imax; ++i)
                    {
                        comColor32S[i] = new Color32(rColor32S[i].r,gColor32S[i].g,bColor32S[i].b,0);
                    }

                    _textureCombine.SetPixels32(comColor32S);
                    _textureCombine.Apply(false);
                    File.WriteAllBytes(filename, _textureCombine.EncodeToPNG());
                    while (!File.Exists(filename)) ;
                    AssetDatabase.Refresh(ImportAssetOptions.Default);
                    TextureImporter textureImporter =
                        AssetImporter.GetAtPath(assetName) as TextureImporter;
                    while (textureImporter == null)
                    {
                        textureImporter = AssetImporter.GetAtPath(assetName) as TextureImporter;
                    }
                    textureImporter.textureType = TextureImporterType.Advanced;
                    textureImporter.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGB16);
                    AssetDatabase.ImportAsset(assetName);
                    _textureCombine = AssetDatabase.LoadAssetAtPath(assetName, typeof(Texture)) as Texture2D;
                    AssetDatabase.SetLabels(_textureCombine, new string[]
                    {
                        "ETC+Alpha combine texture for RGB channel"
                    });

                    textureImporterR.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(pathR);
                    textureImporterG.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(pathG);
                    textureImporterB.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(pathB);
                }
            }

            #endregion

            #region RG

            else if (_textureR != null && _textureG != null)
            {
                string filename = EditorUtility.SaveFilePanel("Combine Texture", Application.dataPath,
                    "Combine_Texture_RG_Channel.png", "png");
                if (!String.IsNullOrEmpty(filename) && filename.Contains(Application.dataPath))
                {
                    string assetName = filename.Replace(Application.dataPath, "Assets");

                    string pathR = AssetDatabase.GetAssetPath(_textureR);
                    string pathG = AssetDatabase.GetAssetPath(_textureG);

                    TextureImporter textureImporterR = AssetImporter.GetAtPath(pathR) as TextureImporter;
                    TextureImporter textureImporterG = AssetImporter.GetAtPath(pathG) as TextureImporter;

                    textureImporterR.isReadable = true;
                    textureImporterR.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGBA32);
                    AssetDatabase.ImportAsset(pathR);
                    textureImporterG.isReadable = true;
                    textureImporterG.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGBA32);
                    AssetDatabase.ImportAsset(pathG);

                    int maxWidth = Mathf.Max(_textureR.width, _textureG.width);
                    int maxHeigth = Mathf.Max(_textureR.height, _textureG.height);
                    _textureCombine = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);

                    Color32[] rColor32S = _textureR.GetPixels32();
                    Color32[] gColor32S = _textureG.GetPixels32();

                    if (_textureR.width != maxWidth || _textureR.height != maxHeigth)
                    {
                        float com2Rw = (float)_textureR.width / (float)maxWidth;
                        float com2Rh = (float)_textureR.height / (float)maxHeigth;
                        Texture2D newTextureR = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);
                        for (int x = 0; x < maxWidth; ++x)
                        {
                            int xR = Mathf.Min(Mathf.RoundToInt(x * com2Rw), _textureR.width);
                            for (int y = 0; y < maxHeigth; ++y)
                            {
                                int yR = Mathf.Min(Mathf.RoundToInt(y * com2Rh), _textureR.height);
                                newTextureR.SetPixel(x, y, _textureR.GetPixel(xR, yR));
                            }
                        }
                        newTextureR.Apply();
                        rColor32S = newTextureR.GetPixels32();
                    }

                    if (_textureG.width != maxWidth || _textureG.height != maxHeigth)
                    {
                        float com2Gw = (float)_textureG.width / (float)maxWidth;
                        float com2Gh = (float)_textureG.height / (float)maxHeigth;
                        Texture2D newTextureG = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);
                        for (int x = 0; x < maxWidth; ++x)
                        {
                            int xG = Mathf.Min(Mathf.RoundToInt(x * com2Gw), _textureG.width);
                            for (int y = 0; y < maxHeigth; ++y)
                            {
                                int yG = Mathf.Min(Mathf.RoundToInt(y * com2Gh), _textureG.height);
                                newTextureG.SetPixel(x, y, _textureG.GetPixel(xG, yG));
                            }
                        }
                        newTextureG.Apply();
                        gColor32S = newTextureG.GetPixels32();
                    }

                    Color32[] comColor32S = new Color32[maxWidth * maxHeigth];

                    for (int i = 0, imax = comColor32S.Length; i < imax; ++i)
                    {
                        comColor32S[i] = new Color32(rColor32S[i].r, gColor32S[i].g,0, 0);
                    }

                    _textureCombine.SetPixels32(comColor32S);
                    _textureCombine.Apply(false);
                    File.WriteAllBytes(filename, _textureCombine.EncodeToPNG());
                    while (!File.Exists(filename)) ;
                    AssetDatabase.Refresh(ImportAssetOptions.Default);
                    TextureImporter textureImporter =
                        AssetImporter.GetAtPath(assetName) as TextureImporter;
                    while (textureImporter == null)
                    {
                        textureImporter = AssetImporter.GetAtPath(assetName) as TextureImporter;
                    }
                    textureImporter.textureType = TextureImporterType.Advanced;
                    textureImporter.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(assetName);
                    _textureCombine = AssetDatabase.LoadAssetAtPath(assetName, typeof(Texture)) as Texture2D;
                    AssetDatabase.SetLabels(_textureCombine, new string[]
                    {
                        "ETC+Alpha combine texture for RG channel"
                    });

                    textureImporterR.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(pathR);
                    textureImporterG.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(pathG);
                }
            }

            #endregion

            #region GB

            else if (_textureG != null && _textureB != null)
            {
                string filename = EditorUtility.SaveFilePanel("Combine Texture", Application.dataPath,
                    "Combine_Texture_GB_Channel.png", "png");
                if (!String.IsNullOrEmpty(filename) && filename.Contains(Application.dataPath))
                {
                    Repaint();
                    string assetName = filename.Replace(Application.dataPath, "Assets");

                    string pathG = AssetDatabase.GetAssetPath(_textureG);
                    string pathB = AssetDatabase.GetAssetPath(_textureB);
                    TextureImporter textureImporterG = AssetImporter.GetAtPath(pathG) as TextureImporter;
                    TextureImporter textureImporterB = AssetImporter.GetAtPath(pathB) as TextureImporter;

                    textureImporterG.isReadable = true;
                    textureImporterG.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGBA32);
                    AssetDatabase.ImportAsset(pathG);
                    textureImporterB.isReadable = true;
                    textureImporterB.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGBA32);
                    AssetDatabase.ImportAsset(pathB);

                    int maxWidth = Mathf.Max(_textureG.width, _textureB.width);
                    int maxHeigth = Mathf.Max(_textureG.height, _textureB.height);
                    _textureCombine = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);

                    Color32[] gColor32S = _textureG.GetPixels32();
                    Color32[] bColor32S = _textureB.GetPixels32();

                    if (_textureG.width != maxWidth || _textureG.height != maxHeigth)
                    {
                        float com2Gw = (float)_textureG.width / (float)maxWidth;
                        float com2Gh = (float)_textureG.height / (float)maxHeigth;
                        Texture2D newTextureG = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);
                        for (int x = 0; x < maxWidth; ++x)
                        {
                            int xG = Mathf.Min(Mathf.RoundToInt(x * com2Gw), _textureG.width);
                            for (int y = 0; y < maxHeigth; ++y)
                            {
                                int yG = Mathf.Min(Mathf.RoundToInt(y * com2Gh), _textureG.height);
                                newTextureG.SetPixel(x, y, _textureG.GetPixel(xG, yG));
                            }
                        }
                        newTextureG.Apply();
                        gColor32S = newTextureG.GetPixels32();
                    }

                    if (_textureB.width != maxWidth || _textureB.height != maxHeigth)
                    {
                        float com2Bw = (float)_textureB.width / (float)maxWidth;
                        float com2Bh = (float)_textureB.height / (float)maxHeigth;
                        Texture2D newTextureB = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);
                        for (int x = 0; x < maxWidth; ++x)
                        {
                            int xB = Mathf.Min(Mathf.RoundToInt(x * com2Bw), _textureB.width);
                            for (int y = 0; y < maxHeigth; ++y)
                            {
                                int yB = Mathf.Min(Mathf.RoundToInt(y * com2Bh), _textureB.height);
                                newTextureB.SetPixel(x, y, _textureB.GetPixel(xB, yB));
                            }
                        }
                        newTextureB.Apply();
                        bColor32S = newTextureB.GetPixels32();
                    }

                    Color32[] comColor32S = new Color32[maxWidth * maxHeigth];

                    for (int i = 0, imax = comColor32S.Length; i < imax; ++i)
                    {
                        comColor32S[i] = new Color32(0, gColor32S[i].g, bColor32S[i].b, 0);
                    }

                    _textureCombine.SetPixels32(comColor32S);
                    _textureCombine.Apply(false);
                    File.WriteAllBytes(filename, _textureCombine.EncodeToPNG());
                    while (!File.Exists(filename)) ;
                    AssetDatabase.Refresh(ImportAssetOptions.Default);
                    TextureImporter textureImporter =
                        AssetImporter.GetAtPath(assetName) as TextureImporter;
                    while (textureImporter == null)
                    {
                        textureImporter = AssetImporter.GetAtPath(assetName) as TextureImporter;
                    }
                    textureImporter.textureType = TextureImporterType.Advanced;
                    textureImporter.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(assetName);
                    _textureCombine = AssetDatabase.LoadAssetAtPath(assetName, typeof(Texture)) as Texture2D;
                    AssetDatabase.SetLabels(_textureCombine, new string[]
                    {
                        "ETC+Alpha combine texture for GB channel"
                    });

                    textureImporterG.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(pathG);
                    textureImporterB.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(pathB);
                }
            }

            #endregion

            #region RB

            else if (_textureR != null && _textureB != null)
            {
                string filename = EditorUtility.SaveFilePanel("Combine Texture", Application.dataPath,
                    "Combine_Texture_RB_Channel.png", "png");
                if (!String.IsNullOrEmpty(filename) && filename.Contains(Application.dataPath))
                {
                    string assetName = filename.Replace(Application.dataPath, "Assets");

                    string pathR = AssetDatabase.GetAssetPath(_textureR);
                    string pathB = AssetDatabase.GetAssetPath(_textureB);
                    TextureImporter textureImporterR = AssetImporter.GetAtPath(pathR) as TextureImporter;
                    TextureImporter textureImporterB = AssetImporter.GetAtPath(pathB) as TextureImporter;
                    textureImporterR.isReadable = true;
                    textureImporterR.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGBA32);
                    AssetDatabase.ImportAsset(pathR);
                    textureImporterB.isReadable = true;
                    textureImporterB.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.RGBA32);
                    AssetDatabase.ImportAsset(pathB);

                    int maxWidth = Mathf.Max(_textureR.width, _textureB.width);
                    int maxHeigth = Mathf.Max(_textureR.height, _textureB.height);
                    _textureCombine = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);

                    Color32[] rColor32S = _textureR.GetPixels32();
                    Color32[] bColor32S = _textureB.GetPixels32();

                    if (_textureR.width != maxWidth || _textureR.height != maxHeigth)
                    {
                        float com2Rw = (float)_textureR.width / (float)maxWidth;
                        float com2Rh = (float)_textureR.height / (float)maxHeigth;
                        Texture2D newTextureR = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);
                        for (int x = 0; x < maxWidth; ++x)
                        {
                            int xR = Mathf.Min(Mathf.RoundToInt(x * com2Rw), _textureR.width);
                            for (int y = 0; y < maxHeigth; ++y)
                            {
                                int yR = Mathf.Min(Mathf.RoundToInt(y * com2Rh), _textureR.height);
                                newTextureR.SetPixel(x, y, _textureR.GetPixel(xR, yR));
                            }
                        }
                        newTextureR.Apply();
                        rColor32S = newTextureR.GetPixels32();
                    }

                    if (_textureB.width != maxWidth || _textureB.height != maxHeigth)
                    {
                        float com2Bw = (float)_textureB.width / (float)maxWidth;
                        float com2Bh = (float)_textureB.height / (float)maxHeigth;
                        Texture2D newTextureB = new Texture2D(maxWidth, maxHeigth, TextureFormat.RGBA32, false);
                        for (int x = 0; x < maxWidth; ++x)
                        {
                            int xB = Mathf.Min(Mathf.RoundToInt(x * com2Bw), _textureB.width);
                            for (int y = 0; y < maxHeigth; ++y)
                            {
                                int yB = Mathf.Min(Mathf.RoundToInt(y * com2Bh), _textureB.height);
                                newTextureB.SetPixel(x, y, _textureB.GetPixel(xB, yB));
                            }
                        }
                        newTextureB.Apply();
                        bColor32S = newTextureB.GetPixels32();
                    }

                    Color32[] comColor32S = new Color32[maxWidth * maxHeigth];

                    for (int i = 0, imax = comColor32S.Length; i < imax; ++i)
                    {
                        comColor32S[i] = new Color32(rColor32S[i].r, 0, bColor32S[i].b, 0);
                    }

                    _textureCombine.SetPixels32(comColor32S);
                    _textureCombine.Apply(false);
                    File.WriteAllBytes(filename, _textureCombine.EncodeToPNG());
                    while (!File.Exists(filename)) ;
                    AssetDatabase.Refresh(ImportAssetOptions.Default);
                    TextureImporter textureImporter =
                        AssetImporter.GetAtPath(assetName) as TextureImporter;
                    while (textureImporter == null)
                    {
                        textureImporter = AssetImporter.GetAtPath(assetName) as TextureImporter;
                    }
                    textureImporter.textureType = TextureImporterType.Advanced;
                    textureImporter.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(assetName);
                    _textureCombine = AssetDatabase.LoadAssetAtPath(assetName, typeof(Texture)) as Texture2D;
                    AssetDatabase.SetLabels(_textureCombine, new string[]
                    {
                        "ETC+Alpha combine texture for RB channel"
                    });

                    textureImporterR.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(pathR);
                    textureImporterB.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4);
                    AssetDatabase.ImportAsset(pathB);
                }
            }

            #endregion
        }
        GUILayout.EndHorizontal();
        DrawGrid.Draw(_rectR);
        DrawGrid.Draw(_rectG);
        DrawGrid.Draw(_rectB);
        if (_textureR!=null)
            GUI.DrawTexture(_rectR, _textureR);
        if (_textureG != null)
            GUI.DrawTexture(_rectG, _textureG);
        if (_textureB != null)
            GUI.DrawTexture(_rectB, _textureB);
        if (_combineNavigationTexture == null)
        {
            _combineNavigationTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/ETC+Alpha/Editor/Texture/combine.png");
        }
        GUI.DrawTexture(_rectNavigation, _combineNavigationTexture);

        DrawGrid.Draw(_rectCombine);
        if (_textureCombine != null)
            GUI.DrawTexture(_rectCombine, _textureCombine);

        Event curEvent = Event.current;
        if (_rectR.Contains(curEvent.mousePosition))
        {
            if (curEvent.type == EventType.DragPerform)
            {
                foreach (var v in DragAndDrop.objectReferences)
                {
                    var type = v.GetType();
                    if (type == typeof(Texture2D))
                    {
                        _textureR = v as Texture2D;
                        break;
                    }
                }
            }
            else if (curEvent.type == EventType.DragUpdated)
            {
                if (IsValidDragPayload(0))
                    DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                else
                    DragAndDrop.visualMode = DragAndDropVisualMode.None;
            }
        }
        else if (_rectG.Contains(curEvent.mousePosition))
        {
            if (curEvent.type == EventType.DragPerform)
            {
                foreach (var v in DragAndDrop.objectReferences)
                {
                    var type = v.GetType();
                    if (type == typeof(Texture2D))
                    {
                        _textureG = v as Texture2D;
                        break;
                    }
                }
            }
            else if (curEvent.type == EventType.DragUpdated)
            {
                if (IsValidDragPayload(1))
                    DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                else
                    DragAndDrop.visualMode = DragAndDropVisualMode.None;
            }
        }
        else if (_rectB.Contains(curEvent.mousePosition))
        {
            if (curEvent.type == EventType.DragPerform)
            {
                foreach (var v in DragAndDrop.objectReferences)
                {
                    var type = v.GetType();
                    if (type == typeof(Texture2D))
                    {
                        _textureB = v as Texture2D;
                        break;
                    }
                }
            }
            else if (curEvent.type == EventType.DragUpdated)
            {
                if (IsValidDragPayload(2))
                    DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                else
                    DragAndDrop.visualMode = DragAndDropVisualMode.None;
            }
        }
    }

    private bool IsValidDragPayload(int channel)
    {
        foreach (var v in DragAndDrop.objectReferences)
        {
            var type = v.GetType();
            if (type == typeof(Texture2D))
            {
                string[] labels=AssetDatabase.GetLabels(v);
                if (labels == null) return false;
                if (labels.Length <= 0) return false;
                if (channel == 0)
                {
                    if (labels[0].Contains("ETC+Alpha using R channel")) return true;
                }
                else if (channel == 1)
                {
                    if (labels[0].Contains("ETC+Alpha using G channel")) return true;
                }
                else
                {
                    if (labels[0].Contains("ETC+Alpha using B channel")) return true;
                }
            }
        }
        return false;
    }
}
