using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

public class IconData
{
    public string eName = null;
    public Vector3 pos = Vector3.zero;
}

/// <summary>
/// 图文混排  
/// 1:在Label的Obj上添加EmoticonBase脚本，并添加Emoticon的GameObject模板，可设置该模板的图集宽高
/// 2:设置[img]和[-]之间为sprite的name 例如：[img]spritename[-]
/// </summary>
public class MultiLabelBase : MonoBehaviour {
    private float char_size, row_height;
    private float cur_height, cur_width, max_width;
    private int per_height;
    private List<IconData> e_list = null;
    private int m_curIndex = 0;

    private UILabel label;
    private GameObject pic, clone_pic;
    private UISprite spriteIcon;

    public float GetStringLen(string text)
    {
        float stringLen = 0f;
        if (!string.IsNullOrEmpty(text))
        {
            label = gameObject.GetComponent<UILabel>();
            label.UpdateNGUIText();
            stringLen = NGUIText.CalculatePrintedSize(text).x;
        }
        return stringLen;
    }

    public void Show(string text, float width = 0)
    {
        Transform child;
        for (int i = 0; i < transform.childCount; i++)
        {
            child = transform.GetChild(i);
            if (child.name == "Icon(Clone)")
                Destroy(child.gameObject);
        }
        if (label == null)
            label = gameObject.GetComponent<UILabel>();

        if (spriteIcon == null)
            spriteIcon = gameObject.transform.Find("Icon").gameObject.GetComponent<UISprite>();
        label.text = "";
        label.UpdateNGUIText();
        per_height = label.height;
        cur_height = per_height;
        cur_width = 0;
        if (e_list == null)
            e_list = new List<IconData>();
        m_curIndex = 0;

        max_width = width;
        System.Text.StringBuilder _sb = LuaInterface.StringBuilderCache.Acquire();

        float ch_width = 0.0f;
        int length = text.Length;
        int n = 0, m = 0;
        float space_width = NGUIText.CalculatePrintedSize(" ").x;
        int lengthIcon = 0;
        if (spriteIcon != null)
        {
            lengthIcon = (int)Math.Ceiling(spriteIcon.localSize.x / space_width);
        }
        for (int i = 0; i < length; i++)
        {
            if (m > i)
            {
                _sb.Append(text[i]);
                continue;
            }
            if (n > 0)
            {
                n--;
                continue;
            }

            if (text[i] == '[')
            {
                int index = i;
                bool is_symbol = NGUIText.ParseSymbol(text, ref index);
                if (is_symbol)
                {
                    m = index;
                    _sb.Append(text[i]);
                    continue;
                }
            }

            if (text[i] == '\n' && i + 1 <= length)
            {
                cur_width = 0;
                cur_height += per_height;
                _sb.Append("\n");
                continue;
            }

            if (text[i] == '[' && text.Substring(i,5).Equals("[img]"))
            {
                if (cur_width + 2 * space_width > max_width)
                {
                    cur_height += per_height;
                    cur_width = 0;
                    _sb.Append("\n");
                }
                int indexEnd = text.IndexOf("[-]",i);
                string eName = text.Substring(i+5, indexEnd-i-5);
                IconData e = null;
                bool isExpression = false;
                if (eName != null || eName != "")
                {
                    isExpression = true;
                    e = GetEmoticonByIndex(m_curIndex);
                    m_curIndex++;
                    e.eName = eName;
                    e.pos.x = cur_width + 2;
                    e.pos.y = -1 * cur_height;
                    cur_width += lengthIcon * space_width;
                    for (int j = 0; j < lengthIcon;j++ )
                        _sb.Append(" ");
                }

                if (!isExpression)
                {
                    _sb.Append(text[i]);
                }
                else
                {
                    n = indexEnd-i+2;
                }
            }
            else
            {
                ch_width = NGUIText.CalculatePrintedSize(text[i].ToString()).x;
                cur_width += ch_width;
                if (cur_width > max_width)
                {
                    _sb.Append("\n");
                    cur_height += per_height;
                    cur_width = ch_width;
                }
                _sb.Append(text[i]);
            }
        }
        label.text = LuaInterface.StringBuilderCache.GetStringAndRelease(_sb);//output_str;        
        Show_emoticon();
    }

    IconData GetEmoticonByIndex(int index)
    {
        if (index >= e_list.Count)
        {
            int num = index + 1 - e_list.Count;
            for (int i = 0; i < num; ++i)
            {
                e_list.Add(new IconData());
            }
        }
        return e_list[index];
    }

    void Show_emoticon()
    {
        UISprite sprite;

        pic = gameObject.transform.Find("Icon").gameObject;
        int count = m_curIndex;
        if (count > 0 && label.pivot == UIWidget.Pivot.TopLeft)
        {
            for (int i = 0; i < count; i++)
            {
                clone_pic = Instantiate(pic) as GameObject;
                clone_pic.transform.parent = gameObject.transform;
                clone_pic.transform.localPosition = e_list[i].pos;
                clone_pic.transform.localScale = new Vector3(1, 1, 1);
                clone_pic.transform.localRotation = Quaternion.identity;
                sprite = clone_pic.GetComponent<UISprite>();
                sprite.spriteName = e_list[i].eName;
                clone_pic.SetActive(true);
            }
        }
        else if (count > 0 && label.pivot == UIWidget.Pivot.TopRight)
        {
            if (cur_height == per_height)
            {
                max_width = cur_width;
            }
            for (int i = 0; i < count; i++)
            {
                clone_pic = Instantiate(pic) as GameObject;
                clone_pic.transform.parent = gameObject.transform;
                e_list[i].pos.x -= max_width;
                clone_pic.transform.localPosition = e_list[i].pos;
                clone_pic.transform.localScale = new Vector3(1, 1, 1);
                clone_pic.transform.localRotation = Quaternion.identity;
                sprite = clone_pic.GetComponent<UISprite>();
                sprite.spriteName = e_list[i].eName;
                clone_pic.SetActive(true);
            }
        }
        else if (count > 0 && label.pivot == UIWidget.Pivot.Center)
        {
            for (int i = 0; i < count; i++)
            {
                clone_pic = Instantiate(pic) as GameObject;
                clone_pic.transform.parent = gameObject.transform;
                if (e_list[i].pos.y == -cur_height)
                {
                    e_list[i].pos.x = e_list[i].pos.x - cur_width / 2;
                }
                else
                {
                    e_list[i].pos.x = e_list[i].pos.x - max_width / 2;
                }
                e_list[i].pos.y = e_list[i].pos.y + cur_height / 2;

                clone_pic.transform.localPosition = e_list[i].pos;
                clone_pic.transform.localScale = new Vector3(1, 1, 1);
                clone_pic.transform.localRotation = Quaternion.identity;
                sprite = clone_pic.GetComponent<UISprite>();
                sprite.spriteName = e_list[i].eName;
                clone_pic.SetActive(true);
            }
        }
    }
}
