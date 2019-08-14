using UnityEngine;
using System.Collections;


public class ExpandDynamicFontTexture : MonoBehaviour {

    public UnityEngine.Font baseFont;
    private static string chineseText = null;
    private static bool flag = false;
    private bool isDirty = false;
    private Font dirtyFont = null;
	// Use this for initialization
	void Start () {
        if (flag) return;
        flag = true;
        ExpandFontTexture();
	
	}

    private void Awake()
    {
        Font.textureRebuilt += delegate (Font font)
        {
            isDirty = true;
            dirtyFont = font;
         //   Debug.LogError("需要刷新字体:" + font.name);
        };
    }

    private void LateUpdate()
    {
        if (isDirty)
        {
            isDirty = false;
            //if (dirtyFont.name.Equals("fangzhengzhunyuan"))
            //{

            //    ExpandFontTexture();
            //}
            dirtyFont = null;
        }
    }

    public void ExpandFontTexture()
    {
        if (chineseText == null)
        {
            TextAsset text = Resources.Load("Fonts/configText") as TextAsset;
            chineseText = text.ToString();
        }
        baseFont.RequestCharactersInTexture(chineseText, 16, FontStyle.Normal);
        Texture texture = baseFont.material.mainTexture;
        Debug.Log(string.Format("Texture:{0},{1}", texture.width, texture.height));
    }

}
