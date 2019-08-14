/********************************************************************
	created:	2017.6.7
	file base:	
	file ext:	cs
	author:		xuemin.lin	
	purpose:	
*********************************************************************/
using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
//1.mutil atlas mananger
//2.atlas release when ui is inactive
//3.find an sprite in multi atlas
public class DynamicAtlas : MonoBehaviour
{
#region destroy
    public bool ClearOnDestroy = false;
    //not support load back on enable now!!!
    void OnDestroy()
    {
        if (ClearOnDestroy)
        {
            foreach (UIAtlas atlas in atlases)
            {
                if (atlas) Resources.UnloadAsset(atlas.texture);
            }
        }
    }
#endregion
    public UIAtlas[] atlases;

    public UIAtlas GetAtlas(string name)
    {
        if (atlases == null) return null;
        foreach (UIAtlas atlas in atlases)
        {
            if (atlas.name == name) return atlas;
        }
        return null;
    }
    /// <summary>
    /// set sprite name, it will find the sprite in all of atlas the atlases. if can't find. do nothing
    /// or change the sprite and atlas
    /// </summary>
    /// <param name="sprite"></param>
    /// <param name="spriteName"></param>
    /// <returns></returns>
    public void SetSprite(UISprite sprite, string spriteName)
    {
        if (!sprite || string.IsNullOrEmpty(spriteName)) return;
        UIAtlas curAtlas = sprite.atlas;
        if (curAtlas)
        {

            UISpriteData spr = curAtlas.GetSprite(spriteName);
            if (spr != null)
            {
                //needn't change the atlas, not change the sprte
                sprite.spriteName = spriteName;
                return;
            }
        }
        //change teh atlas and sprite
        foreach (UIAtlas atlas in atlases)
        {
            if (atlas != curAtlas)
            {

                UISpriteData spr = atlas.GetSprite(spriteName);

                if (spr != null)
                {
                    //find it, set and return
                    sprite.atlas = atlas;
                    sprite.spriteName = spriteName;
                    return;
                }
            }
        }
    }

    public void Init()
    {

    }

    public void UnInit()
    {
        foreach (UIAtlas atlas in atlases)
        {
            GameObject.Destroy(atlas);
        }
    }
}
